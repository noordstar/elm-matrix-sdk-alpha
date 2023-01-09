module Internal.Api.GetEvent.V1_4.Convert exposing (..)

import Internal.Api.GetEvent.V1_4.Objects as O
import Internal.Api.GetEvent.V1_4.SpecObjects as SO


convert : SO.ClientEvent -> O.ClientEvent
convert e =
    { content = e.content
    , eventId = e.eventId
    , originServerTs = e.originServerTs
    , roomId = e.roomId
    , sender = e.sender
    , stateKey = e.stateKey
    , contentType = e.contentType
    , unsigned = Maybe.map convertUnsigned e.unsigned
    }


convertUnsigned : SO.UnsignedData -> O.UnsignedData
convertUnsigned (SO.UnsignedData u) =
    O.UnsignedData
        { age = u.age
        , prevContent = u.prevContent
        , redactedBecause = Maybe.map convert u.redactedBecause
        , transactionId = u.transactionId
        }
