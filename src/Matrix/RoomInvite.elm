module Matrix.RoomInvite exposing
    ( RoomInvite, accept, reject
    , roomId, RoomInviteEvent, getEvent, getAllEvents
    , sender, stateKey, eventType, content
    )

{-| Sometimes, your user will be invited to a new room!
This module offers you a few simple handles to deal with such invites -
you can accept them, reject them or inspect them for further information.


# Invitations

@docs RoomInvite, accept, reject


# Exploring invitations

Sometimes, you may want to display information about the room.

Be careful though, anyone can invite you to any room! This means that room invites
may contain offensive, shocking or other unwanted content that the user may not
want to see.

@docs roomId, RoomInviteEvent, getEvent, getAllEvents

Once you have the event you want, you can explore it with the following functions.

@docs sender, stateKey, eventType, content

-}

import Internal.Api.VaultUpdate exposing (VaultUpdate)
import Internal.Invite as Internal
import Internal.Values.RoomInvite as IR
import Json.Encode as E


{-| The `RoomInvite` type serves as an invite to a given room.
-}
type alias RoomInvite =
    Internal.RoomInvite


{-| If you would like to join a room, you can accept the offer.
-}
accept : { invite : RoomInvite, onResponse : VaultUpdate -> msg, reason : Maybe String } -> Cmd msg
accept =
    Internal.accept


{-| If you don't want to join the room, you can reject the offer.
-}
reject : { invite : RoomInvite, onResponse : VaultUpdate -> msg, reason : Maybe String } -> Cmd msg
reject =
    Internal.reject


{-| Get the room id of the invited room.
-}
roomId : RoomInvite -> String
roomId =
    Internal.roomId


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
eventType : RoomInviteEvent -> String
eventType =
    IR.eventType


{-| Get the event's state key.
-}
stateKey : RoomInviteEvent -> String
stateKey =
    IR.stateKey


{-| Get a specific event with a specific event content type and state key, if it exists.
-}
getEvent : { eventType : String, stateKey : String } -> RoomInvite -> Maybe RoomInviteEvent
getEvent =
    Internal.getEvent


{-| Instead of looking at just one event, get all events in a list.
-}
getAllEvents : RoomInvite -> List RoomInviteEvent
getAllEvents =
    Internal.getAllEvents
