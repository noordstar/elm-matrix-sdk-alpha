module Matrix.Event exposing
    ( Event, contentType, content, stateKey
    , eventId, roomId, sender, originServerTs, redactedBecause
    )

{-| This module allows you to read Matrix events.


# Event

@docs Event, contentType, content, stateKey


## Getting metadata

@docs eventId, roomId, sender, originServerTs, redactedBecause

-}

import Internal.Event as Internal
import Json.Encode as E
import Time


{-| The `Event` type relates to an event type in a room.
-}
type alias Event =
    Internal.Event


{-| Get the content of an event as a JSON Value type.
-}
content : Event -> E.Value
content =
    Internal.content


{-| Get the event's id.
-}
eventId : Event -> String
eventId =
    Internal.eventId


{-| Timestamp of when this event was first received on the original homeserver.
-}
originServerTs : Event -> Time.Posix
originServerTs =
    Internal.originServerTs


{-| Room ID of the room that the event is in.
-}
roomId : Event -> String
roomId =
    Internal.roomId


{-| String representation of the user who sent the message in this room.
-}
sender : Event -> String
sender =
    Internal.sender


{-| The optional statekey of the event.

Whether this contains a value also dictates whether it is a state event or a message event.

-}
stateKey : Event -> Maybe String
stateKey =
    Internal.stateKey


{-| This is the type of the event's content. For example, `m.room.message` indicates that it was a message.
-}
contentType : Event -> String
contentType =
    Internal.contentType


{-| In case the event was redacted, this event will point you to the event that redacted it.
-}
redactedBecause : Event -> Maybe Event
redactedBecause =
    Internal.redactedBecause
