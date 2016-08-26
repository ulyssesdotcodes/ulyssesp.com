module Work exposing (Model, Msg, init, update, view)

import Html exposing (..)

import Model exposing (..)

type alias Model = Work

init : Work -> Model
init w = w

type Msg =
  NoOp

update : Msg -> Model -> Model
update msg m = m

view : Model -> Html Msg
view model =
  div []
    [ text (toString model) ]
