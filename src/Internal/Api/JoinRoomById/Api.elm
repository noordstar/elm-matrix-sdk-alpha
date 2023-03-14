module Internal.Api.JoinRoomById.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context, VBA)
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias JoinRoomByIdInputV1 =
    { roomId : String }


type alias JoinRoomByIdInputV2 =
    { roomId : String, reason : Maybe String }


type alias JoinRoomByIdOutputV1 =
    { roomId : String }


joinRoomByIdV1 : JoinRoomByIdInputV1 -> Context (VBA a) -> Task X.Error JoinRoomByIdOutputV1
joinRoomByIdV1 { roomId } =
    R.callApi "POST" "/_matrix/client/r0/rooms/{roomId}/join"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            ]
        >> R.toTask (D.map (\r -> { roomId = r }) (D.field "room_id" D.string))


joinRoomByIdV2 : JoinRoomByIdInputV2 -> Context (VBA a) -> Task X.Error JoinRoomByIdOutputV1
joinRoomByIdV2 { roomId, reason } =
    R.callApi "POST" "/_matrix/client/v3/rooms/{roomId}/join"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.bodyOpString "reason" reason
            ]
        >> R.toTask (D.map (\r -> { roomId = r }) (D.field "room_id" D.string))
