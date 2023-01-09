module Internal.Api.JoinedMembers.V1_3.Api exposing (..)

import Internal.Api.JoinedMembers.Api as Api
import Internal.Api.JoinedMembers.V1_2.Objects as PO
import Internal.Api.JoinedMembers.V1_3.Convert as C
import Internal.Api.JoinedMembers.V1_3.Objects as O
import Internal.Api.JoinedMembers.V1_3.SpecObjects as SO
import Internal.Api.JoinedMembers.V1_3.Upcast as U
import Internal.Api.VersionControl as V


packet : V.SingleVersion Api.JoinedMembersInputV1 PO.RoomMemberList Api.JoinedMembersInputV1 O.RoomMemberList
packet =
    { version = "v1.3"
    , downcast = identity
    , current = Api.joinedMembersInputV1 SO.roomMemberListDecoder C.convert
    , upcast = U.upcast
    }
