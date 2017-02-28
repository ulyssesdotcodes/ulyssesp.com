module Model exposing (..)

import Array exposing(Array, length, get, fromList, toIndexedList)
import Json.Decode exposing (..)


type Tag
  = Interactive
  | Performance
  | Web
  | Mobile

tagDecoder : String -> Decoder (Tag)
tagDecoder tag =
  case tagParser tag of
    Just t -> succeed t
    Nothing -> fail "Couldn't parse tag"

tagParser : String -> Maybe Tag
tagParser tag =
  case tag of
    "interactive" -> Just Interactive
    "performance" -> Just Performance
    "web" -> Just Web
    "mobile" -> Just Mobile
    _ -> Nothing

type Video = Youtube String | CloudinaryVideo String String
type Image = CloudinaryImage String String

type alias JsonMedia = { source : String, id : String }

imageDecoder : String -> Decoder Image
imageDecoder slug =
  let
    toImage jm =
      case jm.source of
        "cloudinary" -> succeed <| CloudinaryImage slug jm.id
        _ -> fail "could not decode image type"
  in
    andThen toImage decodeJsonMedia

decodeJsonMedia : Decoder JsonMedia
decodeJsonMedia =
  map2 JsonMedia
    (field "source" string)
    (field "id" string)

videoDecoder : String -> Decoder Video
videoDecoder slug =
  let
    toVideo jm =
      case jm.source of
        "youtube" -> succeed <| Youtube jm.id
        "cloudinary" -> succeed <| CloudinaryVideo slug jm.id
        _ -> fail "could not decode video type"
  in
    andThen toVideo decodeJsonMedia

type alias Work =
  { tags : List Tag
  , name : String
  , link : Maybe String
  , company : Maybe String
  , summary : String
  , description : String
  , video : Maybe Video
  , images : Array Image
  , slug : String
  , hero : Image
  }

apply : Decoder a -> Decoder (a -> b) -> Decoder b
apply =
  map2 (|>)

workDecoder : Decoder (List Work)
workDecoder =
  let work =
        map Work (field "tags" (list (andThen tagDecoder string)))
          |> apply (field "name" string)
          |> apply (maybe (field "link" string))
          |> apply (maybe (field "company" string))
          |> apply (field "summary" string)
          |> apply (field "description" string)
          |> apply (maybe (field "slug" string |> map videoDecoder |> andThen (field "video")))
          |> apply (field "slug" string |> andThen (\slug -> field "images" (list (imageDecoder slug)) |> map fromList))
          |> apply (field "slug" string)
          |> apply (field "slug" string |> map imageDecoder |> andThen (field "hero"))
  in
    field "work" (list work)

