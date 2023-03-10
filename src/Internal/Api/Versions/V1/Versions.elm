module Internal.Api.Versions.V1.Versions exposing
    ( Versions
    , encodeVersions
    , versionsDecoder
    )

{-| Automatically generated 'Versions'

Last generated at Unix time 1677064309

-}

import Dict exposing (Dict)
import Internal.Tools.DecodeExtra exposing (opField, opFieldWithDefault)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| Information on what the homeserver supports.
-}
type alias Versions =
    { unstableFeatures : Dict String Bool
    , versions : List String
    }


encodeVersions : Versions -> E.Value
encodeVersions data =
    maybeObject
        [ ( "unstable_features", Just <| E.dict identity E.bool data.unstableFeatures )
        , ( "versions", Just <| E.list E.string data.versions )
        ]


versionsDecoder : D.Decoder Versions
versionsDecoder =
    D.map2
        (\a b ->
            { unstableFeatures = a, versions = b }
        )
        (opFieldWithDefault "unstable_features" Dict.empty (D.dict D.bool))
        (D.field "versions" (D.list D.string))
