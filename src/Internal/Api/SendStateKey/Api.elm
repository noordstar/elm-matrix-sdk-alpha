module Internal.Api.SendStateKey.Api exposing (..)

import Internal.Api.Request as R
import Internal.Api.SendStateKey.V1.SpecObjects as SO1
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias SendStateKeyInputV1 =
    { accessToken : String
    , baseUrl : String
    , content : D.Value
    , eventType : String
    , roomId : String
    , stateKey : String
    }

type alias SendStateKeyOutputV1 =
    Task X.Error SO1.EventResponse


sendStateKeyV1 : SendStateKeyInputV1 -> SendStateKeyOutputV1
sendStateKeyV1 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "PUT"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/r0/rooms/{roomId}/state/{eventType}/{stateKey}"
        , pathParams =
            [ ( "eventType", data.eventType )
            , ( "roomId", data.roomId )
            , ( "stateKey", data.stateKey )
            ]
        , queryParams = []
        , bodyParams = [ R.RequiredValue "*" data.content ]
        , timeout = Nothing
        , decoder = \_ -> SO1.eventResponseDecoder
        }


sendStateKeyV2 : SendStateKeyInputV1 -> SendStateKeyOutputV1
sendStateKeyV2 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "PUT"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/v3/rooms/{roomId}/state/{eventType}/{stateKey}"
        , pathParams =
            [ ( "eventType", data.eventType )
            , ( "roomId", data.roomId )
            , ( "stateKey", data.stateKey )
            ]
        , queryParams = []
        , bodyParams = [ R.RequiredValue "*" data.content ]
        , timeout = Nothing
        , decoder = \_ -> SO1.eventResponseDecoder
        }
