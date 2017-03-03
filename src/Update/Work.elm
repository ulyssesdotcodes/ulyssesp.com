module Update.Work exposing (..)

import Msg.Work exposing (..)
import Model.Work exposing (..)

update : Msg -> Model -> Model
update msg m =
  case msg of
    (DisplayAs t) ->
      { m | displayType = t }

    NextImage ->
      { m | selectedImage = Maybe.map ((+) 1) m.selectedImage }

    PrevImage ->
      { m | selectedImage = Maybe.map ((-) 1) m.selectedImage }

    ShowImage imgIndex ->
      { m | selectedImage = Just imgIndex }

    HideLightbox ->
      { m | selectedImage = Nothing }
