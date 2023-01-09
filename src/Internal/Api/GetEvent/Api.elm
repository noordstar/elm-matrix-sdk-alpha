module Internal.Api.GetEvent.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias GetEventInputV1 =
    { accessToken : String
    , baseUrl : String
    , eventId : String
    , roomId : String
    }


getEventInputV1 : D.Decoder a -> (a -> b) -> GetEventInputV1 -> Task X.Error b
getEventInputV1 decoder mapping data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "GET"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/v3/rooms/{roomId}/event/{eventId}"
        , pathParams =
            [ ( "eventId", data.eventId )
            , ( "roomId", data.roomId )
            ]
        , queryParams = []
        , bodyParams = []
        , timeout = Nothing
        , decoder = \_ -> D.map mapping decoder
        }
