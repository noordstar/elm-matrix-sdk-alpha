module Matrix.Room exposing
    ( Room, roomId
    , accountData, setAccountData
    , name, description
    , stateEvent
    , mostRecentEvents, findOlderEvents
    , sendMessage, sendMessages, sendOneEvent, sendMultipleEvents
    )

{-| This module provides functions for working with Matrix rooms.


# Room

@docs Room, roomId

Each room has the following data:

  - Account data
  - Room state
  - Timeline


## Account data

Account data is private information that the homeserver shows only to this user:
it synchronizes across all devices, but only to this user.
Configure private settings, track room data, keep notes, and more.

Please use the Java package naming convention when picking an appropriate key
for storing information, e.g. `org.example.myapp.property`.

@docs accountData, setAccountData


## Room state

The room state tells you everything you need to know: for example, rooms often
have a name and a room description.

@docs name, description

In Matrix, all information in a room state has an event type and a state key.
The event type dictates the JSON format of the state event, and the state key
makes the state event unique in a room.

State keys starting with an `@` are reserved for users - they can only change
this value themselves.

@docs stateEvent


## Timeline

While other information in the room will be overwritten from time to time,
the timeline is an endless list of events that you can keep appending events to.

@docs mostRecentEvents, findOlderEvents

Not only can you read from the timeline, you can also write to it. If `stateKey`
is not `Nothing`, you will also alter the room state. Keep in mind that this is not
allowed for every room admin.

@docs sendMessage, sendMessages, sendOneEvent, sendMultipleEvents

-}

import Internal.Api.VaultUpdate exposing (VaultUpdate)
import Internal.Event as Event
import Internal.Room as Internal
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


{-| A room represents a channel of communication within a Matrix home server.

Every user has a bunch of rooms that they're in, with which they can share rooms.

-}
type alias Room =
    Internal.Room


{-| Get any account data value that the user stores regarding this room.
-}
accountData : String -> Room -> Maybe D.Value
accountData =
    Internal.accountData


{-| Not all Matrix rooms have a description, but this function will get it if it exists.

This function is also a shorthand for getting the state event `m.room.topic` with
an empty state key, and decoding the content.

-}
description : Room -> Maybe String
description =
    stateEvent { eventType = "m.room.topic", stateKey = "" }
        >> Maybe.map Event.content
        >> Maybe.andThen (D.decodeValue (D.field "topic" D.string) >> Result.toMaybe)


{-| Starting from the most recent events, look for more events. Effectively,
this inserts more events at the start of the `[mostRecentEvents](#mostRecentEvents)` function's output list.
-}
findOlderEvents : { limit : Maybe Int, room : Room } -> Task X.Error VaultUpdate
findOlderEvents { limit, room } =
    Internal.getOlderEvents { limit = limit } room


{-| This function will always display the most recent events from the Matrix room.
The amount of events you'll see, depends on the room activity and how often you synchronize.

For example, you might get the following event list:

```txt
<--- [E0] --- [E1] --- [E2]
```

Then, after running a sync on your Matrix Vault, you might end up with a gap:

```txt
<--- [E0] --- [E1] --- [E2]        [E7] --- [E8] --- [E9]
                           |------|
                              gap
```

Since the `Vault` type doesn't know what's between `[E2]` and `[E7]`, this function
will only return `[E7]`, `[E8]` and `[E9]`. The previous events will be remembered,
however, in case you fill the gap later on.

The events will be returned in chronological order.

-}
mostRecentEvents : Room -> List Event.Event
mostRecentEvents =
    Internal.mostRecentEvents


{-| Not all Matrix rooms have a name, but this function will get it if it exists.

This function is also a shorthand for getting the state event `m.room.name` with
an empty state key, and decoding the content.

-}
name : Room -> Maybe String
name =
    stateEvent { eventType = "m.room.name", stateKey = "" }
        >> Maybe.map Event.content
        >> Maybe.andThen (D.decodeValue (D.field "name" D.string) >> Result.toMaybe)


{-| Get a state event in the room.
-}
stateEvent : { eventType : String, stateKey : String } -> Room -> Maybe Event.Event
stateEvent =
    Internal.getStateEvent


{-| Every room has a unique Matrix ID. You can later use this room ID to find the same room back.
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

    -- SAFE
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
sendOneEvent : { content : D.Value, eventType : String, stateKey : Maybe String } -> Room -> Task X.Error VaultUpdate
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
sendMultipleEvents : List { content : D.Value, eventType : String, stateKey : Maybe String } -> Room -> List (Task X.Error VaultUpdate)
sendMultipleEvents =
    Internal.sendEvents


{-| Save personal account data on this room.

The homeserver will save this information on this room, but it will only be visible to the user who sent it.

-}
setAccountData : String -> D.Value -> Room -> Task X.Error VaultUpdate
setAccountData =
    Internal.setAccountData
