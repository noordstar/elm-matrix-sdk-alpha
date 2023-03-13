module Internal.Api.Invite.Main exposing (..)

import Internal.Api.Invite.Api as Api
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


invite : List String -> InviteInput -> Task X.Error InviteOutput
invite versions =
    VC.withBottomLayer
        { current = Api.inviteV1
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
                    { accessToken = data.accessToken
                    , baseUrl = data.baseUrl
                    , roomId = data.roomId
                    , userId = data.userId
                    }
            , current = Api.inviteV2
            , upcast = identity
            , version = "v1.1"
            }
        |> VC.sameForVersion "v1.2"
        |> VC.sameForVersion "v1.3"
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.mostRecentFromVersionList versions
        |> Maybe.withDefault (always <| Task.fail X.UnsupportedSpecVersion)


type alias InviteInput =
    Api.InviteInputV2


type alias InviteOutput =
    Api.InviteOutputV1
