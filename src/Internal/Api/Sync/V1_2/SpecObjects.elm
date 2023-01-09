module Internal.Api.Sync.V1_2.SpecObjects exposing
    ( AccountData
    , ClientEventWithoutRoomId
    , Ephemeral
    , Event
    , InviteState
    , InvitedRoom
    , JoinedRoom
    , KnockState
    , KnockedRoom
    , LeftRoom
    , Presence
    , RoomSummary
    , Rooms
    , State
    , StrippedStateEvent
    , Sync
    , Timeline
    , UnreadNotificationCounts
    , UnsignedData(..)
    , accountDataDecoder
    , clientEventWithoutRoomIdDecoder
    , encodeAccountData
    , encodeClientEventWithoutRoomId
    , encodeEphemeral
    , encodeEvent
    , encodeInviteState
    , encodeInvitedRoom
    , encodeJoinedRoom
    , encodeKnockState
    , encodeKnockedRoom
    , encodeLeftRoom
    , encodePresence
    , encodeRoomSummary
    , encodeRooms
    , encodeState
    , encodeStrippedStateEvent
    , encodeSync
    , encodeTimeline
    , encodeUnreadNotificationCounts
    , encodeUnsignedData
    , ephemeralDecoder
    , eventDecoder
    , inviteStateDecoder
    , invitedRoomDecoder
    , joinedRoomDecoder
    , knockStateDecoder
    , knockedRoomDecoder
    , leftRoomDecoder
    , presenceDecoder
    , roomSummaryDecoder
    , roomsDecoder
    , stateDecoder
    , strippedStateEventDecoder
    , syncDecoder
    , timelineDecoder
    , unreadNotificationCountsDecoder
    , unsignedDataDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1673279712

-}

import Dict exposing (Dict)
import Internal.Tools.DecodeExtra exposing (opField, opFieldWithDefault)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Internal.Tools.Timestamp exposing (Timestamp, encodeTimestamp, timestampDecoder)
import Json.Decode as D
import Json.Encode as E


{-| The private data created by this user in a given context.
-}
type alias AccountData =
    { events : List Event
    }


encodeAccountData : AccountData -> E.Value
encodeAccountData data =
    maybeObject
        [ ( "events", Just <| E.list encodeEvent data.events )
        ]


accountDataDecoder : D.Decoder AccountData
accountDataDecoder =
    D.map
        (\a ->
            { events = a }
        )
        (opFieldWithDefault "events" [] (D.list eventDecoder))


{-| Client event that has all data except the room id.
-}
type alias ClientEventWithoutRoomId =
    { content : E.Value
    , eventId : String
    , originServerTs : Timestamp
    , sender : String
    , stateKey : Maybe String
    , contentType : String
    , unsigned : Maybe UnsignedData
    }


encodeClientEventWithoutRoomId : ClientEventWithoutRoomId -> E.Value
encodeClientEventWithoutRoomId data =
    maybeObject
        [ ( "content", Just <| data.content )
        , ( "event_id", Just <| E.string data.eventId )
        , ( "origin_server_ts", Just <| encodeTimestamp data.originServerTs )
        , ( "sender", Just <| E.string data.sender )
        , ( "state_key", Maybe.map E.string data.stateKey )
        , ( "type", Just <| E.string data.contentType )
        , ( "unsigned", Maybe.map encodeUnsignedData data.unsigned )
        ]


clientEventWithoutRoomIdDecoder : D.Decoder ClientEventWithoutRoomId
clientEventWithoutRoomIdDecoder =
    D.map7
        (\a b c d e f g ->
            { content = a, eventId = b, originServerTs = c, sender = d, stateKey = e, contentType = f, unsigned = g }
        )
        (D.field "content" D.value)
        (D.field "event_id" D.string)
        (D.field "origin_server_ts" timestampDecoder)
        (D.field "sender" D.string)
        (opField "state_key" D.string)
        (D.field "type" D.string)
        (opField "unsigned" (D.lazy (\_ -> unsignedDataDecoder)))


{-| Ephemeral events in a room that aren't recorded in the timeline or the room state.
-}
type alias Ephemeral =
    { events : List Event
    }


encodeEphemeral : Ephemeral -> E.Value
encodeEphemeral data =
    maybeObject
        [ ( "events", Just <| E.list encodeEvent data.events )
        ]


