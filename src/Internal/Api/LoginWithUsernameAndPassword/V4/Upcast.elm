module Internal.Api.LoginWithUsernameAndPassword.V4.Upcast exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.V3.SpecObjects as PO
import Internal.Api.LoginWithUsernameAndPassword.V4.SpecObjects as SO


upcastLoggedInResponse : PO.LoggedInResponse -> SO.LoggedInResponse
upcastLoggedInResponse old =
    { accessToken = old.accessToken
    , deviceId = old.deviceId
    , homeServer = old.homeServer
    , refreshToken = old.refreshToken
    , userId = old.userId
    , wellKnown = Nothing
    }
