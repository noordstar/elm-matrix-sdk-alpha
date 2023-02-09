module Internal.Api.SendMessageEvent.V1.Api exposing (sendMessageEventV1, sendMessageEventV2, SendMessageEventOutputV1, SendMessageEventInputV1)

import Internal.Api.Request as R
import Internal.Api.SendMessageEvent.V1.SpecObjects as SO1
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias SendMessageEventInputV1 =
    { accessToken : String
    , baseUrl : String
    , content : D.Value
    , eventType : String
    , roomId : String
    , transactionId : String
    }

type alias SendMessageEventOutputV1 = Task X.Error SO1.EventResponse


sendMessageEventV1 : SendMessageEventInputV1 -> SendMessageEventOutputV1
sendMessageEventV1 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "PUT"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/r0/rooms/{roomId}/send/{eventType}/{txnId}"
        , pathParams =
            [ ( "eventType", data.eventType )
            , ( "roomId", data.roomId )
            , ( "txnId", data.transactionId )
            ]
        , queryParams = []
        , bodyParams = [ R.RequiredValue "*" data.content ]
        , timeout = Nothing
        , decoder = \_ -> SO1.eventResponseDecoder
        }


sendMessageEventV2 : SendMessageEventInputV1 -> SendMessageEventOutputV1
sendMessageEventV2 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "PUT"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}"
        , pathParams =
            [ ( "eventType", data.eventType )
            , ( "roomId", data.roomId )
            , ( "txnId", data.transactionId )
            ]
        , queryParams = []
        , bodyParams = [ R.RequiredValue "*" data.content ]
        , timeout = Nothing
        , decoder = \_ -> SO1.eventResponseDecoder
        }
