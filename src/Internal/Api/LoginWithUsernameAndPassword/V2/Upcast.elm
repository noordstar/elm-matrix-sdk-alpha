module Internal.Api.LoginWithUsernameAndPassword.V2.Upcast exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.V1.Login as PO
import Internal.Api.LoginWithUsernameAndPassword.V2.SpecObjects as SO


upcastLoggedInResponse : PO.LoggedInResponse -> SO.LoggedInResponse
upcastLoggedInResponse old =
    { accessToken = old.accessToken
    , deviceId = Nothing
    , homeServer = old.homeServer
    , refreshToken = old.refreshToken
    , userId = old.userId
    }
