module Internal.Api.JoinedMembers.V1_5.Convert exposing (..)

import Internal.Api.JoinedMembers.V1_5.Objects as O
import Internal.Api.JoinedMembers.V1_5.SpecObjects as SO


convert : SO.RoomMemberList -> O.RoomMemberList
convert =
    identity
