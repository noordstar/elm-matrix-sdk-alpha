module Internal.Api.All exposing (..)

import Internal.Api.GetEvent.Main as GetEvent
import Internal.Api.JoinedMembers.Main as JoinedMembers
import Internal.Api.SendMessageEvent.Main as SendMessageEvent
import Internal.Api.SendStateKey.Main as SendStateKey
import Internal.Api.Sync.Main as Sync
import Internal.Api.Versions.Main as Versions


{-| Get a specific event from the Matrix API.
-}
getEvent : List String -> GetEvent.EventInput -> GetEvent.EventOutput
getEvent =
    GetEvent.getEvent


{-| Get a list of members who are part of a Matrix room.
-}
joinedMembers : List String -> JoinedMembers.JoinedMembersInput -> JoinedMembers.JoinedMembersOutput
joinedMembers =
    JoinedMembers.joinedMembers


{-| Send a message event into a Matrix room.
-}
sendMessageEvent : List String -> Maybe (SendMessageEvent.SendMessageEventInput -> SendMessageEvent.SendMessageEventOutput)
sendMessageEvent =
    SendMessageEvent.sendMessageEvent


{-| Send a state event into a Matrix room.
-}
sendStateEvent : List String -> SendStateKey.SendStateKeyInput -> SendStateKey.SendStateKeyOutput
sendStateEvent =
    SendStateKey.sendStateKey


{-| Get the latest sync from the Matrix API.
-}
syncCredentials : List String -> Sync.SyncInput -> Sync.SyncOutput
syncCredentials =
    Sync.sync


{-| Get all supported versions on the Matrix homeserver.
-}
versions : Versions.VersionsInput -> Versions.VersionsOutput
versions =
    Versions.getVersions
