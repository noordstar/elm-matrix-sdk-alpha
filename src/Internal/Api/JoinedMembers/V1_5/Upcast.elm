module Internal.Api.JoinedMembers.V1_5.Upcast exposing (..)

import Internal.Api.JoinedMembers.V1_4.Objects as PO
import Internal.Api.JoinedMembers.V1_5.Objects as O


upcast : PO.RoomMemberList -> O.RoomMemberList
upcast =
    identity
