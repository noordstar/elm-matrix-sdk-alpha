module Internal.Vault exposing (..)

{-| The Vault type is the keychain that stores all tokens, values,
numbers and other types that need to be remembered.

This file combines the internal functions with the API endpoints to create a fully functional Vault keychain.

-}

import Dict
import Internal.Api.Credentials as Credentials exposing (Credentials)
import Internal.Api.Sync.Main exposing (SyncInput)
import Internal.Api.Task as Api
import Internal.Api.VaultUpdate exposing (VaultUpdate(..))
import Internal.Event as Event
import Internal.Invite as Invite
import Internal.Room as Room
import Internal.Tools.Exceptions as X
import Internal.Tools.SpecEnums as Enums
import Internal.Values.Room as IRoom
import Internal.Values.RoomInvite exposing (IRoomInvite)
import Internal.Values.StateManager as StateManager
import Internal.Values.Vault as Internal
import Json.Encode as E
import Task exposing (Task)


{-| You can consider the `Vault` type as a large ring of keys,
and Elm will figure out which key to use.
If you pass the `Vault` into any function, then the library will look for
the right keys and tokens to get the right information.
-}
type Vault
    = Vault
        { cred : Internal.IVault
        , context : Credentials
        }


{-| Get a Vault type based on an unknown access token.

This is an easier way to connect to a Matrix homeserver, but your access may end
when the access token expires, is revoked or something else happens.

-}
fromAccessToken : { baseUrl : String, accessToken : String } -> Vault
fromAccessToken { baseUrl, accessToken } =
    Credentials.fromBaseUrl baseUrl
        |> Credentials.addToken accessToken
        |> (\context ->
                { cred = Internal.init, context = context }
           )
        |> Vault


{-| Get a Vault type using a username and password.
-}
fromLoginVault : { username : String, password : String, baseUrl : String } -> Vault
fromLoginVault { username, password, baseUrl } =
    Credentials.fromBaseUrl baseUrl
        |> Credentials.addUsernameAndPassword
            { username = username
            , password = password
            }
        |> (\context ->
                { cred = Internal.init, context = context }
           )
        |> Vault


{-| Get personal account data linked to an account.
-}
accountData : String -> Vault -> Maybe E.Value
accountData key (Vault { cred }) =
    Internal.accountData key cred


{-| Get a user's invited rooms.
-}
getInvites : Vault -> List Invite.RoomInvite
getInvites (Vault { cred, context }) =
    Internal.getInvites cred
        |> List.map (Invite.withCredentials context)


{-| Get a room based on its id.
-}
getRoomById : String -> Vault -> Maybe Room.Room
getRoomById roomId (Vault { cred, context }) =
    Internal.getRoomById roomId cred
        |> Maybe.map (Room.withCredentials context)


{-| Insert an internal room type into the credentials.
-}
insertInternalRoom : IRoom.IRoom -> Vault -> Vault
insertInternalRoom iroom (Vault data) =
    Vault { data | cred = Internal.insertRoom iroom data.cred }


{-| Internal a full room type into the credentials.
-}
insertRoom : Room.Room -> Vault -> Vault
insertRoom =
    Room.withoutCredentials >> insertInternalRoom


{-| Join a Matrix room by its id.
-}
joinRoomById : String -> Vault -> Task X.Error VaultUpdate
joinRoomById roomId (Vault { context }) =
    Api.joinRoomById { roomId = roomId, reason = Nothing } context


{-| Update the Vault type with new values
-}
updateWith : VaultUpdate -> Vault -> Vault
updateWith vaultUpdate ((Vault ({ cred, context } as data)) as vault) =
    case vaultUpdate of
        MultipleUpdates updates ->
            List.foldl updateWith vault updates

        -- TODO
        AccountDataSet input () ->
            vault

        -- TODO
        BanUser input () ->
            vault

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

        -- TODO
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
                        |> Room.withoutCredentials
                        |> IRoom.insertEvents
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
                        |> Internal.insertRoom
                        |> (|>) cred
                        |> (\v -> Vault { cred = v, context = context })

                _ ->
                    vault

        -- TODO
        InviteSent _ _ ->
            vault

        -- TODO
        JoinedMembersToRoom _ _ ->
            vault

        -- TODO
        JoinedRoom input _ ->
            cred
                |> Internal.removeInvite input.roomId
                |> (\x -> { cred = x, context = context })
                |> Vault

        -- TODO
        LeftRoom input _ ->
            cred
                |> Internal.removeInvite input.roomId
                |> (\x -> { cred = x, context = context })
                |> Vault

        -- TODO
        MessageEventSent _ _ ->
            vault

        -- TODO
        RedactedEvent _ _ ->
            vault

        -- TODO
        StateEventSent _ _ ->
            vault

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
                                                    |> Room.withoutCredentials
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
                                                Room.withoutCredentials room
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

                invites : List IRoomInvite
                invites =
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
            cred
                -- Add global account data
                |> (\c -> List.foldl Internal.insertAccountData c accData)
                -- Add new since token
                |> Internal.addSince output.nextBatch
                -- Add joined rooms
                |> List.foldl Internal.insertRoom
                |> (|>) jRooms
                -- Add invites
                |> List.foldl Internal.addInvite
                |> (|>) invites
                |> (\x -> { cred = x, context = context })
                |> Vault

        UpdateAccessToken token ->
            Vault { data | context = Credentials.addToken token context }

        UpdateVersions versions ->
            Vault { data | context = Credentials.addVersions versions context }

        UpdateWhoAmI whoami ->
            Vault { data | context = Credentials.addWhoAmI whoami context }

        -- TODO: Save ALL info
        LoggedInWithUsernameAndPassword _ output ->
            Vault { data | context = Credentials.addToken output.accessToken context }


{-| Set personal account data
-}
setAccountData : String -> E.Value -> Vault -> Task X.Error VaultUpdate
setAccountData key value (Vault { context }) =
    Api.setAccountData { content = value, eventType = key, roomId = Nothing } context


{-| Synchronize vault
-}
sync : Vault -> Task X.Error VaultUpdate
sync (Vault { cred, context }) =
    let
        syncInput : SyncInput
        syncInput =
            { filter = Nothing
            , fullState = Nothing
            , setPresence = Nothing
            , since = Internal.getSince cred
            , timeout = Just 30
            }
    in
    Api.sync syncInput context
        -- TODO: The sync function is described as "updating all the tokens".
        -- TODO: For this reason, (only) the sync function should handle errors
        -- TODO: that indicate that the user's access tokens have expired.
        -- TODO: This implementation needs to be tested.
        |> Task.onError
            (\err ->
                case err of
                    X.UnsupportedSpecVersion ->
                        Task.fail err

                    X.SDKException _ ->
                        Task.fail err

                    X.InternetException _ ->
                        Task.fail err

                    -- TODO: The login should be different when soft_logout.
                    -- TODO: Add support for refresh token.
                    X.ServerException (X.M_UNKNOWN_TOKEN _) ->
                        Api.loginMaybeSync syncInput context

                    X.ServerException (X.M_MISSING_TOKEN _) ->
                        Api.loginMaybeSync syncInput context

                    X.ServerException _ ->
                        Task.fail err
            )


{-| Get a list of all synchronised rooms.
-}
rooms : Vault -> List Room.Room
rooms (Vault { cred, context }) =
    cred
        |> Internal.getRooms
        |> List.map (Room.withCredentials context)
