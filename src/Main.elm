module Main exposing (..)

import Html exposing (..)
import Html.App
import Http
import Json.Decode as Json exposing ((:=))
import Task exposing (..)

-- MODEL

type alias Model = String

init : (Model, Cmd Msg)
init =
  ( "Hello", fetchData )

type alias Work =
  { company : String
  , position : String
  }

-- MESSAGES
type Msg
  = NoOp
  | FetchFail Http.Error
  | FetchSucceed (List Work)
  | FetchData

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ text model ]

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    FetchFail _ ->
      (model, Cmd.none)
    FetchSucceed data ->
      let
        x = Debug.log "test" data
      in
        (model, Cmd.none)
    FetchData ->
      (model, fetchData)



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MAIN
main : Program Never
main =
  Html.App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

fetchData : Cmd Msg
fetchData =
  Task.perform FetchFail FetchSucceed (Http.get works ("./data.json"))

works : Json.Decoder (List Work)
works =
  let work =
      Json.object2 Work
        ("company" := Json.string)
        ("position" := Json.string)
  in
    "work" := Json.list work

