module Internal.Api.Invite.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias InviteInputV1 =
    { roomId : String
    , userId : String
    }


type alias InviteInputV2 =
    { reason : Maybe String
    , roomId : String
    , userId : String
    }


type alias InviteOutputV1 =
    ()


inviteV1 : InviteInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error InviteOutputV1
inviteV1 { roomId, userId } =
    R.callApi "POST" "/_matrix/client/r0/rooms/{roomId}/invite"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.bodyString "user_id" userId
            ]
        >> R.toTask (D.map (always ()) D.value)


inviteV2 : InviteInputV2 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error InviteOutputV1
inviteV2 { reason, roomId, userId } =
    R.callApi "POST" "/_matrix/client/v3/rooms/{roomId}/invite"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.bodyString "user_id" userId
            , R.bodyOpString "reason" reason
            ]
        >> R.toTask (D.map (always ()) D.value)
