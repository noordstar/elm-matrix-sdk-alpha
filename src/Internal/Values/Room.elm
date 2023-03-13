module Internal.Values.Room exposing (..)

import Dict exposing (Dict)
import Internal.Tools.Hashdict as Hashdict exposing (Hashdict)
import Internal.Tools.SpecEnums exposing (SessionDescriptionType(..))
import Internal.Values.Event exposing (BlindEvent, IEvent)
import Internal.Values.StateManager as StateManager exposing (StateManager)
import Internal.Values.Timeline as Timeline exposing (Timeline)
import Json.Encode as E


type IRoom
    = IRoom
        { accountData : Dict String E.Value
        , ephemeral : List BlindEvent
        , events : Hashdict IEvent
        , roomId : String
        , timeline : Timeline
        }


{-| Add the data of a single event to the hashdict of events.
-}
addEvent : IEvent -> IRoom -> IRoom
addEvent event (IRoom ({ events } as room)) =
    IRoom { room | events = Hashdict.insert event events }


{-| Add new events as the most recent events.
-}
addEvents :
    { events : List IEvent
    , limited : Bool
    , nextBatch : String
    , prevBatch : String
    , stateDelta : Maybe StateManager
    }
    -> IRoom
    -> IRoom
addEvents ({ events } as data) (IRoom room) =
    IRoom
        { room
            | events = List.foldl Hashdict.insert room.events events
            , timeline = Timeline.addNewEvents data room.timeline
        }


{-| Get an event by its id.
-}
getEventById : String -> IRoom -> Maybe IEvent
getEventById eventId (IRoom room) =
    Hashdict.get eventId room.events


getStateEvent : { eventType : String, stateKey : String } -> IRoom -> Maybe IEvent
getStateEvent data (IRoom room) =
    room.timeline
        |> Timeline.mostRecentState
        |> StateManager.getStateEvent data


{-| Get the room's id.
-}
roomId : IRoom -> String
roomId (IRoom room) =
    room.roomId


{-| Get the most recent events.
-}
mostRecentEvents : IRoom -> List IEvent
mostRecentEvents (IRoom room) =
    Timeline.mostRecentEvents room.timeline
