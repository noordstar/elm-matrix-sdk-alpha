module Internal.Tools.Filters.Filter exposing (..)

import Internal.Tools.Filters.SpecObjects as SO
import Internal.Tools.Filters.SimpleFilter as SF exposing (SimpleFilter)
import Internal.Tools.SpecEnums as Enums

{-| Event filters tell the API what events to look for, 
but specifically for events that are unrelated to any room.
-}
type EventFilter
    = EventFilter
        { limit : Maybe Int
        , senders : SimpleFilter String
        , types : SimpleFilter String
        }

{-| The final type dictates how everything else behaves.
-}
type Filter =
    Filter
        { accountData : EventFilter
        , presence : EventFilter
        , room : RoomFilter
        }

{-| RoomFilter types tell the API what is considered relevant in a room, 
and which rooms to include.
-}
type RoomFilter
    = RoomFilter
        { accountData : RoomEventFilter
        , ephemeral : RoomEventFilter
        , rooms : SimpleFilter String
        , timeline : RoomEventFilter
        }

{-| RoomEventFilter types tell the API what events to look for, 
and what ones to ignore.
-}
type RoomEventFilter
    = RoomEventFilter
        { lazyLoadMembers : Bool
        , limit : Maybe Int
        , rooms : SimpleFilter String
        , senders : SimpleFilter String
        , types : SimpleFilter String
        }

allEvents : EventFilter
allEvents =
    EventFilter
        { limit = Nothing
        , senders = SF.all
        , types = SF.all
        }

allFilters : Filter
allFilters =
    Filter
        { accountData = allEvents
        , presence = allEvents
        , room = allRooms
        }

allRooms : RoomFilter
allRooms =
    RoomFilter
        { accountData = allRoomEvents
        , ephemeral = allRoomEvents
        , rooms = SF.all
        , timeline = allRoomEvents
        }

allRoomEvents : RoomEventFilter
allRoomEvents =
    RoomEventFilter
        { lazyLoadMembers = False
        , limit = Nothing
        , rooms = SF.all
        , senders = SF.all
        , types = SF.all
        }

decodeEventFilter : SO.EventFilter -> EventFilter
decodeEventFilter data =
    EventFilter
        { limit = data.limit
        , senders = SF.toSimpleFilter data.senders data.notSenders
        , types = SF.toSimpleFilter data.types data.notTypes
        }

decodeFilter : SO.Filter -> Filter
decodeFilter data =
    Filter
        { accountData =
            data.accountData
                |> Maybe.map decodeEventFilter
                |> Maybe.withDefault allEvents
        , presence =
            data.presence
                |> Maybe.map decodeEventFilter
                |> Maybe.withDefault allEvents
        , room =
            data.room
                |> Maybe.map decodeRoomFilter
                |> Maybe.withDefault allRooms
        }

{-| Decode a RoomFilter from a spec-compliant format.
-}
decodeRoomFilter : SO.RoomFilter -> RoomFilter
decodeRoomFilter data =
    let
        decodeREF : Maybe SO.RoomEventFilter -> RoomEventFilter
        decodeREF =
            Maybe.map decodeRoomEventFilter >> Maybe.withDefault allRoomEvents
    in
        RoomFilter
            { accountData = decodeREF data.accountData
            , ephemeral = decodeREF data.ephemeral
            , rooms = SF.toSimpleFilter data.rooms data.notRooms
            , timeline = decodeREF data.timeline
            }

{-| Decode a RoomEventFilter from a spec-compliant format.
-}
decodeRoomEventFilter : SO.RoomEventFilter -> RoomEventFilter
decodeRoomEventFilter data =
    RoomEventFilter
        { lazyLoadMembers = data.lazyLoadMembers
        , limit = data.limit
        , rooms = SF.toSimpleFilter data.rooms data.notRooms
        , senders = SF.toSimpleFilter data.senders data.notSenders
        , types = SF.toSimpleFilter data.types data.notTypes
        }

{-| Encode an EventFilter into a spec-compliant format.
-}
encodeEventFilter : EventFilter -> SO.EventFilter
encodeEventFilter (EventFilter data) =
    { limit = data.limit
    , notSenders = SF.toExclude data.senders
    , notTypes = SF.toExclude data.types
    , senders = SF.toInclude data.senders
    , types = SF.toInclude data.types
    }

{-| Encode a Filter into a spec-compliant format.
-}
encodeFilter : Filter -> SO.Filter
encodeFilter (Filter data) =
    { accountData = Just <| encodeEventFilter data.accountData
    , eventFields = Nothing
    , eventFormat = Enums.Client
    , presence = Just <| encodeEventFilter data.presence
    , room = Just <| encodeRoomFilter data.room
    }

