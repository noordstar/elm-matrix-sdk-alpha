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
import Internal.Api.Snackbar as Snackbar
import Internal.Api.Sync.Main exposing (SyncInput)
import Internal.Api.VaultUpdate as C exposing (Vnackbar)
import Json.Encode as E


type alias FutureTask =
    C.FutureTask


type alias EventInput =
    { eventId : String
    , roomId : String
    }


getEvent : EventInput -> Vnackbar a -> FutureTask
getEvent { eventId, roomId } cred =
    C.toTask
        ("Get event `" ++ eventId ++ "` from room `" ++ roomId ++ "`")
        (C.makeVBA
            >> Chain.andThen (C.withSentEvent eventId)
            >> Chain.andThen (C.getEvent { roomId = roomId })
        )
        (Snackbar.withoutContent cred)


getMessages : GetMessagesInput -> Vnackbar a -> FutureTask
getMessages data cred =
    C.toTask
        ("Get messages from room `" ++ data.roomId ++ "`")
        (C.makeVBA >> Chain.andThen (C.getMessages data))
        (Snackbar.withoutContent cred)


invite : InviteInput -> Vnackbar a -> FutureTask
invite data cred =
    C.toTask
        ("Invite user " ++ data.userId ++ " to room " ++ data.roomId)
        (C.makeVBA >> Chain.andThen (C.invite data))
        (Snackbar.withoutContent cred)


joinedMembers : JoinedMembersInput -> Vnackbar a -> FutureTask
joinedMembers data cred =
    C.toTask
        ("Get a list of joined members from room " ++ data.roomId)
        (C.makeVBA >> Chain.andThen (C.joinedMembers data))
        (Snackbar.withoutContent cred)


joinRoomById : JoinRoomByIdInput -> Vnackbar a -> FutureTask
joinRoomById data cred =
    C.toTask
        ("Join room " ++ data.roomId ++ "by its room id")
        (C.makeVBA >> Chain.andThen (C.joinRoomById data))
        (Snackbar.withoutContent cred)


leave : LeaveInput -> Vnackbar a -> FutureTask
leave data cred =
    C.toTask
        ("Leave room " ++ data.roomId)
        (C.makeVBA >> Chain.andThen (C.leave data))
        (Snackbar.withoutContent cred)


type alias RedactInput =
    { eventId : String
    , extraTransactionNoise : String
    , reason : Maybe String
    , roomId : String
    }


redact : RedactInput -> Vnackbar a -> FutureTask
redact { eventId, extraTransactionNoise, reason, roomId } cred =
    C.toTask
        ("Redact event " ++ eventId ++ " from room " ++ roomId)
        (C.makeVBAT
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
            >> Chain.andThen (C.redact { eventId = eventId, reason = reason, roomId = roomId })
            >> Chain.andThen (C.withSentEvent eventId)
            >> Chain.andThen
                (Chain.maybe <| C.getEvent { roomId = roomId })
        )
        (Snackbar.withoutContent cred)


type alias SendMessageEventInput =
    { content : E.Value
    , eventType : String
    , extraTransactionNoise : String
    , roomId : String
    }


sendMessageEvent : SendMessageEventInput -> Vnackbar a -> FutureTask
sendMessageEvent { content, eventType, extraTransactionNoise, roomId } cred =
    C.toTask
        ("Send a message event to room " ++ roomId ++ " with event type " ++ eventType)
        (C.makeVBAT
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
            >> Chain.andThen C.getTimestamp
            >> Chain.andThen (C.sendMessageEvent { content = content, eventType = eventType, roomId = roomId })
            >> Chain.andThen
                (Chain.maybe <| C.getEvent { roomId = roomId })
        )
        (Snackbar.withoutContent cred)


sendStateEvent : SendStateKeyInput -> Vnackbar a -> FutureTask
sendStateEvent data cred =
    C.toTask
        ("Send a state event to room " ++ data.roomId ++ " with event type " ++ data.eventType)
        (C.makeVBA
            >> Chain.andThen C.getTimestamp
            >> Chain.andThen (C.sendStateEvent data)
            >> Chain.andThen
                (Chain.maybe <| C.getEvent { roomId = data.roomId })
        )
        (Snackbar.withoutContent cred)


setAccountData : SetAccountInput -> Vnackbar a -> FutureTask
setAccountData data cred =
    C.toTask
        ("Set account data "
            ++ data.eventType
            ++ (case data.roomId of
                    Just r ->
                        " in room " ++ r

                    Nothing ->
                        " in main account"
               )
        )
        (C.makeVBA >> Chain.andThen (C.setAccountData data))
        (Snackbar.withoutContent cred)


sync : SyncInput -> Vnackbar a -> FutureTask
sync data cred =
    C.toTask
        "Sync Vault"
        (C.makeVBA >> Chain.andThen (C.sync data))
        (Snackbar.withoutContent cred)


loginMaybeSync : SyncInput -> Vnackbar a -> FutureTask
loginMaybeSync data cred =
    C.toTask
        "Log in again, then sync Vault"
        (C.makeVB
            >> Chain.andThen (C.accessToken (Snackbar.removedAccessToken cred))
            >> Chain.andThen
                (Chain.maybe <| C.sync data)
        )
        (Snackbar.withoutContent cred)
