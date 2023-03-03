module Internal.Values.Timeline exposing (..)

{-| This module shapes the Timeline type used to keep track of timelines in Matrix rooms.
-}

import Internal.Config.Leaking as Leaking
import Internal.Tools.Fold as Fold
import Internal.Values.Event as Event exposing (IEvent)
import Internal.Values.StateManager as StateManager exposing (StateManager)


type Timeline
    = Timeline
        { prevBatch : String
        , nextBatch : String
        , events : List IEvent
        , stateAtStart : StateManager
        , previous : BeforeTimeline
        }


type BeforeTimeline
    = Endless String
    | Gap Timeline
    | StartOfTimeline


{-| Add a new batch of events to the front of the timeline.
-}
addNewEvents :
    { events : List IEvent
    , limited : Bool
    , nextBatch : String
    , prevBatch : String
    , stateDelta : Maybe StateManager
    }
    -> Timeline
    -> Timeline
addNewEvents { events, limited, nextBatch, prevBatch, stateDelta } (Timeline t) =
    Timeline
        (if prevBatch == t.nextBatch || not limited then
            { t
                | events = t.events ++ events
                , nextBatch = nextBatch
            }

         else
            { prevBatch = prevBatch
            , nextBatch = nextBatch
            , events = events
            , stateAtStart =
                t
                    |> Timeline
                    |> mostRecentState
                    |> StateManager.updateRoomStateWith
                        (stateDelta
                            |> Maybe.withDefault StateManager.empty
                        )
            , previous = Gap (Timeline t)
            }
        )


{-| Create a new timeline.
-}
newFromEvents :
    { events : List IEvent
    , nextBatch : String
    , prevBatch : Maybe String
    , stateDelta : Maybe StateManager
    }
    -> Timeline
newFromEvents { events, nextBatch, prevBatch, stateDelta } =
    Timeline
        { events = events
        , nextBatch = nextBatch
        , prevBatch =
            prevBatch
                |> Maybe.withDefault Leaking.prevBatch
        , previous =
            prevBatch
                |> Maybe.map Endless
                |> Maybe.withDefault StartOfTimeline
        , stateAtStart =
            stateDelta
                |> Maybe.withDefault StateManager.empty
        }


{-| Insert events starting from a known batch token.
-}
insertEvents :
    { events : List IEvent
    , nextBatch : String
    , prevBatch : String
    , stateDelta : Maybe StateManager
    }
    -> Timeline
    -> Timeline
insertEvents ({ events, nextBatch, prevBatch, stateDelta } as data) (Timeline t) =
    Timeline
        (if t.nextBatch == prevBatch then
            { t
                | events = t.events ++ events
                , nextBatch = nextBatch
            }

         else if nextBatch == t.prevBatch then
            case t.previous of
                Gap (Timeline prevT) ->
                    if prevT.nextBatch == prevBatch then
                        { events = prevT.events ++ events ++ t.events
                        , nextBatch = t.nextBatch
                        , prevBatch = prevT.prevBatch
                        , stateAtStart = prevT.stateAtStart
                        , previous = prevT.previous
                        }

                    else
                        { t
                            | events = events ++ t.events
                            , prevBatch = prevBatch
                            , stateAtStart =
                                stateDelta
                                    |> Maybe.withDefault StateManager.empty
                        }

                _ ->
                    { t
                        | events = events ++ t.events
                        , prevBatch = prevBatch
                        , stateAtStart =
                            stateDelta
                                |> Maybe.withDefault StateManager.empty
                    }

         else
            case t.previous of
                Gap prevT ->
                    { t
                        | previous =
                            prevT
                                |> insertEvents data
                                |> Gap
                    }

                _ ->
                    t
        )


{-| Get the longest uninterrupted length of most recent events.
-}
localSize : Timeline -> Int
localSize =
    mostRecentEvents >> List.length


{-| Get a list of the most recent events recorded.
-}
mostRecentEvents : Timeline -> List IEvent
mostRecentEvents (Timeline t) =
    t.events


{-| Get the needed `since` parameter to get the latest events.
-}
nextSyncToken : Timeline -> String
nextSyncToken (Timeline t) =
    t.nextBatch


{-| Get the state of the room after the most recent event.
-}
mostRecentState : Timeline -> StateManager
mostRecentState (Timeline t) =
    t.stateAtStart
        |> StateManager.updateRoomStateWith
            (StateManager.fromEventList t.events)


{-| Get the timeline's room state at any given event. The function returns `Nothing` if the event is not found in the timeline.
-}
stateAtEvent : IEvent -> Timeline -> Maybe StateManager
stateAtEvent event (Timeline t) =
    if
        t.events
            |> List.map Event.eventId
            |> List.member (Event.eventId event)
    then
        Fold.untilCompleted
            List.foldl
            (\e ->
                StateManager.addEvent e
                    >> (if Event.eventId e == Event.eventId event then
                            Fold.AnswerWith

                        else
                            Fold.ContinueWith
                       )
            )
            t.stateAtStart
            t.events
            |> Just

    else
        case t.previous of
            Gap prevT ->
                stateAtEvent event prevT

            _ ->
                Nothing


{-| Count how many events the current timeline is storing.
-}
size : Timeline -> Int
size (Timeline t) =
    (case t.previous of
        Gap prev ->
            size prev

        _ ->
            0
    )
        + List.length t.events
