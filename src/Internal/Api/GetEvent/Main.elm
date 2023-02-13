module Internal.Api.GetEvent.Main exposing (..)

import Internal.Api.GetEvent.Api as Api
import Internal.Tools.VersionControl as VC


getEvent : List String -> Maybe (EventInput -> EventOutput)
getEvent versions =
    VC.withBottomLayer
        { current = Api.getEventInputV1
        , version = "v1.2"
        }
        |> VC.sameForVersion "v1.3"
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.mostRecentFromVersionList versions


type alias EventOutput =
    Api.GetEventOutputV1


type alias EventInput =
    Api.GetEventInputV1
