module Internal.Vault exposing (..)

{-| The Vault type is the keychain that stores all tokens, values,
numbers and other types that need to be remembered.

This file combines the internal functions with the API endpoints to create a fully functional Vault keychain.

-}

import Dict
import Internal.Api.Snackbar as Snackbar
import Internal.Api.Sync.Main exposing (SyncInput)
import Internal.Api.Task as Api
import Internal.Api.VaultUpdate exposing (VaultUpdate(..), Vnackbar)
import Internal.Event as Event
import Internal.Invite as Invite
import Internal.Room as Room
import Internal.Tools.SpecEnums as Enums
import Internal.Values.Room as IRoom
import Internal.Values.RoomInvite exposing (IRoomInvite)
import Internal.Values.StateManager as StateManager
import Internal.Values.Vault as Internal
import Json.Encode as E
import Task


{-| You can consider the `Vault` type as a large ring of keys,
and Elm will figure out which key to use.
If you pass the `Vault` into any function, then the library will look for
the right keys and tokens to get the right information.
-}
type alias Vault =
    Vnackbar Internal.IVault


{-| Get personal account data linked to an account.
-}
accountData : String -> Vault -> Maybe E.Value
accountData key =
    Snackbar.withoutCandy >> Internal.accountData key


{-| Get a Vault type based on an unknown access token.

This is an easier way to connect to a Matrix homeserver, but your access may end
when the access token expires, is revoked or something else happens.

-}
fromAccessToken : { baseUrl : String, accessToken : String } -> Vault
fromAccessToken { baseUrl, accessToken } =
    Snackbar.init
        { baseUrl = baseUrl
        , content = Internal.init
        }
        |> Snackbar.addToken accessToken


{-| Get a Vault type using a username and password.
-}
fromLoginVault : { username : String, password : String, baseUrl : String } -> Vault
fromLoginVault { username, password, baseUrl } =
    Snackbar.init
        { baseUrl = baseUrl
        , content = Internal.init
        }
        |> Snackbar.addUsernameAndPassword
            { username = username
            , password = password
            }


{-| Get a user's invited rooms.
-}
invites : Vault -> List Invite.RoomInvite
invites =
    Snackbar.mapList Internal.getInvites


{-| Get a room based on its id.
-}
getRoomById : String -> Vault -> Maybe Room.Room
getRoomById roomId =
    Snackbar.mapMaybe (Internal.getRoomById roomId)


{-| Insert an internal room type into the vault.
-}
insertInternalRoom : IRoom.IRoom -> Vault -> Vault
insertInternalRoom iroom =
    Snackbar.map (Internal.insertRoom iroom)


{-| Internal a full room type into the vault.
-}
insertRoom : Room.Room -> Vault -> Vault
insertRoom =
    Snackbar.withoutCandy >> insertInternalRoom


{-| Join a Matrix room by its id.
-}
joinRoomById : { roomId : String, onResponse : VaultUpdate -> msg, vault : Vault } -> Cmd msg
joinRoomById { roomId, onResponse, vault } =
    Api.joinRoomById { roomId = roomId, reason = Nothing } vault
        |> Task.perform onResponse


