module Internal.Api.JoinedMembers.V1_2.Convert exposing (..)

import Internal.Api.JoinedMembers.V1_2.Objects as O
import Internal.Api.JoinedMembers.V1_2.SpecObjects as SO


convert : SO.RoomMemberList -> O.RoomMemberList
convert =
    identity
