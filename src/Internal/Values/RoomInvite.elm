module Internal.Values.RoomInvite exposing (..)

{-| This module contains the internal version of the `RoomInvite` type.
-}

import Dict exposing (Dict)
import Json.Encode as E


type IRoomInvite
    = IRoomInvite
        { roomId : String
        , events : Dict ( String, String ) RoomInviteEvent
        }


type RoomInviteEvent
    = RoomInviteEvent
        { content : E.Value
        , sender : String
        , stateKey : String
        , eventType : String
        }


init : { roomId : String, events : List { content : E.Value, sender : String, stateKey : String, eventType : String } } -> IRoomInvite
init data =
    data.events
        |> List.map
            (\event ->
                ( ( event.eventType, event.stateKey ), RoomInviteEvent event )
            )
        |> Dict.fromList
        |> (\e -> IRoomInvite { roomId = data.roomId, events = e })


getEvent : { eventType : String, stateKey : String } -> IRoomInvite -> Maybe RoomInviteEvent
getEvent data (IRoomInvite { events }) =
    Dict.get ( data.eventType, data.stateKey ) events


getAllEvents : IRoomInvite -> List RoomInviteEvent
getAllEvents (IRoomInvite { events }) =
    Dict.values events


roomId : IRoomInvite -> String
roomId (IRoomInvite data) =
    data.roomId


content : RoomInviteEvent -> E.Value
content (RoomInviteEvent data) =
    data.content


sender : RoomInviteEvent -> String
sender (RoomInviteEvent data) =
    data.sender


stateKey : RoomInviteEvent -> String
stateKey (RoomInviteEvent data) =
    data.stateKey


eventType : RoomInviteEvent -> String
eventType (RoomInviteEvent data) =
    data.eventType
