module Internal.Tools.Filters.SpecObjects exposing
    ( EventFilter
    , Filter
    , RoomEventFilter
    , RoomFilter
    , StateFilter
    , encodeEventFilter
    , encodeFilter
    , encodeRoomEventFilter
    , encodeRoomFilter
    , encodeStateFilter
    , eventFilterDecoder
    , filterDecoder
    , roomEventFilterDecoder
    , roomFilterDecoder
    , stateFilterDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1681915222

-}

import Internal.Tools.DecodeExtra as D exposing (opField, opFieldWithDefault)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Internal.Tools.SpecEnums as Enums
import Json.Decode as D
import Json.Encode as E


{-| Filter that describes which events to include/exclude.
-}
type alias EventFilter =
    { limit : Maybe Int
    , notSenders : Maybe (List String)
    , notTypes : Maybe (List String)
    , senders : Maybe (List String)
    , types : Maybe (List String)
    }


encodeEventFilter : EventFilter -> E.Value
encodeEventFilter data =
    maybeObject
        [ ( "limit", Maybe.map E.int data.limit )
        , ( "not_senders", Maybe.map (E.list E.string) data.notSenders )
        , ( "not_types", Maybe.map (E.list E.string) data.notTypes )
        , ( "senders", Maybe.map (E.list E.string) data.senders )
        , ( "types", Maybe.map (E.list E.string) data.types )
        ]


eventFilterDecoder : D.Decoder EventFilter
eventFilterDecoder =
    D.map5
        (\a b c d e ->
            { limit = a, notSenders = b, notTypes = c, senders = d, types = e }
        )
        (opField "limit" D.int)
        (opField "not_senders" (D.list D.string))
        (opField "not_types" (D.list D.string))
        (opField "senders" (D.list D.string))
        (opField "types" (D.list D.string))


{-| Main filter for filtering results
-}
type alias Filter =
    { accountData : Maybe EventFilter
    , eventFields : Maybe (List String)
    , eventFormat : Enums.EventFormat
    , presence : Maybe EventFilter
    , room : Maybe RoomFilter
    }


encodeFilter : Filter -> E.Value
encodeFilter data =
    maybeObject
        [ ( "account_data", Maybe.map encodeEventFilter data.accountData )
        , ( "event_fields", Maybe.map (E.list E.string) data.eventFields )
        , ( "event_format", Just <| Enums.encodeEventFormat data.eventFormat )
        , ( "presence", Maybe.map encodeEventFilter data.presence )
        , ( "room", Maybe.map encodeRoomFilter data.room )
        ]


filterDecoder : D.Decoder Filter
filterDecoder =
    D.map5
        (\a b c d e ->
            { accountData = a, eventFields = b, eventFormat = c, presence = d, room = e }
        )
        (opField "account_data" eventFilterDecoder)
        (opField "event_fields" (D.list D.string))
        (opFieldWithDefault "event_format" Enums.Client Enums.eventFormatDecoder)
        (opField "presence" eventFilterDecoder)
        (opField "room" roomFilterDecoder)


{-| Filter that describes which events to include/exclude in a Matrix room.
-}
type alias RoomEventFilter =
    { containsUrl : Maybe Bool
    , includeRedundantMembers : Bool
    , lazyLoadMembers : Bool
    , limit : Maybe Int
    , notRooms : Maybe (List String)
    , notSenders : Maybe (List String)
    , notTypes : Maybe (List String)
    , rooms : Maybe (List String)
    , senders : Maybe (List String)
    , types : Maybe (List String)
    , unreadThreadNotifications : Bool
    }


encodeRoomEventFilter : RoomEventFilter -> E.Value
encodeRoomEventFilter data =
    maybeObject
        [ ( "contains_url", Maybe.map E.bool data.containsUrl )
        , ( "include_redundant_members", Just <| E.bool data.includeRedundantMembers )
        , ( "lazy_load_members", Just <| E.bool data.lazyLoadMembers )
        , ( "limit", Maybe.map E.int data.limit )
        , ( "not_rooms", Maybe.map (E.list E.string) data.notRooms )
        , ( "not_senders", Maybe.map (E.list E.string) data.notSenders )
        , ( "not_types", Maybe.map (E.list E.string) data.notTypes )
        , ( "rooms", Maybe.map (E.list E.string) data.rooms )
        , ( "senders", Maybe.map (E.list E.string) data.senders )
        , ( "types", Maybe.map (E.list E.string) data.types )
        , ( "unread_thread_notifications", Just <| E.bool data.unreadThreadNotifications )
        ]


