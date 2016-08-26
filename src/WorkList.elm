module WorkList exposing (Model, Msg, init, update, view, newData)

import Html exposing (..)
import Html.App as App
import Lazy.List exposing (..)

import Model exposing (..)
import Work as W

type alias Model =
  { dataList : List Work
  , displayList : List (Int, Work)
  , filter : Tag
  }

init : List Work -> Model
init ws =
  Model ws (indexWorks ws) None

indexWorks : List Work -> List (Int, Work)
indexWorks ws =
   toList <| (zip numbers) <| fromList ws


type Msg
  = NoOp
  | Update (List Work)
  | Modify Int W.Msg


view : Model -> Html Msg
view model =
  div [] (List.map viewWork model.displayList)

viewWork : (Int, W.Model) -> Html Msg
viewWork (id, model) =
  App.map (Modify id) (W.view model)

newData : List Work -> Model -> Model
newData ws model =
  update (Update ws) model

update : Msg -> Model -> Model
update msg model =
  case msg of
    Update ws ->
      init ws

    Modify id msg ->
      { model | displayList = List.map (updateHelp id msg) model.displayList }

    NoOp ->
      model

updateHelp : Int -> W.Msg -> (Int, W.Model) -> (Int, W.Model)
updateHelp id msg (id', model) =
  (id', if id == id' then W.update msg model else model)
