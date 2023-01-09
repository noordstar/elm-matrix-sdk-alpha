module Internal.Api.JoinedMembers.V1_3.Convert exposing (..)

import Internal.Api.JoinedMembers.V1_3.Objects as O
import Internal.Api.JoinedMembers.V1_3.SpecObjects as SO


convert : SO.RoomMemberList -> O.RoomMemberList
convert =
    identity
