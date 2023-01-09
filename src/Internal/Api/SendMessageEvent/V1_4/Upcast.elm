module Internal.Api.SendMessageEvent.V1_4.Upcast exposing (..)

import Internal.Api.SendMessageEvent.V1_3.Objects as PO
import Internal.Api.SendMessageEvent.V1_4.Objects as O


upcast : PO.EventResponse -> O.EventResponse
upcast =
    identity
