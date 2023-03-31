module Internal.Room exposing (..)

{-| The `Room` type represents a Matrix Room. In here, you will find utilities to ask information about a room.
-}

import Dict
import Internal.Api.Credentials exposing (Credentials)
import Internal.Api.Sync.V2.SpecObjects as Sync
import Internal.Api.Task as Api
import Internal.Api.VaultUpdate exposing (VaultUpdate(..))
import Internal.Event as Event exposing (Event)
import Internal.Tools.Exceptions as X
import Internal.Tools.Hashdict as Hashdict
import Internal.Tools.SpecEnums as Enums
import Internal.Values.Event as IEvent
import Internal.Values.Room as Internal
import Internal.Values.StateManager as StateManager
import Internal.Values.Timeline as Timeline
import Json.Encode as E
import Task exposing (Task)


{-| The `Room` type represents a Matrix Room. It contains context information
such as the `accessToken` that allows the retrieval of new information from
the Matrix API if necessary.

The `Room` type contains utilities to inquire about the room and send messages
to it.

-}
type Room
    = Room
        { room : Internal.IRoom
        , context : Credentials
        }


{-| Create a new object from a joined room.
-}
initFromJoinedRoom : { roomId : String, nextBatch : String } -> Sync.JoinedRoom -> Internal.IRoom
initFromJoinedRoom data jroom =
    Internal.IRoom
        { accountData =
            jroom.accountData
                |> Maybe.map .events
                |> Maybe.withDefault []
                |> List.map (\{ eventType, content } -> ( eventType, content ))
                |> Dict.fromList
        , ephemeral =
            jroom.ephemeral
                |> Maybe.map .events
                |> Maybe.withDefault []
                |> List.map IEvent.BlindEvent
        , events =
            jroom.timeline
                |> Maybe.map .events
                |> Maybe.withDefault []
                |> List.map (Event.initFromClientEventWithoutRoomId data.roomId)
                |> Hashdict.fromList IEvent.eventId
        , roomId = data.roomId
        , timeline =
            jroom.timeline
                |> Maybe.map
                    (\timeline ->
                        Timeline.newFromEvents
                            { events = List.map (Event.initFromClientEventWithoutRoomId data.roomId) timeline.events
                            , nextBatch = data.nextBatch
                            , prevBatch = timeline.prevBatch
                            , stateDelta =
                                jroom.state
                                    |> Maybe.map
                                        (.events
                                            >> List.map (Event.initFromClientEventWithoutRoomId data.roomId)
                                            >> StateManager.fromEventList
                                        )
                            }
                    )
                |> Maybe.withDefault
                    (Timeline.newFromEvents
                        { events = []
                        , nextBatch = data.nextBatch
                        , prevBatch = Nothing
                        , stateDelta = Nothing
                        }
                    )
        }


accountData : String -> Room -> Maybe E.Value
accountData key =
    withoutCredentials >> Internal.accountData key


{-| Adds an internal event to the `Room`. An internal event is a custom event
that has been generated by the client.
-}
addInternalEvent : IEvent.IEvent -> Room -> Room
addInternalEvent ievent (Room ({ room } as data)) =
    Room { data | room = Internal.addEvent ievent room }


{-| Adds an `Event` object to the `Room`. An `Event` is a value from the
`Internal.Event` module that is used to represent an event in a Matrix room.
-}
addEvent : Event -> Room -> Room
addEvent =
    Event.withoutCredentials >> addInternalEvent


{-| Creates a new `Room` object with the given parameters.
-}
withCredentials : Credentials -> Internal.IRoom -> Room
withCredentials context room =
    Room
        { context = context
        , room = room
        }


{-| Retrieves the `Internal.IRoom` type contained within the given `Room`.
-}
withoutCredentials : Room -> Internal.IRoom
withoutCredentials (Room { room }) =
    room


{-| Get a given state event.
-}
getStateEvent : { eventType : String, stateKey : String } -> Room -> Maybe Event
getStateEvent data (Room { room, context }) =
    Internal.getStateEvent data room
        |> Maybe.map (Event.withCredentials context)


