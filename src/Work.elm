module Work exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import Maybe exposing (withDefault, map)

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
    [ viewLink model
    , p [] [ text (withDefault "Personal" (map ((++) "Company: ") model.company))]
    , Markdown.toHtml [] model.summary
    ]

viewLink : Model -> Html Msg
viewLink model =
  h3 [] ([text (model.name ++ " ")] ++
           (withDefault [] (map (\l -> [h6 [class "inline"] [a [href l, target "_blank"] [text "[link]"]]]) model.link))
        )
