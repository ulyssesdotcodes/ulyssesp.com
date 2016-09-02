module Work exposing (Model, Msg, init, update, view, subscriptions)

import AnimationFrame
import Time exposing (second)
import Array exposing(Array, length, get, fromList, toIndexedList)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode as Json
import List
import Markdown
import Maybe exposing (withDefault, map, withDefault)
import Style
import Style.Properties exposing (..)
import Style.Spring.Presets exposing (..)

import Model exposing (..)

type DisplayType = Mini | Full

type alias Model =
  { work : Work
  , displayType : DisplayType
  , selectedImage : Int
  , images : Array Image
  , imageLeft : Style.Animation
  }

init : Work -> Model
init w = Model w Mini 0 (fromList w.images) (Style.init [Left 0.0 Px])

type Msg
  = DisplayAs DisplayType
  | NextImage
  | PrevImage
  | Animate Float

update : Msg -> Model -> Model
update msg m =
  case msg of
    (DisplayAs t) ->
      { m | displayType = t }

    NextImage ->
      let
        si' = (m.selectedImage + 1) % (length m.images)
      in
        { m | selectedImage = si', imageLeft = Style.animate |> Style.duration second |> Style.spring wobbly |> Style.to [Left (toFloat (si' * -660)) Px] |> Style.on m.imageLeft }

    PrevImage ->
      let
        si' = (m.selectedImage - 1) % (length m.images)
      in
        { m | selectedImage = si', imageLeft = Style.animate |> Style.duration second |> Style.spring wobbly |> Style.to [Left (toFloat (si' * -660)) Px] |> Style.on m.imageLeft }

    Animate t ->
      { m | imageLeft = Style.tick t m.imageLeft }


view : Model -> Html Msg
view model =
  let
    mainView =
      case model.displayType of
        Mini -> viewMini model.work
        Full -> viewFull model
    nextDisplay =
      case model.displayType of
        Mini -> a [href ("#" ++ model.work.slug), onClick (DisplayAs Full)] [text "Show more"]
        Full -> a [href ("#" ++ model.work.slug), onClick (DisplayAs Mini)] [text "Show less"]
  in
    div [class "row align-center"] [div [class "small-10 columns"] (mainView ++ [ p [] [nextDisplay] ]) ]

viewMini : Work -> List (Html Msg)
viewMini model =
  [ viewLink model
  , p [] [ text (withDefault "Personal" (map ((++) "Company: ") model.company))]
  , Markdown.toHtml [] model.summary
  ]

viewFull : Model -> List (Html Msg)
viewFull model =
  (viewMini model.work) ++
  [ Markdown.toHtml [] model.work.description
  ]
  ++
  (withDefault [] <| map ((\x -> [x]) << viewVideo) model.work.video)
  ++
  [viewImages model.imageLeft model.selectedImage <| toIndexedList model.images]

viewLink : Work -> Html Msg
viewLink model =
  a [name model.slug, href ("#" ++ model.slug), class "work-item"] ([h3 [class "work-name inline"] [text (model.name ++ " ")]] ++
           (withDefault [] (map (\l -> [h6 [class "inline"] [a [href l, target "_blank"] [text "[link]"]]]) model.link)))

viewVideo : Video -> Html Msg
viewVideo vid =
  case vid of
    (Youtube id) ->
      div [class "media flex-video"]
        [ iframe [width 640, height 360, src ("https://www.youtube.com/embed/" ++ id)] []
        ]

viewImages : Style.Animation -> Int -> List (Int, Image) -> Html Msg
viewImages imageLeft selected images =
  div [class "gallery"]
    [ div [class "left", onClick PrevImage] [i [class "fa fa-arrow-left"] []]
    , div [class"right", onClick NextImage] [i [class "fa fa-arrow-right"] []]
    , ul [style (Style.render imageLeft)]
      (List.map (\indexedImage -> viewImage ((fst indexedImage) == selected) (snd indexedImage)) images)
    ]


viewImage : Bool -> Image -> Html Msg
viewImage active media =
  case media of
    (Cloudinary slug id) ->
      li [] [img [ class (if active then "is-active" else "")
                 , src ("http://res.cloudinary.com/dezngnedw/image/upload/c_fit,h_375,w_666/v1472550364/ulyssesp.com/" ++ slug ++ "/" ++ id)
                 , onClick NextImage
             ] []
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
  AnimationFrame.times Animate
