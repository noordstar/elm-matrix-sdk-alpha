module Internal.Api.GetMessages.V2.Upcast exposing (..)

import Internal.Api.GetMessages.V1.SpecObjects as PO
import Internal.Api.GetMessages.V2.SpecObjects as SO


upcastMessagesResponse : PO.MessagesResponse -> SO.MessagesResponse
upcastMessagesResponse old =
    { chunk = List.map upcastRoomEvent old.chunk
    , start = old.start
    , end = old.end
    }


upcastRoomEvent : PO.RoomEvent -> SO.RoomEvent
upcastRoomEvent old =
    { content = old.content
    , eventId = old.eventId
    , originServerTs = old.originServerTs
    , roomId = old.roomId
    , sender = old.userId
    , eventType = old.eventType
    , prevContent = old.prevContent
    , stateKey = old.stateKey
    , unsigned =
        Maybe.map
            (\age -> SO.UnsignedData { age = Just age, redactedBecause = Nothing, transactionId = Nothing })
            old.age
    }