{-| Encode a RoomFilter into a spec-compliant format.
-}
encodeRoomFilter : RoomFilter -> SO.RoomFilter
encodeRoomFilter (RoomFilter data) =
    { accountData = Just <| encodeRoomEventFilter data.accountData
    , ephemeral = Just <| encodeRoomEventFilter data.ephemeral
    , includeLeave = False
    , notRooms = SF.toExclude data.rooms
    , rooms = SF.toInclude data.rooms
    , state = Just <| encodeRoomEventFilter data.timeline
    , timeline = Just <| encodeRoomEventFilter data.timeline
    }

{-| Encode a RoomEventFilter into a spec-compliant format.
-}
encodeRoomEventFilter : RoomEventFilter -> SO.RoomEventFilter
encodeRoomEventFilter (RoomEventFilter data) =
    { containsUrl = Nothing
    , includeRedundantMembers = False
    , lazyLoadMembers = data.lazyLoadMembers
    , limit = data.limit
    , notRooms = SF.toExclude data.rooms
    , notSenders = SF.toExclude data.senders
    , notTypes = SF.toExclude data.types
    , rooms = SF.toInclude data.rooms
    , senders = SF.toInclude data.senders
    , types = SF.toInclude data.types
    , unreadThreadNotifications = True
    }

{-| Flatten a filter.
-}
flattenFilter : Filter -> List (SimpleFilter String)
flattenFilter (Filter f) =
    List.concat
        [ flattenEventFilter f.accountData
        , flattenEventFilter f.presence
        , flattenRoomFilter f.room
        ]

{-| Flatten a EventFilter.
-}
flattenEventFilter : EventFilter -> List (SimpleFilter String)
flattenEventFilter (EventFilter f) = [ f.senders, f.types ]

{-| Flatten a RoomFilter.
-}
flattenRoomFilter : RoomFilter -> List (SimpleFilter String)
flattenRoomFilter (RoomFilter f) =
    [ f.accountData, f.ephemeral, f.timeline ]
        |> List.map flattenRoomEventFilter
        |> List.concat
        |> (::) f.rooms

{-| Flatten a RoomEventFilter.
-}
flattenRoomEventFilter : RoomEventFilter -> List (SimpleFilter String)
flattenRoomEventFilter (RoomEventFilter f) = [ f.rooms, f.senders, f.types ]

{-| Get an intersection of a Filter.
-}
intersectFilter : Filter -> Filter -> Filter
intersectFilter (Filter f1) (Filter f2) =
    Filter
        { accountData = intersectEventFilter f1.accountData f2.accountData
        , presence = intersectEventFilter f1.presence f2.presence
        , room = intersectRoomFilter f1.room f2.room
        }

{-| Get an intersection of a EventFilter.
-}
intersectEventFilter : EventFilter -> EventFilter -> EventFilter
intersectEventFilter (EventFilter f1) (EventFilter f2) =
    EventFilter
        { limit =
            case (f1.limit, f2.limit) of
                (Just l1, Just l2) ->
                    Just (max l1 l2)
                
                (Just _, Nothing) ->
                    f1.limit
                
                (Nothing, Just _) ->
                    f2.limit
                
                (Nothing, Nothing) ->
                    Nothing
        , senders = SF.intersect f1.senders f2.senders
        , types = SF.intersect f1.types f2.types
        }

{-| Get an intersection of a RoomFilter.
-}
intersectRoomFilter : RoomFilter -> RoomFilter -> RoomFilter
intersectRoomFilter (RoomFilter f1) (RoomFilter f2) =
    RoomFilter
        { accountData = intersectRoomEventFilter f1.accountData f2.accountData
        , ephemeral = intersectRoomEventFilter f1.ephemeral f2.ephemeral
        , rooms = SF.intersect f1.rooms f2.rooms
        , timeline = intersectRoomEventFilter f1.timeline f2.timeline
        }

{-| Get an intersection of a RoomEventFilter.
-}
intersectRoomEventFilter : RoomEventFilter -> RoomEventFilter -> RoomEventFilter
intersectRoomEventFilter (RoomEventFilter f1) (RoomEventFilter f2) =
    RoomEventFilter
        { lazyLoadMembers = f1.lazyLoadMembers && f2.lazyLoadMembers
        , limit =
            case (f1.limit, f2.limit) of
                (Just l1, Just l2) ->
                    Just (max l1 l2)
                
                (Just _, Nothing) ->
                    f1.limit
                
                (Nothing, Just _) ->
                    f2.limit
                
                (Nothing, Nothing) ->
                    Nothing
        , rooms = SF.intersect f1.rooms f2.rooms
        , senders = SF.intersect f1.senders f2.senders
        , types = SF.intersect f1.types f2.types
        }

