module Internal.Values.StateManager exposing (..)

import Dict exposing (Dict)
import Internal.Values.Event as Event exposing (Event)

type alias StateManager = Dict (String, String) Event

getStateEvent : String -> String -> StateManager -> Maybe Event
getStateEvent eventType stateKey =
    Dict.get ( eventType, stateKey )

updateRoomStateWith : StateManager -> StateManager -> StateManager
updateRoomStateWith = Dict.union

fromEventList : List Event -> StateManager
fromEventList =
    List.filterMap
        (\event ->
            event
                |> Event.stateKey
                |> Maybe.map
                    (\key ->
                        ( ( Event.contentType event, key ), event )
                    )
        )
        >> Dict.fromList


