module Internal.Api.All exposing (..)

import Hash
import Internal.Api.GetEvent.Main as GetEvent
import Internal.Api.JoinedMembers.Main as JoinedMembers
import Internal.Api.PreApi.Main as PreApi
import Internal.Api.PreApi.Objects.Versions as V
import Internal.Api.Redact.Main as Redact
import Internal.Api.SendMessageEvent.Main as SendMessageEvent
import Internal.Api.SendStateKey.Main as SendStateKey
import Internal.Api.Sync.Main as Sync
import Internal.Tools.Exceptions as X
import Internal.Tools.LoginValues exposing (AccessToken)
import Internal.Tools.SpecEnums as Enums
import Internal.Tools.ValueGetter as VG
import Json.Encode as E
import Task exposing (Task)


type CredUpdate
    = MultipleUpdates (List CredUpdate)
      -- Updates as a result of API calls
    | GetEvent GetEvent.EventInput GetEvent.EventOutput
    | JoinedMembersToRoom JoinedMembers.JoinedMembersInput JoinedMembers.JoinedMembersOutput
    | MessageEventSent SendMessageEvent.SendMessageEventInput SendMessageEvent.SendMessageEventOutput
    | RedactedEvent Redact.RedactInput Redact.RedactOutput
    | StateEventSent SendStateKey.SendStateKeyInput SendStateKey.SendStateKeyOutput
    | SyncUpdate Sync.SyncInput Sync.SyncOutput
      -- Updates as a result of getting data early
    | UpdateAccessToken String
    | UpdateVersions V.Versions


type alias Future a =
    Task X.Error a


type alias GetEventInput =
    { accessToken : AccessToken
    , baseUrl : String
    , eventId : String
    , roomId : String
    , versions : Maybe V.Versions
    }


{-| Get a specific event from the Matrix API.
-}
getEvent : GetEventInput -> Future CredUpdate
getEvent data =
    VG.withInfo2
        (\accessToken versions ->
            let
                input : GetEvent.EventInput
                input =
                    { accessToken = accessToken
                    , baseUrl = data.baseUrl
                    , eventId = data.eventId
                    , roomId = data.roomId
                    }
            in
            GetEvent.getEvent versions.versions input
                |> Task.map
                    (\output ->
                        MultipleUpdates
                            [ GetEvent input output
                            , UpdateAccessToken accessToken
                            , UpdateVersions versions
                            ]
                    )
        )
        (PreApi.accessToken data.baseUrl data.accessToken)
        (PreApi.versions data.baseUrl data.versions)


type alias JoinedMembersInput =
    { accessToken : AccessToken
    , baseUrl : String
    , roomId : String
    , versions : Maybe V.Versions
    }


{-| Get a list of members who are part of a Matrix room.
-}
joinedMembers : JoinedMembersInput -> Future CredUpdate
joinedMembers data =
    VG.withInfo2
        (\accessToken versions ->
            let
                input : JoinedMembers.JoinedMembersInput
                input =
                    { accessToken = accessToken
                    , baseUrl = data.baseUrl
                    , roomId = data.roomId
                    }
            in
            JoinedMembers.joinedMembers versions.versions input
                |> Task.map
                    (\output ->
                        MultipleUpdates
                            [ JoinedMembersToRoom input output
                            , UpdateAccessToken accessToken
                            , UpdateVersions versions
                            ]
                    )
        )
        (PreApi.accessToken data.baseUrl data.accessToken)
        (PreApi.versions data.baseUrl data.versions)


type alias RedactEventInput =
    { accessToken : AccessToken
    , baseUrl : String
    , eventId : String
    , reason : Maybe String
    , roomId : String
    , versions : Maybe V.Versions
    , extraTransactionNoise : String
    }


