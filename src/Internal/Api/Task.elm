module Internal.Api.Task exposing (..)

{-| This module contains all tasks that can be executed.
-}

import Hash
import Internal.Api.Chain as Chain
import Internal.Api.GetEvent.Main exposing (EventInput)
import Internal.Api.GetMessages.Main exposing (GetMessagesInput)
import Internal.Api.Invite.Main exposing (InviteInput)
import Internal.Api.JoinRoomById.Main exposing (JoinRoomByIdInput)
import Internal.Api.JoinedMembers.Main exposing (JoinedMembersInput)
import Internal.Api.Leave.Main exposing (LeaveInput)
import Internal.Api.SendStateKey.Main exposing (SendStateKeyInput)
import Internal.Api.SetAccountData.Main exposing (SetAccountInput)
import Internal.Api.Snackbar as Snackbar exposing (Snackbar)
import Internal.Api.Sync.Main exposing (SyncInput)
import Internal.Api.VaultUpdate as C
import Json.Encode as E


type alias FutureTask =
    C.FutureTask


type alias EventInput =
    { eventId : String
    , roomId : String
    }


getEvent : EventInput -> Snackbar a -> FutureTask
getEvent { eventId, roomId } cred =
    C.makeVBA cred
        |> Chain.andThen (C.withSentEvent eventId)
        |> Chain.andThen (C.getEvent { roomId = roomId })
        |> C.toTask


getMessages : GetMessagesInput -> Snackbar a -> FutureTask
getMessages data cred =
    C.makeVBA cred
        |> Chain.andThen (C.getMessages data)
        |> C.toTask


invite : InviteInput -> Snackbar a -> FutureTask
invite data cred =
    C.makeVBA cred
        |> Chain.andThen (C.invite data)
        |> C.toTask


joinedMembers : JoinedMembersInput -> Snackbar a -> FutureTask
joinedMembers data cred =
    C.makeVBA cred
        |> Chain.andThen (C.joinedMembers data)
        |> C.toTask


joinRoomById : JoinRoomByIdInput -> Snackbar a -> FutureTask
joinRoomById data cred =
    C.makeVBA cred
        |> Chain.andThen (C.joinRoomById data)
        |> C.toTask


leave : LeaveInput -> Snackbar a -> FutureTask
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


redact : RedactInput -> Snackbar a -> FutureTask
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


sendMessageEvent : SendMessageEventInput -> Snackbar a -> FutureTask
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
        |> Chain.andThen C.getTimestamp
        |> Chain.andThen (C.sendMessageEvent { content = content, eventType = eventType, roomId = roomId })
        |> Chain.andThen
            (Chain.maybe <| C.getEvent { roomId = roomId })
        |> C.toTask


sendStateEvent : SendStateKeyInput -> Snackbar a -> FutureTask
sendStateEvent data cred =
    C.makeVBA cred
        |> Chain.andThen C.getTimestamp
        |> Chain.andThen (C.sendStateEvent data)
        |> Chain.andThen
            (Chain.maybe <| C.getEvent { roomId = data.roomId })
        |> C.toTask


setAccountData : SetAccountInput -> Snackbar a -> FutureTask
setAccountData data cred =
    C.makeVBA cred
        |> Chain.andThen (C.setAccountData data)
        |> C.toTask


sync : SyncInput -> Snackbar a -> FutureTask
sync data cred =
    C.makeVBA cred
        |> Chain.andThen (C.sync data)
        |> C.toTask


loginMaybeSync : SyncInput -> Snackbar a -> FutureTask
loginMaybeSync data cred =
    C.makeVB cred
        |> Chain.andThen (C.accessToken (Snackbar.removedAccessToken cred))
        |> Chain.andThen
            (Chain.maybe <| C.sync data)
        |> C.toTask
