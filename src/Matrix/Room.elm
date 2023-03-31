module Matrix.Room exposing
    ( Room, roomId, mostRecentEvents, findOlderEvents
    , stateEvent, accountData
    , sendMessage, sendMessages, sendOneEvent, sendMultipleEvents
    )

{-| This module provides functions for working with Matrix rooms.


# Room

A room represents a channel of communication within a Matrix home server.

@docs Room, roomId, mostRecentEvents, findOlderEvents


# Exploring a room

@docs stateEvent, accountData


# Sending events

@docs sendMessage, sendMessages, sendOneEvent, sendMultipleEvents

-}

import Internal.Api.VaultUpdate exposing (VaultUpdate)
import Internal.Event as Event
import Internal.Room as Internal
import Internal.Tools.Exceptions as X
import Json.Encode as E
import Task exposing (Task)


{-| The `Room` type represents a Matrix Room that the user has joined.
It contains context information that allows the retrieval of new information from
the Matrix API if necessary.
-}
type alias Room =
    Internal.Room


{-| Get any account data value that the user stores regarding this room.
-}
accountData : String -> Room -> Maybe E.Value
accountData =
    Internal.accountData


{-| If you want more events as part of the most recent events, you can run this task to get more.
-}
findOlderEvents : { limit : Maybe Int, room : Room } -> Task X.Error VaultUpdate
findOlderEvents { limit, room } =
    Internal.getOlderEvents { limit = limit } room


{-| Get the most recent events from this room.
-}
mostRecentEvents : Room -> List Event.Event
mostRecentEvents =
    Internal.mostRecentEvents


{-| Get a state event in the room.
-}
stateEvent : { eventType : String, stateKey : String } -> Room -> Maybe Event.Event
stateEvent =
    Internal.getStateEvent


{-| Get the Matrix room id of a room.
-}
roomId : Room -> String
roomId =
    Internal.roomId


{-| Send an unformatted text message to a room.

    task =
        room
            |> sendMessage "Hello, world!"
            |> Task.attempt toMsg

**Hint:** are you trying to send multiple messages at the same time? You might want to use `sendMessages` instead.

-}
sendMessage : String -> Room -> Task X.Error VaultUpdate
sendMessage =
    Internal.sendMessage


{-| Send multiple unformatted text messages to a room.

**Why this function?** If you send the same message too quickly again, the Matrix API might get confused and think it's the same message.
This way, you will lose messages!

If you're intending to send the same message multiple times, this function will emphasize that these messages are not the same.

    -- SAFE
    Task.sequence [ sendMessage "Hello, world!", sendMessage "hi mom!" ]

    -- NOT SAFE
    Task.sequence [ sendMessage "Hello, world!", sendMessage "Hello world!" ]

    -- SAFE
    Task.sequence <| sendMessages [ "Hello, world!", "hi mom!" ]

    Task.sequence <| sendMessages [ "Hello, world!", "Hello, world!" ]

-}
sendMessages : List String -> Room -> List (Task X.Error VaultUpdate)
sendMessages =
    Internal.sendMessages


{-| Send a custom event to the Matrix room.

Keep in mind that this function is not safe to use if you're sending exactly the same messages multiple times:

    -- SAFE
    Task.sequence
        [ sendOneEvent { content = E.object [], eventType = "com.example.foo", stateKey = Nothing } room
        , sendOneEvent { content = E.int 0, eventType = "com.example.foo", stateKey = Nothing } room
        ]

    -- NOT SAFE
    Task.sequence
        [ sendOneEvent { content = E.object [], eventType = "com.example.foo", stateKey = Nothing } room
        , sendOneEvent { content = E.object [], eventType = "com.example.foo", stateKey = Nothing } room
        ]

-}
sendOneEvent : { content : E.Value, eventType : String, stateKey : Maybe String } -> Room -> Task X.Error VaultUpdate
sendOneEvent =
    Internal.sendEvent


{-| Send multiple events to the same room.

If you send the same event twice to the same room too close together, the Matrix API will sometimes think that it's the same event.
This function ensures that every messages is treated separately.

Keep in mind that this function doesn't send the events in order, it just makes them safe to send at the same time.

    -- NOT SAFE
    [ sendOneEvent { content = E.object [], eventType = "com.example.foo", stateKey = Nothing } room
    , sendOneEvent { content = E.object [], eventType = "com.example.foo", stateKey = Nothing } room
    ]
        |> Task.sequence

    -- SAFE
    [ { content = E.object [], eventType = "com.example.foo", stateKey = Nothing } room
    , { content = E.object [], eventType = "com.example.foo", stateKey = Nothing } room
    ]
        |> sendMultipleEvents
        |> Task.sequence

-}
sendMultipleEvents : List { content : E.Value, eventType : String, stateKey : Maybe String } -> Room -> List (Task X.Error VaultUpdate)
sendMultipleEvents =
    Internal.sendEvents
