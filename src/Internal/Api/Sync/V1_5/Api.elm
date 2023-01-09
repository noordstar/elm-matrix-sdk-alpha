module Internal.Api.Sync.V1_5.Api exposing (..)

import Internal.Api.Sync.Api as Api
import Internal.Api.Sync.V1_4.Objects as PO
import Internal.Api.Sync.V1_5.Convert as C
import Internal.Api.Sync.V1_5.Objects as O
import Internal.Api.Sync.V1_5.SpecObjects as SO
import Internal.Api.Sync.V1_5.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion Api.SyncInputV1 PO.Sync Api.SyncInputV1 O.Sync
packet =
    { version = "v1.5"
    , downcast = identity
    , current = Api.syncV1 SO.syncDecoder C.convert
    , upcast = U.upcast
    }
