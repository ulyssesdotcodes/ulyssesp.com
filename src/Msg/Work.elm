module Msg.Work exposing (..)

import Model.Work exposing (..)

type Msg
  = DisplayAs DisplayType
  | NextImage
  | PrevImage
  | Animate Float
