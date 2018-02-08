module View.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href)
import Maybe exposing (map, withDefault)

import Model exposing (..)
import Model.Main exposing (..)
import Msg.Main exposing (..)
import View.WorkList as WL
import View.Work as W

view : Model -> Html Msg
view model =
  div []
    [ div [class "container"]
      [ div [class "row header"]
          ([ div [class "nine columns"]
              ([ h1 [] [a [href "#"] [text "Ulysses Popple"]] ]
              ++ (if fullHeader model.content then
                   [a [class "email", href "mailto:ulysses.popple@gmail.com"] [text "ulysses.popple@gmail.com"]]
                 else [])
              )
          , div [class "three columns"]
            [ icon "linkedin" "https://www.linkedin.com/in/ulysses-popple-98649a33"
            , icon "github" "https://github.com/ulyssesp"
            , icon "youtube" "https://www.youtube.com/c/UlyssesPopple"
            ]
          ]
          ++
          (if fullHeader model.content then
            [ div [class "twelve columns blurb"] [text "I specialize in solo or small team development for responsive, interaction-based experiences, use the most appropriate tools for the job, and deliver them under strict timeframes."]
            , div [class "twelve columns blurb"] [text "Previous clients include Saatchi & Saatchi, SAP, HBO, and the NBA. Based in NYC, my projects have been installed in NYC, LA, and New Orleans."]
            , div [class "twelve columns blurb"] [text "Below are a selection of projects and performances that I enjoyed working on, and some text about what I enjoyed about them."]
            ]
           else []
          ))
    ]
    , viewContent model
    , div [class "footer"] [text "Copyright 2016 Ulysses Popple, created with ", a [href "http://elm-lang.org/", target "_blank"] [text "Elm"], text "."]
    ]

viewContent : Model -> Html Msg
viewContent model =
  case model.content of
    ContentList wlstate ->
      Html.map ModifyList (WL.view wlstate model.works)

    ContentSingle workModel slug ->
      div [class "container"]
        [ Html.map ModifyWork (findWork slug model.works
                              |> Maybe.map (W.view workModel)
                              |> withDefault W.viewNotFound)
        ]

    ContentNotFound ->
      div [class "container"] [text "Content not found"]

fullHeader : Content -> Bool
fullHeader content =
  case content of
    ContentList _ -> True
    _ -> False

icon : String -> String -> Html Msg
icon icon link =
  div [class "social-icon"] [a [href link, target "_blank"] [i [class ("ion-social-" ++ icon)] []]]

findWork : String -> List Work -> Maybe Work
findWork slug = List.head << List.filter ((==) slug << .slug)
