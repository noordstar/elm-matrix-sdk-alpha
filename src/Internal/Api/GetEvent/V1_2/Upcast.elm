module Internal.Api.GetEvent.V1_2.Upcast exposing (..)

import Internal.Api.GetEvent.V1_2.Objects as O
import Internal.Config.Leaking as L
import Json.Encode as E


upcast : () -> O.ClientEvent
upcast _ =
    { content = E.object []
    , eventId = L.eventId
    , originServerTs = L.originServerTs
    , roomId = L.roomId
    , sender = L.sender
    , stateKey = Nothing
    , contentType = L.eventType
    , unsigned = Nothing
    }
