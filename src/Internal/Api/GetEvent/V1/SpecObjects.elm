module Internal.Api.GetEvent.V1.SpecObjects exposing
    ( ClientEvent
    , UnsignedData(..)
    , clientEventDecoder
    , encodeClientEvent
    , encodeUnsignedData
    , unsignedDataDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1680263083

-}

import Internal.Tools.DecodeExtra exposing (opField)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Internal.Tools.Timestamp exposing (Timestamp, encodeTimestamp, timestampDecoder)
import Json.Decode as D
import Json.Encode as E


{-| Client Event containing all data on an event.
-}
type alias ClientEvent =
    { content : E.Value
    , eventId : String
    , originServerTs : Timestamp
    , roomId : String
    , sender : String
    , stateKey : Maybe String
    , eventType : String
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
        , ( "type", Just <| E.string data.eventType )
        , ( "unsigned", Maybe.map encodeUnsignedData data.unsigned )
        ]


clientEventDecoder : D.Decoder ClientEvent
clientEventDecoder =
    D.map8
        (\a b c d e f g h ->
            { content = a, eventId = b, originServerTs = c, roomId = d, sender = e, stateKey = f, eventType = g, unsigned = h }
        )
        (D.field "content" D.value)
        (D.field "event_id" D.string)
        (D.field "origin_server_ts" timestampDecoder)
        (D.field "room_id" D.string)
        (D.field "sender" D.string)
        (opField "state_key" D.string)
        (D.field "type" D.string)
        (opField "unsigned" (D.lazy (\_ -> unsignedDataDecoder)))


{-| Extra information about the event.
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
