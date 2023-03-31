module Internal.Api.GetMessages.V1.SpecObjects exposing
    ( MessagesResponse
    , RoomEvent
    , encodeMessagesResponse
    , encodeRoomEvent
    , messagesResponseDecoder
    , roomEventDecoder
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
    { age : Maybe Int
    , content : E.Value
    , eventId : String
    , originServerTs : Timestamp
    , prevContent : Maybe E.Value
    , roomId : String
    , stateKey : Maybe String
    , eventType : String
    , userId : String
    }


encodeRoomEvent : RoomEvent -> E.Value
encodeRoomEvent data =
    maybeObject
        [ ( "age", Maybe.map E.int data.age )
        , ( "content", Just <| data.content )
        , ( "event_id", Just <| E.string data.eventId )
        , ( "origin_server_ts", Just <| encodeTimestamp data.originServerTs )
        , ( "prev_content", data.prevContent )
        , ( "room_id", Just <| E.string data.roomId )
        , ( "state_key", Maybe.map E.string data.stateKey )
        , ( "type", Just <| E.string data.eventType )
        , ( "user_id", Just <| E.string data.userId )
        ]


roomEventDecoder : D.Decoder RoomEvent
roomEventDecoder =
    D.map9
        (\a b c d e f g h i ->
            { age = a, content = b, eventId = c, originServerTs = d, prevContent = e, roomId = f, stateKey = g, eventType = h, userId = i }
        )
        (opField "age" D.int)
        (D.field "content" D.value)
        (D.field "event_id" D.string)
        (D.field "origin_server_ts" timestampDecoder)
        (opField "prev_content" D.value)
        (D.field "room_id" D.string)
        (opField "state_key" D.string)
        (D.field "type" D.string)
        (D.field "user_id" D.string)
