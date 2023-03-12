module Internal.Api.LoginWithUsernameAndPassword.Main exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.Api as Api
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)

loginWithUsernameAndPassword : List String -> LoginWithUsernameAndPasswordInput -> Task X.Error LoginWithUsernameAndPasswordOutput
loginWithUsernameAndPassword versions =
    VC.withBottomLayer
        { current = Api.loginWithUsernameAndPasswordV1
        , version = "v1.5"
        }
        |> VC.mostRecentFromVersionList versions
        |> Maybe.withDefault (always <| Task.fail X.UnsupportedSpecVersion)


type alias LoginWithUsernameAndPasswordInput =
    Api.LoginWithUsernameAndPasswordInputV1

type alias LoginWithUsernameAndPasswordOutput =
    Api.LoginWithUsernameAndPasswordOutputV1

