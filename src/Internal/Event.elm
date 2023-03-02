module Internal.Event exposing (..)

{-| This module represents the event type in the Matrix API.

Users can use this type to reply to events, to link them, look for other events,
resend other events or forward them elsewhere.

-}

import Internal.Api.GetEvent.Main as GetEvent
import Internal.Api.GetEvent.V1.SpecObjects as GetEventSO
import Internal.Api.PreApi.Objects.Versions as V
import Internal.Api.Sync.V2.SpecObjects as SyncSO
import Internal.Tools.LoginValues exposing (AccessToken)
import Internal.Tools.Timestamp exposing (Timestamp)
import Internal.Values.Event as Internal
import Json.Encode as E


{-| The central event type. This type will be used by the user and will be directly interacted with.
-}
type Event
    = Event
        { event : Internal.Event
        , accessToken : AccessToken
        , baseUrl : String
        , versions : Maybe V.Versions
        }


{-| Using the credentials' background information and an internal event type,
create an interactive event type.
-}
init : { accessToken : AccessToken, baseUrl : String, versions : Maybe V.Versions } -> Internal.Event -> Event
init { accessToken, baseUrl, versions } event =
    Event
        { event = event
        , accessToken = accessToken
        , baseUrl = baseUrl
        , versions = versions
        }


{-| Create an internal event type from an API endpoint event object.
This function is placed in this file to respect file hierarchy and avoid circular imports.
-}
initFromGetEvent : GetEvent.EventOutput -> Internal.Event
initFromGetEvent output =
    Internal.init
        { content = output.content
        , eventId = output.eventId
        , originServerTs = output.originServerTs
        , roomId = output.roomId
        , sender = output.sender
        , stateKey = output.stateKey
        , contentType = output.contentType
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
initFromClientEventWithoutRoomId : String -> SyncSO.ClientEventWithoutRoomId -> Internal.Event
initFromClientEventWithoutRoomId rId output =
    Internal.init
        { content = output.content
        , eventId = output.eventId
        , originServerTs = output.originServerTs
        , roomId = rId
        , sender = output.sender
        , stateKey = output.stateKey
        , contentType = output.contentType
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


{-| Get the internal event type that is hidden in the interactive event type.
-}
internalValue : Event -> Internal.Event
internalValue (Event { event }) =
    event



{- GETTER FUNCTIONS -}


content : Event -> E.Value
content =
    internalValue >> Internal.content


eventId : Event -> String
eventId =
    internalValue >> Internal.eventId


originServerTs : Event -> Timestamp
originServerTs =
    internalValue >> Internal.originServerTs


roomId : Event -> String
roomId =
    internalValue >> Internal.roomId


sender : Event -> String
sender =
    internalValue >> Internal.sender


stateKey : Event -> Maybe String
stateKey =
    internalValue >> Internal.stateKey


contentType : Event -> String
contentType =
    internalValue >> Internal.contentType


age : Event -> Maybe Int
age =
    internalValue >> Internal.age


redactedBecause : Event -> Maybe Event
redactedBecause (Event data) =
    data.event
        |> Internal.redactedBecause
        |> Maybe.map
            (\event ->
                Event { data | event = event }
            )


transactionId : Event -> Maybe String
transactionId =
    internalValue >> Internal.transactionId
