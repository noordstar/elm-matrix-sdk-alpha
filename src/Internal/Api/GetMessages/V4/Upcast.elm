module Internal.Api.GetMessages.V4.Upcast exposing (..)

import Internal.Api.GetMessages.V3.SpecObjects as PO
import Internal.Api.GetMessages.V4.SpecObjects as SO
import Json.Encode as E


upcastMessagesResponse : PO.MessagesResponse -> SO.MessagesResponse
upcastMessagesResponse old =
    { chunk = List.map upcastRoomEvent old.chunk
    , end = old.end
    , start = old.start
    , state = List.map upcastRoomStateEvent old.state
    }


upcastRoomEvent : PO.RoomEvent -> SO.ClientEvent
upcastRoomEvent old =
    { content = old.content
    , eventId = old.eventId
    , originServerTs = old.originServerTs
    , roomId = old.roomId
    , sender = old.sender
    , stateKey = old.stateKey
    , eventType = old.eventType
    , unsigned = Maybe.map (upcastUnsigned old.prevContent) old.unsigned
    }


upcastRoomStateEvent : PO.RoomStateEvent -> SO.ClientEvent
upcastRoomStateEvent old =
    { content = old.content
    , eventId = old.eventId
    , originServerTs = old.originServerTs
    , roomId = old.roomId
    , sender = old.sender
    , stateKey = Just old.stateKey
    , eventType = old.eventType
    , unsigned = Maybe.map (upcastUnsigned old.prevContent) old.unsigned
    }


upcastUnsigned : Maybe E.Value -> PO.UnsignedData -> SO.UnsignedData
upcastUnsigned prevContent (PO.UnsignedData old) =
    SO.UnsignedData
        { age = old.age
        , prevContent = prevContent
        , redactedBecause = Maybe.map upcastRoomEvent old.redactedBecause
        , transactionId = old.transactionId
        }