{-| Redact an event from a Matrix room.
-}
redact : RedactEventInput -> Future CredUpdate
redact data =
    VG.withInfo3
        (\accessToken versions transactionId ->
            let
                input : Redact.RedactInput
                input =
                    { accessToken = accessToken
                    , baseUrl = data.baseUrl
                    , roomId = data.roomId
                    , eventId = data.eventId
                    , txnId = transactionId
                    , reason = data.reason
                    }
            in
            -- TODO: As an option, the API may get this event to see
            -- what the event looks like now.
            Redact.redact versions.versions input
                |> Task.map
                    (\output ->
                        MultipleUpdates
                            [ RedactedEvent input output
                            ]
                    )
        )
        (PreApi.accessToken data.baseUrl data.accessToken)
        (PreApi.versions data.baseUrl data.versions)
        (PreApi.transactionId
            (\timestamp ->
                [ Hash.fromInt timestamp
                , Hash.fromString data.baseUrl
                , Hash.fromString data.eventId
                , Hash.fromString data.roomId
                , Hash.fromString (data.reason |> Maybe.withDefault "no-reason")
                , Hash.fromString data.extraTransactionNoise
                ]
                    |> List.foldl Hash.dependent (Hash.fromInt 0)
                    |> Hash.toString
                    |> (++) "elm"
            )
        )


type alias SendMessageEventInput =
    { accessToken : AccessToken
    , baseUrl : String
    , content : E.Value
    , eventType : String
    , roomId : String
    , versions : Maybe V.Versions
    , extraTransactionNoise : String
    }


{-| Send a message event into a Matrix room.
-}
sendMessageEvent : SendMessageEventInput -> Future CredUpdate
sendMessageEvent data =
    VG.withInfo3
        (\accessToken versions transactionId ->
            let
                input : SendMessageEvent.SendMessageEventInput
                input =
                    { accessToken = accessToken
                    , baseUrl = data.baseUrl
                    , content = data.content
                    , eventType = data.eventType
                    , roomId = data.roomId
                    , transactionId = transactionId
                    }
            in
            SendMessageEvent.sendMessageEvent versions.versions input
                |> Task.map
                    (\output ->
                        MultipleUpdates
                            [ MessageEventSent input output
                            , UpdateAccessToken accessToken
                            , UpdateVersions versions
                            ]
                    )
        )
        (PreApi.accessToken data.baseUrl data.accessToken)
        (PreApi.versions data.baseUrl data.versions)
        (PreApi.transactionId
            (\timestamp ->
                [ Hash.fromInt timestamp
                , Hash.fromString data.baseUrl
                , Hash.fromString data.eventType
                , Hash.fromString data.roomId
                , Hash.fromString data.extraTransactionNoise
                ]
                    |> List.foldl Hash.dependent (Hash.fromInt 0)
                    |> Hash.toString
                    |> (++) "elm"
            )
        )


type alias SendStateKeyInput =
    { accessToken : AccessToken
    , baseUrl : String
    , content : E.Value
    , eventType : String
    , roomId : String
    , stateKey : String
    , versions : Maybe V.Versions
    }


{-| Send a state event into a Matrix room.
-}
sendStateEvent : SendStateKeyInput -> Future CredUpdate
sendStateEvent data =
    VG.withInfo2
        (\accessToken versions ->
            let
                input : SendStateKey.SendStateKeyInput
                input =
                    { accessToken = accessToken
                    , baseUrl = data.baseUrl
                    , content = data.content
                    , eventType = data.eventType
                    , roomId = data.roomId
                    , stateKey = data.stateKey
                    }
            in
            SendStateKey.sendStateKey versions.versions input
                |> Task.map
                    (\output ->
                        MultipleUpdates
                            [ StateEventSent input output
                            , UpdateAccessToken accessToken
                            , UpdateVersions versions
                            ]
                    )
        )
        (PreApi.accessToken data.baseUrl data.accessToken)
        (PreApi.versions data.baseUrl data.versions)


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


{-| Get the latest sync from the Matrix API.
-}
syncCredentials : SyncInput -> Future CredUpdate
syncCredentials data =
    VG.withInfo2
        (\accessToken versions ->
            let
                input : Sync.SyncInput
                input =
                    { accessToken = accessToken
                    , baseUrl = data.baseUrl
                    , filter = data.filter
                    , fullState = data.fullState
                    , setPresence = data.setPresence
                    , since = data.since
                    , timeout = data.timeout
                    }
            in
            Sync.sync versions.versions input
                |> Task.map
                    (\output ->
                        MultipleUpdates
                            [ SyncUpdate input output
                            , UpdateAccessToken accessToken
                            , UpdateVersions versions
                            ]
                    )
        )
        (PreApi.accessToken data.baseUrl data.accessToken)
        (PreApi.versions data.baseUrl data.versions)
