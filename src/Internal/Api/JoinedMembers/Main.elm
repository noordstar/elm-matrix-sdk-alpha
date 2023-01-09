module Internal.Api.JoinedMembers.Main exposing (..)

import Internal.Api.JoinedMembers.Api as Api
import Internal.Api.JoinedMembers.V1_2.Api as V1_2
import Internal.Api.JoinedMembers.V1_3.Api as V1_3
import Internal.Api.JoinedMembers.V1_4.Api as V1_4
import Internal.Api.JoinedMembers.V1_5.Api as V1_5
import Internal.Api.JoinedMembers.V1_5.Objects as O
import Internal.Api.VersionControl as V
import Internal.Tools.Exceptions as X
import Task exposing (Task)


joinedMembers : List String -> JoinedMembersInput -> JoinedMembersOutput
joinedMembers =
    V.firstVersion V1_2.packet
        |> V.updateWith V1_3.packet
        |> V.updateWith V1_4.packet
        |> V.updateWith V1_5.packet
        |> V.toFunction


type alias JoinedMembersInput =
    Api.JoinedMembersInputV1


type alias JoinedMembersOutput =
    Task X.Error O.RoomMemberList
