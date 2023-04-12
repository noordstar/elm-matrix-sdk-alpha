module Matrix.Event exposing
    ( Event, eventId
    , content, eventType, stateKey
    , roomId, sender, originServerTs, redactedBecause
    )

{-| This module allows you to read and manipulate events in a Matrix room.


# Event

@docs Event, eventId


## Reading data

Every event has a JSON value as its body, which was sent by the sender.
The `eventType` indicates the format that you should expect of the JSON value,
and the `stateKey` indicates whether it changes the room state or not.

@docs content, eventType, stateKey

Other than that, there's other information that you'll be able to look up.
This is considered metadata that will help you put the events in context.

@docs roomId, sender, originServerTs, redactedBecause

-}

import Internal.Event as Internal
import Json.Encode as E
import Time


{-| The `Event` type relates to an event type in a room. This can both
-}
type alias Event =
    Internal.Event


{-| Get the content of an event as a JSON Value type.
-}
content : Event -> E.Value
content =
    Internal.content


{-| Get the event's id. Event ids are usually named using the Java package naming convention,
for example `org.example.custom.event`.
-}
eventId : Event -> String
eventId =
    Internal.eventId


{-| Timestamp of when this event was first received on the original homeserver.

**NOTE:** You shouldn't rely on this value to determine the chronological order of events.
Matrix has many servers, and a homeserver can spoof this value.

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

Whether this contains a value also dictates whether the event updates the room state.

-}
stateKey : Event -> Maybe String
stateKey =
    Internal.stateKey


{-| The type of the event's content. For example, `m.room.message` indicates that it was a message.
-}
eventType : Event -> String
eventType =
    Internal.eventType


{-| In case the event was redacted, this event will point you to the event that redacted it.
-}
redactedBecause : Event -> Maybe Event
redactedBecause =
    Internal.redactedBecause
