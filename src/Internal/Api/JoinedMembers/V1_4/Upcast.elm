module Internal.Api.JoinedMembers.V1_4.Upcast exposing (..)

import Internal.Api.JoinedMembers.V1_3.Objects as PO
import Internal.Api.JoinedMembers.V1_4.Objects as O


upcast : PO.RoomMemberList -> O.RoomMemberList
upcast =
    identity
