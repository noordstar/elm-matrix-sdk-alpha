module Internal.Tools.Context exposing (..)

{-| This module hosts functions for the `Context` type.

The `Context` type is a type that is passed along a chain of tasks.
This way, the result of a task can be used in a multitude of future tasks.

The module has a bunch of getters and setters. If you start with a simple version
from the `init` function, the compiler will only allow you to use getter functions
after having set the value using a setter function.

Additionaly, there are remove functions which are intended to tell the compiler
"you will have to get this value again if you'd like to use it later."

-}

import Internal.Config.Leaking as L
import Internal.Tools.LoginValues exposing (AccessToken(..))


type Context a
    = Context
        { accessToken : String
        , baseUrl : String
        , loginParts : Maybe LoginParts
        , sentEvent : String
        , transactionId : String
        , userId : String
        , versions : List String
        }


type alias LoginParts =
    { deviceId : Maybe String
    , initialDeviceDisplayName : Maybe String
    , password : String
    , username : String
    }


type alias VB a =
    { a | versions : (), baseUrl : () }


type alias VBA a =
    { a | accessToken : (), baseUrl : (), versions : () }


type alias VBAT a =
    { a | accessToken : (), baseUrl : (), versions : (), transactionId : () }


{-| Get a default Context type.
-}
init : Context {}
init =
    Context
        { accessToken = L.accessToken
        , baseUrl = L.baseUrl
        , loginParts = Nothing
        , sentEvent = L.eventId
        , transactionId = L.transactionId
        , userId = L.sender
        , versions = L.versions
        }


{-| Get the access token from the Context.
-}
getAccessToken : Context { a | accessToken : () } -> String
getAccessToken (Context { accessToken }) =
    accessToken


{-| Get the base url from the Context.
-}
getBaseUrl : Context { a | baseUrl : () } -> String
getBaseUrl (Context { baseUrl }) =
    baseUrl


{-| Get the username and password of the user, if present.
-}
getLoginParts : Context { a | accessToken : () } -> Maybe LoginParts
getLoginParts (Context { loginParts }) =
    loginParts


{-| Get the event that has been sent to the API recently.
-}
getSentEvent : Context { a | sentEvent : () } -> String
getSentEvent (Context { sentEvent }) =
    sentEvent


{-| Get the transaction id from the Context.
-}
getTransactionId : Context { a | transactionId : () } -> String
getTransactionId (Context { transactionId }) =
    transactionId


{-| Get the user id from the Context.
-}
getUserId : Context { a | userId : () } -> String
getUserId (Context { userId }) =
    userId


{-| Get the supported spec versions from the Context.
-}
getVersions : Context { a | versions : () } -> List String
getVersions (Context { versions }) =
    versions


{-| Insert an access token into the context.
-}
setAccessToken : { accessToken : String, loginParts : Maybe LoginParts } -> Context a -> Context { a | accessToken : () }
setAccessToken { accessToken, loginParts } (Context data) =
    Context { data | accessToken = accessToken, loginParts = loginParts }


{-| Insert a base url into the context.
-}
setBaseUrl : String -> Context a -> Context { a | baseUrl : () }
setBaseUrl baseUrl (Context data) =
    Context { data | baseUrl = baseUrl }


{-| Insert a sent event id into the context.
-}
setSentEvent : String -> Context a -> Context { a | sentEvent : () }
setSentEvent sentEvent (Context data) =
    Context { data | sentEvent = sentEvent }


{-| Insert a transaction id into the context.
-}
setTransactionId : String -> Context a -> Context { a | transactionId : () }
setTransactionId transactionId (Context data) =
    Context { data | transactionId = transactionId }


{-| Insert a user id into the context.
-}
setUserId : String -> Context a -> Context { a | userId : () }
setUserId userId (Context data) =
    Context { data | userId = userId }


{-| Insert versions into the context.
-}
setVersions : List String -> Context a -> Context { a | versions : () }
setVersions versions (Context data) =
    Context { data | versions = versions }


{-| Remove the access token from the Context
-}
removeAccessToken : Context { a | accessToken : () } -> Context a
removeAccessToken (Context data) =
    Context data


{-| Remove the base url from the Context
-}
removeBaseUrl : Context { a | baseUrl : () } -> Context a
removeBaseUrl (Context data) =
    Context data


{-| Remove the sent event's id from the Context
-}
removeSentEvent : Context { a | sentEvent : () } -> Context a
removeSentEvent (Context data) =
    Context data


{-| Remove the transaction id from the Context
-}
removeTransactionId : Context { a | transactionId : () } -> Context a
removeTransactionId (Context data) =
    Context data


{-| Remove the user id from the Context
-}
removeUserId : Context { a | userId : () } -> Context a
removeUserId (Context data) =
    Context data


{-| Remove the versions from the Context
-}
removeVersions : Context { a | versions : () } -> Context a
removeVersions (Context data) =
    Context data
