module Internal.Values.Timeline exposing (..)
{-| The Timeline can be very complex, and it can be represented in surprisingly
complex manners. This module aims to provide one single Timeline type that
accepts the complex pieces of information from the API and contain it all in
a simple way to view events.
-}

import FastDict as Dict exposing (Dict)
import Internal.Config.Leaking as Leaking
import Internal.Tools.Fold as Fold
import Internal.Values.Event as Event exposing (IEvent)
import Internal.Values.StateManager as StateManager exposing (StateManager)
import Internal.Tools.DefaultDict as DefaultDict exposing (DefaultDict)
import Internal.Tools.Hashdict as Hashdict exposing (Hashdict)
import Internal.Tools.Iddict as Iddict exposing (Iddict)
import Internal.Tools.Filters.Main as Filter exposing (Filter)
import Internal.Config.Leaking exposing (nextBatch)

{-| The Timeline is a comprehensive object describing a timeline in a room.

Any Timeline type contains the following pieces of information:

- `events` Comprehensive dictionary containing all locally stored timeline events
- `batches` Comprehensive dictionary containing all batches. Batches are pieces 
    of the timeline that have been sent by the homeserver.
- `token` Dictionary that maps for each batch token which batches it borders
- `mostRecentSync` Id of the most "recent" batch in the timeline
-}
type Timeline
    = Timeline
        { events : Hashdict IEvent
        , batches : Iddict TimelineBatch
        , token : DefaultDict String (List Int)
        , mostRecentSync : Maybe Int
        }

{-| A BatchToken is a token that has been handed out by the server to mark the end of a  -}
type alias BatchToken = String

type alias TimelineBatch =
    { prevBatch : List Batch
    , nextBatch : List Batch
    , filter : Filter
    , events : List String
    , stateDelta : StateManager
    }

type Batch
    = Token BatchToken
    | Batch Int

addNewSync :
    { events : List IEvent
    , filter : Filter
    , limited : Bool
    , nextBatch : String
    , prevBatch : String
    , stateDelta : Maybe StateManager
    } -> Timeline -> Timeline
addNewSync data (Timeline timeline) =
    let
        batchToInsert : TimelineBatch
        batchToInsert =
            { prevBatch = 
                [ Just <| Token data.prevBatch
                , Maybe.map Batch timeline.mostRecentSync
                ]
                    |> List.filterMap identity
            , nextBatch =
                [ Token data.nextBatch ]
            , filter = data.filter
            , events = List.map Event.eventId data.events
            , stateDelta = Maybe.withDefault StateManager.empty data.stateDelta
            }
    in
        case Iddict.insert batchToInsert timeline.batches of
            ( batchId, batches ) ->
                Timeline
                    { events = List.foldl Hashdict.insert timeline.events data.events
                    , batches = batches
                    , mostRecentSync = Just batchId
                    , token =
                        timeline.token
                            |> DefaultDict.update data.prevBatch
                                (\value ->
                                    case value of
                                        Just v ->
                                            Just (batchId :: v)
                                        Nothing ->
                                            Just [ batchId ]
                                )
                            |> DefaultDict.update data.nextBatch
                                (\value ->
                                    case value of
                                        Just v ->
                                            Just (batchId :: v)
                                        Nothing ->
                                            Just [ batchId ]
                                )
                    }

-- type Timeline
--     = Timeline
--         { prevBatch : String
--         , nextBatch : String
--         , events : List IEvent
--         , stateAtStart : StateManager
--         , previous : BeforeTimeline
--         }


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
    , prevBatch : Maybe String
    , stateDelta : Maybe StateManager
    }
    -> Timeline
    -> Timeline
insertEvents ({ events, nextBatch, prevBatch, stateDelta } as data) (Timeline t) =
    Timeline
        (case prevBatch of
            -- No prevbatch suggests the start of the timeline.
            -- This means that we must recurse until we've hit the bottom,
            -- and then mark the bottom of the timeline.
            Nothing ->
                case t.previous of
                    Gap prevT ->
                        { t
                            | previous =
                                prevT
                                    |> insertEvents data
                                    |> Gap
                        }

                    _ ->
                        if nextBatch == t.prevBatch then
                            { t | previous = StartOfTimeline, events = events ++ t.events, stateAtStart = StateManager.empty }

                        else
                            { t | previous = Gap <| newFromEvents data }

            -- If there is a prevbatch, it is not the start of the timeline
            -- and could be located anywhere.
            -- Starting at the front, look for a way to match it with the existing timeline.
            Just p ->
                -- Piece connects to the front of the timeline.
                if t.nextBatch == p then
                    { t
                        | events = t.events ++ events
                        , nextBatch = nextBatch
                    }
                    -- Piece connects to the back of the timeline.

                else if nextBatch == t.prevBatch then
                    case t.previous of
                        Gap (Timeline prevT) ->
                            -- Piece also connects to the timeline in the back,
                            -- allowing the two timelines to merge.
                            if prevT.nextBatch == p then
                                { events = prevT.events ++ events ++ t.events
                                , nextBatch = t.nextBatch
                                , prevBatch = prevT.prevBatch
                                , stateAtStart = prevT.stateAtStart
                                , previous = prevT.previous
                                }

                            else
                                { t
                                    | events = events ++ t.events
                                    , prevBatch = p
                                    , stateAtStart =
                                        stateDelta
                                            |> Maybe.withDefault StateManager.empty
                                }

                        Endless _ ->
                            { t
                                | events = events ++ t.events
                                , prevBatch = p
                                , stateAtStart =
                                    stateDelta
                                        |> Maybe.withDefault StateManager.empty
                                , previous = Endless p
                            }

                        _ ->
                            { t
                                | events = events ++ t.events
                                , prevBatch = p
                                , stateAtStart =
                                    stateDelta
                                        |> Maybe.withDefault StateManager.empty
                            }
                    -- Piece doesn't connect to this piece of the timeline.
                    -- Consequently, look for previous parts of the timeline to see if it connects.

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


{-| Get the width of the latest gap. This data is usually accessed when trying to get more messages.
-}
latestGap : Timeline -> Maybe { from : Maybe String, to : String }
latestGap (Timeline t) =
    case t.previous of
        StartOfTimeline ->
            Nothing

        Endless prevBatch ->
            Just { from = Nothing, to = prevBatch }

        Gap (Timeline pt) ->
            Just { from = Just pt.nextBatch, to = t.prevBatch }


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
