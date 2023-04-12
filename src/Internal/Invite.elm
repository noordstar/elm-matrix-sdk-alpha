module Internal.Invite exposing (..)

{-| An invite is an Elm type that informs the user they've been invited to a room.
-}

import Internal.Api.Snackbar as Snackbar exposing (Snackbar)
import Internal.Api.Sync.V2.SpecObjects exposing (StrippedStateEvent)
import Internal.Api.Task as Api
import Internal.Api.VaultUpdate exposing (VaultUpdate(..))
import Internal.Tools.Exceptions as X
import Internal.Values.RoomInvite as Internal
import Task exposing (Task)


type alias RoomInvite =
    Snackbar Internal.IRoomInvite


accept : { invite : RoomInvite, reason : Maybe String } -> Task X.Error VaultUpdate
accept { invite, reason } =
    Api.joinRoomById
        { roomId = roomId invite
        , reason = reason
        }
        invite


roomId : RoomInvite -> String
roomId =
    Snackbar.withoutCandy >> Internal.roomId


getEvent : { eventType : String, stateKey : String } -> RoomInvite -> Maybe Internal.RoomInviteEvent
getEvent data =
    Snackbar.withoutCandy >> Internal.getEvent data


getAllEvents : RoomInvite -> List Internal.RoomInviteEvent
getAllEvents =
    Snackbar.withoutCandy >> Internal.getAllEvents


initFromStrippedStateEvent : { roomId : String, events : List StrippedStateEvent } -> Internal.IRoomInvite
initFromStrippedStateEvent =
    Internal.init


{-| Reject the invite and do not join the room.
-}
reject : { invite : RoomInvite, reason : Maybe String } -> Task X.Error VaultUpdate
reject { invite, reason } =
    Api.leave
        { roomId = roomId invite
        , reason = reason
        }
        invite
