module Internal.Api.Redact.Api exposing (..)

import Internal.Api.Redact.V1.SpecObjects as SO1
import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias RedactInputV1 =
    { accessToken : String
    , baseUrl : String
    , roomId : String
    , eventId : String
    , txnId : String
    , reason : Maybe String
    }


type alias RedactOutputV1 =
    SO1.Redaction


redactV1 : RedactInputV1 -> Task X.Error RedactOutputV1
redactV1 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "PUT"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/r0/rooms/{roomId}/redact/{eventId}/{txnId}"
        , pathParams =
            [ ( "roomId", data.roomId )
            , ( "eventId", data.eventId )
            , ( "txnId", data.txnId )
            ]
        , queryParams = []
        , bodyParams =
            [ R.OptionalString "reason" data.reason
            ]
        , timeout = Nothing
        , decoder = always SO1.redactionDecoder
        }


redactV2 : RedactInputV1 -> Task X.Error RedactOutputV1
redactV2 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "PUT"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/v3/rooms/{roomId}/redact/{eventId}/{txnId}"
        , pathParams =
            [ ( "roomId", data.roomId )
            , ( "eventId", data.eventId )
            , ( "txnId", data.txnId )
            ]
        , queryParams = []
        , bodyParams = []
        , timeout = Nothing
        , decoder = always SO1.redactionDecoder
        }
