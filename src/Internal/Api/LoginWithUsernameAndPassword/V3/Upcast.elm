module Internal.Api.LoginWithUsernameAndPassword.V3.Upcast exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.V2.SpecObjects as PO
import Internal.Api.LoginWithUsernameAndPassword.V3.SpecObjects as SO


upcastLoggedInResponse : PO.LoggedInResponse -> SO.LoggedInResponse
upcastLoggedInResponse old =
    { accessToken = old.accessToken
    , deviceId = Nothing
    , homeServer = Just old.homeServer
    , refreshToken = old.refreshToken
    , userId = old.userId
    }
