module View.Work exposing (..)

import Animation
import Array exposing(Array, length, get, fromList, toIndexedList)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List
import Markdown
import Maybe exposing (withDefault, map, withDefault, andThen, map2)
import Regex exposing (..)

import Model exposing (..)
import Msg.Work exposing (..)
import Model.Work exposing (..)

view : Model -> Work -> Html Msg
view model work =
  let
    mainView =
      case model.displayType of
        Mini -> viewMini work
        Full -> viewFull model work
    nextDisplay =
      case model.displayType of
        Mini -> a [class "change-display", href ("#" ++ work.slug), onClick (DisplayAs Full)] [text "Show more"]
        Full -> a [class "change-display", href ("#" ++ work.slug), onClick (DisplayAs Mini)] [text "Show less"]
  in
    div [class "row align-center"] [div [class "ten columns"] (mainView ++ [ p [] [nextDisplay] ]) ]

viewNotFound : Html Msg
viewNotFound =
  div [class "ten columns"] [text "Couldn't find that work!"]

viewMini : Work -> List (Html Msg)
viewMini work =
  [ viewLink work
  , p [] [ text (withDefault "Personal" (Maybe.map ((++) "Company: ") work.company))]
  , Markdown.toHtml [] work.summary
  ]

viewFull : Model -> Work -> List (Html Msg)
viewFull model work =
  (viewMini work) ++
  [ Markdown.toHtml [] work.description
  ]
  ++
  (withDefault [] <| Maybe.map ((\x -> [x]) << viewVideo) work.video)
  ++
  [viewImages model.imageLeft model.selectedImage work.images]

viewLink : Work -> Html Msg
viewLink work =
  let
    findDomain l =
      withDefault Nothing
        <| get 1 << fromList << List.filter ((/=) (Just "s"))
        <| withDefault []
        <| Maybe.map (\r -> r.submatches)
        <| List.head
        <| find (AtMost 1) (regex "(?:(^https?://))([^/?#]+)(?:([/?#]|$))") l
    findDomainp l = map2 (,) l (andThen findDomain l)
  in
    a [name work.slug, href ("#work/" ++ work.slug), class "work-item"] ([h3 [class "work-name inline"] [text (work.name ++ " ")]] ++
            (withDefault [] (Maybe.map (\l -> [h6 [class "work-link inline"] [a [href (Tuple.first l), target "_blank"] [text ("[" ++ (Tuple.second l) ++ "]")]]]) (findDomainp work.link))))

viewVideo : Video -> Html Msg
viewVideo vid =
  case vid of
    (Youtube id) ->
      div [class "media flex-video"]
        [ iframe [src ("https://www.youtube.com/embed/" ++ id)] []]

viewImages : Animation.State -> Int -> Array Image -> Html Msg
viewImages imageLeft selected images =
  div [class "gallery"]
    (
    (if length images > 1 then
      [ div [class "control left", onClick PrevImage] [i [class "fa fa-arrow-left"] []]
      , div [class "control right", onClick NextImage] [i [class "fa fa-arrow-right"] []]]
    else [])
    ++
    [ ul (Animation.render imageLeft)
        (List.map (\indexedImage -> viewImage ((Tuple.first indexedImage) == selected) (Tuple.second indexedImage)) <| toIndexedList images)
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
