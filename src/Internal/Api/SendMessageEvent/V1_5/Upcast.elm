module Internal.Api.SendMessageEvent.V1_5.Upcast exposing (..)

import Internal.Api.SendMessageEvent.V1_4.Objects as PO
import Internal.Api.SendMessageEvent.V1_5.Objects as O


upcast : PO.EventResponse -> O.EventResponse
upcast =
    identity
