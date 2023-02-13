module Internal.Api.JoinedMembers.Main exposing (..)

import Internal.Api.JoinedMembers.Api as Api
import Internal.Tools.VersionControl as VC


joinedMembers : List String -> Maybe (JoinedMembersInput -> JoinedMembersOutput)
joinedMembers versions =
    VC.withBottomLayer
        { current = Api.joinedMembersInputV1
        , version = "v1.1"
        }
        |> VC.sameForVersion "v1.2"
        |> VC.sameForVersion "v1.3"
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.mostRecentFromVersionList versions


type alias JoinedMembersInput =
    Api.JoinedMembersInputV1


type alias JoinedMembersOutput =
    Api.JoinedMembersOutputV1
