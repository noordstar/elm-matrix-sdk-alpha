module Internal.Context exposing (..)

{-| The `Context` type serves as an extra layer between the internal Room/Event types
and the types that the user may deal with directly.

Since pointers cannot point to values that the `Credentials` type has,
the `Credentials` type passes information down in the form of a `Context` type.

-}

import Internal.Api.PreApi.Objects.Versions as V
import Internal.Tools.LoginValues as Login exposing (AccessToken(..))


type Context
    = Context
        { access : AccessToken
        , homeserver : String
        , vs : Maybe V.Versions
        }


{-| Retrieves the access token from a given `Context` value.
-}
accessToken : Context -> AccessToken
accessToken (Context { access }) =
    access


{-| Add a new access token to the `Context` type.
-}
addToken : String -> Context -> Context
addToken token (Context ({ access } as data)) =
    Context { data | access = Login.addToken token access }


{-| Add a username and password to the `Context` type.
-}
addUsernameAndPassword : { username : String, password : String } -> Context -> Context
addUsernameAndPassword uap (Context ({ access } as data)) =
    Context { data | access = Login.addUsernameAndPassword uap access }


{-| Add known spec versions to the `Context` type.
-}
addVersions : V.Versions -> Context -> Context
addVersions vs (Context data) =
    Context { data | vs = Just vs }


{-| Retrieves the base url from a given `Context` value.
-}
baseUrl : Context -> String
baseUrl (Context { homeserver }) =
    homeserver


{-| Creates a `Context` value from a base URL.
-}
fromBaseUrl : String -> Context
fromBaseUrl url =
    Context
        { access = NoAccess
        , homeserver = url
        , vs = Nothing
        }


{-| Retrieves the spec versions from a given `Context` value.
-}
versions : Context -> Maybe V.Versions
versions (Context { vs }) =
    vs
