module Msg.WorkList exposing (..)

import Model exposing (..)

import Msg.Work as W

type Msg
  = NoOp
  | Filter (Maybe Tag)
  | Modify Int W.Msg
