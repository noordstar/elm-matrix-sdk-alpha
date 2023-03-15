module Matrix.RoomInvite exposing (..)

{-| Sometimes, your user will be invited to a new room!
This module offers you a few simple handles to deal with such invites -
you can accept them, reject them or inspect them for further information.


# Invitations

@docs RoomInvite, accept, reject, acceptWithReason, rejectWithReason


# Exploring invitations

Sometimes, you may want to display information about the room.

Be careful though, anyone can invite you to any room! This means that room invites
may contain offensive, shocking or other unwanted content that the user may not
want to see.

-}

import Internal.Api.VaultUpdate exposing (VaultUpdate)
import Internal.Invite as Internal
import Internal.Tools.Exceptions as X
import Internal.Values.RoomInvite as IR
import Json.Encode as E
import Task exposing (Task)


{-| The `RoomInvite` type serves as an invite to a given room.
-}
type alias RoomInvite =
    Internal.RoomInvite


{-| If you would like to join a room, you can accept the offer.
-}
accept : RoomInvite -> Task X.Error VaultUpdate
accept invite =
    Internal.accept { invite = invite, reason = Nothing }


{-| If you don't want to join the room, you can reject the offer.
-}
reject : RoomInvite -> Task X.Error VaultUpdate
reject invite =
    Internal.reject { invite = invite, reason = Nothing }


{-| If the Matrix server supports it, you can add a reason for accepting an invite.
-}
acceptWithReason : String -> RoomInvite -> Task X.Error VaultUpdate
acceptWithReason reason invite =
    Internal.accept { invite = invite, reason = Just reason }


{-| If the Matrix server supports it, you can add a reason for rejecting an invite.
-}
rejectWithReason : String -> RoomInvite -> Task X.Error VaultUpdate
rejectWithReason reason invite =
    Internal.reject { invite = invite, reason = Just reason }


{-| Get the room id of the invited room.
-}
roomId : RoomInvite -> String
roomId =
    Internal.getRoomId


{-| The `RoomInviteEvent` type represents a stripped event that your user can see while they haven't joined the group yet.

The invite includes a bunch of these events to tell you what the room looks like, who may be part of it,
and other information that will give you a hint of what kind of room it is.

-}
type alias RoomInviteEvent =
    IR.RoomInviteEvent


{-| Get the Matrix user that originally sent this event.
-}
sender : RoomInviteEvent -> String
sender =
    IR.sender


{-| Get the content of the event.
-}
content : RoomInviteEvent -> E.Value
content =
    IR.content


{-| Get the event's content type.
-}
contentType : RoomInviteEvent -> String
contentType =
    IR.contentType


{-| Get the event's state key.
-}
stateKey : RoomInviteEvent -> String
stateKey =
    IR.stateKey


{-| Get a specific event with a specific event content type and state key, if it exists.
-}
getEvent : { contentType : String, stateKey : String } -> RoomInvite -> Maybe RoomInviteEvent
getEvent data invite =
    invite
        |> Internal.withoutCredentials
        |> IR.getEvent data


{-| Instead of looking at just one event, get all events in a list.
-}
getAllEvents : RoomInvite -> List RoomInviteEvent
getAllEvents =
    Internal.getAllEvents
