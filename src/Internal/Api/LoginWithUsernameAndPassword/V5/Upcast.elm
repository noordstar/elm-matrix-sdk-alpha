module Internal.Api.LoginWithUsernameAndPassword.V5.Upcast exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.V4.SpecObjects as PO
import Internal.Api.LoginWithUsernameAndPassword.V5.Login as SO


upcastLoggedInResponse : PO.LoggedInResponse -> SO.LoggedInResponse
upcastLoggedInResponse old =
    { accessToken = old.accessToken
    , deviceId = old.deviceId
    , expiresInMs = Nothing
    , homeServer = old.homeServer
    , refreshToken = old.refreshToken
    , userId = old.userId
    , wellKnown = old.wellKnown
    }
