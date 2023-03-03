module Internal.Values.Credentials exposing (..)

{-| The Credentials type is the keychain of the Matrix SDK.
It handles all communication with the homeserver.
-}

import Internal.Tools.Hashdict as Hashdict exposing (Hashdict)
import Internal.Values.Room as Room exposing (IRoom)


type ICredentials
    = ICredentials
        { rooms : Hashdict IRoom
        , since : Maybe String
        }


{-| Add a new `since` token to sync from.
-}
addSince : String -> ICredentials -> ICredentials
addSince since (ICredentials data) =
    ICredentials { data | since = Just since }


{-| Get a room from the Credentials type by the room's id.
-}
getRoomById : String -> ICredentials -> Maybe IRoom
getRoomById roomId (ICredentials cred) =
    Hashdict.get roomId cred.rooms


{-| Get a list of all synchronised rooms.
-}
getRooms : ICredentials -> List IRoom
getRooms (ICredentials { rooms }) =
    Hashdict.values rooms


{-| Get the latest `since` token.
-}
getSince : ICredentials -> Maybe String
getSince (ICredentials { since }) =
    since


{-| Create new empty Credentials.
-}
init : ICredentials
init =
    ICredentials
        { rooms = Hashdict.empty Room.roomId
        , since = Nothing
        }


{-| Add a new room to the Credentials type. If a room with this id already exists, it is overwritten.

This function can hence also be used as an update function for rooms.

-}
insertRoom : IRoom -> ICredentials -> ICredentials
insertRoom room (ICredentials cred) =
    ICredentials
        { cred | rooms = Hashdict.insert room cred.rooms }
