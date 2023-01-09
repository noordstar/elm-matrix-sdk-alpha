module Internal.Api.SendStateKey.Api exposing (..)

import Internal.Api.Request as R
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


sendStateKeyV1 : D.Decoder a -> (a -> b) -> SendStateKeyInputV1 -> Task X.Error b
sendStateKeyV1 decoder mapping data =
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
        , decoder = \_ -> D.map mapping decoder
        }
