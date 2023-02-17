module Internal.Api.Sync.Main exposing (..)

import Internal.Api.Sync.Api as Api
import Internal.Api.Sync.V2.Upcast as U2
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


sync : List String -> Maybe (SyncInput -> Task X.Error SyncOutput)
sync versions =
    VC.withBottomLayer
        { current = Api.syncV1
        , version = "v1.2"
        }
        |> VC.sameForVersion "v1.3"
        |> VC.addMiddleLayer
            { current = Api.syncV2
            , downcast = identity
            , upcast = Task.map U2.upcastSync
            , version = "v1.4"
            }
        |> VC.sameForVersion "v1.5"
        |> VC.mostRecentFromVersionList versions


type alias SyncInput =
    Api.SyncInputV1


type alias SyncOutput =
    Api.SyncOutputV2