ephemeralDecoder : D.Decoder Ephemeral
ephemeralDecoder =
    D.map
        (\a ->
            { events = a }
        )
        (opFieldWithDefault "events" [] (D.list eventDecoder))


{-| A blind event that does not give context about itself.
-}
type alias Event =
    { content : E.Value
    , contentType : String
    }


encodeEvent : Event -> E.Value
encodeEvent data =
    maybeObject
        [ ( "content", Just <| data.content )
        , ( "type", Just <| E.string data.contentType )
        ]


eventDecoder : D.Decoder Event
eventDecoder =
    D.map2
        (\a b ->
            { content = a, contentType = b }
        )
        (D.field "content" D.value)
        (D.field "type" D.string)


{-| Room that the user has been invited to.
-}
type alias InvitedRoom =
    { inviteState : Maybe InviteState
    }


encodeInvitedRoom : InvitedRoom -> E.Value
encodeInvitedRoom data =
    maybeObject
        [ ( "invite_state", Maybe.map encodeInviteState data.inviteState )
        ]


invitedRoomDecoder : D.Decoder InvitedRoom
invitedRoomDecoder =
    D.map
        (\a ->
            { inviteState = a }
        )
        (opField "invite_state" inviteStateDecoder)


{-| The state of a room that the user has been invited to.
-}
type alias InviteState =
    { events : List StrippedStateEvent
    }


encodeInviteState : InviteState -> E.Value
encodeInviteState data =
    maybeObject
        [ ( "events", Just <| E.list encodeStrippedStateEvent data.events )
        ]


inviteStateDecoder : D.Decoder InviteState
inviteStateDecoder =
    D.map
        (\a ->
            { events = a }
        )
        (opFieldWithDefault "events" [] (D.list strippedStateEventDecoder))


{-| Room that the user has joined.
-}
type alias JoinedRoom =
    { accountData : Maybe AccountData
    , ephemeral : Maybe Ephemeral
    , state : Maybe State
    , summary : Maybe RoomSummary
    , timeline : Maybe Timeline
    , unreadNotifications : Maybe UnreadNotificationCounts
    }


encodeJoinedRoom : JoinedRoom -> E.Value
encodeJoinedRoom data =
    maybeObject
        [ ( "account_data", Maybe.map encodeAccountData data.accountData )
        , ( "ephemeral", Maybe.map encodeEphemeral data.ephemeral )
        , ( "state", Maybe.map encodeState data.state )
        , ( "summary", Maybe.map encodeRoomSummary data.summary )
        , ( "timeline", Maybe.map encodeTimeline data.timeline )
        , ( "unread_notifications", Maybe.map encodeUnreadNotificationCounts data.unreadNotifications )
        ]


joinedRoomDecoder : D.Decoder JoinedRoom
joinedRoomDecoder =
    D.map6
        (\a b c d e f ->
            { accountData = a, ephemeral = b, state = c, summary = d, timeline = e, unreadNotifications = f }
        )
        (opField "account_data" accountDataDecoder)
        (opField "ephemeral" ephemeralDecoder)
        (opField "state" stateDecoder)
        (opField "summary" roomSummaryDecoder)
        (opField "timeline" timelineDecoder)
        (opField "unread_notifications" unreadNotificationCountsDecoder)


{-| Room that the user has knocked upon.
-}
type alias KnockedRoom =
    { knockState : Maybe KnockState
    }


encodeKnockedRoom : KnockedRoom -> E.Value
encodeKnockedRoom data =
    maybeObject
        [ ( "knock_state", Maybe.map encodeKnockState data.knockState )
        ]


knockedRoomDecoder : D.Decoder KnockedRoom
knockedRoomDecoder =
    D.map
        (\a ->
            { knockState = a }
        )
        (opField "knock_state" knockStateDecoder)


{-| The state of a room that the user has knocked upon.
-}
type alias KnockState =
    { events : List StrippedStateEvent
    }


encodeKnockState : KnockState -> E.Value
encodeKnockState data =
    maybeObject
        [ ( "events", Just <| E.list encodeStrippedStateEvent data.events )
        ]


knockStateDecoder : D.Decoder KnockState
knockStateDecoder =
    D.map
        (\a ->
            { events = a }
        )
        (opFieldWithDefault "events" [] (D.list strippedStateEventDecoder))


