module Internal.Config.DefaultSettings exposing (..)

{-| This module hosts default configurations.
These configurations are intended to be version-specific
and are free to be changed in later releases.

Alternatively, one may change these values in a fork of the repository.

-}


{-| This Matrix SDK version
-}
currentVersion : String
currentVersion =
    "0.0.0"


{-| Matrix spec versions that this SDK supports,
sorted in ascending order of preference.
-}
supportedVersions : List String
supportedVersions =
    [ "v1.2"
    , "v1.3"
    , "v1.4"
    , "v1.5"
    ]


{-| The default device name that this SDK will use when logging in.
-}
defaultDeviceName : String
defaultDeviceName =
    "Elm Matrix SDK (v" ++ currentVersion ++ ")"
