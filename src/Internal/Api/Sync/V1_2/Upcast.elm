module Internal.Api.Sync.V1_2.Upcast exposing (..)

import Internal.Api.Sync.V1_2.Objects as O
import Internal.Config.Leaking as L


upcast : () -> O.Sync
upcast _ =
    { accountData = []
    , nextBatch = L.nextBatch
    , presence = []
    , rooms = Nothing
    }
