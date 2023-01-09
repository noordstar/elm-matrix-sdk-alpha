module Internal.Api.GetEvent.Main exposing (..)

import Internal.Api.GetEvent.Api as Api
import Internal.Api.GetEvent.V1_2.Api as V1_2
import Internal.Api.GetEvent.V1_3.Api as V1_3
import Internal.Api.GetEvent.V1_4.Api as V1_4
import Internal.Api.GetEvent.V1_5.Api as V1_5
import Internal.Api.GetEvent.V1_5.Objects as O
import Internal.Api.VersionControl as V
import Internal.Tools.Exceptions as X
import Task exposing (Task)


getEvent : List String -> EventInput -> EventOutput
getEvent =
    V.firstVersion V1_2.packet
        |> V.updateWith V1_3.packet
        |> V.updateWith V1_4.packet
        |> V.updateWith V1_5.packet
        |> V.toFunction


type alias EventOutput =
    Task X.Error O.ClientEvent


type alias EventInput =
    Api.GetEventInputV1
