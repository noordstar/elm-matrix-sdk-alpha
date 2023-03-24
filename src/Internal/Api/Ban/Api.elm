module Internal.Api.Ban.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias BanInputV1 =
    { reason : Maybe String
    , roomId : String
    , userId : String
    }


type alias BanOutputV1 =
    ()


banV1 : BanInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error BanOutputV1
banV1 { reason, roomId, userId } =
    R.callApi "POST" "/_matrix/client/r0/rooms/{roomId}/ban"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.bodyOpString "reason" reason
            , R.bodyString "user_id" userId
            ]
        >> R.toTask (D.map (always ()) D.value)


banV2 : BanInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error BanOutputV1
banV2 { reason, roomId, userId } =
    R.callApi "POST" "/_matrix/client/v3/rooms/{roomId}/ban"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.bodyOpString "reason" reason
            , R.bodyString "user_id" userId
            ]
        >> R.toTask (D.map (always ()) D.value)
