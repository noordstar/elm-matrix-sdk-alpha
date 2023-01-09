module Internal.Api.JoinedMembers.V1_3.Upcast exposing (..)

import Internal.Api.JoinedMembers.V1_2.Objects as PO
import Internal.Api.JoinedMembers.V1_3.Objects as O


upcast : PO.RoomMemberList -> O.RoomMemberList
upcast =
    identity
