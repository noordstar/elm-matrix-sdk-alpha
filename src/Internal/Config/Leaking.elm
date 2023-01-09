module Internal.Config.Leaking exposing (..)

{-| This module contains data that you're not supposed to see.

Event types that you're not supposed to encounter, Matrix users that shouldn't exist, etc.

Values like these usually imply that there is a leakage in the implementation or that there was a small mistake in the refactor.

-}

import Time


eventId : String
eventId =
    "$unknown-event-id"


eventType : String
eventType =
    "me.noordstar.invalid_type"


nextBatch : String
nextBatch =
    "this_batch_does_not_exist"


originServerTs : Time.Posix
originServerTs =
    Time.millisToPosix 0


roomId : String
roomId =
    "!unknown-room:example.org"


sender : String
sender =
    "@alice:example.org"
