module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href)
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
    [ div [class ""]
        [ div [class "header"]
            [div [class "row"]
               [ h1 [class "columns"] [text "Ulysses Popple"]
               , h2 [class "shrink columns"]
                 [ icon "github" "https://github.com/ulyssesp"
                 , icon "youtube-play" "https://www.youtube.com/user/upopple"
                 ]
               ]
            , div [class "row"]
                [div [class "small-12 columns"] [text "I architect pixels with planning, some computing power, and a small bit of finger movement."]]
            ]
        ]
    , App.map ModifyList (WL.view model)
    ]

icon : String -> String -> Html Msg
icon icon link =
  a [href link, target "_blank", class "pl2 color-inherit"] [i [class ("fa fa-" ++ icon)] []]

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
  Sub.map ModifyList <| WL.subscriptions model

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


