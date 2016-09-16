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
import Maybe exposing (withDefault, map, withDefault, andThen, map2)
import Regex exposing (..)
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
        Mini -> viewMini model
        Full -> viewFull model
    nextDisplay =
      case model.displayType of
        Mini -> a [class "change-display", href ("#" ++ model.work.slug), onClick (DisplayAs Full)] [text "Show more"]
        Full -> a [class "change-display", href ("#" ++ model.work.slug), onClick (DisplayAs Mini)] [text "Show less"]
  in
    div [class "row align-center"] [div [class "small-10"] (mainView ++ [ p [] [nextDisplay] ]) ]

reverseDisplay : DisplayType -> DisplayType
reverseDisplay d =
  case d of
    Mini -> Full
    Full -> Mini

viewMini : Model -> List (Html Msg)
viewMini model =
  [ viewLink model
  , p [] [ text (withDefault "Personal" (map ((++) "Company: ") model.work.company))]
  , Markdown.toHtml [] model.work.summary
  ]

viewFull : Model -> List (Html Msg)
viewFull model =
  (viewMini model) ++
  [ Markdown.toHtml [] model.work.description
  ]
  ++
  (withDefault [] <| map ((\x -> [x]) << viewVideo) model.work.video)
  ++
  [viewImages model.imageLeft model.selectedImage model.images]

viewLink : Model -> Html Msg
viewLink { work, displayType } =
  let
    findDomain l =
      withDefault Nothing
        <| get 1 << fromList << List.filter ((/=) (Just "s"))
        <| withDefault []
        <| map (\r -> r.submatches)
        <| List.head
        <| find (AtMost 1) (regex "(?:(^http(s?)://))([^/?#]+)(?:([/?#]|$))") l
    findDomain' l = map2 (,) l (l `andThen` findDomain)
  in
    a [name work.slug, href ("#" ++ work.slug), class "work-item", onClick (DisplayAs (reverseDisplay displayType))] ([h3 [class "work-name inline"] [text (work.name ++ " ")]] ++
            (withDefault [] (map (\l -> [h6 [class "work-link inline"] [a [href (fst l), target "_blank"] [text ("[" ++ (snd l) ++ "]")]]]) (findDomain' work.link))))

viewVideo : Video -> Html Msg
viewVideo vid =
  case vid of
    (Youtube id) ->
      div [class "media flex-video"]
        [ iframe [src ("https://www.youtube.com/embed/" ++ id)] []]

viewImages : Style.Animation -> Int -> Array Image -> Html Msg
viewImages imageLeft selected images =
  div [class "gallery"]
    (
    (if length images > 1 then
      [ div [class "control left", onClick PrevImage] [i [class "fa fa-arrow-left"] []]
      , div [class "control right", onClick NextImage] [i [class "fa fa-arrow-right"] []]]
    else [])
    ++
    [ ul [style (Style.render imageLeft)]
      (List.map (\indexedImage -> viewImage ((fst indexedImage) == selected) (snd indexedImage)) <| toIndexedList images)
    ]
    )


viewImage : Bool -> Image -> Html Msg
viewImage active media =
  case media of
    (Cloudinary slug id) ->
      li [] [img [ class (if active then "is-active" else "")
                 , src ("http://res.cloudinary.com/dezngnedw/image/upload/c_fit,h_375,w_666/v1472550364/ulyssesp.com/" ++ slug ++ "/" ++ id)
             ] []
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
  AnimationFrame.times Animate
