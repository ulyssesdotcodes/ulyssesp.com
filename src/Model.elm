module Model exposing (..)

import Json.Decode as Json exposing ((:=), andThen)

type Tag
  = Interactive
  | Performance
  | Web
  | Mobile

tagDecoder : String -> Json.Decoder (Tag)
tagDecoder tag =
  case tagParser tag of
    Just t -> Json.succeed t
    Nothing -> Json.fail "Couldn't parse tag"

tagParser : String -> Maybe Tag
tagParser tag =
  case tag of
    "interactive" -> Just Interactive
    "performance" -> Just Performance
    "web" -> Just Web
    "mobile" -> Just Mobile
    _ -> Nothing

type alias Work =
  { tags : List Tag
  , name : String
  , link : String
  , company : String
  , summary : String
  }

workDecoder : Json.Decoder (List Work)
workDecoder =
  let work =
        Json.object5 Work
          ("tags" := Json.list (Json.string `andThen` tagDecoder))
          ("name" := Json.string)
          ("link" := Json.string)
          ("company" := Json.string)
          ("summary" := Json.string)
  in
    "work" := Json.list work

