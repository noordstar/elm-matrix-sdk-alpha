module Internal.Api.GetEvent.V1_3.Api exposing (..)

import Internal.Api.GetEvent.Api as Api
import Internal.Api.GetEvent.V1_2.Objects as PO
import Internal.Api.GetEvent.V1_3.Convert as C
import Internal.Api.GetEvent.V1_3.Objects as O
import Internal.Api.GetEvent.V1_3.SpecObjects as SO
import Internal.Api.GetEvent.V1_3.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion Api.GetEventInputV1 PO.ClientEvent Api.GetEventInputV1 O.ClientEvent
packet =
    { version = "v1.3"
    , downcast = identity
    , current = Api.getEventInputV1 SO.clientEventDecoder C.convert
    , upcast = U.upcast
    }
