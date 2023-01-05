module Internal.Tools.Timestamp exposing (Timestamp, encodeTimestamp, timestampDecoder)

import Json.Decode as D
import Json.Encode as E
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
