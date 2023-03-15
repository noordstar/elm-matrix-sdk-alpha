module Internal.Api.Task exposing (..)

{-| This module contains all tasks that can be executed.
-}

import Hash
import Internal.Api.Chain as Chain
import Internal.Api.Credentials as Cred exposing (Credentials)
import Internal.Api.GetEvent.Main exposing (EventInput)
import Internal.Api.Invite.Main exposing (InviteInput)
import Internal.Api.JoinRoomById.Main exposing (JoinRoomByIdInput)
import Internal.Api.JoinedMembers.Main exposing (JoinedMembersInput)
import Internal.Api.Leave.Main exposing (LeaveInput)
import Internal.Api.SendStateKey.Main exposing (SendStateKeyInput)
import Internal.Api.Sync.Main exposing (SyncInput)
import Internal.Api.VaultUpdate as C
import Json.Encode as E


type alias FutureTask =
    C.FutureTask


type alias EventInput =
    { eventId : String
    , roomId : String
    }


getEvent : EventInput -> Credentials -> FutureTask
getEvent { eventId, roomId } cred =
    C.makeVBA cred
        |> Chain.andThen (C.withSentEvent eventId)
        |> Chain.andThen (C.getEvent { roomId = roomId })
        |> C.toTask


invite : InviteInput -> Credentials -> FutureTask
invite data cred =
    C.makeVBA cred
        |> Chain.andThen (C.invite data)
        |> C.toTask


joinedMembers : JoinedMembersInput -> Credentials -> FutureTask
joinedMembers data cred =
    C.makeVBA cred
        |> Chain.andThen (C.joinedMembers data)
        |> C.toTask


joinRoomById : JoinRoomByIdInput -> Credentials -> FutureTask
joinRoomById data cred =
    C.makeVBA cred
        |> Chain.andThen (C.joinRoomById data)
        |> C.toTask


leave : LeaveInput -> Credentials -> FutureTask
leave data cred =
    C.makeVBA cred
        |> Chain.andThen (C.leave data)
        |> C.toTask


type alias RedactInput =
    { eventId : String
    , extraTransactionNoise : String
    , reason : Maybe String
    , roomId : String
    }


redact : RedactInput -> Credentials -> FutureTask
redact { eventId, extraTransactionNoise, reason, roomId } cred =
    cred
        |> C.makeVBAT
            (\now ->
                [ Hash.fromInt now
                , Hash.fromString eventId
                , Hash.fromString extraTransactionNoise
                , Hash.fromString (reason |> Maybe.withDefault "noreason")
                , Hash.fromString roomId
                ]
                    |> List.foldl Hash.independent (Hash.fromString "redact")
                    |> Hash.toString
            )
        |> Chain.andThen (C.redact { eventId = eventId, reason = reason, roomId = roomId })
        |> Chain.andThen (C.withSentEvent eventId)
        |> Chain.andThen
            (Chain.maybe <| C.getEvent { roomId = roomId })
        |> C.toTask


type alias SendMessageEventInput =
    { content : E.Value
    , eventType : String
    , extraTransactionNoise : String
    , roomId : String
    }


sendMessageEvent : SendMessageEventInput -> Credentials -> FutureTask
sendMessageEvent { content, eventType, extraTransactionNoise, roomId } cred =
    cred
        |> C.makeVBAT
            (\now ->
                [ Hash.fromInt now
                , Hash.fromString (E.encode 0 content)
                , Hash.fromString eventType
                , Hash.fromString extraTransactionNoise
                , Hash.fromString roomId
                ]
                    |> List.foldl Hash.independent (Hash.fromString "send message")
                    |> Hash.toString
            )
        |> Chain.andThen (C.sendMessageEvent { content = content, eventType = eventType, roomId = roomId })
        |> Chain.andThen
            (Chain.maybe <| C.getEvent { roomId = roomId })
        |> C.toTask


sendStateEvent : SendStateKeyInput -> Credentials -> FutureTask
sendStateEvent data cred =
    C.makeVBA cred
        |> Chain.andThen (C.sendStateEvent data)
        |> Chain.andThen
            (Chain.maybe <| C.getEvent { roomId = data.roomId })
        |> C.toTask


sync : SyncInput -> Credentials -> FutureTask
sync data cred =
    C.makeVBA cred
        |> Chain.andThen (C.sync data)
        |> C.toTask


loginMaybeSync : SyncInput -> Credentials -> FutureTask
loginMaybeSync data cred =
    C.makeVB cred
        |> Chain.andThen (C.accessToken (Cred.refreshedAccessToken cred))
        |> Chain.andThen
            (Chain.maybe <| C.sync data)
        |> C.toTask
