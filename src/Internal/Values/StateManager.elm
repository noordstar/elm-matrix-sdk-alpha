module Internal.Values.StateManager exposing (..)

import Dict exposing (Dict)
import Internal.Values.Event as Event exposing (Event)


type alias StateManager =
    Dict ( String, String ) Event


addEvent : Event -> StateManager -> StateManager
addEvent event oldManager =
    case Event.stateKey event of
        Just key ->
            Dict.insert ( Event.contentType event, key ) event oldManager

        Nothing ->
            oldManager


getStateEvent : String -> String -> StateManager -> Maybe Event
getStateEvent eventType stateKey =
    Dict.get ( eventType, stateKey )


updateRoomStateWith : StateManager -> StateManager -> StateManager
updateRoomStateWith =
    Dict.union


fromEvent : Event -> StateManager
fromEvent event =
    Dict.empty
        |> addEvent event


fromEventList : List Event -> StateManager
fromEventList =
    List.foldl addEvent Dict.empty


empty : StateManager
empty =
    Dict.empty
