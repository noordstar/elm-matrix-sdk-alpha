module Internal.Credentials exposing (..)

{-| The `Credentials` type serves as an extra layer between the internal Room/Event types
and the types that the user may deal with directly.

Since pointers cannot point to values that the `Vault` type has,
the `Vault` type passes information down in the form of a `Credentials` type.

-}

import Internal.Api.Versions.V1.Versions as V
import Internal.Tools.LoginValues as Login exposing (AccessToken(..))


type Credentials
    = Credentials
        { access : AccessToken
        , homeserver : String
        , vs : Maybe V.Versions
        }


{-| Retrieves the access token from a given `Credentials` value.
-}
accessToken : Credentials -> AccessToken
accessToken (Credentials { access }) =
    access


{-| Add a new access token to the `Credentials` type.
-}
addToken : String -> Credentials -> Credentials
addToken token (Credentials ({ access } as data)) =
    Credentials { data | access = Login.addToken token access }


{-| Add a username and password to the `Credentials` type.
-}
addUsernameAndPassword : { username : String, password : String } -> Credentials -> Credentials
addUsernameAndPassword uap (Credentials ({ access } as data)) =
    Credentials { data | access = Login.addUsernameAndPassword uap access }


{-| Add known spec versions to the `Credentials` type.
-}
addVersions : V.Versions -> Credentials -> Credentials
addVersions vs (Credentials data) =
    Credentials { data | vs = Just vs }


{-| Retrieves the base url from a given `Credentials` value.
-}
baseUrl : Credentials -> String
baseUrl (Credentials { homeserver }) =
    homeserver


{-| Creates a `Credentials` value from a base URL.
-}
fromBaseUrl : String -> Credentials
fromBaseUrl url =
    Credentials
        { access = NoAccess
        , homeserver = url
        , vs = Nothing
        }


{-| Retrieves the spec versions from a given `Credentials` value.
-}
versions : Credentials -> Maybe V.Versions
versions (Credentials { vs }) =
    vs
