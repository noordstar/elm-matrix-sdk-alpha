module Internal.Api.WhoAmI.V1.SpecObjects exposing
    ( WhoAmIResponse
    , encodeWhoAmIResponse
    , whoAmIResponseDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1679665928

-}

import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| Response telling the user to whom their access token belongs.
-}
type alias WhoAmIResponse =
    { userId : String
    }


encodeWhoAmIResponse : WhoAmIResponse -> E.Value
encodeWhoAmIResponse data =
    maybeObject
        [ ( "user_id", Just <| E.string data.userId )
        ]


whoAmIResponseDecoder : D.Decoder WhoAmIResponse
whoAmIResponseDecoder =
    D.map
        (\a ->
            { userId = a }
        )
        (D.field "user_id" D.string)
