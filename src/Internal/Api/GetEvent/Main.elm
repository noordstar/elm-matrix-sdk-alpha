module Internal.Api.GetEvent.Main exposing (..)

import Internal.Api.GetEvent.Api as Api
import Internal.Tools.Context as Context exposing (Context, VBA)
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


getEvent : Context (VBA { a | sentEvent : () }) -> EventInput -> Task X.Error EventOutput
getEvent context input =
    VC.withBottomLayer
        { current = Api.getEventInputV1
        , version = "r0.5.0"
        }
        |> VC.sameForVersion "r0.6.0"
        |> VC.sameForVersion "r0.6.1"
        |> VC.sameForVersion "v1.1"
        |> VC.sameForVersion "v1.2"
        |> VC.sameForVersion "v1.3"
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.sameForVersion "v1.6"
        |> VC.mostRecentFromVersionList (Context.getVersions context)
        |> Maybe.withDefault (always <| always <| Task.fail X.UnsupportedSpecVersion)
        |> (|>) input
        |> (|>) context


type alias EventOutput =
    Api.GetEventOutputV1


type alias EventInput =
    Api.GetEventInputV1
