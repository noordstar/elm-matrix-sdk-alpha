module Internal.Api.Versions.SpecObjects exposing
    ( Versions
    , encodeVersions
    , versionsDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1673279712

-}

import Dict exposing (Dict)
import Internal.Tools.DecodeExtra exposing (opField)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| Information on what the homeserver supports.
-}
type alias Versions =
    { unstableFeatures : Maybe (Dict String Bool)
    , versions : List String
    }


encodeVersions : Versions -> E.Value
encodeVersions data =
    maybeObject
        [ ( "unstable_features", Maybe.map (E.dict identity E.bool) data.unstableFeatures )
        , ( "versions", Just <| E.list E.string data.versions )
        ]


versionsDecoder : D.Decoder Versions
versionsDecoder =
    D.map2
        (\a b ->
            { unstableFeatures = a, versions = b }
        )
        (opField "unstable_features" (D.dict D.bool))
        (D.field "versions" (D.list D.string))
