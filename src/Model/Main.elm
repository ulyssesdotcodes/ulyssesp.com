module Model.Main exposing (..)

import Http
import Navigation
import Monocle.Optional exposing (Optional)

import Model exposing (..)
import Model.Work as W
import Model.WorkList as WL

type Content = ContentList WL.Model | ContentSingle W.Model String | ContentNotFound

type alias Model =
  { works : List Work
  , loc : Navigation.Location
  , content : Content
  }

init : Navigation.Location -> Model
init loc = Model [] loc <| ContentList WL.init

updateListContent : Optional Model WL.Model
updateListContent =
  let
    getListContent m =
      case m.content of
        (ContentList wl) -> Just wl
        _ -> Nothing

    set wl m = { m | content = ContentList wl }
  in
    Optional getListContent set
