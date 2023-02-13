module Internal.Api.GetEvent.Api exposing (..)

import Internal.Api.GetEvent.V1.SpecObjects as SO1
import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias GetEventInputV1 =
    { accessToken : String
    , baseUrl : String
    , eventId : String
    , roomId : String
    }


type alias GetEventOutputV1 =
    Task X.Error SO1.ClientEvent


getEventInputV1 : GetEventInputV1 -> GetEventOutputV1
getEventInputV1 data =
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
        , decoder = \_ -> SO1.clientEventDecoder
        }
