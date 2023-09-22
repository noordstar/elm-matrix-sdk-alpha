module Internal.Api.LoginWithUsernameAndPassword.Main exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.Api as Api
import Internal.Api.LoginWithUsernameAndPassword.V2.Upcast as U2
import Internal.Api.LoginWithUsernameAndPassword.V3.Upcast as U3
import Internal.Api.LoginWithUsernameAndPassword.V4.Upcast as U4
import Internal.Api.LoginWithUsernameAndPassword.V5.Upcast as U5
import Internal.Tools.Context as Context exposing (Context, VB)
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


loginWithUsernameAndPassword : Context (VB a) -> LoginWithUsernameAndPasswordInput -> Task X.Error LoginWithUsernameAndPasswordOutput
loginWithUsernameAndPassword context input =
    VC.withBottomLayer
        { current = Api.loginWithUsernameAndPasswordV1
        , version = "r0.0.0"
        }
        |> VC.sameForVersion "r0.0.1"
        |> VC.sameForVersion "r0.1.0"
        |> VC.sameForVersion "r0.2.0"
        |> VC.addMiddleLayer
            { downcast = \{ username, password } -> { username = username, password = password }
            , current = Api.loginWithUsernameAndPasswordV2
            , upcast =
                \f c ->
                    Task.map U2.upcastLoggedInResponse (f c)
            , version = "r0.3.0"
            }
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.loginWithUsernameAndPasswordV3
            , upcast =
                \f c ->
                    Task.map U3.upcastLoggedInResponse (f c)
            , version = "r0.4.0"
            }
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.loginWithUsernameAndPasswordV4
            , upcast =
                \f c ->
                    Task.map U4.upcastLoggedInResponse (f c)
            , version = "r0.5.0"
            }
        |> VC.sameForVersion "r0.6.0"
        |> VC.sameForVersion "r0.6.1"
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.loginWithUsernameAndPasswordV5
            , upcast = identity
            , version = "v1.1"
            }
        |> VC.sameForVersion "v1.2"
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.loginWithUsernameAndPasswordV6
            , upcast =
                \f c ->
                    Task.map U5.upcastLoggedInResponse (f c)
            , version = "v1.3"
            }
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.sameForVersion "v1.6"
        |> VC.sameForVersion "v1.7"
        |> VC.sameForVersion "v1.8"
        |> VC.mostRecentFromVersionList (Context.getVersions context)
        |> Maybe.withDefault (always <| always <| Task.fail X.UnsupportedSpecVersion)
        |> (|>) input
        |> (|>) context


type alias LoginWithUsernameAndPasswordInput =
    Api.LoginWithUsernameAndPasswordInputV2


type alias LoginWithUsernameAndPasswordOutput =
    Api.LoginWithUsernameAndPasswordOutputV5
