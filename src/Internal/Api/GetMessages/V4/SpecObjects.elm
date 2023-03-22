module Internal.Api.GetMessages.V4.SpecObjects exposing
    ( ClientEvent
    , MessagesResponse
    , UnsignedData(..)
    , clientEventDecoder
    , encodeClientEvent
    , encodeMessagesResponse
    , encodeUnsignedData
    , messagesResponseDecoder
    , unsignedDataDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1679486096

-}

import Internal.Tools.DecodeExtra exposing (opField, opFieldWithDefault)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Internal.Tools.Timestamp exposing (Timestamp, encodeTimestamp, timestampDecoder)
import Json.Decode as D
import Json.Encode as E


{-| An event gathered by running back through paginated chunks of a room.
-}
type alias ClientEvent =
    { content : E.Value
    , eventId : String
    , originServerTs : Timestamp
    , roomId : String
    , sender : String
    , stateKey : Maybe String
    , contentType : String
    , unsigned : Maybe UnsignedData
    }


encodeClientEvent : ClientEvent -> E.Value
encodeClientEvent data =
    maybeObject
        [ ( "content", Just <| data.content )
        , ( "event_id", Just <| E.string data.eventId )
        , ( "origin_server_ts", Just <| encodeTimestamp data.originServerTs )
        , ( "room_id", Just <| E.string data.roomId )
        , ( "sender", Just <| E.string data.sender )
        , ( "state_key", Maybe.map E.string data.stateKey )
        , ( "type", Just <| E.string data.contentType )
        , ( "unsigned", Maybe.map encodeUnsignedData data.unsigned )
        ]


clientEventDecoder : D.Decoder ClientEvent
clientEventDecoder =
    D.map8
        (\a b c d e f g h ->
            { content = a, eventId = b, originServerTs = c, roomId = d, sender = e, stateKey = f, contentType = g, unsigned = h }
        )
        (D.field "content" D.value)
        (D.field "event_id" D.string)
        (D.field "origin_server_ts" timestampDecoder)
        (D.field "room_id" D.string)
        (D.field "sender" D.string)
        (opField "state_key" D.string)
        (D.field "type" D.string)
        (opField "unsigned" (D.lazy (\_ -> unsignedDataDecoder)))


{-| Paginated response of requested messages.
-}
type alias MessagesResponse =
    { chunk : List ClientEvent
    , end : Maybe String
    , start : String
    , state : List ClientEvent
    }


encodeMessagesResponse : MessagesResponse -> E.Value
encodeMessagesResponse data =
    maybeObject
        [ ( "chunk", Just <| E.list encodeClientEvent data.chunk )
        , ( "end", Maybe.map E.string data.end )
        , ( "start", Just <| E.string data.start )
        , ( "state", Just <| E.list encodeClientEvent data.state )
        ]


messagesResponseDecoder : D.Decoder MessagesResponse
messagesResponseDecoder =
    D.map4
        (\a b c d ->
            { chunk = a, end = b, start = c, state = d }
        )
        (D.field "chunk" (D.list clientEventDecoder))
        (opField "end" D.string)
        (D.field "start" D.string)
        (opFieldWithDefault "state" [] (D.list clientEventDecoder))


{-| Extra information about an event that won't be signed by the homeserver.
-}
type UnsignedData
    = UnsignedData
        { age : Maybe Int
        , prevContent : Maybe E.Value
        , redactedBecause : Maybe ClientEvent
        , transactionId : Maybe String
        }


encodeUnsignedData : UnsignedData -> E.Value
encodeUnsignedData (UnsignedData data) =
    maybeObject
        [ ( "age", Maybe.map E.int data.age )
        , ( "prev_content", data.prevContent )
        , ( "redacted_because", Maybe.map encodeClientEvent data.redactedBecause )
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
        (opField "redacted_because" clientEventDecoder)
        (opField "transaction_id" D.string)
