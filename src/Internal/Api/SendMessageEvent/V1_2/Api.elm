module Internal.Api.SendMessageEvent.V1_2.Api exposing (..)

import Internal.Api.SendMessageEvent.Api as Api
import Internal.Api.SendMessageEvent.V1_2.Convert as C
import Internal.Api.SendMessageEvent.V1_2.Objects as O
import Internal.Api.SendMessageEvent.V1_2.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion () () Api.SendMessageEventInputV1 O.EventResponse
packet =
    { version = "v1.2"
    , downcast = \_ -> ()
    , current = Api.sendMessageEventV1 O.eventResponseDecoder C.convert
    , upcast = U.upcast
    }
