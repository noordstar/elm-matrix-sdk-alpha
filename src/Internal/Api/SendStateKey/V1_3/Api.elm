module Internal.Api.SendStateKey.V1_3.Api exposing (..)

import Internal.Api.SendStateKey.Api as Api
import Internal.Api.SendStateKey.V1_2.Objects as PO
import Internal.Api.SendStateKey.V1_3.Convert as C
import Internal.Api.SendStateKey.V1_3.Objects as O
import Internal.Api.SendStateKey.V1_3.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion Api.SendStateKeyInputV1 PO.EventResponse Api.SendStateKeyInputV1 O.EventResponse
packet =
    { version = "v1.3"
    , downcast = identity
    , current = Api.sendStateKeyV1 O.eventResponseDecoder C.convert
    , upcast = U.upcast
    }
