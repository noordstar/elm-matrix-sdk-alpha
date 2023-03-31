module Internal.Api.Sync.V2.Upcast exposing (..)

import Dict
import Internal.Api.Sync.V1.SpecObjects as PO
import Internal.Api.Sync.V2.SpecObjects as SO


upcastSync : PO.Sync -> SO.Sync
upcastSync old =
    { accountData = old.accountData
    , nextBatch = old.nextBatch
    , presence = old.presence
    , rooms = Maybe.map upcastRooms old.rooms
    }


upcastRooms : PO.Rooms -> SO.Rooms
upcastRooms old =
    { invite = old.invite
    , join = Dict.map (\_ -> upcastJoinedRoom) old.join
    , knock = old.knock
    , leave = Dict.map (\_ -> upcastLeftRoom) old.leave
    }


upcastJoinedRoom : PO.JoinedRoom -> SO.JoinedRoom
upcastJoinedRoom old =
    { accountData = old.accountData
    , ephemeral = old.ephemeral
    , state = Maybe.map upcastState old.state
    , summary = old.summary
    , timeline = Maybe.map upcastTimeline old.timeline
    , unreadNotifications = old.unreadNotifications
    , unreadThreadNotifications = Dict.empty
    }


upcastState : PO.State -> SO.State
upcastState old =
    { events = List.map upcastClientEventWithoutRoomId old.events }


upcastClientEventWithoutRoomId : PO.ClientEventWithoutRoomId -> SO.ClientEventWithoutRoomId
upcastClientEventWithoutRoomId old =
    { content = old.content
    , eventId = old.eventId
    , originServerTs = old.originServerTs
    , sender = old.sender
    , stateKey = old.stateKey
    , eventType = old.eventType
    , unsigned = Maybe.map upcastUnsigned old.unsigned
    }


upcastUnsigned : PO.UnsignedData -> SO.UnsignedData
upcastUnsigned (PO.UnsignedData old) =
    SO.UnsignedData
        { age = old.age
        , prevContent = old.prevContent
        , redactedBecause = Maybe.map upcastClientEventWithoutRoomId old.redactedBecause
        , transactionId = old.transactionId
        }


upcastTimeline : PO.Timeline -> SO.Timeline
upcastTimeline old =
    { events = List.map upcastClientEventWithoutRoomId old.events
    , limited = old.limited
    , prevBatch = old.prevBatch
    }


upcastLeftRoom : PO.LeftRoom -> SO.LeftRoom
upcastLeftRoom old =
    { accountData = old.accountData
    , state = Maybe.map upcastState old.state
    , timeline = Maybe.map upcastTimeline old.timeline
    }
