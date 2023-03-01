module Internal.Api.All exposing (..)

import Hash
import Internal.Api.GetEvent.Main as GetEvent
import Internal.Api.JoinedMembers.Main as JoinedMembers
import Internal.Api.PreApi.Main as PreApi
import Internal.Api.PreApi.Objects.Versions as V
import Internal.Api.SendMessageEvent.Main as SendMessageEvent
import Internal.Api.SendStateKey.Main as SendStateKey
import Internal.Api.Sync.Main as Sync
import Internal.Tools.Exceptions as X
import Internal.Tools.LoginValues exposing (AccessToken)
import Internal.Tools.SpecEnums as Enums
import Internal.Tools.ValueGetter as VG
import Json.Encode as E
import Task exposing (Task)


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
getEvent : GetEventInput -> Future GetEvent.EventOutput
getEvent data =
    VG.withInfo2
        (\accessToken versions ->
            GetEvent.getEvent
                versions.versions
                { accessToken = accessToken
                , baseUrl = data.baseUrl
                , eventId = data.eventId
                , roomId = data.roomId
                }
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
joinedMembers : JoinedMembersInput -> Future JoinedMembers.JoinedMembersOutput
joinedMembers data =
    VG.withInfo2
        (\accessToken versions ->
            JoinedMembers.joinedMembers
                versions.versions
                { accessToken = accessToken
                , baseUrl = data.baseUrl
                , roomId = data.roomId
                }
        )
        (PreApi.accessToken data.baseUrl data.accessToken)
        (PreApi.versions data.baseUrl data.versions)


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
sendMessageEvent : SendMessageEventInput -> Future SendMessageEvent.SendMessageEventOutput
sendMessageEvent data =
    VG.withInfo3
        (\accessToken versions transactionId ->
            SendMessageEvent.sendMessageEvent
                versions.versions
                { accessToken = accessToken
                , baseUrl = data.baseUrl
                , content = data.content
                , eventType = data.eventType
                , roomId = data.roomId
                , transactionId = transactionId
                }
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
sendStateEvent : SendStateKeyInput -> Future SendStateKey.SendStateKeyOutput
sendStateEvent data =
    VG.withInfo2
        (\accessToken versions ->
            SendStateKey.sendStateKey
                versions.versions
                { accessToken = accessToken
                , baseUrl = data.baseUrl
                , content = data.content
                , eventType = data.eventType
                , roomId = data.roomId
                , stateKey = data.stateKey
                }
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
syncCredentials : SyncInput -> Future Sync.SyncOutput
syncCredentials data =
    VG.withInfo2
        (\accessToken versions ->
            Sync.sync
                versions.versions
                { accessToken = accessToken
                , baseUrl = data.baseUrl
                , filter = data.filter
                , fullState = data.fullState
                , setPresence = data.setPresence
                , since = data.since
                , timeout = data.timeout
                }
        )
        (PreApi.accessToken data.baseUrl data.accessToken)
        (PreApi.versions data.baseUrl data.versions)
