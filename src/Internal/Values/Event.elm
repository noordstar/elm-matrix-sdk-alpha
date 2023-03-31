module Internal.Values.Event exposing (..)

import Internal.Tools.Timestamp exposing (Timestamp)
import Json.Encode as E


type IEvent
    = IEvent
        { content : E.Value
        , eventId : String
        , originServerTs : Timestamp
        , roomId : String
        , sender : String
        , stateKey : Maybe String
        , eventType : String
        , unsigned :
            Maybe
                { age : Maybe Int
                , prevContent : Maybe E.Value
                , redactedBecause : Maybe IEvent
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
    , eventType : String
    , unsigned :
        Maybe
            { age : Maybe Int
            , prevContent : Maybe E.Value
            , redactedBecause : Maybe IEvent
            , transactionId : Maybe String
            }
    }
    -> IEvent
init =
    IEvent



{- GETTER FUNCTIONS -}


content : IEvent -> E.Value
content (IEvent e) =
    e.content


eventId : IEvent -> String
eventId (IEvent e) =
    e.eventId


originServerTs : IEvent -> Timestamp
originServerTs (IEvent e) =
    e.originServerTs


roomId : IEvent -> String
roomId (IEvent e) =
    e.roomId


sender : IEvent -> String
sender (IEvent e) =
    e.sender


stateKey : IEvent -> Maybe String
stateKey (IEvent e) =
    e.stateKey


eventType : IEvent -> String
eventType (IEvent e) =
    e.eventType


age : IEvent -> Maybe Int
age (IEvent e) =
    e.unsigned
        |> Maybe.andThen .age


redactedBecause : IEvent -> Maybe IEvent
redactedBecause (IEvent e) =
    e.unsigned
        |> Maybe.andThen .redactedBecause


transactionId : IEvent -> Maybe String
transactionId (IEvent e) =
    e.unsigned
        |> Maybe.andThen .transactionId


type BlindEvent
    = BlindEvent { eventType : String, content : E.Value }


blindContent : BlindEvent -> E.Value
blindContent (BlindEvent be) =
    be.content


blindContentType : BlindEvent -> String
blindContentType (BlindEvent be) =
    be.eventType
