module Internal.Api.CredUpdate exposing (getEvent, joinedMembers, sendMessage, sendState, sync)
{-| Sometimes, the `Credentials` type needs to refresh its tokens, log in again,
change some state or adjust its values to be able to keep talking to the server.

That's what the `CredUpdate` type is for. It is a list of changes that the
`Credentials` type needs to make.
-}

import Internal.Api.GetEvent.Main as GetEvent
import Internal.Api.Helpers as H
import Internal.Api.JoinedMembers.Main as JoinedMembers
import Internal.Api.SendMessageEvent.Main as SendMessageEvent
import Internal.Api.SendStateKey.Main as SendStateKey
import Internal.Api.Sync.Main as Sync
import Internal.Api.Versions.Main as Versions
import Internal.Tools.Exceptions as X
import Task exposing (Task)

type CredUpdate
    = MultipleChanges (List CredUpdate)
    | EventDetails GetEvent.EventOutput
    | RoomMemberList JoinedMembers.JoinedMembersOutput
    | MessageEventSent SendMessageEvent.SendMessageEventOutput
    | StateEventSent SendStateKey.SendStateKeyOutput
    | SyncReceived Sync.SyncOutput
    | VersionReceived Versions.VersionsOutput

type alias Updater = Task X.Error CredUpdate

getEvent : Maybe (List String) -> GetEvent.EventInput -> Updater
getEvent versions =
    maybeWithVersions
        { maybeVersions = versions
        , f = GetEvent.getEvent
        , toUpdate = EventDetails
        }
    >> H.retryTask 2

joinedMembers : Maybe (List String) -> JoinedMembers.JoinedMembersInput -> Updater
joinedMembers versions =
    maybeWithVersions
        { maybeVersions = versions
        , f = JoinedMembers.joinedMembers
        , toUpdate = RoomMemberList
        }

sendMessage : Maybe (List String) -> SendMessageEvent.SendMessageEventInput -> Updater
sendMessage versions =
    maybeWithVersions
        { maybeVersions = versions
        , f = SendMessageEvent.sendMessageEvent
        , toUpdate = MessageEventSent
        }
    >> H.retryTask 5

sendState : Maybe (List String) -> SendStateKey.SendStateKeyInput -> Updater
sendState versions =
    maybeWithVersions
        { maybeVersions = versions
        , f = SendStateKey.sendStateKey
        , toUpdate = StateEventSent
        }
    >> H.retryTask 5

sync : Maybe (List String) -> Sync.SyncInput -> Updater
sync versions =
    maybeWithVersions
        { maybeVersions = versions
        , f = Sync.sync
        , toUpdate = SyncReceived
        }
    >> H.retryTask 1


maybeWithVersions : 
    { maybeVersions : Maybe (List String)
    , f : (List String -> Maybe ({ in | baseUrl : String } -> Task X.Error out))
    , toUpdate : (out -> CredUpdate)
    } -> 
    { in | baseUrl : String } -> Updater
maybeWithVersions {maybeVersions, f, toUpdate} params =
    case maybeVersions of
        Just versions ->
            case f versions of
                Just task ->
                    task params
                    |> Task.map toUpdate
                Nothing ->
                    Task.fail X.UnsupportedSpecVersion
        
        Nothing ->
            Versions.getVersions params.baseUrl
            |> Task.andThen
                (\versions ->
                    maybeWithVersions (Just versions.supportedVersions) f toUpdate params
                    |> Task.map
                        (\update ->
                            MultipleChanges
                                [ update
                                , VersionReceived versions
                                ]
                        )
                )

