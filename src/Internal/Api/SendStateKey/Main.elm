module Internal.Api.SendStateKey.Main exposing (..)

import Internal.Api.SendStateKey.Api as Api
import Internal.Api.SendStateKey.V1_2.Api as V1_2
import Internal.Api.SendStateKey.V1_3.Api as V1_3
import Internal.Api.SendStateKey.V1_4.Api as V1_4
import Internal.Api.SendStateKey.V1_5.Api as V1_5
import Internal.Api.SendStateKey.V1_5.Objects as O
import Internal.Api.VersionControl as V
import Internal.Tools.Exceptions as X
import Task exposing (Task)


sendStateKey : List String -> SendStateKeyInput -> SendStateKeyOutput
sendStateKey =
    V.firstVersion V1_2.packet
        |> V.updateWith V1_3.packet
        |> V.updateWith V1_4.packet
        |> V.updateWith V1_5.packet
        |> V.toFunction


type alias SendStateKeyInput =
    Api.SendStateKeyInputV1


type alias SendStateKeyOutput =
    Task X.Error O.EventResponse
