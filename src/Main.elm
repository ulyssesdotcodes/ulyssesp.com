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

type Content = ContentList WL.Model | ContentSingle W.Model

type alias Model =
  { data : List Work
  , content : Content
  }

init : Navigation.Location -> (Model, Cmd Msg)
init loc =
  ( Model [] (ContentList <| WL.init []), fetchData )


-- MESSAGES
type Msg
  = NoOp
  | FetchResult (Result Http.Error (List Work))
  | FetchData
  | ModifyList WL.Msg
  | ModifyWork W.Msg
  | UrlChange Navigation.Location

-- VIEW
view : Model -> Html Msg
view { data, content } =
  case content of
    ContentList worklist ->
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

    ContentSingle work ->
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
        , div [class "container"] [ Html.map ModifyWork (W.view work) ]
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

    FetchResult (Ok result) ->
      let
        { data, content } = model
      in
        case content of
          (ContentList wl) ->
            ({ model | content = (ContentList <| WL.newData result wl), data = result }, Cmd.none)

          (ContentSingle w) ->
            ({ model | data = result }, Cmd.none)

    FetchData ->
      (model, fetchData)

    ModifyList msg ->
      let
        { data, content } = model
      in
        case content of
          (ContentList wl) ->
            ({ model | content = ContentList <| WL.update msg wl }, Cmd.none)

          (ContentSingle w) ->
            (model, Cmd.none)


    ModifyWork msg ->
      let
        { data, content } = model
      in
        case content of
          (ContentList wl) ->
            (model, Cmd.none)

          (ContentSingle w) ->
            ({ model | content = ContentSingle w }, Cmd.none)


    UrlChange loc ->
      let
        mid = parseHash (UrlParser.s "work" </> string) loc
        mwork = mid |> Maybe.andThen (\id -> Maybe.map (W.init W.Full) (List.head <| List.filter ((==) id << .slug) model.data))
      in
        case mwork of
          (Just work) ->
            (Model model.data (ContentSingle work), Cmd.none)

          Nothing ->
            ({ model | content = (ContentList <| WL.init model.data) }, Cmd.none)



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions { data, content } =
  case content of
    (ContentList wl) ->
      Sub.map ModifyList <| WL.subscriptions wl

    (ContentSingle w) ->
      Sub.map ModifyWork <| W.subscriptions w

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


