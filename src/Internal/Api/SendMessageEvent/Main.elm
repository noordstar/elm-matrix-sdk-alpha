module Internal.Api.SendMessageEvent.Main exposing (..)

import Internal.Api.SendMessageEvent.Api as Api
import Internal.Api.SendMessageEvent.V1_2.Api as V1_2
import Internal.Api.SendMessageEvent.V1_3.Api as V1_3
import Internal.Api.SendMessageEvent.V1_4.Api as V1_4
import Internal.Api.SendMessageEvent.V1_5.Api as V1_5
import Internal.Api.SendMessageEvent.V1_5.Objects as O
import Internal.Api.VersionControl as V
import Internal.Tools.Exceptions as X
import Task exposing (Task)


sendMessageEvent : List String -> SendMessageEventInput -> SendMessageEventOutput
sendMessageEvent =
    V.firstVersion V1_2.packet
        |> V.updateWith V1_3.packet
        |> V.updateWith V1_4.packet
        |> V.updateWith V1_5.packet
        |> V.toFunction


type alias SendMessageEventInput =
    Api.SendMessageEventInputV1


type alias SendMessageEventOutput =
    Task X.Error O.EventResponse
