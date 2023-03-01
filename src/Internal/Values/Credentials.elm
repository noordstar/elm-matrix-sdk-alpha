module Internal.Values.Credentials exposing (..)

{-| The Credentials type is the keychain of the Matrix SDK.
It handles all communication with the homeserver.
-}

import Internal.Api.PreApi.Objects.Versions as V
import Internal.Tools.Hashdict as Hashdict exposing (Hashdict)
import Internal.Tools.LoginValues as Login exposing (AccessToken(..))
import Internal.Values.Room as Room exposing (Room)


type Credentials
    = Credentials { access : AccessToken, baseUrl : String, rooms : Hashdict Room, versions : Maybe V.Versions }


{-| Get the stringed access token the Credentials type is using, if any.
-}
getAccessToken : Credentials -> Maybe String
getAccessToken =
    getAccessTokenType >> Login.getToken


{-| Get the access token type that stores the Credentials's ways of getting access.
-}
getAccessTokenType : Credentials -> AccessToken
getAccessTokenType (Credentials { access }) =
    access


{-| Get the baseUrl that the credentials accesses.
-}
getBaseUrl : Credentials -> String
getBaseUrl (Credentials { baseUrl }) =
    baseUrl


{-| Get the versions that the homeserver supports.
-}
getVersions : Credentials -> Maybe V.Versions
getVersions (Credentials { versions }) =
    versions


{-| Internal value to be used as a "default" for credentials settings.
-}
defaultCredentials : String -> Credentials
defaultCredentials homeserver =
    Credentials
        { access = NoAccess
        , baseUrl = homeserver
        , rooms = Hashdict.empty Room.roomId
        , versions = Nothing
        }


{-| Create a Credentials type using an unknown access token.
-}
fromAccessToken : { accessToken : String, homeserver : String } -> Credentials
fromAccessToken { accessToken, homeserver } =
    case defaultCredentials homeserver of
        Credentials c ->
            Credentials { c | access = AccessToken accessToken }


{-| Create a Credentials type using a username and password.
-}
fromLoginCredentials : { username : String, password : String, homeserver : String } -> Credentials
fromLoginCredentials { username, password, homeserver } =
    case defaultCredentials homeserver of
        Credentials c ->
            Credentials { c | access = UsernameAndPassword { username = username, password = password, token = Nothing } }


{-| Get a room from the Credentials type by the room's id.
-}
getRoomById : String -> Credentials -> Maybe Room
getRoomById roomId (Credentials cred) =
    Hashdict.get roomId cred.rooms


{-| Add a new room to the Credentials type. If a room with this id already exists, it is overwritten.

This function can hence also be used as an update function for rooms.

-}
insertRoom : Room -> Credentials -> Credentials
insertRoom room (Credentials cred) =
    Credentials
        { cred | rooms = Hashdict.insert room cred.rooms }
