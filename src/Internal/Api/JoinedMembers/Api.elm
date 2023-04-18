module Internal.Api.JoinedMembers.Api exposing (..)

import Internal.Api.JoinedMembers.V1.SpecObjects as SO1
import Internal.Api.Request as R
import Internal.Config.SpecErrors as SE
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias JoinedMembersInputV1 =
    { roomId : String
    }


type alias JoinedMembersOutputV1 =
    SO1.RoomMemberList


joinedMembersV1 : JoinedMembersInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error JoinedMembersOutputV1
joinedMembersV1 { roomId } =
    R.callApi "GET" "/_matrix/client/r0/rooms/{roomId}/joined_members"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.onStatusCode 403 (X.M_FORBIDDEN { error = Just SE.notInRoom })
            ]
        >> R.toTask SO1.roomMemberListDecoder


joinedMembersV2 : JoinedMembersInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error JoinedMembersOutputV1
joinedMembersV2 { roomId } =
    R.callApi "GET" "/_matrix/client/v3/rooms/{roomId}/joined_members"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.onStatusCode 403 (X.M_FORBIDDEN { error = Just SE.notInRoom })
            ]
        >> R.toTask SO1.roomMemberListDecoder
