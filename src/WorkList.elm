module WorkList exposing (Model, Msg, init, update, view, newData)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Lazy.List exposing (..)

import Model exposing (..)
import Work as W

type alias Model =
  { dataList : List Work
  , displayList : List (Int, Work)
  , filter : Maybe Tag
  }

init : List Work -> Model
init ws =
  Model ws (indexWorks ws) Nothing

indexWorks : List Work -> List (Int, Work)
indexWorks ws =
   toList <| (zip numbers) <| fromList ws


type Msg
  = NoOp
  | Update (List Work)
  | Modify Int W.Msg
  | Filter (Maybe Tag)

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

    Filter tag ->
      case tag of
        Just t ->
          { model | filter = tag, displayList = indexWorks (List.filter (\w -> List.member t w.tags) model.dataList) }

        Nothing ->
          { model | filter = tag, displayList = indexWorks model.dataList }

    NoOp ->
      model

updateHelp : Int -> W.Msg -> (Int, W.Model) -> (Int, W.Model)
updateHelp id msg (id', model) =
  (id', if id == id' then W.update msg model else model)


view : Model -> Html Msg
view model =
  div [class "max-width-3 mx-auto"]
    [ ul [ class "list-reset" ] ([filterSelect "All" Nothing model.filter] ++ (List.map (tagSelect model.filter) [Interactive, Performance, Web, Mobile]))
    , div [class "max-width-2 mx-auto"] (List.map viewWork model.displayList)
    ]

tagSelect : Maybe Tag -> Tag -> Html Msg
tagSelect cur tag =
  filterSelect (filterText tag) (Just tag) cur

filterSelect : String -> Maybe Tag -> Maybe Tag -> Html Msg
filterSelect str mt cur =
  li [class ("inline-block mr1" ++ (if cur == mt then " bold" else "")), onClick (Filter mt)]
    [a [href "#", class "color-inherit text-decoration-none"] [text str]]

filterText : Tag -> String
filterText tag =
  case tag of
    Interactive -> "Interactive"
    Performance -> "Performance"
    Web -> "Web"
    Mobile -> "Mobile"

viewWork : (Int, W.Model) -> Html Msg
viewWork (id, model) =
  App.map (Modify id) (W.view model)
