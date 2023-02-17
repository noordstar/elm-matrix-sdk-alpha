module Internal.Values.Credentials exposing (..)

import Internal.Tools.Hashdict as Hashdict exposing (Hashdict)
import Internal.Values.Room as Room exposing (Room)


type Credentials
    = Credentials { access : AccessToken, homeserver : String, rooms : Hashdict Room }


type AccessToken
    = AccessToken String
    | NoAccess
    | UsernameAndPassword { username : String, password : String, accessToken : Maybe String }


defaultCredentials : String -> Credentials
defaultCredentials homeserver =
    Credentials
        { access = NoAccess
        , homeserver = homeserver
        , rooms = Hashdict.empty Room.roomId
        }


fromAccessToken : { accessToken : String, homeserver : String } -> Credentials
fromAccessToken { accessToken, homeserver } =
    case defaultCredentials homeserver of
        Credentials c ->
            Credentials { c | access = AccessToken accessToken }


fromLoginCredentials : { username : String, password : String, homeserver : String } -> Credentials
fromLoginCredentials { username, password, homeserver } =
    case defaultCredentials homeserver of
        Credentials c ->
            Credentials { c | access = UsernameAndPassword { username = username, password = password, accessToken = Nothing } }


getRoomById : String -> Credentials -> Maybe Room
getRoomById roomId (Credentials cred) =
    Hashdict.get roomId cred.rooms


insertRoom : Room -> Credentials -> Credentials
insertRoom room (Credentials cred) =
    Credentials
        { cred | rooms = Hashdict.insert room cred.rooms }
