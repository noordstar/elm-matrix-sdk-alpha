module Internal.Api.SendStateKey.V1_2.Upcast exposing (..)

import Internal.Api.SendStateKey.V1_2.Objects as O
import Internal.Config.Leaking as L


upcast : () -> O.EventResponse
upcast _ =
    { eventId = L.eventId }