{-| Room that the user has left.
-}
type alias LeftRoom =
    { accountData : Maybe AccountData
    , state : Maybe State
    , timeline : Maybe Timeline
    }


encodeLeftRoom : LeftRoom -> E.Value
encodeLeftRoom data =
    maybeObject
        [ ( "account_data", Maybe.map encodeAccountData data.accountData )
        , ( "state", Maybe.map encodeState data.state )
        , ( "timeline", Maybe.map encodeTimeline data.timeline )
        ]


leftRoomDecoder : D.Decoder LeftRoom
leftRoomDecoder =
    D.map3
        (\a b c ->
            { accountData = a, state = b, timeline = c }
        )
        (opField "account_data" accountDataDecoder)
        (opField "state" stateDecoder)
        (opField "timeline" timelineDecoder)


{-| The updates to the presence status of other users.
-}
type alias Presence =
    { events : List Event
    }


encodePresence : Presence -> E.Value
encodePresence data =
    maybeObject
        [ ( "events", Just <| E.list encodeEvent data.events )
        ]


presenceDecoder : D.Decoder Presence
presenceDecoder =
    D.map
        (\a ->
            { events = a }
        )
        (opFieldWithDefault "events" [] (D.list eventDecoder))


{-| Updates to rooms.
-}
type alias Rooms =
    { invite : Dict String InvitedRoom
    , join : Dict String JoinedRoom
    , knock : Dict String KnockedRoom
    , leave : Dict String LeftRoom
    }


encodeRooms : Rooms -> E.Value
encodeRooms data =
    maybeObject
        [ ( "invite", Just <| E.dict identity encodeInvitedRoom data.invite )
        , ( "join", Just <| E.dict identity encodeJoinedRoom data.join )
        , ( "knock", Just <| E.dict identity encodeKnockedRoom data.knock )
        , ( "leave", Just <| E.dict identity encodeLeftRoom data.leave )
        ]


roomsDecoder : D.Decoder Rooms
roomsDecoder =
    D.map4
        (\a b c d ->
            { invite = a, join = b, knock = c, leave = d }
        )
        (opFieldWithDefault "invite" Dict.empty (D.dict invitedRoomDecoder))
        (opFieldWithDefault "join" Dict.empty (D.dict joinedRoomDecoder))
        (opFieldWithDefault "knock" Dict.empty (D.dict knockedRoomDecoder))
        (opFieldWithDefault "leave" Dict.empty (D.dict leftRoomDecoder))


{-| Information about a room which clients may need to correctly render it to users.
-}
type alias RoomSummary =
    { mHeroes : Maybe (List String)
    , mInvitedMemberCount : Maybe Int
    , mJoinedMemberCount : Maybe Int
    }


encodeRoomSummary : RoomSummary -> E.Value
encodeRoomSummary data =
    maybeObject
        [ ( "m.heroes", Maybe.map (E.list E.string) data.mHeroes )
        , ( "m.invited_member_count", Maybe.map E.int data.mInvitedMemberCount )
        , ( "m.joined_member_count", Maybe.map E.int data.mJoinedMemberCount )
        ]


roomSummaryDecoder : D.Decoder RoomSummary
roomSummaryDecoder =
    D.map3
        (\a b c ->
            { mHeroes = a, mInvitedMemberCount = b, mJoinedMemberCount = c }
        )
        (opField "m.heroes" (D.list D.string))
        (opField "m.invited_member_count" D.int)
        (opField "m.joined_member_count" D.int)


{-| Updates to the state of a room.
-}
type alias State =
    { events : List ClientEventWithoutRoomId
    }


encodeState : State -> E.Value
encodeState data =
    maybeObject
        [ ( "events", Just <| E.list encodeClientEventWithoutRoomId data.events )
        ]


stateDecoder : D.Decoder State
stateDecoder =
    D.map
        (\a ->
            { events = a }
        )
        (opFieldWithDefault "events" [] (D.list clientEventWithoutRoomIdDecoder))


{-| Stripped state events of a room that the user has limited access to.
-}
type alias StrippedStateEvent =
    { content : E.Value
    , sender : String
    , stateKey : String
    , contentType : String
    }


