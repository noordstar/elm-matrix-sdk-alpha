module Internal.Event exposing (..)

{-| This module represents the event type in the Matrix API.

Users can use this type to reply to events, to link them, look for other events,
resend other events or forward them elsewhere.

-}

import Internal.Api.GetEvent.Main as GetEvent
import Internal.Api.GetEvent.V1.SpecObjects as GetEventSO
import Internal.Api.GetMessages.V4.SpecObjects as GetMessagesSO
import Internal.Api.Snackbar as Snackbar
import Internal.Api.Sync.V2.SpecObjects as SyncSO
import Internal.Api.VaultUpdate exposing (Vnackbar)
import Internal.Tools.Timestamp exposing (Timestamp)
import Internal.Values.Event as Internal
import Json.Encode as E


{-| The central event type. This type will be used by the user and will be directly interacted with.
-}
type alias Event =
    Vnackbar Internal.IEvent


{-| Create an internal event type from an API endpoint event object.
This function is placed in this file to respect file hierarchy and avoid circular imports.
-}
initFromGetEvent : GetEvent.EventOutput -> Internal.IEvent
initFromGetEvent output =
    Internal.init
        { content = output.content
        , eventId = output.eventId
        , originServerTs = output.originServerTs
        , roomId = output.roomId
        , sender = output.sender
        , stateKey = output.stateKey
        , eventType = output.eventType
        , unsigned =
            output.unsigned
                |> Maybe.map
                    (\(GetEventSO.UnsignedData data) ->
                        { age = data.age
                        , prevContent = data.prevContent
                        , redactedBecause = Maybe.map initFromGetEvent data.redactedBecause
                        , transactionId = data.transactionId
                        }
                    )
        }


{-| Create an internal event type from an API endpoint event object.
This function is placed in this file to respect file hierarchy and avoid circular imports.
-}
initFromGetMessages : GetMessagesSO.ClientEvent -> Internal.IEvent
initFromGetMessages output =
    Internal.init
        { content = output.content
        , eventId = output.eventId
        , originServerTs = output.originServerTs
        , roomId = output.roomId
        , sender = output.sender
        , stateKey = output.stateKey
        , eventType = output.eventType
        , unsigned =
            output.unsigned
                |> Maybe.map
                    (\(GetMessagesSO.UnsignedData data) ->
                        { age = data.age
                        , prevContent = data.prevContent
                        , redactedBecause = Maybe.map initFromGetMessages data.redactedBecause
                        , transactionId = data.transactionId
                        }
                    )
        }


{-| Create an internal event type from an API endpoint event object.
This function is placed in this file to respect file hierarchy and avoid circular imports.
-}
initFromClientEventWithoutRoomId : String -> SyncSO.ClientEventWithoutRoomId -> Internal.IEvent
initFromClientEventWithoutRoomId rId output =
    Internal.init
        { content = output.content
        , eventId = output.eventId
        , originServerTs = output.originServerTs
        , roomId = rId
        , sender = output.sender
        , stateKey = output.stateKey
        , eventType = output.eventType
        , unsigned =
            output.unsigned
                |> Maybe.map
                    (\(SyncSO.UnsignedData data) ->
                        { age = data.age
                        , prevContent = data.prevContent
                        , redactedBecause = Maybe.map (initFromClientEventWithoutRoomId rId) data.redactedBecause
                        , transactionId = data.transactionId
                        }
                    )
        }



{- GETTER FUNCTIONS -}


content : Event -> E.Value
content =
    Snackbar.withoutCandy >> Internal.content


eventId : Event -> String
eventId =
    Snackbar.withoutCandy >> Internal.eventId


originServerTs : Event -> Timestamp
originServerTs =
    Snackbar.withoutCandy >> Internal.originServerTs


roomId : Event -> String
roomId =
    Snackbar.withoutCandy >> Internal.roomId


sender : Event -> String
sender =
    Snackbar.withoutCandy >> Internal.sender


stateKey : Event -> Maybe String
stateKey =
    Snackbar.withoutCandy >> Internal.stateKey


eventType : Event -> String
eventType =
    Snackbar.withoutCandy >> Internal.eventType


age : Event -> Maybe Int
age =
    Snackbar.withoutCandy >> Internal.age


redactedBecause : Event -> Maybe Event
redactedBecause event =
    event
        |> Snackbar.withoutCandy
        |> Internal.redactedBecause
        |> Maybe.map (Snackbar.withCandyFrom event)


transactionId : Event -> Maybe String
transactionId =
    Snackbar.withoutCandy >> Internal.transactionId
