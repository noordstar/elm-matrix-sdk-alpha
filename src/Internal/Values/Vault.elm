module Internal.Values.Vault exposing (..)

{-| The Credentials type is the keychain of the Matrix SDK.
It handles all communication with the homeserver.
-}

import Dict exposing (Dict)
import Internal.Tools.Hashdict as Hashdict exposing (Hashdict)
import Internal.Values.Room as Room exposing (IRoom)
import Internal.Values.RoomInvite as Invite exposing (IRoomInvite)
import Json.Encode as E


type IVault
    = IVault
        { accountData : Dict String E.Value
        , invites : List IRoomInvite
        , rooms : Hashdict IRoom
        , since : Maybe String
        }


{-| Get an account data value.
-}
accountData : String -> IVault -> Maybe E.Value
accountData key (IVault data) =
    Dict.get key data.accountData


{-| Add a new `since` token to sync from.
-}
addSince : String -> IVault -> IVault
addSince since (IVault data) =
    IVault { data | since = Just since }


{-| Add a new invite.
-}
addInvite : IRoomInvite -> IVault -> IVault
addInvite invite (IVault data) =
    IVault { data | invites = List.append data.invites [ invite ] }


{-| Get all the invited rooms of a user.
-}
getInvites : IVault -> List IRoomInvite
getInvites (IVault data) =
    data.invites


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
        { accountData = Dict.empty
        , invites = []
        , rooms = Hashdict.empty Room.roomId
        , since = Nothing
        }


insertAccountData : { content : E.Value, eventType : String, roomId : Maybe String } -> IVault -> IVault
insertAccountData { content, eventType, roomId } (IVault data) =
    case roomId of
        Just rId ->
            getRoomById rId (IVault data)
                |> Maybe.map
                    (Room.insertAccountData (Dict.singleton eventType content)
                        >> Hashdict.insert
                        >> (|>) data.rooms
                        >> (\rooms -> IVault { data | rooms = rooms })
                    )
                |> Maybe.withDefault (IVault data)

        Nothing ->
            IVault { data | accountData = Dict.insert eventType content data.accountData }


{-| Add a new room to the Credentials type. If a room with this id already exists, it is overwritten.

This function can hence also be used as an update function for rooms.

-}
insertRoom : IRoom -> IVault -> IVault
insertRoom room (IVault data) =
    IVault
        { data | rooms = Hashdict.insert room data.rooms }


{-| Remove an invite. This is usually done when the invite has been accepted or rejected.
-}
removeInvite : String -> IVault -> IVault
removeInvite roomId (IVault data) =
    IVault { data | invites = List.filter (\i -> Invite.roomId i /= roomId) data.invites }
