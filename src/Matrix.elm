module Matrix exposing
    ( Vault, fromLoginCredentials, fromAccessToken
    , sync, VaultUpdate, updateWith
    , getRooms, getRoomById, getInvites
    , joinRoomById
    )

{-| This is the main module of the SDK. Here, you will find basic functions to
interact with the API.


# Create a new Vault

@docs Vault, fromLoginCredentials, fromAccessToken


# Keeping your Vault up-to-date

@docs sync, VaultUpdate, updateWith


# Exploring your vault

@docs getRooms, getRoomById, getInvites


# Taking action

@docs joinRoomById

-}

import Internal.Api.VaultUpdate as Api
import Internal.Invite exposing (RoomInvite)
import Internal.Room exposing (Room)
import Internal.Tools.Exceptions as X
import Internal.Vault
import Task exposing (Task)


{-| The Matrix API requires you to keep track of a lot of tokens, keys, values and more.
Luckily, you don't need to!

You can view the `Vault` as a large box of keys that will help you get
the information that you need. The type also caches information that it receives
from the API, so you can also ask it for information that it has seen before.

-}
type alias Vault =
    Internal.Vault.Vault


{-| The `VaultUpdate` is a type that helps you keep your `Vault` type up-to-date.
Sometimes, the API will tell you to change certain tokens, and this SDK will
translate those instructions to a `VaultUpdate` that you can feed to your `Vault`.
-}
type alias VaultUpdate =
    Api.VaultUpdate


{-| Create a new vault based on an access token.
Keep in mind that access tokens might eventually be revoked or expire,
so it is better to use login credentials if you're planning to use a Vault long-term.
-}
fromAccessToken : { accessToken : String, baseUrl : String } -> Vault
fromAccessToken =
    Internal.Vault.fromAccessToken


{-| Based on a user's username and password, you can create a vault that will automatically
log in if an access token ever happens to run out, expire or lose contact in any other way.
-}
fromLoginCredentials : { baseUrl : String, username : String, password : String } -> Vault
fromLoginCredentials =
    Internal.Vault.fromLoginVault


{-| Whenever you're asking the Matrix API for information that your Vault doesn't have,
you will receive a `VaultUpdate` type. This will reorganise your Vault with the newly
gained information.

After having updated your vault, it (usually) has all the information you need.

-}
updateWith : VaultUpdate -> Vault -> Vault
updateWith =
    Internal.Vault.updateWith


{-| The Matrix API is always looking for new ways to optimize synchronising events to your client.
Luckily, you don't need to worry about keeping up a connection!

Your vault is always a snapshot of changes since the last time you updated it.
If you'd like to update it once more, simply run this function and the API will make sure that your Vault has the latest changes.

-}
sync : Vault -> Task X.Error VaultUpdate
sync =
    Internal.Vault.sync


{-| Get all the rooms your user has joined, according to your vault.
-}
getRooms : Vault -> List Room
getRooms =
    Internal.Vault.rooms


{-| Get a Matrix room by its id.
This will only return the room if you have joined the room.
-}
getRoomById : String -> Vault -> Maybe Room
getRoomById =
    Internal.Vault.getRoomById


{-| Get all invites that the user is invited to.
-}
getInvites : Vault -> List RoomInvite
getInvites =
    Internal.Vault.getInvites


{-| Join a Matrix room based on its room id.
-}
joinRoomById : String -> Vault -> Task X.Error VaultUpdate
joinRoomById =
    Internal.Vault.joinRoomById
