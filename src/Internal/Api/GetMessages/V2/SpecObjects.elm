module Internal.Api.GetMessages.V2.SpecObjects exposing
    ( MessagesResponse
    , RoomEvent
    , UnsignedData(..)
    , encodeMessagesResponse
    , encodeRoomEvent
    , encodeUnsignedData
    , messagesResponseDecoder
    , roomEventDecoder
    , unsignedDataDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1680263083

-}

import Internal.Tools.DecodeExtra as D exposing (opField, opFieldWithDefault)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Internal.Tools.Timestamp exposing (Timestamp, encodeTimestamp, timestampDecoder)
import Json.Decode as D
import Json.Encode as E


{-| Paginated response of requested messages.
-}
type alias MessagesResponse =
    { chunk : List RoomEvent
    , end : Maybe String
    , start : String
    }


encodeMessagesResponse : MessagesResponse -> E.Value
encodeMessagesResponse data =
    maybeObject
        [ ( "chunk", Just <| E.list encodeRoomEvent data.chunk )
        , ( "end", Maybe.map E.string data.end )
        , ( "start", Just <| E.string data.start )
        ]


messagesResponseDecoder : D.Decoder MessagesResponse
messagesResponseDecoder =
    D.map3
        (\a b c ->
            { chunk = a, end = b, start = c }
        )
        (opFieldWithDefault "chunk" [] (D.list roomEventDecoder))
        (opField "end" D.string)
        (D.field "start" D.string)


{-| An event gathered by running back through paginated chunks of a room.
-}
type alias RoomEvent =
    { content : E.Value
    , eventId : String
    , originServerTs : Timestamp
    , prevContent : Maybe E.Value
    , roomId : String
    , sender : String
    , stateKey : Maybe String
    , eventType : String
    , unsigned : Maybe UnsignedData
    }


encodeRoomEvent : RoomEvent -> E.Value
encodeRoomEvent data =
    maybeObject
        [ ( "content", Just <| data.content )
        , ( "event_id", Just <| E.string data.eventId )
        , ( "origin_server_ts", Just <| encodeTimestamp data.originServerTs )
        , ( "prev_content", Nothing )
        , ( "room_id", Just <| E.string data.roomId )
        , ( "sender", Just <| E.string data.sender )
        , ( "state_key", Maybe.map E.string data.stateKey )
        , ( "type", Just <| E.string data.eventType )
        , ( "unsigned", Maybe.map encodeUnsignedData data.unsigned )
        ]


roomEventDecoder : D.Decoder RoomEvent
roomEventDecoder =
    D.map9
        (\a b c d e f g h i ->
            { content = a, eventId = b, originServerTs = c, prevContent = d, roomId = e, sender = f, stateKey = g, eventType = h, unsigned = i }
        )
        (D.field "content" D.value)
        (D.field "event_id" D.string)
        (D.field "origin_server_ts" timestampDecoder)
        (D.succeed Nothing)
        (D.field "room_id" D.string)
        (D.field "sender" D.string)
        (opField "state_key" D.string)
        (D.field "type" D.string)
        (opField "unsigned" (D.lazy (\_ -> unsignedDataDecoder)))


{-| Extra information about an event that won't be signed by the homeserver.
-}
type UnsignedData
    = UnsignedData
        { age : Maybe Int
        , redactedBecause : Maybe RoomEvent
        , transactionId : Maybe String
        }


encodeUnsignedData : UnsignedData -> E.Value
encodeUnsignedData (UnsignedData data) =
    maybeObject
        [ ( "age", Maybe.map E.int data.age )
        , ( "redacted_because", Maybe.map encodeRoomEvent data.redactedBecause )
        , ( "transaction_id", Maybe.map E.string data.transactionId )
        ]


unsignedDataDecoder : D.Decoder UnsignedData
unsignedDataDecoder =
    D.map3
        (\a b c ->
            UnsignedData { age = a, redactedBecause = b, transactionId = c }
        )
        (opField "age" D.int)
        (opField "redacted_because" roomEventDecoder)
        (opField "transaction_id" D.string)
