module Model exposing (..)

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

type Video = Youtube String
type Image = Cloudinary String String

type alias JsonMedia = { source : String, id : String }

imageDecoder : String -> Decoder Image
imageDecoder slug =
  let
    toImage jm =
      case jm.source of
        "cloudinary" -> succeed <| Cloudinary slug jm.id
        _ -> fail "could not decode image type"
  in
    decodeJsonMedia `andThen` toImage

decodeJsonMedia : Decoder JsonMedia
decodeJsonMedia =
  object2 JsonMedia
    ("source" := string)
    ("id" := string)

videoDecoder : Decoder Video
videoDecoder =
  let
    toVideo jm =
      case jm.source of
        "youtube" -> succeed <| Youtube jm.id
        _ -> fail "could not decode video type"
  in
    decodeJsonMedia `andThen` toVideo

type alias Work =
  { tags : List Tag
  , name : String
  , link : Maybe String
  , company : Maybe String
  , summary : String
  , description : String
  , video : Maybe Video
  , images : List Image
  , slug : String
  }

apply : Decoder (a -> b) -> Decoder a -> Decoder b
apply =
  object2 (<|)

workDecoder : Decoder (List Work)
workDecoder =
  let work =
        map Work ("tags" := list (string `andThen` tagDecoder))
          `apply` ("name" := string)
          `apply` (maybe ("link" := string))
          `apply` (maybe ("company" := string))
          `apply` ("summary" := string)
          `apply` ("description" := string)
          `apply` (maybe ("video" := videoDecoder))
          `apply` (("slug" := string) `andThen` (\slug -> "images" := list (imageDecoder slug)))
          `apply` ("slug" := string)
  in
    "work" := list work

