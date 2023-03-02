module Internal.Credentials exposing (..)

{-| The Credentials type is the keychain that stores all tokens, values,
numbers and other types that need to be remembered.

This file combines the internal functions with the API endpoints to create a fully functional Credentials keychain.

-}

import Dict
import Internal.Api.All as Api
import Internal.Event as Event
import Internal.Room as Room
import Internal.Tools.Exceptions as X
import Internal.Values.Credentials as Internal
import Internal.Values.Event as IEvent
import Internal.Values.Room as IRoom
import Internal.Values.StateManager as StateManager
import Task exposing (Task)


{-| You can consider the `Credentials` type as a large ring of keys,
and Elm will figure out which key to use.
If you pass the `Credentials` into any function, then the library will look for
the right keys and tokens to get the right information.
-}
type alias Credentials =
    Internal.Credentials


{-| Get a Credentials type based on an unknown access token.

This is an easier way to connect to a Matrix homeserver, but your access may end
when the access token expires, is revoked or something else happens.

-}
fromAccessToken : { homeserver : String, accessToken : String } -> Credentials
fromAccessToken =
    Internal.fromAccessToken


{-| Get a Credentials type using a username and password.
-}
fromLoginCredentials : { username : String, password : String, homeserver : String } -> Credentials
fromLoginCredentials =
    Internal.fromLoginCredentials


{-| Get a room based on its id.
-}
getRoomById : String -> Credentials -> Maybe Room.Room
getRoomById roomId credentials =
    Internal.getRoomById roomId credentials
        |> Maybe.map
            (Room.init
                { accessToken = Internal.getAccessTokenType credentials
                , baseUrl = Internal.getBaseUrl credentials
                , versions = Internal.getVersions credentials
                }
            )


{-| Insert an internal room type into the credentials.
-}
insertInternalRoom : IRoom.Room -> Credentials -> Credentials
insertInternalRoom =
    Internal.insertRoom


{-| Internal a full room type into the credentials.
-}
insertRoom : Room.Room -> Credentials -> Credentials
insertRoom =
    Room.internalValue >> insertInternalRoom


{-| Update the Credentials type with new values
-}
updateWith : Api.CredUpdate -> Credentials -> Credentials
updateWith credUpdate credentials =
    case credUpdate of
        Api.MultipleUpdates updates ->
            List.foldl updateWith credentials updates

        Api.GetEvent input output ->
            case getRoomById input.roomId credentials of
                Just room ->
                    output
                        |> Event.initFromGetEvent
                        |> Room.addInternalEvent
                        |> (|>) room
                        |> insertRoom
                        |> (|>) credentials

                Nothing ->
                    credentials

        Api.JoinedMembersToRoom _ _ ->
            credentials

        -- TODO
        Api.MessageEventSent _ _ ->
            credentials

        -- TODO
        Api.StateEventSent _ _ ->
            credentials

        -- TODO
        Api.SyncUpdate input output ->
            let
                jRooms =
                    output.rooms
                        |> Maybe.map .join
                        |> Maybe.withDefault Dict.empty
                        |> Dict.toList
                        |> List.map
                            (\( roomId, jroom ) ->
                                case getRoomById roomId credentials of
                                    -- Update existing room
                                    Just room ->
                                        room
                                            |> Room.internalValue
                                            |> IRoom.addEvents
                                                { events =
                                                    jroom.timeline
                                                        |> Maybe.map .events
                                                        |> Maybe.withDefault []
                                                        |> List.map (Event.initFromClientEventWithoutRoomId roomId)
                                                , nextBatch = output.nextBatch
                                                , prevBatch =
                                                    jroom.timeline
                                                        |> Maybe.andThen .prevBatch
                                                        |> Maybe.withDefault (Maybe.withDefault "" input.since)
                                                , stateDelta =
                                                    jroom.state
                                                        |> Maybe.map
                                                            (.events
                                                                >> List.map (Event.initFromClientEventWithoutRoomId roomId)
                                                                >> StateManager.fromEventList
                                                            )
                                                }

                                    -- Add new room
                                    Nothing ->
                                        Room.initFromJoinedRoom { nextBatch = output.nextBatch, roomId = roomId } jroom
                            )
            in
            List.foldl Internal.insertRoom (Internal.addSince output.nextBatch credentials) jRooms

        Api.UpdateAccessToken token ->
            Internal.addAccessToken token credentials

        Api.UpdateVersions versions ->
            Internal.addVersions versions credentials


{-| Synchronize credentials
-}
sync : Credentials -> Task X.Error Api.CredUpdate
sync credentials =
    Api.syncCredentials
        { accessToken = Internal.getAccessTokenType credentials
        , baseUrl = Internal.getBaseUrl credentials
        , filter = Nothing
        , fullState = Nothing
        , setPresence = Nothing
        , since = Internal.getSince credentials
        , timeout = Just 30
        , versions = Internal.getVersions credentials
        }


{-| Get a list of all synchronised rooms.
-}
rooms : Credentials -> List Room.Room
rooms credentials =
    credentials
        |> Internal.getRooms
        |> ({ accessToken = Internal.getAccessTokenType credentials
            , baseUrl = Internal.getBaseUrl credentials
            , versions = Internal.getVersions credentials
            }
                |> Room.init
                |> List.map
           )
