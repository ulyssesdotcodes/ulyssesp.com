module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Http
import Json.Decode as Json exposing ((:=))
import Task exposing (..)

import Model exposing (..)
import WorkList as WL

-- MODEL

type alias Model = WL.Model

init : (Model, Cmd Msg)
init =
  ( WL.init [], fetchData )


-- MESSAGES
type Msg
  = NoOp
  | FetchFail Http.Error
  | FetchSucceed (List Work)
  | FetchData
  | ModifyList WL.Msg

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ App.map ModifyList (WL.view model) ]

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    FetchFail err ->
      let
        x = Debug.log "err" err
      in
        (model, Cmd.none)
    FetchSucceed data ->
      let
        x = Debug.log "test" data
      in
        (WL.newData data model, Cmd.none)
    FetchData ->
      (model, fetchData)

    ModifyList msg ->
      (WL.update msg model, Cmd.none)



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MAIN
main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

fetchData : Cmd Msg
fetchData =
  Task.perform FetchFail FetchSucceed (Http.get workDecoder ("./data.json"))


