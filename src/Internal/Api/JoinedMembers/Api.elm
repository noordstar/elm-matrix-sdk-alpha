module Internal.Api.JoinedMembers.Api exposing (..)

import Internal.Api.JoinedMembers.V1.SpecObjects as SO1
import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias JoinedMembersInputV1 =
    { accessToken : String
    , baseUrl : String
    , roomId : String
    }


type alias JoinedMembersOutputV1 =
    Task X.Error SO1.RoomMemberList


joinedMembersInputV1 : JoinedMembersInputV1 -> JoinedMembersOutputV1
joinedMembersInputV1 data =
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
        , decoder = \_ -> SO1.roomMemberListDecoder
        }
