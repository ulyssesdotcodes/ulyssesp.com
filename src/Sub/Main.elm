module Sub.Main exposing (..)

import Model.Main exposing (..)
import Msg.Main exposing (..)
import Sub.WorkList as WL
import Sub.Work as W

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.content of
    (ContentList wl) ->
      Sub.map ModifyList <| WL.subscriptions wl

    (ContentSingle w slug) ->
      Sub.map ModifyWork <| W.subscriptions w

    (ContentNotFound) ->
      Sub.none
