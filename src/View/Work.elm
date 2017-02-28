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
  in
    mainView

viewNotFound : Html Msg
viewNotFound =
  div [class "ten columns"] [text "Couldn't find that work!"]

viewMini : Work -> Html Msg
viewMini work =
  div [class "container"]
    [ miniImage work
    , miniTitle work
    , p [] [ text (withDefault "Personal" (Maybe.map ((++) "Company: ") work.company))]
    ]

viewFull : Model -> Work -> Html Msg
viewFull model work =
  div []
    [ fullTitle work
    , div [class "container"]
      ((withDefault [] <| Maybe.map ((\x -> [x]) << viewVideo) work.video)
         ++
         [ p [] [ text (withDefault "Personal" (Maybe.map ((++) "Company: ") work.company))]
         , Markdown.toHtml [] work.description
         , viewImages model.imageLeft model.selectedImage work.images
         ]
      )
    ]

miniTitle : Work -> Html Msg
miniTitle work =
  let
    findDomainp l = map2 (,) l (andThen findDomain l)
  in
    div [class "title mini"]
      ([ a [name work.slug, href ("#work/" ++ work.slug), class "work-name"]
        [h3 [] [text (work.name)]]
       ] ++
      (work.link |> andThen externalLink |> Maybe.map List.singleton |> withDefault []))

findDomain : String -> Maybe String
findDomain l =
  withDefault Nothing
    <| get 1 << fromList << List.filter ((/=) (Just "s"))
    <| withDefault []
    <| Maybe.map (\r -> r.submatches)
    <| List.head
    <| find (AtMost 1) (regex "(?:(^https?://))([^/?#]+)(?:([/?#]|$))") l

viewVideo : Video -> Html Msg
viewVideo vid =
  case vid of
    (Youtube id) ->
      div [class "media row"]
        [ iframe [class "twelve columns", src ("https://www.youtube.com/embed/" ++ id)] [] ]

    (CloudinaryVideo slug id) ->
      div [class "media row"]
        [ video [ class "twelve columns"
                , src ("http://res.cloudinary.com/dezngnedw/video/upload/v1488300074/ulyssesp.com/"
                         ++
                         slug
                         ++ "/" ++
                         id
                      )
                , autoplay False
                , controls True
                ] [] ]

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
  li [] [ img [ class (if active then "is-active" else "") , src <| cloudinary media] [] ]

fullTitle : Work -> Html Msg
fullTitle w =
  div [class ""]
    [ a [href "#"] [text "Projects"]
    , text " > "
    , div [class "title full"]
      ([h3 [class "work-name inline no-link"] [text (w.name)]] ++
       (w.link |> andThen externalLink |> Maybe.map List.singleton |> withDefault [])
      )
    ]

externalLink : String -> Maybe (Html Msg)
externalLink link =
  findDomain link
    |> Maybe.map (\d -> a [href link, target "_blank"] [text ("[" ++ d ++ "]")])

miniImage : Work -> Html Msg
miniImage work = img [class "hero", src <| cloudinary work.hero] []

cloudinary : Image -> String
cloudinary media =
  case media of
    (CloudinaryImage slug id) ->
      "http://res.cloudinary.com/dezngnedw/image/upload/c_scale,w_960/c_crop,h_540,w_960/v1472550364/ulyssesp.com/" ++
        slug ++ "/" ++ id
