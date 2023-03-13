module Internal.Api.Task exposing (..)

{-| This module contains all tasks that can be executed.
-}

import Hash
import Internal.Api.Chain as Chain
import Internal.Api.CredUpdate as C exposing (CredUpdate)
import Internal.Api.Versions.V1.Versions as V
import Internal.Tools.LoginValues exposing (AccessToken)
import Internal.Tools.SpecEnums as Enums
import Json.Encode as E


type alias FutureTask =
    C.FutureTask


type alias GetEventInput =
    { accessToken : AccessToken
    , baseUrl : String
    , eventId : String
    , roomId : String
    , versions : Maybe V.Versions
    }


getEvent : GetEventInput -> FutureTask
getEvent { accessToken, baseUrl, eventId, roomId, versions } =
    C.withBaseUrl baseUrl
        |> Chain.andThen (C.versions versions)
        |> Chain.andThen (C.accessToken accessToken)
        |> Chain.andThen (C.getEvent { eventId = eventId, roomId = roomId })
        |> C.toTask


type alias InviteInput =
    { accessToken : AccessToken
    , baseUrl : String
    , reason : Maybe String
    , roomId : String
    , userId : String
    , versions : Maybe V.Versions
    }


invite : InviteInput -> FutureTask
invite { accessToken, baseUrl, reason, roomId, userId, versions } =
    C.withBaseUrl baseUrl
        |> Chain.andThen (C.versions versions)
        |> Chain.andThen (C.accessToken accessToken)
        |> Chain.andThen (C.invite { reason = reason, roomId = roomId, userId = userId })
        |> C.toTask


type alias JoinedMembersInput =
    { accessToken : AccessToken
    , baseUrl : String
    , roomId : String
    , versions : Maybe V.Versions
    }


joinedMembers : JoinedMembersInput -> FutureTask
joinedMembers { accessToken, baseUrl, roomId, versions } =
    C.withBaseUrl baseUrl
        |> Chain.andThen (C.versions versions)
        |> Chain.andThen (C.accessToken accessToken)
        |> Chain.andThen (C.joinedMembers { roomId = roomId })
        |> C.toTask


type alias RedactInput =
    { accessToken : AccessToken
    , baseUrl : String
    , eventId : String
    , extraTransactionNoise : String
    , reason : Maybe String
    , roomId : String
    , versions : Maybe V.Versions
    }


redact : RedactInput -> FutureTask
redact { accessToken, baseUrl, eventId, extraTransactionNoise, reason, roomId, versions } =
    C.withBaseUrl baseUrl
        |> Chain.andThen (C.versions versions)
        |> Chain.andThen (C.accessToken accessToken)
        |> Chain.andThen
            (C.withTransactionId
                (\now ->
                    [ Hash.fromInt now
                    , Hash.fromString baseUrl
                    , Hash.fromString eventId
                    , Hash.fromString extraTransactionNoise
                    , Hash.fromString (reason |> Maybe.withDefault "noreason")
                    , Hash.fromString roomId
                    ]
                        |> List.foldl Hash.independent (Hash.fromString "redact")
                        |> Hash.toString
                )
            )
        |> Chain.andThen (C.redact { eventId = eventId, reason = reason, roomId = roomId })
        |> Chain.andThen
            (Chain.maybe <| C.getEvent { eventId = eventId, roomId = roomId })
        |> C.toTask


type alias SendMessageEventInput =
    { accessToken : AccessToken
    , baseUrl : String
    , content : E.Value
    , eventType : String
    , extraTransactionNoise : String
    , roomId : String
    , versions : Maybe V.Versions
    }


sendMessageEvent : SendMessageEventInput -> FutureTask
sendMessageEvent { accessToken, baseUrl, content, eventType, extraTransactionNoise, roomId, versions } =
    C.withBaseUrl baseUrl
        |> Chain.andThen (C.versions versions)
        |> Chain.andThen (C.accessToken accessToken)
        |> Chain.andThen
            (C.withTransactionId
                (\now ->
                    [ Hash.fromInt now
                    , Hash.fromString baseUrl
                    , Hash.fromString (E.encode 0 content)
                    , Hash.fromString eventType
                    , Hash.fromString extraTransactionNoise
                    , Hash.fromString roomId
                    ]
                        |> List.foldl Hash.independent (Hash.fromString "send message")
                        |> Hash.toString
                )
            )
        |> Chain.andThen (C.sendMessageEvent { content = content, eventType = eventType, roomId = roomId })
        -- TODO: Get event from API to see what it looks like
        |> C.toTask


type alias SendStateKeyInput =
    { accessToken : AccessToken
    , baseUrl : String
    , content : E.Value
    , eventType : String
    , roomId : String
    , stateKey : String
    , versions : Maybe V.Versions
    }


sendStateKey : SendStateKeyInput -> FutureTask
sendStateKey { accessToken, baseUrl, content, eventType, roomId, stateKey, versions } =
    C.withBaseUrl baseUrl
        |> Chain.andThen (C.versions versions)
        |> Chain.andThen (C.accessToken accessToken)
        |> Chain.andThen (C.sendStateEvent { content = content, eventType = eventType, roomId = roomId, stateKey = stateKey })
        -- TODO: Get event from API to see what it looks like
        |> C.toTask


type alias SyncInput =
    { accessToken : AccessToken
    , baseUrl : String
    , filter : Maybe String
    , fullState : Maybe Bool
    , setPresence : Maybe Enums.UserPresence
    , since : Maybe String
    , timeout : Maybe Int
    , versions : Maybe V.Versions
    }


sync : SyncInput -> FutureTask
sync { accessToken, baseUrl, filter, fullState, setPresence, since, timeout, versions } =
    C.withBaseUrl baseUrl
        |> Chain.andThen (C.versions versions)
        |> Chain.andThen (C.accessToken accessToken)
        |> Chain.andThen
            (C.sync
                { filter = filter
                , fullState = fullState
                , setPresence = setPresence
                , since = since
                , timeout = timeout
                }
            )
        |> C.toTask
