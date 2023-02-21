module Internal.Tools.Timestamp exposing (Timestamp, encodeTimestamp, generateTransactionId, timestampDecoder)

import Json.Decode as D
import Json.Encode as E
import Task exposing (Task)
import Time


type alias Timestamp =
    Time.Posix


{-| Encode a timestamp
-}
encodeTimestamp : Timestamp -> E.Value
encodeTimestamp =
    Time.posixToMillis >> E.int


{-| Decode a timestmap
-}
timestampDecoder : D.Decoder Timestamp
timestampDecoder =
    D.map Time.millisToPosix D.int


{-| Generate a transaction id from the current Unix timestamp
-}
generateTransactionId : Task x String
generateTransactionId =
    Time.now
        |> Task.map Time.posixToMillis
        |> Task.map String.fromInt
        |> Task.map ((++) "elm")
