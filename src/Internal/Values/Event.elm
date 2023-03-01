module Internal.Values.Event exposing (..)

import Internal.Tools.Timestamp exposing (Timestamp)
import Json.Encode as E


type Event
    = Event
        { content : E.Value
        , eventId : String
        , originServerTs : Timestamp
        , roomId : String
        , sender : String
        , stateKey : Maybe String
        , contentType : String
        , unsigned :
            Maybe
                { age : Maybe Int
                , prevContent : Maybe E.Value
                , redactedBecause : Maybe Event
                , transactionId : Maybe String
                }
        }


init :
    { content : E.Value
    , eventId : String
    , originServerTs : Timestamp
    , roomId : String
    , sender : String
    , stateKey : Maybe String
    , contentType : String
    , unsigned :
        Maybe
            { age : Maybe Int
            , prevContent : Maybe E.Value
            , redactedBecause : Maybe Event
            , transactionId : Maybe String
            }
    }
    -> Event
init =
    Event



{- GETTER FUNCTIONS -}


content : Event -> E.Value
content (Event e) =
    e.content


eventId : Event -> String
eventId (Event e) =
    e.eventId


originServerTs : Event -> Timestamp
originServerTs (Event e) =
    e.originServerTs


roomId : Event -> String
roomId (Event e) =
    e.roomId


sender : Event -> String
sender (Event e) =
    e.sender


stateKey : Event -> Maybe String
stateKey (Event e) =
    e.stateKey


contentType : Event -> String
contentType (Event e) =
    e.contentType


age : Event -> Maybe Int
age (Event e) =
    e.unsigned
        |> Maybe.andThen .age


redactedBecause : Event -> Maybe Event
redactedBecause (Event e) =
    e.unsigned
        |> Maybe.andThen .redactedBecause


transactionId : Event -> Maybe String
transactionId (Event e) =
    e.unsigned
        |> Maybe.andThen .transactionId


type BlindEvent
    = BlindEvent { contentType : String, content : E.Value }


blindContent : BlindEvent -> E.Value
blindContent (BlindEvent be) =
    be.content


blindContentType : BlindEvent -> String
blindContentType (BlindEvent be) =
    be.contentType
