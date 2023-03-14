module Internal.Api.SendMessageEvent.Api exposing (SendMessageEventInputV1, SendMessageEventOutputV1, sendMessageEventV1, sendMessageEventV2)

import Internal.Api.Request as R
import Internal.Api.SendMessageEvent.V1.SpecObjects as SO1
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias SendMessageEventInputV1 =
    { content : D.Value
    , eventType : String
    , roomId : String
    }


type alias SendMessageEventOutputV1 =
    SO1.EventResponse


sendMessageEventV1 : SendMessageEventInputV1 -> Context { a | accessToken : (), baseUrl : (), transactionId : () } -> Task X.Error SendMessageEventOutputV1
sendMessageEventV1 { content, eventType, roomId } =
    R.callApi "PUT" "/_matrix/client/r0/rooms/{roomId}/send/{eventType}/{txnId}"
        >> R.withAttributes
            [ R.accessToken
            , R.withTransactionId
            , R.replaceInUrl "eventType" eventType
            , R.replaceInUrl "roomId" roomId
            , R.fullBody content
            ]
        >> R.toTask SO1.eventResponseDecoder


sendMessageEventV2 : SendMessageEventInputV1 -> Context { a | accessToken : (), baseUrl : (), transactionId : () } -> Task X.Error SendMessageEventOutputV1
sendMessageEventV2 { content, eventType, roomId } =
    R.callApi "PUT" "/_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}"
        >> R.withAttributes
            [ R.accessToken
            , R.withTransactionId
            , R.replaceInUrl "eventType" eventType
            , R.replaceInUrl "roomId" roomId
            , R.fullBody content
            ]
        >> R.toTask SO1.eventResponseDecoder
