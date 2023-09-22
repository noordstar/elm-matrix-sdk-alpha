module Internal.Api.Sync.Main exposing (..)

import Internal.Api.Sync.Api as Api
import Internal.Api.Sync.V2.Upcast as U2
import Internal.Tools.Context as Context exposing (Context, VBA)
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


sync : Context (VBA a) -> SyncInput -> Task X.Error SyncOutput
sync context input =
    VC.withBottomLayer
        { current = Api.syncV1
        , version = "v1.2"
        }
        |> VC.sameForVersion "v1.3"
        |> VC.addMiddleLayer
            { current = Api.syncV2
            , downcast = identity
            , upcast =
                \f c ->
                    Task.map U2.upcastSync (f c)
            , version = "v1.4"
            }
        |> VC.sameForVersion "v1.5"
        |> VC.sameForVersion "v1.6"
        |> VC.sameForVersion "v1.7"
        |> VC.sameForVersion "v1.8"
        |> VC.mostRecentFromVersionList (Context.getVersions context)
        |> Maybe.withDefault (always <| always <| Task.fail X.UnsupportedSpecVersion)
        |> (|>) input
        |> (|>) context


type alias SyncInput =
    Api.SyncInputV1


type alias SyncOutput =
    Api.SyncOutputV2
