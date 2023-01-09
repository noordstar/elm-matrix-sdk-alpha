module Internal.Api.GetEvent.V1_2.Api exposing (..)

import Internal.Api.GetEvent.Api as Api
import Internal.Api.GetEvent.V1_2.Convert as C
import Internal.Api.GetEvent.V1_2.Objects as O
import Internal.Api.GetEvent.V1_2.SpecObjects as SO
import Internal.Api.GetEvent.V1_2.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion () () Api.GetEventInputV1 O.ClientEvent
packet =
    { version = "v1.2"
    , downcast = \_ -> ()
    , current = Api.getEventInputV1 SO.clientEventDecoder C.convert
    , upcast = U.upcast
    }
