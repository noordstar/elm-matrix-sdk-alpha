module Internal.Api.SendStateKey.V1_5.Api exposing (..)

import Internal.Api.SendStateKey.Api as Api
import Internal.Api.SendStateKey.V1_4.Objects as PO
import Internal.Api.SendStateKey.V1_5.Convert as C
import Internal.Api.SendStateKey.V1_5.Objects as O
import Internal.Api.SendStateKey.V1_5.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion Api.SendStateKeyInputV1 PO.EventResponse Api.SendStateKeyInputV1 O.EventResponse
packet =
    { version = "v1.5"
    , downcast = identity
    , current = Api.sendStateKeyV1 O.eventResponseDecoder C.convert
    , upcast = U.upcast
    }