encodeStrippedStateEvent : StrippedStateEvent -> E.Value
encodeStrippedStateEvent data =
    maybeObject
        [ ( "content", Just <| data.content )
        , ( "sender", Just <| E.string data.sender )
        , ( "state_key", Just <| E.string data.stateKey )
        , ( "type", Just <| E.string data.contentType )
        ]


strippedStateEventDecoder : D.Decoder StrippedStateEvent
strippedStateEventDecoder =
    D.map4
        (\a b c d ->
            { content = a, sender = b, stateKey = c, contentType = d }
        )
        (D.field "content" D.value)
        (D.field "sender" D.string)
        (D.field "state_key" D.string)
        (D.field "type" D.string)


{-| The sync response the homeserver sends to the user.
-}
type alias Sync =
    { accountData : Maybe AccountData
    , nextBatch : String
    , presence : Maybe Presence
    , rooms : Maybe Rooms
    }


encodeSync : Sync -> E.Value
encodeSync data =
    maybeObject
        [ ( "account_data", Maybe.map encodeAccountData data.accountData )
        , ( "next_batch", Just <| E.string data.nextBatch )
        , ( "presence", Maybe.map encodePresence data.presence )
        , ( "rooms", Maybe.map encodeRooms data.rooms )
        ]


syncDecoder : D.Decoder Sync
syncDecoder =
    D.map4
        (\a b c d ->
            { accountData = a, nextBatch = b, presence = c, rooms = d }
        )
        (opField "account_data" accountDataDecoder)
        (D.field "next_batch" D.string)
        (opField "presence" presenceDecoder)
        (opField "rooms" roomsDecoder)


{-| The timeline of messages and state changes in a room.
-}
type alias Timeline =
    { events : List ClientEventWithoutRoomId
    , limited : Bool
    , prevBatch : Maybe String
    }


encodeTimeline : Timeline -> E.Value
encodeTimeline data =
    maybeObject
        [ ( "events", Just <| E.list encodeClientEventWithoutRoomId data.events )
        , ( "limited", Just <| E.bool data.limited )
        , ( "prev_batch", Maybe.map E.string data.prevBatch )
        ]


timelineDecoder : D.Decoder Timeline
timelineDecoder =
    D.map3
        (\a b c ->
            { events = a, limited = b, prevBatch = c }
        )
        (opFieldWithDefault "events" [] (D.list clientEventWithoutRoomIdDecoder))
        (opFieldWithDefault "limited" False D.bool)
        (opField "prev_batch" D.string)


{-| Counts of unread notifications for this room.
-}
type alias UnreadNotificationCounts =
    { highlightCount : Maybe Int
    , notificationCount : Maybe Int
    }


encodeUnreadNotificationCounts : UnreadNotificationCounts -> E.Value
encodeUnreadNotificationCounts data =
    maybeObject
        [ ( "highlight_count", Maybe.map E.int data.highlightCount )
        , ( "notification_count", Maybe.map E.int data.notificationCount )
        ]


unreadNotificationCountsDecoder : D.Decoder UnreadNotificationCounts
unreadNotificationCountsDecoder =
    D.map2
        (\a b ->
            { highlightCount = a, notificationCount = b }
        )
        (opField "highlight_count" D.int)
        (opField "notification_count" D.int)


{-| Data that isn't getting signed for Canonical JSON.
-}
type UnsignedData
    = UnsignedData
        { age : Maybe Int
        , prevContent : Maybe E.Value
        , redactedBecause : Maybe ClientEventWithoutRoomId
        , transactionId : Maybe String
        }


encodeUnsignedData : UnsignedData -> E.Value
encodeUnsignedData (UnsignedData data) =
    maybeObject
        [ ( "age", Maybe.map E.int data.age )
        , ( "prev_content", data.prevContent )
        , ( "redacted_because", Maybe.map encodeClientEventWithoutRoomId data.redactedBecause )
        , ( "transaction_id", Maybe.map E.string data.transactionId )
        ]


unsignedDataDecoder : D.Decoder UnsignedData
unsignedDataDecoder =
    D.map4
        (\a b c d ->
            UnsignedData { age = a, prevContent = b, redactedBecause = c, transactionId = d }
        )
        (opField "age" D.int)
        (opField "prev_content" D.value)
        (opField "redacted_because" clientEventWithoutRoomIdDecoder)
        (opField "transaction_id" D.string)
