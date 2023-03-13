module Internal.Api.Invite.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias InviteInputV1 =
    { accessToken : String
    , baseUrl : String
    , roomId : String
    , userId : String
    }


type alias InviteInputV2 =
    { accessToken : String
    , baseUrl : String
    , reason : Maybe String
    , roomId : String
    , userId : String
    }


type alias InviteOutputV1 =
    ()


inviteV1 : InviteInputV1 -> Task X.Error InviteOutputV1
inviteV1 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "POST"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/r0/rooms/{roomId}/invite"
        , pathParams =
            [ ( "roomId", data.roomId )
            ]
        , queryParams = []
        , bodyParams =
            [ R.RequiredString "user_id" data.userId
            ]
        , timeout = Nothing
        , decoder = always (D.map (always ()) D.value)
        }


inviteV2 : InviteInputV2 -> Task X.Error InviteOutputV1
inviteV2 data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "POST"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/r0/rooms/{roomId}/invite"
        , pathParams =
            [ ( "roomId", data.roomId )
            ]
        , queryParams = []
        , bodyParams =
            [ R.RequiredString "user_id" data.userId
            , R.OptionalString "reason" data.reason
            ]
        , timeout = Nothing
        , decoder = always (D.map (always ()) D.value)
        }
