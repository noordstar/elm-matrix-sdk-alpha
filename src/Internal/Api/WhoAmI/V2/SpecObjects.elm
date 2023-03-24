module Internal.Api.WhoAmI.V2.SpecObjects exposing
    ( WhoAmIResponse
    , encodeWhoAmIResponse
    , whoAmIResponseDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1679665928

-}

import Internal.Tools.DecodeExtra exposing (opField)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| Response telling the user to whom their access token belongs.
-}
type alias WhoAmIResponse =
    { deviceId : Maybe String
    , userId : String
    }


encodeWhoAmIResponse : WhoAmIResponse -> E.Value
encodeWhoAmIResponse data =
    maybeObject
        [ ( "device_id", Maybe.map E.string data.deviceId )
        , ( "user_id", Just <| E.string data.userId )
        ]


whoAmIResponseDecoder : D.Decoder WhoAmIResponse
whoAmIResponseDecoder =
    D.map2
        (\a b ->
            { deviceId = a, userId = b }
        )
        (opField "device_id" D.string)
        (D.field "user_id" D.string)
