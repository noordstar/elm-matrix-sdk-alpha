module Internal.Api.Sync.V1_4.Convert exposing (..)

import Dict
import Internal.Api.Sync.V1_4.Objects as O
import Internal.Api.Sync.V1_4.SpecObjects as SO


convert : SO.Sync -> O.Sync
convert sync =
    { accountData = convertEventHolder sync.accountData
    , nextBatch = sync.nextBatch
    , presence = convertEventHolder sync.presence
    , rooms = Maybe.map convertRooms sync.rooms
    }


convertEventHolder : Maybe { a | events : List b } -> List b
convertEventHolder =
    Maybe.map .events >> Maybe.withDefault []


convertRooms : SO.Rooms -> O.Rooms
convertRooms rooms =
    { invite =
        Dict.map
            (\_ -> .inviteState >> Maybe.map .events >> Maybe.withDefault [])
            rooms.invite
    , join = Dict.map (\_ -> convertJoinedRoom) rooms.join
    , knock =
        Dict.map
            (\_ -> .knockState >> Maybe.map .events >> Maybe.withDefault [])
            rooms.knock
    , leave = Dict.map (\_ -> convertLeftRoom) rooms.leave
    }


convertJoinedRoom : SO.JoinedRoom -> O.JoinedRoom
convertJoinedRoom room =
    { accountData = convertEventHolder room.accountData
    , ephemeral = convertEventHolder room.ephemeral
    , state = convertEventHolder room.state |> List.map convertClientEventWithoutRoomId
    , summary = room.summary
    , timeline = Maybe.map convertTimeline room.timeline
    , unreadNotifications = room.unreadNotifications
    , unreadThreadNotifications = room.unreadThreadNotifications
    }


convertClientEventWithoutRoomId : SO.ClientEventWithoutRoomId -> O.ClientEventWithoutRoomId
convertClientEventWithoutRoomId event =
    { content = event.content
    , eventId = event.eventId
    , originServerTs = event.originServerTs
    , sender = event.sender
    , stateKey = event.stateKey
    , contentType = event.contentType
    , unsigned = Maybe.map convertUnsigned event.unsigned
    }


convertUnsigned : SO.UnsignedData -> O.UnsignedData
convertUnsigned (SO.UnsignedData data) =
    O.UnsignedData
        { age = data.age
        , prevContent = data.prevContent
        , redactedBecause = Maybe.map convertClientEventWithoutRoomId data.redactedBecause
        , transactionId = data.transactionId
        }


convertTimeline : SO.Timeline -> O.Timeline
convertTimeline timeline =
    { events = List.map convertClientEventWithoutRoomId timeline.events
    , limited = timeline.limited
    , prevBatch = timeline.prevBatch
    }


convertLeftRoom : SO.LeftRoom -> O.LeftRoom
convertLeftRoom room =
    { accountData = convertEventHolder room.accountData
    , state = convertEventHolder room.state |> List.map convertClientEventWithoutRoomId
    , timeline = Maybe.map convertTimeline room.timeline
    }
