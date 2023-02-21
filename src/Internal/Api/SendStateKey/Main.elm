module Internal.Api.SendStateKey.Main exposing (..)

import Internal.Api.SendStateKey.Api as Api
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


sendStateKey : List String -> Maybe (SendStateKeyInput -> Task X.Error SendStateKeyOutput)
sendStateKey versions =
    VC.withBottomLayer
        { current = Api.sendStateKeyV1
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
            { downcast = identity
            , current = Api.sendStateKeyV2
            , upcast = identity
            , version = "v1.1"
            }
        |> VC.sameForVersion "v1.2"
        |> VC.sameForVersion "v1.3"
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.mostRecentFromVersionList versions


type alias SendStateKeyInput =
    Api.SendStateKeyInputV1


type alias SendStateKeyOutput =
    Api.SendStateKeyOutputV1
