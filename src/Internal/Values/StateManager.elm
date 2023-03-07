module Internal.Values.StateManager exposing (..)

import Dict exposing (Dict)
import Internal.Values.Event as Event exposing (IEvent)


type alias StateManager =
    Dict ( String, String ) IEvent


addEvent : IEvent -> StateManager -> StateManager
addEvent event oldManager =
    case Event.stateKey event of
        Just key ->
            Dict.insert ( Event.contentType event, key ) event oldManager

        Nothing ->
            oldManager


getStateEvent : { eventType : String, stateKey : String } -> StateManager -> Maybe IEvent
getStateEvent { eventType, stateKey } =
    Dict.get ( eventType, stateKey )


updateRoomStateWith : StateManager -> StateManager -> StateManager
updateRoomStateWith =
    Dict.union


fromEvent : IEvent -> StateManager
fromEvent event =
    Dict.empty
        |> addEvent event


fromEventList : List IEvent -> StateManager
fromEventList =
    List.foldl addEvent Dict.empty


empty : StateManager
empty =
    Dict.empty
