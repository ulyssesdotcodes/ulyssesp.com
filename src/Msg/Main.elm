module Msg.Main exposing (..)

import Http
import Navigation

import Model exposing (..)
import Msg.Work as W
import Msg.WorkList as WL
import Model.Main exposing (..)

type Msg
  = NoOp
  | FetchResult (Result Http.Error (List Work))
  | FetchData
  | ModifyList WL.Msg
  | ModifyWork W.Msg
  | UrlChange Navigation.Location
