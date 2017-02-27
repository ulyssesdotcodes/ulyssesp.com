module Model.WorkList exposing (..)

import Model exposing (..)

import Model.Work as W

type alias Model =
  { filter : Maybe Tag
  , workModels : List W.Model
  }

init : Model
init = Model Nothing []

generateModels : List Work -> Model -> Model
generateModels ws model =
  { model | workModels = List.map (\_ -> W.init W.Mini) ws}
