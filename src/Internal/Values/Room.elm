module Internal.Values.Room exposing (..)

import Dict exposing (Dict)
import Internal.Tools.SpecEnums exposing (SessionDescriptionType(..))
import Internal.Values.Event as Event exposing (BlindEvent, Event)
import Internal.Values.StateManager exposing (StateManager)
import Internal.Values.Timeline as Timeline exposing (Timeline)
import Json.Encode as E


type Room
    = Room
        { accountData : Dict String E.Value
        , ephemeral : List BlindEvent
        , events : Dict String Event
        , roomId : String
        , timeline : Timeline
        }


{-| Add new events as the most recent events.
-}
addEvents :
    { events : List Event
    , nextBatch : String
    , prevBatch : String
    , stateDelta : Maybe StateManager
    }
    -> Room
    -> Room
addEvents ({ events } as data) (Room room) =
    Room
        { room
            | events =
                events
                    |> List.map (\e -> ( Event.eventId e, e ))
                    |> Dict.fromList
                    |> (\x -> Dict.union x room.events)
            , timeline = Timeline.addNewEvents data room.timeline
        }


{-| Get an event by its id.
-}
getEventById : String -> Room -> Maybe Event
getEventById eventId (Room room) =
    Dict.get eventId room.events


{-| Get the room's id.
-}
roomId : Room -> String
roomId (Room room) =
    room.roomId
