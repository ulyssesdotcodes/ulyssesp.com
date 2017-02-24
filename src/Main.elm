module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href)
import Http
import Json.Decode as Json exposing (field)
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
  | FetchResult (Result Http.Error (List Work))
  | FetchData
  | ModifyList WL.Msg

-- VIEW
view : Model -> Html Msg
view model =
  div [class ""]
    [ div [class "container"]
      [ div [class "row header"]
          [ div [class "nine columns"]
              [ h1 [] [text "Ulysses Popple"]
              , a [class "email", href "mailto:ulysses.popple@gmail.com"] [text "ulysses.popple@gmail.com"]
              ]
          , div [class "three columns"]
              [ icon "linkedin" "https://www.linkedin.com/in/ulysses-popple-98649a33"
              , icon "github" "https://github.com/ulyssesp"
              , icon "youtube" "https://www.youtube.com/c/UlyssesPopple"
              ]
          ]
      , div [class "twelve columns"] [text "I architect pixels with planning, a small bit of finger movement, and some computing power."]
      , div [class "twelve columns"] [text "Below are a selection of projects and performances that I enjoyed working on, and some text about what I enjoyed about them."]
      ]
    , Html.map ModifyList (WL.view model)
    , div [class "footer"] [text "Copyright 2016 Ulysses Popple, created with ", a [href "http://elm-lang.org/", target "_blank"] [text "Elm"], text "."]
    ]

icon : String -> String -> Html Msg
icon icon link =
  div [class "social-icon"] [a [href link, target "_blank"] [i [class ("ion-social-" ++ icon)] []]]

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    FetchResult (Err err) ->
      let
        x = Debug.log "err" err
      in
        (model, Cmd.none)
    FetchResult (Ok data) ->
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
main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

fetchData : Cmd Msg
fetchData =
  Http.send FetchResult (Http.get "./data.json" workDecoder)


