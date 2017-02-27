module Update.WorkList exposing (..)

import Model.Work as W
import Model.WorkList exposing (..)
import Msg.Work as W
import Msg.WorkList exposing (..)
import Update.Work as W

update : Msg -> Model -> Model
update msg model =
  case msg of
    Modify id msg ->
      { model | workModels = List.map (Tuple.second << updateHelp id msg) (indexModels model.workModels) }

    Filter tag ->
      { model | filter = tag }

    NoOp ->
      model

indexModels : List W.Model -> List (Int, W.Model)
indexModels ws =
   List.indexedMap (,) ws

updateHelp : Int -> W.Msg -> (Int, W.Model) -> (Int, W.Model)
updateHelp id msg (idp, model) =
  (idp, if id == idp then W.update msg model else model)
