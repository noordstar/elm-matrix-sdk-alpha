module Internal.Api.Leave.Main exposing (..)

import Internal.Api.Leave.Api as Api
import Internal.Tools.Context as Context exposing (Context, VBA)
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


leave : Context (VBA a) -> LeaveInput -> Task X.Error LeaveOutput
leave context input =
    VC.withBottomLayer
        { current = Api.leaveV1
        , version = "r0.0.0"
        }
        |> VC.sameForVersion "r0.0.1"
        |> VC.sameForVersion "r0.1.0"
        |> VC.sameForVersion "r0.2.0"
        |> VC.sameForVersion "r0.3.0"
        |> VC.sameForVersion "r0.4.0"
        |> VC.sameForVersion "r0.5.0"
        |> VC.sameForVersion "r0.6.0"
        |> VC.sameForVersion "r0.6.1"
        |> VC.addMiddleLayer
            { downcast =
                \data ->
                    { roomId = data.roomId
                    }
            , current = Api.leaveV2
            , upcast = identity
            , version = "v1.1"
            }
        |> VC.sameForVersion "v1.2"
        |> VC.sameForVersion "v1.3"
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.sameForVersion "v1.6"
        |> VC.mostRecentFromVersionList (Context.getVersions context)
        |> Maybe.withDefault (always <| always <| Task.fail X.UnsupportedSpecVersion)
        |> (|>) input
        |> (|>) context


type alias LeaveInput =
    Api.LeaveInputV2


type alias LeaveOutput =
    Api.LeaveOutputV1
