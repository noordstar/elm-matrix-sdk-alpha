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
    SO1.RoomMemberList


joinedMembersV1 : JoinedMembersInputV1 -> Task X.Error JoinedMembersOutputV1
joinedMembersV1 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "GET"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/r0/rooms/{roomId}/joined_members"
        , pathParams =
            [ ( "roomId", data.roomId )
            ]
        , queryParams = []
        , bodyParams = []
        , timeout = Nothing
        , decoder = \_ -> SO1.roomMemberListDecoder
        }


joinedMembersV2 : JoinedMembersInputV1 -> Task X.Error JoinedMembersOutputV1
joinedMembersV2 data =
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
