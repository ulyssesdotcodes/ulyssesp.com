module Update.Main exposing (..)

import Http
import Navigation
import Maybe exposing (map, withDefault)
import Monocle.Optional exposing (modify)

import Model exposing (..)
import Model.Main exposing (..)
import Model.WorkList as WL
import Model.Work as W
import Msg.Main exposing (..)
import Msg.WorkList as WL
import Msg.Work as W
import Update.WorkList as WL
import Update.Work as W

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

    FetchResult (Ok ws) ->
      let
        modelp = { model | works = ws }
      in
        (modify updateListContent (WL.generateModels modelp.works) modelp, Cmd.none)

    FetchData ->
      (model, fetchData)

    ModifyList msg ->
      let
        { works, content } = model
      in
        case content of
          (ContentList wl) ->
            ({ model | content = ContentList <| WL.update msg wl }, Cmd.none)

          _ ->
            (model, Cmd.none)

    ModifyWork msg ->
      let
        { works, content } = model
      in
        case content of
          (ContentSingle w slug) ->
            ({ model | content = ContentSingle (W.update msg w) slug }, Cmd.none)

          _ ->
            (model, Cmd.none)

    UrlChange loc ->
      ( changeUrl loc model, Cmd.none )

fetchData : Cmd Msg
fetchData =
  Http.send FetchResult (Http.get "./data.json" workDecoder)
