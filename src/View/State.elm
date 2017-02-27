module State exposing (..)

import Navigation

type Content = ContentList WL.Model | ContentSingle W.Model

type alias State =
  { content : Content
  , loc : Navigation.Location
  }
