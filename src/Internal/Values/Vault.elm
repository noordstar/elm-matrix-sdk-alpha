module Internal.Values.Vault exposing (..)

{-| The Credentials type is the keychain of the Matrix SDK.
It handles all communication with the homeserver.
-}

import Internal.Tools.Hashdict as Hashdict exposing (Hashdict)
import Internal.Values.Room as Room exposing (IRoom)


type IVault
    = IVault
        { rooms : Hashdict IRoom
        , since : Maybe String
        }


{-| Add a new `since` token to sync from.
-}
addSince : String -> IVault -> IVault
addSince since (IVault data) =
    IVault { data | since = Just since }


{-| Get a room from the Credentials type by the room's id.
-}
getRoomById : String -> IVault -> Maybe IRoom
getRoomById roomId (IVault cred) =
    Hashdict.get roomId cred.rooms


{-| Get a list of all synchronised rooms.
-}
getRooms : IVault -> List IRoom
getRooms (IVault { rooms }) =
    Hashdict.values rooms


{-| Get the latest `since` token.
-}
getSince : IVault -> Maybe String
getSince (IVault { since }) =
    since


{-| Create new empty Credentials.
-}
init : IVault
init =
    IVault
        { rooms = Hashdict.empty Room.roomId
        , since = Nothing
        }


{-| Add a new room to the Credentials type. If a room with this id already exists, it is overwritten.

This function can hence also be used as an update function for rooms.

-}
insertRoom : IRoom -> IVault -> IVault
insertRoom room (IVault cred) =
    IVault
        { cred | rooms = Hashdict.insert room cred.rooms }
