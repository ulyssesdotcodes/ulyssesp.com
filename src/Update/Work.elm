module Update.Work exposing (..)

import Msg.Work exposing (..)
import Model.Work exposing (..)

update : Msg -> Model -> Model
update msg m =
  case msg of
    (DisplayAs t) ->
      { m | displayType = t }

    NextImage -> m
      -- let
      --   sip = (m.selectedImage + 1) % (length m.images)
      -- in
      --   { m | selectedImage = sip, imageLeft = Animation.update |> Animation.duration second |> Animation.spring wobbly |> Animation.to [Left (toFloat (sip * -660)) Px] |> Animation.on m.imageLeft }

    PrevImage -> m
      -- let
      --   sip = (m.selectedImage - 1) % (length m.images)
      -- in
      --   { m | selectedImage = sip, imageLeft = Animation.animate |> Animation.duration second |> Animation.spring wobbly |> Animation.to [Left (toFloat (sip * -660)) Px] |> Animation.on m.imageLeft }

    Animate t -> m
      -- { m | imageLeft = Animation.tick t m.imageLeft }
