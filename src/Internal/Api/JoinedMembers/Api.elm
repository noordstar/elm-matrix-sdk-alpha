module Internal.Api.JoinedMembers.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias JoinedMembersInputV1 =
    { accessToken : String
    , baseUrl : String
    , roomId : String
    }


joinedMembersInputV1 : D.Decoder a -> (a -> b) -> JoinedMembersInputV1 -> Task X.Error b
joinedMembersInputV1 decoder mapping data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "GET"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/v3/rooms/{roomId}/joined_members"
        , pathParams =
            [ ( "roomId", data.roomId )
            ]
        , queryParams = []
        , bodyParams = []
        , timeout = Nothing
        , decoder = \_ -> D.map mapping decoder
        }
