module Internal.Values.Room exposing (..)

import Dict exposing (Dict)
import Internal.Tools.Hashdict as Hashdict exposing (Hashdict)
import Internal.Tools.SpecEnums exposing (SessionDescriptionType(..))
import Internal.Values.Event as Event exposing (BlindEvent, Event)
import Internal.Values.StateManager exposing (StateManager)
import Internal.Values.Timeline as Timeline exposing (Timeline)
import Json.Encode as E


type Room
    = Room
        { accountData : Dict String E.Value
        , ephemeral : List BlindEvent
        , events : Hashdict Event
        , roomId : String
        , timeline : Timeline
        }


{-| Add the data of a single event to the hashdict of events.
-}
addEvent : Event -> Room -> Room
addEvent event (Room ({ events } as room)) =
    Room { room | events = Hashdict.insert event events }


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
            | events = List.foldl Hashdict.insert room.events events
            , timeline = Timeline.addNewEvents data room.timeline
        }


{-| Get an event by its id.
-}
getEventById : String -> Room -> Maybe Event
getEventById eventId (Room room) =
    Hashdict.get eventId room.events


{-| Get the room's id.
-}
roomId : Room -> String
roomId (Room room) =
    room.roomId


{-| Get the most recent events.
-}
mostRecentEvents : Room -> List Event
mostRecentEvents (Room room) =
    Timeline.mostRecentEvents room.timeline