roomEventFilterDecoder : D.Decoder RoomEventFilter
roomEventFilterDecoder =
    D.map11
        (\a b c d e f g h i j k ->
            { containsUrl = a, includeRedundantMembers = b, lazyLoadMembers = c, limit = d, notRooms = e, notSenders = f, notTypes = g, rooms = h, senders = i, types = j, unreadThreadNotifications = k }
        )
        (opField "contains_url" D.bool)
        (opFieldWithDefault "include_redundant_members" False D.bool)
        (opFieldWithDefault "lazy_load_members" False D.bool)
        (opField "limit" D.int)
        (opField "not_rooms" (D.list D.string))
        (opField "not_senders" (D.list D.string))
        (opField "not_types" (D.list D.string))
        (opField "rooms" (D.list D.string))
        (opField "senders" (D.list D.string))
        (opField "types" (D.list D.string))
        (opFieldWithDefault "unread_thread_notifications" False D.bool)


{-| Filter that describes what should and shouldn't be included for rooms.
-}
type alias RoomFilter =
    { accountData : Maybe RoomEventFilter
    , ephemeral : Maybe RoomEventFilter
    , includeLeave : Bool
    , notRooms : Maybe (List String)
    , rooms : Maybe (List String)
    , state : Maybe StateFilter
    , timeline : Maybe RoomEventFilter
    }


encodeRoomFilter : RoomFilter -> E.Value
encodeRoomFilter data =
    maybeObject
        [ ( "account_data", Maybe.map encodeRoomEventFilter data.accountData )
        , ( "ephemeral", Maybe.map encodeRoomEventFilter data.ephemeral )
        , ( "include_leave", Just <| E.bool data.includeLeave )
        , ( "not_rooms", Maybe.map (E.list E.string) data.notRooms )
        , ( "rooms", Maybe.map (E.list E.string) data.rooms )
        , ( "state", Maybe.map encodeStateFilter data.state )
        , ( "timeline", Maybe.map encodeRoomEventFilter data.timeline )
        ]


roomFilterDecoder : D.Decoder RoomFilter
roomFilterDecoder =
    D.map7
        (\a b c d e f g ->
            { accountData = a, ephemeral = b, includeLeave = c, notRooms = d, rooms = e, state = f, timeline = g }
        )
        (opField "account_data" roomEventFilterDecoder)
        (opField "ephemeral" roomEventFilterDecoder)
        (opFieldWithDefault "include_leave" False D.bool)
        (opField "not_rooms" (D.list D.string))
        (opField "rooms" (D.list D.string))
        (opField "state" stateFilterDecoder)
        (opField "timeline" roomEventFilterDecoder)


{-| Filter that describes which events to include/exclude in a Matrix room.
-}
type alias StateFilter =
    { containsUrl : Maybe Bool
    , includeRedundantMembers : Bool
    , lazyLoadMembers : Bool
    , limit : Maybe Int
    , notRooms : Maybe (List String)
    , notSenders : Maybe (List String)
    , notTypes : Maybe (List String)
    , rooms : Maybe (List String)
    , senders : Maybe (List String)
    , types : Maybe (List String)
    , unreadThreadNotifications : Bool
    }


encodeStateFilter : StateFilter -> E.Value
encodeStateFilter data =
    maybeObject
        [ ( "contains_url", Maybe.map E.bool data.containsUrl )
        , ( "include_redundant_members", Just <| E.bool data.includeRedundantMembers )
        , ( "lazy_load_members", Just <| E.bool data.lazyLoadMembers )
        , ( "limit", Maybe.map E.int data.limit )
        , ( "not_rooms", Maybe.map (E.list E.string) data.notRooms )
        , ( "not_senders", Maybe.map (E.list E.string) data.notSenders )
        , ( "not_types", Maybe.map (E.list E.string) data.notTypes )
        , ( "rooms", Maybe.map (E.list E.string) data.rooms )
        , ( "senders", Maybe.map (E.list E.string) data.senders )
        , ( "types", Maybe.map (E.list E.string) data.types )
        , ( "unread_thread_notifications", Just <| E.bool data.unreadThreadNotifications )
        ]


stateFilterDecoder : D.Decoder StateFilter
stateFilterDecoder =
    D.map11
        (\a b c d e f g h i j k ->
            { containsUrl = a, includeRedundantMembers = b, lazyLoadMembers = c, limit = d, notRooms = e, notSenders = f, notTypes = g, rooms = h, senders = i, types = j, unreadThreadNotifications = k }
        )
        (opField "contains_url" D.bool)
        (opFieldWithDefault "include_redundant_members" False D.bool)
        (opFieldWithDefault "lazy_load_members" False D.bool)
        (opField "limit" D.int)
        (opField "not_rooms" (D.list D.string))
        (opField "not_senders" (D.list D.string))
        (opField "not_types" (D.list D.string))
        (opField "rooms" (D.list D.string))
        (opField "senders" (D.list D.string))
        (opField "types" (D.list D.string))
        (opFieldWithDefault "unread_thread_notifications" False D.bool)
