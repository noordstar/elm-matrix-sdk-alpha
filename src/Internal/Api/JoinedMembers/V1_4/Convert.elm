module Internal.Api.JoinedMembers.V1_4.Convert exposing (..)

import Internal.Api.JoinedMembers.V1_4.Objects as O
import Internal.Api.JoinedMembers.V1_4.SpecObjects as SO


convert : SO.RoomMemberList -> O.RoomMemberList
convert =
    identity
