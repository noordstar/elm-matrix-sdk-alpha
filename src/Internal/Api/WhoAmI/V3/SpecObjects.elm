module Internal.Api.WhoAmI.V3.SpecObjects exposing
    ( WhoAmIResponse
    , encodeWhoAmIResponse
    , whoAmIResponseDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1679665928

-}

import Internal.Tools.DecodeExtra exposing (opField, opFieldWithDefault)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| Response telling the user to whom their access token belongs.
-}
type alias WhoAmIResponse =
    { deviceId : Maybe String
    , isGuest : Bool
    , userId : String
    }


encodeWhoAmIResponse : WhoAmIResponse -> E.Value
encodeWhoAmIResponse data =
    maybeObject
        [ ( "device_id", Maybe.map E.string data.deviceId )
        , ( "is_guest", Just <| E.bool data.isGuest )
        , ( "user_id", Just <| E.string data.userId )
        ]


whoAmIResponseDecoder : D.Decoder WhoAmIResponse
whoAmIResponseDecoder =
    D.map3
        (\a b c ->
            { deviceId = a, isGuest = b, userId = c }
        )
        (opField "device_id" D.string)
        (opFieldWithDefault "is_guest" False D.bool)
        (D.field "user_id" D.string)
