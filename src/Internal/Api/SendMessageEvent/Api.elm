module Internal.Api.SendMessageEvent.Api exposing (..)

import Internal.Api.Request as R
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


sendMessageEventV1 : D.Decoder a -> (a -> b) -> SendMessageEventInputV1 -> Task X.Error b
sendMessageEventV1 decoder mapping data =
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
        , decoder = \_ -> D.map mapping decoder
        }
