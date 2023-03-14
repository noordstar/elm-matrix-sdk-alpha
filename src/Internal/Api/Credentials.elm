module Internal.Api.Credentials exposing (..)

{-| The `Credentials` type stitches the Vault together to the Matrix API.
It stores tokens and values needed to interact with the API, and it provides
the necessary context when the user aims to talk to the Matrix API.
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


{-| Retrieves the access token type without the access token value in case the value is no longer valid.
-}
refreshedAccessToken : Credentials -> AccessToken
refreshedAccessToken (Credentials { access }) =
    Login.removeToken access


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
