module Internal.Api.Invite.Api exposing (..)

import Internal.Api.Request as R
import Internal.Config.SpecErrors as SE
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
            , R.onStatusCode 403 (X.M_FORBIDDEN { error = Just SE.inviteNotAllowed })
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
            , R.onStatusCode 400 (X.M_INVALID_PARAM { error = Just SE.invalidRequest })
            , R.onStatusCode 403 (X.M_FORBIDDEN { error = Just SE.inviteNotAllowed })
            , R.onStatusCode 429 (X.M_LIMIT_EXCEEDED { error = Just SE.ratelimited, retryAfterMs = Nothing })
            ]
        >> R.toTask (D.map (always ()) D.value)