{-| Check whether a filter is a subset of another filter.
-}
isSubSet : Filter -> Filter -> Bool
isSubSet f1 f2 =
    let
        isSame : List (SimpleFilter String) -> List (SimpleFilter String) -> Bool
        isSame l1 l2 =
            case (l1, l2) of
                (h1 :: t1, h2 :: t2) ->
                    SF.subset h1 h2 && isSame t1 t2
                ([], []) ->
                    True
                _ ->
                    False
    in
        isSame (flattenFilter f1) (flattenFilter f2)

lazyLoadMembers : Bool -> RoomEventFilter -> RoomEventFilter
lazyLoadMembers b (RoomEventFilter data) =
    RoomEventFilter { data | lazyLoadMembers = b }

{-| Determine a limit for the amount of events. If no limit is given, the homeserver decides this limit for itself.
-}
setEventLimit : Maybe Int -> RoomEventFilter -> RoomEventFilter
setEventLimit i (RoomEventFilter data) =
    RoomEventFilter { data | limit = i }

{-| Include a specific event type.
-}
withEventType : String -> RoomEventFilter -> RoomEventFilter
withEventType x (RoomEventFilter ({ types } as data)) =
    RoomEventFilter { data | types = SF.with x types }

{-| Include all event types that haven't been explicitly mentioned.
-}
withOtherEventTypes : RoomEventFilter -> RoomEventFilter
withOtherEventTypes (RoomEventFilter ({ types } as data)) =
    RoomEventFilter { data | types = SF.withOthers types }

{-| Include all rooms that haven't been explicitly mentioned.
-}
withOtherRooms : RoomEventFilter -> RoomEventFilter
withOtherRooms (RoomEventFilter ({ rooms } as data)) =
    RoomEventFilter { data | rooms = SF.withOthers rooms }

{-| Include all senders that haven't been explicitly mentioned.
-}
withOtherSenders : RoomEventFilter -> RoomEventFilter
withOtherSenders (RoomEventFilter ({ senders } as data)) =
    RoomEventFilter { data | senders = SF.withOthers senders }

{-| Include a specific room.
-}
withRoom : String -> RoomEventFilter -> RoomEventFilter
withRoom x (RoomEventFilter ({ rooms } as data)) =
    RoomEventFilter { data | rooms = SF.with x rooms }

{-| Include a specific sender.
-}
withSender : String -> RoomEventFilter -> RoomEventFilter
withSender x (RoomEventFilter ({ senders } as data)) =
    RoomEventFilter { data | senders = SF.with x senders }

{-| Ignore a specific event type.
-}
withoutEventType : String -> RoomEventFilter -> RoomEventFilter
withoutEventType x (RoomEventFilter ({ types } as data)) =
    RoomEventFilter { data | types = SF.without x types }

{-| Ignore all rooms that haven't been explicitly mentioned.
-}
withoutOtherEventTypes : RoomEventFilter -> RoomEventFilter
withoutOtherEventTypes (RoomEventFilter ({ types } as data)) =
    RoomEventFilter { data | types = SF.withoutOthers types }

{-| Ignore all rooms that haven't been explicitly mentioned.
-}
withoutOtherRooms : RoomEventFilter -> RoomEventFilter
withoutOtherRooms (RoomEventFilter ({ rooms } as data)) =
    RoomEventFilter { data | rooms = SF.withoutOthers rooms }

{-| Ignore all senders that haven't been explicitly mentioned.
-}
withoutOtherSenders : RoomEventFilter -> RoomEventFilter
withoutOtherSenders (RoomEventFilter ({ senders } as data)) =
    RoomEventFilter { data | senders = SF.withoutOthers senders }

{-| Ignore a specific room.
-}
withoutRoom : String -> RoomEventFilter -> RoomEventFilter
withoutRoom x (RoomEventFilter ({ rooms } as data)) =
    RoomEventFilter { data | rooms = SF.without x rooms }

{-| Ignore a specific sender.
-}
withoutSender : String -> RoomEventFilter -> RoomEventFilter
withoutSender x (RoomEventFilter ({ senders } as data)) =
    RoomEventFilter { data | senders = SF.without x senders }


