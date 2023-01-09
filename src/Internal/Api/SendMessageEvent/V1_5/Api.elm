module Internal.Api.SendMessageEvent.V1_5.Api exposing (..)

import Internal.Api.SendMessageEvent.Api as Api
import Internal.Api.SendMessageEvent.V1_4.Objects as PO
import Internal.Api.SendMessageEvent.V1_5.Convert as C
import Internal.Api.SendMessageEvent.V1_5.Objects as O
import Internal.Api.SendMessageEvent.V1_5.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion Api.SendMessageEventInputV1 PO.EventResponse Api.SendMessageEventInputV1 O.EventResponse
packet =
    { version = "v1.5"
    , downcast = identity
    , current = Api.sendMessageEventV1 O.eventResponseDecoder C.convert
    , upcast = U.upcast
    }
