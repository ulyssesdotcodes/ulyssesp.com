module Model.Main exposing (..)

import Navigation
import Monocle.Optional exposing (Optional)
import UrlParser exposing (parseHash, string, (</>), oneOf, Parser, s, top)

import Model exposing (..)
import Model.Work as W
import Model.WorkList as WL

type Content = ContentList WL.Model | ContentSingle W.Model String | ContentNotFound

type Route = WorkList | Work String

type alias Model =
  { works : List Work
  , loc : Navigation.Location
  , content : Content
  }

init : Navigation.Location -> Model
init loc = changeUrl loc <| Model [] loc ContentNotFound

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

changeUrl : Navigation.Location -> Model -> Model
changeUrl loc model =
  case parseHash route loc of

    (Just WorkList) ->
      { model | content = ContentList <| WL.generateModels model.works WL.init }

    (Just (Work id)) ->
      { model | content = ContentSingle (W.init W.Full) id }

    Nothing ->
      { model | content = ContentNotFound }

route : Parser (Route -> a) a
route =
  oneOf
    [ UrlParser.map WorkList top
    , UrlParser.map Work (s "work" </> string)
    ]
