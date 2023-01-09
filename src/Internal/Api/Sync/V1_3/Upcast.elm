module Internal.Api.Sync.V1_3.Upcast exposing (..)

import Dict
import Internal.Api.Sync.V1_2.Objects as PO
import Internal.Api.Sync.V1_3.Objects as O


upcast : PO.Sync -> O.Sync
upcast sync =
    { accountData = sync.accountData
    , nextBatch = sync.nextBatch
    , presence = sync.presence
    , rooms = Maybe.map upcastRooms sync.rooms
    }


upcastRooms : PO.Rooms -> O.Rooms
upcastRooms rooms =
    { invite = rooms.invite
    , join = Dict.map (\_ -> upcastJoinedRoom) rooms.join
    , knock = rooms.knock
    , leave = Dict.map (\_ -> upcastLeftRoom) rooms.leave
    }


upcastJoinedRoom : PO.JoinedRoom -> O.JoinedRoom
upcastJoinedRoom room =
    { accountData = room.accountData
    , ephemeral = room.ephemeral
    , state = List.map upcastClientEventWithoutRoomId room.state
    , summary = room.summary
    , timeline = Maybe.map upcastTimeline room.timeline
    , unreadNotifications = room.unreadNotifications
    }


upcastClientEventWithoutRoomId : PO.ClientEventWithoutRoomId -> O.ClientEventWithoutRoomId
upcastClientEventWithoutRoomId event =
    { content = event.content
    , eventId = event.eventId
    , originServerTs = event.originServerTs
    , sender = event.sender
    , stateKey = event.stateKey
    , contentType = event.contentType
    , unsigned = Maybe.map upcastUnsigned event.unsigned
    }


upcastUnsigned : PO.UnsignedData -> O.UnsignedData
upcastUnsigned (PO.UnsignedData data) =
    O.UnsignedData
        { age = data.age
        , prevContent = data.prevContent
        , redactedBecause = Maybe.map upcastClientEventWithoutRoomId data.redactedBecause
        , transactionId = data.transactionId
        }


upcastTimeline : PO.Timeline -> O.Timeline
upcastTimeline timeline =
    { events = List.map upcastClientEventWithoutRoomId timeline.events
    , limited = timeline.limited
    , prevBatch = timeline.prevBatch
    }


upcastLeftRoom : PO.LeftRoom -> O.LeftRoom
upcastLeftRoom room =
    { accountData = room.accountData
    , state = List.map upcastClientEventWithoutRoomId room.state
    , timeline = Maybe.map upcastTimeline room.timeline
    }