{-| Get older events from the Matrix API.
-}
getOlderEvents : { limit : Maybe Int } -> Room -> Task X.Error VaultUpdate
getOlderEvents { limit } (Room { context, room }) =
    case Internal.latestGap room of
        Nothing ->
            Task.succeed (MultipleUpdates [])

        Just { from, to } ->
            Api.getMessages
                { direction = Enums.ReverseChronological
                , filter = Nothing
                , from = Just to
                , limit = limit
                , roomId = Internal.roomId room
                , to = from
                }
                context


{-| Get the most recent events.
-}
mostRecentEvents : Room -> List Event
mostRecentEvents (Room { context, room }) =
    room
        |> Internal.mostRecentEvents
        |> List.map (Event.withCredentials context)


{-| Retrieves the ID of the Matrix room associated with the given `Room`.
-}
roomId : Room -> String
roomId =
    withoutCredentials >> Internal.roomId


{-| Sends a new event to the Matrix room associated with the given `Room`.
-}
sendEvent : { content : E.Value, eventType : String, stateKey : Maybe String } -> Room -> Task X.Error VaultUpdate
sendEvent { eventType, content, stateKey } (Room { context, room }) =
    case stateKey of
        Nothing ->
            Api.sendMessageEvent
                { content = content
                , eventType = eventType
                , extraTransactionNoise = "send-one-message"
                , roomId = Internal.roomId room
                }
                context

        Just s ->
            Api.sendStateEvent
                { content = content
                , eventType = eventType
                , stateKey = s
                , roomId = Internal.roomId room
                }
                context


sendEvents : List { content : E.Value, eventType : String, stateKey : Maybe String } -> Room -> List (Task X.Error VaultUpdate)
sendEvents events (Room { context, room }) =
    List.indexedMap Tuple.pair events
        |> List.map
            (\( i, { eventType, content, stateKey } ) ->
                case stateKey of
                    Nothing ->
                        Api.sendMessageEvent
                            { content = content
                            , eventType = eventType
                            , extraTransactionNoise = "send-message-" ++ String.fromInt i
                            , roomId = Internal.roomId room
                            }
                            context

                    Just s ->
                        Api.sendStateEvent
                            { content = content
                            , eventType = eventType
                            , stateKey = s
                            , roomId = Internal.roomId room
                            }
                            context
            )


{-| Sends a new text message to the Matrix room associated with the given `Room`.
-}
sendMessage : String -> Room -> Task X.Error VaultUpdate
sendMessage text (Room { context, room }) =
    Api.sendMessageEvent
        { content =
            E.object
                [ ( "msgtype", E.string "m.text" )
                , ( "body", E.string text )
                ]
        , eventType = "m.room.message"
        , extraTransactionNoise = "literal-message:" ++ text
        , roomId = Internal.roomId room
        }
        context


sendMessages : List String -> Room -> List (Task X.Error VaultUpdate)
sendMessages pieces (Room { context, room }) =
    pieces
        |> List.indexedMap Tuple.pair
        |> List.map
            (\( i, piece ) ->
                Api.sendMessageEvent
                    { content =
                        E.object
                            [ ( "msgtype", E.string "m.text" )
                            , ( "body", E.string piece )
                            ]
                    , eventType = "m.room.message"
                    , extraTransactionNoise = "literal-message-" ++ String.fromInt i ++ ":" ++ piece
                    , roomId = Internal.roomId room
                    }
                    context
            )


{-| Leave this room.
-}
leave : Room -> Task X.Error VaultUpdate
leave ((Room { context }) as r) =
    Api.leave { roomId = roomId r, reason = Nothing } context


{-| Set account data.
-}
setAccountData : String -> E.Value -> Room -> Task X.Error VaultUpdate
setAccountData key value ((Room { context }) as r) =
    Api.setAccountData { content = value, eventType = key, roomId = Just (roomId r) } context
