module View.WorkList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Model exposing (..)
import Model.Work as W
import View.Work as W
import Model.WorkList exposing (..)
import Msg.WorkList exposing (..)
import Model

view : Model -> List Model.Work -> Html Msg
view { filter, workModels } works =
  div [class "container"]
    [ div [class "row"]
        [ nav [class "navbar"]
          [ ul [ class "navbar-list" ] ([filterSelect "All" Nothing filter] ++ (List.map (tagSelect filter) tags))]]
    , div [class "container"] (List.map viewWork <| filterTag filter <| List.map2 (,) (List.indexedMap (,) workModels) works)
    ]

tags = [Interactive, Performance, Web, Mobile]

tagSelect : Maybe Tag -> Tag -> Html Msg
tagSelect cur tag =
  filterSelect (filterText tag) (Just tag) cur

filterTag : Maybe Tag -> List ((Int, W.Model), Work) -> List ((Int, W.Model), Work)
filterTag mtag ws =
  case mtag of
    (Just tag) ->
      List.filter (\(_, w) -> List.member tag w.tags) ws

    Nothing ->
      ws

viewWork : ((Int, W.Model), Work) -> Html Msg
viewWork ((id, model), work) =
  Html.map (Modify id) (W.view model work)

filterSelect : String -> Maybe Tag -> Maybe Tag -> Html Msg
filterSelect str mt cur =
  li [class ("navbar-item" ++ (if cur == mt then " active" else "")), onClick (Filter mt)]
    [a [class "navbar-link"] [text str]]

filterText : Tag -> String
filterText tag =
  case tag of
    Interactive -> "Interactive"
    Performance -> "Performance"
    Web -> "Web"
    Mobile -> "Mobile"
