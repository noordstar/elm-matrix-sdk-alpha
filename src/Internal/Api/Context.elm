module Internal.Api.Context exposing (..)

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
        , transactionId : String
        , usernameAndPassword : Maybe UsernameAndPassword
        , versions : List String
        }


type alias UsernameAndPassword =
    { username : String, password : String }


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
        , transactionId = L.transactionId
        , usernameAndPassword = Nothing
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


{-| Get the transaction id from the Context.
-}
getTransactionId : Context { a | transactionId : () } -> String
getTransactionId (Context { transactionId }) =
    transactionId


{-| Get the username and password of the user, if present.
-}
getUsernameAndPassword : Context { a | accessToken : () } -> Maybe UsernameAndPassword
getUsernameAndPassword (Context { usernameAndPassword }) =
    usernameAndPassword


{-| Get the supported spec versions from the Context.
-}
getVersions : Context { a | versions : () } -> List String
getVersions (Context { versions }) =
    versions


{-| Insert an access token into the context.
-}
setAccessToken : { accessToken : String, usernameAndPassword : Maybe UsernameAndPassword } -> Context a -> Context { a | accessToken : () }
setAccessToken { accessToken, usernameAndPassword } (Context data) =
    Context { data | accessToken = accessToken, usernameAndPassword = usernameAndPassword }


{-| Insert a base url into the context.
-}
setBaseUrl : String -> Context a -> Context { a | baseUrl : () }
setBaseUrl baseUrl (Context data) =
    Context { data | baseUrl = baseUrl }


{-| Insert a transaction id into the context.
-}
setTransactionId : String -> Context a -> Context { a | transactionId : () }
setTransactionId transactionId (Context data) =
    Context { data | transactionId = transactionId }


{-| Insert a transaction id into the context.
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


{-| Remove the transaction id from the Context
-}
removeTransactionId : Context { a | transactionId : () } -> Context a
removeTransactionId (Context data) =
    Context data


{-| Remove the versions from the Context
-}
removeVersions : Context { a | versions : () } -> Context a
removeVersions (Context data) =
    Context data
