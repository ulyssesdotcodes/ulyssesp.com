module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href)
import Http
import Json.Decode as Json exposing (field)
import Navigation
import Task exposing (..)
import UrlParser exposing ((</>), s, int, string, parseHash)

import Model exposing (..)
import WorkList as WL
import Work as W

-- MODEL

type DisplayType = List | Single String

type alias Model =
  { worklist: WL.Model
  , displayType : DisplayType
  }

init : Navigation.Location -> (Model, Cmd Msg)
init loc =
  ( Model (WL.init []) List, fetchData )


-- MESSAGES
type Msg
  = NoOp
  | FetchResult (Result Http.Error (List Work))
  | FetchData
  | ModifyList WL.Msg
  | UrlChange Navigation.Location

-- VIEW
view : Model -> Html Msg
view { worklist, displayType } =
  case displayType of
    List ->
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
        , Html.map ModifyList (WL.view worklist)
        , div [class "footer"] [text "Copyright 2016 Ulysses Popple, created with ", a [href "http://elm-lang.org/", target "_blank"] [text "Elm"], text "."]
        ]

    Single id ->
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
          ]
        , text (toString id)
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
        {worklist, displayType} = model
      in
        (Model (WL.newData data worklist) displayType, Cmd.none)
    FetchData ->
      (model, fetchData)

    ModifyList msg ->
      ({ model | worklist = WL.update msg model.worklist }, Cmd.none)

    UrlChange loc ->
      let
        x = Debug.log "loc" loc
        mid = parseHash (UrlParser.s "posts" </> string) loc
        y = Debug.log "mid" mid
      in
        case mid of
          (Just id) ->
            (Model model.worklist (Single id), Cmd.none)

          Nothing ->
            (Model (WL.init model.worklist.dataList) List, Cmd.none)



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions { worklist } =
  Sub.map ModifyList <| WL.subscriptions worklist

-- MAIN
main : Program Never Model Msg
main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

fetchData : Cmd Msg
fetchData =
  Http.send FetchResult (Http.get "./data.json" workDecoder)


