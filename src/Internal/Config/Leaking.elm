module Internal.Config.Leaking exposing (..)

{-| This module contains data that you're not supposed to see.

Event types that you're not supposed to encounter, Matrix users that shouldn't exist, etc.

Values like these usually imply that there is a leakage in the implementation or that there was a small mistake in the refactor.

-}

import Hash
import Time


accessToken : String
accessToken =
    "mistaken_access_token"


baseUrl : String
baseUrl =
    "https://matrix.example.org"


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


prevBatch : String
prevBatch =
    "this_previous_batch_does_not_exist"


roomId : String
roomId =
    "!unknown-room:example.org"


sender : String
sender =
    "@alice:example.org"


transactionId : String
transactionId =
    "elm" ++ (Hash.fromString "leaked_transactionId" |> Hash.toString)


versions : List String
versions =
    []
