module Model.Work exposing (..)

import Animation

type DisplayType = Mini | Full

type alias Model =
  { displayType : DisplayType
  , selectedImage : Maybe Int
  }

init : DisplayType -> Model
init dt = Model dt Nothing
