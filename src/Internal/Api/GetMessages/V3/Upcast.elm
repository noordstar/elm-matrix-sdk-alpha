module Internal.Api.GetMessages.V3.Upcast exposing (..)

import Internal.Api.GetMessages.V2.SpecObjects as PO
import Internal.Api.GetMessages.V3.SpecObjects as SO


upcastMessagesResponse : PO.MessagesResponse -> SO.MessagesResponse
upcastMessagesResponse old =
    { chunk = List.map upcastRoomEvent old.chunk
    , start = old.start
    , end = old.end
    , state = []
    }


upcastRoomEvent : PO.RoomEvent -> SO.RoomEvent
upcastRoomEvent old =
    { content = old.content
    , eventId = old.eventId
    , originServerTs = old.originServerTs
    , roomId = old.roomId
    , sender = old.sender
    , eventType = old.eventType
    , prevContent = old.prevContent
    , stateKey = old.stateKey
    , unsigned =
        old.unsigned
            |> Maybe.map
                (\(PO.UnsignedData data) ->
                    SO.UnsignedData
                        { age = data.age
                        , redactedBecause = Maybe.map upcastRoomEvent data.redactedBecause
                        , transactionId = data.transactionId
                        }
                )
    }
