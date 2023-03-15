module Internal.Api.Leave.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias LeaveInputV1 =
    { roomId : String }


type alias LeaveInputV2 =
    { roomId : String, reason : Maybe String }


type alias LeaveOutputV1 =
    ()


leaveV1 : LeaveInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error LeaveOutputV1
leaveV1 { roomId } =
    R.callApi "POST" "/_matrix/client/r0/rooms/{roomId}/leave"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            ]
        >> R.toTask (D.map (always ()) D.value)


leaveV2 : LeaveInputV2 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error LeaveOutputV1
leaveV2 { roomId, reason } =
    R.callApi "POST" "/_matrix/client/r0/rooms/{roomId}/leave"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.bodyOpString "reason" reason
            ]
        >> R.toTask (D.map (always ()) D.value)
