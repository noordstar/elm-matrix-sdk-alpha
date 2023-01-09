module Internal.Api.Sync.V1_2.Api exposing (..)

import Internal.Api.Sync.Api as Api
import Internal.Api.Sync.V1_2.Convert as C
import Internal.Api.Sync.V1_2.Objects as O
import Internal.Api.Sync.V1_2.SpecObjects as SO
import Internal.Api.Sync.V1_2.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion () () Api.SyncInputV1 O.Sync
packet =
    { version = "v1.2"
    , downcast = \_ -> ()
    , current = Api.syncV1 SO.syncDecoder C.convert
    , upcast = U.upcast
    }
