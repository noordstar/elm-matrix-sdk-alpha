module Internal.Api.LoginWithUsernameAndPassword.Main exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.Api as Api
import Internal.Tools.Context as Context exposing (Context, VB)
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


loginWithUsernameAndPassword : Context (VB a) -> LoginWithUsernameAndPasswordInput -> Task X.Error LoginWithUsernameAndPasswordOutput
loginWithUsernameAndPassword context input =
    VC.withBottomLayer
        { current = Api.loginWithUsernameAndPasswordV1
        , version = "v1.5"
        }
        |> VC.mostRecentFromVersionList (Context.getVersions context)
        |> Maybe.withDefault (always <| always <| Task.fail X.UnsupportedSpecVersion)
        |> (|>) input
        |> (|>) context


type alias LoginWithUsernameAndPasswordInput =
    Api.LoginWithUsernameAndPasswordInputV1


type alias LoginWithUsernameAndPasswordOutput =
    Api.LoginWithUsernameAndPasswordOutputV1
