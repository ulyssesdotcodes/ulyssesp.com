module Main exposing (..)

import Navigation

import Model.Main exposing (..)
import Msg.Main exposing (..)
import View.Main exposing (..)
import Update.Main exposing (..)
import Sub.Main exposing (..)

-- MAIN

main : Program Never Model Msg
main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : Navigation.Location -> ( Model, Cmd Msg )
init loc = (Model.Main.init loc, fetchData)
