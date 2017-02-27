module Model.Work exposing (..)

import Animation

type DisplayType = Mini | Full

type alias Model =
  { displayType : DisplayType
  , selectedImage : Int
  , imageLeft : Animation.State
  }

init : DisplayType -> Model
init dt = Model dt 0 (Animation.style [Animation.left (Animation.px 0.0)])
