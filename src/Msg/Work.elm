module Msg.Work exposing (..)

import Model exposing (..)
import Model.Work exposing (..)

type Msg
  = DisplayAs DisplayType
  | NextImage
  | PrevImage
  | ShowImage Int
  | HideLightbox
