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
               [ div [class "medium-6 small-12 name"]
                   [ h1 [] [text "Ulysses Popple"]
                   , a [class "email", href "mailto:ulysses.popple@gmail.com"] [text "ulysses.popple@gmail.com"]
                   ]
               , h2 [class "social medium-6 small-12 align-self-top"]
                 [ icon "linkedin" "https://www.linkedin.com/in/ulysses-popple-98649a33"
                 , icon "github" "https://github.com/ulyssesp"
                 , icon "youtube-play" "https://www.youtube.com/c/UlyssesPopple"
                 ]
               ]
            , div [class "row"]
                [div [class "small-12 columns"] [text "I architect pixels with planning, a small bit of finger movement, and some computing power."]]
            , div [class "row"]
              [div [class "small-12 columns"] [text "Below are a selection of projects and performances that I enjoyed working on, and some text about what I enjoyed about them."]]
            ]
        ]
    , App.map ModifyList (WL.view model)
    , div [class "footer"] [text "Copyright 2016 Ulysses Popple, created with ", a [href "http://elm-lang.org/", target "_blank"] [text "Elm"], text "."]
    ]

icon : String -> String -> Html Msg
icon icon link =
  a [href link, target "_blank", class "columns pl2 color-inherit"] [i [class ("fa fa-" ++ icon)] []]

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


