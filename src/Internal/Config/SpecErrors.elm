module Internal.Config.SpecErrors exposing (..)

{-| Sometimes, the Matrix spec suggests to interpret an HTTP response as a certain
error, even if the server doesn't explicitly say so.

In such cases, the following constants are used to indicate that such an error has occurred.

-}


{-| A user attempts to get information but the homeserver does not recognize the access token that the user has provided.
-}
accessTokenNotRecognized : String
accessTokenNotRecognized =
    "Unrecognised access token."


{-| A user attempts to change account data that is controlled by the server.
-}
accountDataControlledByServer : String
accountDataControlledByServer =
    "You cannot change this account data type as it's controlled by the server."


{-| A user tries to set account data, but they are not allowed to do so.
-}
accountDataSetNotAllowed : String
accountDataSetNotAllowed =
    "You are not authorized to set this account data."


{-| The appservice cannot masquerade as the user or has not registered them.
-}
appserviceCannotMasquerade : String
appserviceCannotMasquerade =
    "Application service has not registered this user."


{-| The user attempts to ban another user, but they are not allowed to do so.
For example,

  - The banner is not currently in the room.
  - The banner’s power level is insufficient to ban users from the room.

-}
banNotAllowed : String
banNotAllowed =
    "You do not have permission to ban someone in this room."


{-| A user tries to access to an event, but either it doesn't exist or they lack permission to read it.
-}
eventNotFound : String
eventNotFound =
    "The event was not found or you do not have permission to read this event."


{-| A user made a request that is considered invalid. For example:

  - The request body is malformed
  - The user tried to interact with users from a homeserver that do not support the action

-}
invalidRequest : String
invalidRequest =
    "The request is invalid."


{-| A user tries to invite another user to a room, but they lack the permission to do so. Example reasons for rejection are:

  - The invitee has been banned from the room.
  - The invitee is already a member of the room.
  - The inviter is not currently in the room.
  - The inviter's power level is insufficient to invite users to the room.

-}
inviteNotAllowed : String
inviteNotAllowed =
    "You do not have permission to invite the user to the room."


{-| A user tries to join a room that they're not allowed to join.
-}
joinNotAllowed : String
joinNotAllowed =
    "You do not have permission to join the room."


{-| A user tries to access information from a room that they don't have access to.
-}
notInRoom : String
notInRoom =
    "You aren't a member of the room."


{-| A user tries to make an HTTP request, but it was ratelimited.
-}
ratelimited : String
ratelimited =
    "This request was rate-limited."


{-| A user is trying to send an invite to a room, but they're not allowed to do so.
-}
sendNotAllowed : String
sendNotAllowed =
    "You don't have permission to send the event into the room."
