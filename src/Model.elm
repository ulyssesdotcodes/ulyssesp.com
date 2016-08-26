module Model exposing (..)

import Json.Decode as Json exposing ((:=), andThen)

type Tag
  = Interactive
  | Performance
  | Web
  | Mobile
  | None

tagDecoder : String -> Json.Decoder (Tag)
tagDecoder tag = Json.succeed (tagParser tag)

tagParser : String -> Tag
tagParser tag =
  case tag of
    "interactive" -> Interactive
    "performance" -> Performance
    "web" -> Web
    "mobile" -> Mobile
    _ -> None

type alias Work =
  { tags : List Tag
  , company : String
  , position : String
  , summary : String
  }

workDecoder : Json.Decoder (List Work)
workDecoder =
  let work =
        Json.object4 Work
          ("tags" := Json.list (Json.string `andThen` tagDecoder))
          ("summary" := Json.string)
          ("company" := Json.string)
          ("position" := Json.string)
  in
    "work" := Json.list work

