module Internal.Credentials exposing (..)

{-| The Credentials type is the keychain that stores all tokens, values,
numbers and other types that need to be remembered.

This file combines the internal functions with the API endpoints to create a fully functional Credentials keychain.

-}

import Internal.Room as Room
import Internal.Values.Credentials as Internal


{-| You can consider the `Credentials` type as a large ring of keys,
and Elm will figure out which key to use.
If you pass the `Credentials` into any function, then the library will look for
the right keys and tokens to get the right information.
-}
type alias Credentials =
    Internal.Credentials


{-| Get a Credentials type based on an unknown access token.

This is an easier way to connect to a Matrix homeserver, but your access may end
when the access token expires, is revoked or something else happens.

-}
fromAccessToken : { homeserver : String, accessToken : String } -> Credentials
fromAccessToken =
    Internal.fromAccessToken


{-| Get a Credentials type using a username and password.
-}
fromLoginCredentials : { username : String, password : String, homeserver : String } -> Credentials
fromLoginCredentials =
    Internal.fromLoginCredentials


{-| Get a room based on its id.
-}
getRoomById : String -> Credentials -> Maybe Room.Room
getRoomById roomId credentials =
    Internal.getRoomById roomId credentials
        |> Maybe.map
            (Room.init
                { accessToken = Internal.getAccessTokenType credentials
                , baseUrl = Internal.getBaseUrl credentials
                , versions = Internal.getVersions credentials
                }
            )
