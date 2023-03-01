module Internal.Credentials exposing (..)

{-| The Credentials type is the keychain that stores all tokens, values,
numbers and other types that need to be remembered.

This file combines the internal functions with the API endpoints to create a fully functional Credentials keychain.

-}

import Dict
import Internal.Api.All as Api
import Internal.Room as Room
import Internal.Event as Event
import Internal.Values.Credentials as Internal
import Internal.Values.Event as IEvent
import Internal.Values.Room as IRoom


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
insertInternalRoom = Internal.insertRoom

{-| Internal a full room type into the credentials. -}
insertRoom : Room.Room -> Credentials -> Credentials
insertRoom = Room.internalValue >> insertInternalRoom

{-| Update the Credentials type with new values -}
updateWith : Api.CredUpdate -> Credentials -> Credentials
updateWith credUpdate credentials =
    case credUpdate of
        Api.MultipleUpdates updates ->
            List.foldl updateWith credentials updates
        
        Api.GetEvent input output ->
            case getRoomById input.roomId credentials of
                Just room ->
                    output
                        |> IEvent.initFromGetEvent
                        |> Room.addInternalEvent
                        |> (|>) room
                        |> insertRoom
                        |> (|>) credentials
                
                Nothing ->
                    credentials
        
        Api.JoinedMembersToRoom _ _ ->
            credentials -- TODO
        
        Api.MessageEventSent _ _ ->
            credentials -- TODO
        
        Api.StateEventSent _ _ ->
            credentials -- TODO

        Api.SyncUpdate input output ->
            let
                rooms =
                    output.rooms
                    |> Maybe.map .join
                    |> Maybe.withDefault Dict.empty
                    |> Dict.toList
                    |> List.map
                        (\(roomId, jroom)->
                            case getRoomById roomId credentials of
                                -- Update existing room
                                Just room ->
                                    room
                                    |> Room.internalValue
                                    |> IRoom.addEvents
                                    

                                -- Add new room
                                Nothing ->
                                    jroom
                        )
            in
                credentials
        
        Api.UpdateAccessToken token ->
            Internal.addAccessToken token credentials
        
        Api.UpdateVersions versions ->
            Internal.addVersions versions credentials
