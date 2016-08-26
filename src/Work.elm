module Work exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown

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
  div [class "work"]
    [ h3 [] [ a [href model.link, target "_blank"][ text model.name ]]
    , p [] [ text ("Company: " ++ model.company)]
    , Markdown.toHtml [] model.summary
    ]
