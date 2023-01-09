module Internal.Api.Sync.Main exposing (..)

import Internal.Api.Sync.Api as Api
import Internal.Api.Sync.V1_2.Api as V1_2
import Internal.Api.Sync.V1_3.Api as V1_3
import Internal.Api.Sync.V1_4.Api as V1_4
import Internal.Api.Sync.V1_5.Api as V1_5
import Internal.Api.Sync.V1_5.Objects as O
import Internal.Api.VersionControl as V
import Internal.Tools.Exceptions as X
import Task exposing (Task)


sync : List String -> SyncInput -> SyncOutput
sync =
    V.firstVersion V1_2.packet
        |> V.updateWith V1_3.packet
        |> V.updateWith V1_4.packet
        |> V.updateWith V1_5.packet
        |> V.toFunction


type alias SyncInput =
    Api.SyncInputV1


type alias SyncOutput =
    Task X.Error O.Sync
