module Internal.Invite exposing (..)

{-| An invite is an Elm type that informs the user they've been invited to a room.
-}

import Internal.Api.Credentials exposing (Credentials)
import Internal.Api.Sync.V2.SpecObjects exposing (StrippedStateEvent)
import Internal.Api.Task as Api
import Internal.Api.VaultUpdate exposing (VaultUpdate(..))
import Internal.Tools.Exceptions as X
import Internal.Values.RoomInvite as Internal
import Task exposing (Task)


type RoomInvite
    = RoomInvite
        { invite : Internal.IRoomInvite
        , context : Credentials
        }


getRoomId : RoomInvite -> String
getRoomId =
    withoutCredentials >> Internal.roomId


initFromStrippedStateEvent : { roomId : String, events : List StrippedStateEvent } -> Internal.IRoomInvite
initFromStrippedStateEvent =
    Internal.init


withCredentials : Credentials -> Internal.IRoomInvite -> RoomInvite
withCredentials context invite =
    RoomInvite { context = context, invite = invite }


withoutCredentials : RoomInvite -> Internal.IRoomInvite
withoutCredentials (RoomInvite { invite }) =
    invite


getEvent : { eventType : String, stateKey : String } -> RoomInvite -> Maybe Internal.RoomInviteEvent
getEvent data =
    withoutCredentials >> Internal.getEvent data


getAllEvents : RoomInvite -> List Internal.RoomInviteEvent
getAllEvents =
    withoutCredentials >> Internal.getAllEvents


{-| Accept an invite and join the room.
-}
accept : { invite : RoomInvite, reason : Maybe String } -> Task X.Error VaultUpdate
accept { invite, reason } =
    case invite of
        RoomInvite data ->
            Api.joinRoomById
                { roomId = Internal.roomId data.invite
                , reason = reason
                }
                data.context


{-| Reject the invite and do not join the room.
-}
reject : { invite : RoomInvite, reason : Maybe String } -> Task X.Error VaultUpdate
reject { invite, reason } =
    case invite of
        RoomInvite data ->
            Api.leave
                { roomId = Internal.roomId data.invite
                , reason = reason
                }
                data.context
