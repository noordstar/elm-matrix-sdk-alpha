module Internal.Api.Redact.V1.SpecObjects exposing
    ( Redaction
    , encodeRedaction
    , redactionDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1678053256

-}

import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| A confirmation containing the ID for the redaction event.
-}
type alias Redaction =
    { eventId : String
    }


encodeRedaction : Redaction -> E.Value
encodeRedaction data =
    maybeObject
        [ ( "event_id", Just <| E.string data.eventId )
        ]


redactionDecoder : D.Decoder Redaction
redactionDecoder =
    D.map
        (\a ->
            { eventId = a }
        )
        (D.field "event_id" D.string)
