module Internal.Api.JoinedMembers.V1_2.Upcast exposing (..)

import Dict
import Internal.Api.JoinedMembers.V1_2.Objects as O


upcast : () -> O.RoomMemberList
upcast _ =
    { joined = Dict.empty }
