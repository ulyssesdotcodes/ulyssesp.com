module View.Work exposing (..)

import Animation
import Array exposing(Array, length, get, fromList, toIndexedList)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode
import List
import Markdown
import Maybe exposing (withDefault, map, withDefault, andThen, map2)
import Regex exposing (..)

import Model exposing (..)
import Msg.Work exposing (..)
import Model.Work exposing (..)

type ImageSize = Original | Hero | Thumb

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
         , viewImages model.selectedImage work.images
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

viewImages : Maybe Int -> Array Image -> Html Msg
viewImages selected images =
  div [class "gallery"]
    ((
      selected
        |> Maybe.andThen (\i -> Maybe.map (\image -> (i, image)) <| get i images)
        |> Maybe.map (\(index, image) ->
                        List.singleton
                          <| div [class "lightbox", onClick HideLightbox]
                              [ img [src <| imgSrc Original image] []
                              , div [class ("control next" ++ if index < length images - 1 then "" else " hidden"), Html.Events.onWithOptions "click" (Html.Events.Options True False) (Json.Decode.succeed NextImage)] [text ">"]
                              , div [class ("control prev" ++ if index > 0  then "" else " hidden"), Html.Events.onWithOptions "click" (Html.Events.Options True False) (Json.Decode.succeed PrevImage)] [text "<"]
                              ]
                     )
        |> Maybe.withDefault []
    )
    ++
    [ ul []
        (List.map (\indexedImage -> viewImage (Tuple.first indexedImage) (Tuple.second indexedImage)) <| toIndexedList images)
    ])


viewImage : Int -> Image -> Html Msg
viewImage imgIndex media =
  li [class "three columns", onClick (ShowImage imgIndex)]
    [ img [ src <| imgSrc Thumb media ] [] ]

fullTitle : Work -> Html Msg
fullTitle w =
  div []
    [ a [href "#"] [h6 [] [text "Projects"]]
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
miniImage work = a [name work.slug, href ("#work/" ++ work.slug)] [img [class "hero", src <| imgSrc Hero work.hero] []]

imgSrc : ImageSize -> Image -> String
imgSrc imgSize media =
  case media of
    (CloudinaryImage slug id) ->
      let
        transform =
          case imgSize of
            Original -> ""
            Hero -> "/c_scale,w_960/c_crop,h_540,w_960"
            Thumb -> "/c_scale,w_600/c_crop,h_338,w_600"
      in
        "http://res.cloudinary.com/dezngnedw/image/upload" ++ transform  ++ "/v1472550364/ulyssesp.com/" ++ slug ++ "/" ++ id