{-| Update the Vault type with new values
-}
updateWith : VaultUpdate -> Vault -> Vault
updateWith vaultUpdate vault =
    case vaultUpdate of
        MultipleUpdates updates ->
            List.foldl updateWith vault updates

        -- TODO
        AccountDataSet input () ->
            case input.roomId of
                Just rId ->
                    case getRoomById rId vault of
                        Just room ->
                            room
                                |> Room.addAccountData input.eventType input.content
                                |> insertRoom
                                |> (|>) vault

                        Nothing ->
                            vault

                -- TODO: Add global account data
                Nothing ->
                    vault

        -- TODO
        BanUser input () ->
            vault

        CurrentTimestamp t ->
            Snackbar.map (Internal.insertTimestamp t) vault

        GetEvent input output ->
            case getRoomById input.roomId vault of
                Just room ->
                    output
                        |> Event.initFromGetEvent
                        |> Room.addInternalEvent
                        |> (|>) room
                        |> insertRoom
                        |> (|>) vault

                Nothing ->
                    vault

        GetMessages input output ->
            let
                prevBatch : Maybe String
                prevBatch =
                    case input.direction of
                        Enums.Chronological ->
                            Just output.start

                        Enums.ReverseChronological ->
                            case output.end of
                                Just end ->
                                    Just end

                                Nothing ->
                                    input.to

                nextBatch : Maybe String
                nextBatch =
                    case input.direction of
                        Enums.Chronological ->
                            case output.end of
                                Just end ->
                                    Just end

                                Nothing ->
                                    input.to

                        Enums.ReverseChronological ->
                            Just output.start
            in
            case ( getRoomById input.roomId vault, nextBatch ) of
                ( Just room, Just nb ) ->
                    room
                        |> Snackbar.map
                            (IRoom.insertEvents
                                { events =
                                    output.chunk
                                        |> List.map Event.initFromGetMessages
                                        |> (\x ->
                                                case input.direction of
                                                    Enums.Chronological ->
                                                        x

                                                    Enums.ReverseChronological ->
                                                        List.reverse x
                                           )
                                , prevBatch = prevBatch
                                , nextBatch = nb
                                , stateDelta = Just <| StateManager.fromEventList (List.map Event.initFromGetMessages output.state)
                                }
                            )
                        |> insertRoom
                        |> (|>) vault

                _ ->
                    vault

        -- TODO
        InviteSent _ _ ->
            vault

        -- TODO
        JoinedMembersToRoom _ _ ->
            vault

        JoinedRoom input _ ->
            Snackbar.map (Internal.removeInvite input.roomId) vault

        -- TODO: Remove room from dict of joined rooms
        LeftRoom input () ->
            Snackbar.map (Internal.removeInvite input.roomId) vault

        MessageEventSent { content, eventType, roomId } { eventId } ->
            Maybe.map2
                (\room sender ->
                    room
                        |> Snackbar.map
                            (IRoom.addTemporaryEvent
                                { content = content
                                , eventType = eventType
                                , eventId = eventId
                                , originServerTs = Internal.lastUpdate (Snackbar.withoutCandy vault)
                                , sender = sender
                                , stateKey = Nothing
                                }
                            )
                        |> insertRoom
                        |> (|>) vault
                )
                (getRoomById roomId vault)
                (getUsername vault)
                |> Maybe.withDefault vault

        -- TODO
        RedactedEvent _ _ ->
            vault

        RemoveFailedTask i ->
            Snackbar.removeFailedTask i vault

        StateEventSent { content, eventType, roomId, stateKey } { eventId } ->
            Maybe.map2
                (\room sender ->
                    room
                        |> Snackbar.map
                            (IRoom.addTemporaryEvent
                                { content = content
                                , eventType = eventType
                                , eventId = eventId
                                , originServerTs = Internal.lastUpdate (Snackbar.withoutCandy vault)
                                , sender = sender
                                , stateKey = Just stateKey
                                }
                            )
                        |> insertRoom
                        |> (|>) vault
                )
                (getRoomById roomId vault)
                (getUsername vault)
                |> Maybe.withDefault vault

        SyncUpdate input output ->
            let
                accData : List { content : E.Value, eventType : String, roomId : Maybe String }
                accData =
                    output.accountData
                        |> Maybe.map .events
                        |> Maybe.withDefault []
                        |> List.map (\{ content, eventType } -> { content = content, eventType = eventType, roomId = Nothing })

                jRooms : List IRoom.IRoom
                jRooms =
                    output.rooms
                        |> Maybe.map .join
                        |> Maybe.withDefault Dict.empty
                        |> Dict.toList
                        |> List.map
                            (\( roomId, jroom ) ->
                                case getRoomById roomId vault of
                                    -- Update existing room
                                    Just room ->
                                        (case jroom.timeline of
                                            Just timeline ->
                                                room
                                                    |> Snackbar.withoutCandy
                                                    |> IRoom.addEvents
                                                        { events =
                                                            List.map
                                                                (Event.initFromClientEventWithoutRoomId roomId)
                                                                timeline.events
                                                        , limited = timeline.limited
                                                        , nextBatch = output.nextBatch
                                                        , prevBatch =
                                                            timeline.prevBatch
                                                                |> Maybe.withDefault
                                                                    (Maybe.withDefault "" input.since)
                                                        , stateDelta =
                                                            jroom.state
                                                                |> Maybe.map
                                                                    (.events
                                                                        >> List.map (Event.initFromClientEventWithoutRoomId roomId)
                                                                        >> StateManager.fromEventList
                                                                    )
                                                        }

                                            Nothing ->
                                                Snackbar.withoutCandy room
                                        )
                                            |> (\r ->
                                                    jroom.accountData
                                                        |> Maybe.map .events
                                                        |> Maybe.withDefault []
                                                        |> List.map (\{ content, eventType } -> ( eventType, content ))
                                                        |> Dict.fromList
                                                        |> (\a -> IRoom.insertAccountData a r)
                                               )

                                    -- Add new room
                                    Nothing ->
                                        jroom
                                            |> Room.initFromJoinedRoom { nextBatch = output.nextBatch, roomId = roomId }
                            )

                inviteList : List IRoomInvite
                inviteList =
                    output.rooms
                        |> Maybe.map .invite
                        |> Maybe.withDefault Dict.empty
                        |> Dict.toList
                        |> List.map (Tuple.mapSecond .inviteState)
                        |> List.map (Tuple.mapSecond (Maybe.map .events))
                        |> List.map (Tuple.mapSecond (Maybe.withDefault []))
                        |> List.map (\( roomId, events ) -> { roomId = roomId, events = events })
                        |> List.map Invite.initFromStrippedStateEvent
            in
            Snackbar.map
                (\ivault ->
                    ivault
                        -- Add global account data
                        |> (\c -> List.foldl Internal.insertAccountData c accData)
                        -- Add new since token
                        |> Internal.addSince output.nextBatch
                        -- Add joined rooms
                        |> List.foldl Internal.insertRoom
                        |> (|>) jRooms
                        -- Add invites
                        |> List.foldl Internal.addInvite
                        |> (|>) inviteList
                )
                vault

        TaskFailed s t ->
            Snackbar.addFailedTask
                (\taskId ->
                    ( s
                    , t
                        >> Task.map
                            (\u ->
                                case u of
                                    MultipleUpdates [] ->
                                        RemoveFailedTask taskId

                                    MultipleUpdates l ->
                                        MultipleUpdates (RemoveFailedTask taskId :: l)

                                    _ ->
                                        MultipleUpdates [ RemoveFailedTask taskId, u ]
                            )
                    )
                )
                vault

        UpdateAccessToken token ->
            Snackbar.addToken token vault

        UpdateVersions versions ->
            Snackbar.addVersions versions vault

        UpdateWhoAmI whoami ->
            Snackbar.addWhoAmI whoami vault

        LoggedInWithUsernameAndPassword _ output ->
            Snackbar.addToken output.accessToken vault


getUsername : Vault -> Maybe String
getUsername =
    Snackbar.userId


{-| Set personal account data
-}
setAccountData : { key : String, value : E.Value, onResponse : VaultUpdate -> msg, vault : Vault } -> Cmd msg
setAccountData { key, value, onResponse, vault } =
    Api.setAccountData { content = value, eventType = key, roomId = Nothing } vault
        |> Task.perform onResponse


{-| Synchronize vault
-}
sync : Vault -> (VaultUpdate -> msg) -> Cmd msg
sync vault onResponse =
    let
        syncInput : SyncInput
        syncInput =
            { filter = Nothing
            , fullState = Nothing
            , setPresence = Nothing
            , since = Internal.getSince (Snackbar.withoutCandy vault)
            , timeout = Just 30
            }
    in
    Api.sync syncInput vault
        |> Task.perform onResponse


{-| Get a list of all synchronised rooms.
-}
rooms : Vault -> List Room.Room
rooms =
    Snackbar.mapList Internal.getRooms


settings : (Snackbar.Settings -> Snackbar.Settings) -> Vault -> Vault
settings =
    Snackbar.updateSettings
