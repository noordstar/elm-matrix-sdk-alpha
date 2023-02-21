module Internal.Tools.VersionControl exposing
    ( VersionControl, withBottomLayer
    , MiddleLayer, addMiddleLayer
    , toDict, fromVersion, fromVersionList
    , isSupported
    , mostRecentFromVersionList, sameForVersion
    )

{-| This module helps you create multiple functions for different (spec) versions
while still having only one input, one output.

The module can be best described as a layered version type.

    |----------------------------------------------|
    | VersionControl                               |
    |                     input            output  |
    |                       |                ^     |
    |---------------------- | -------------- | ----|
                            |                |
    |---------------------- | -------------- | ----|
    | MiddleLayer v3        |                |     |
    |                       [---> current ---]     |
    |                       |                |     |
    |                    downcast          upcast  |
    |                       |                ^     |
    |---------------------- | -------------- | ----|
                            |                |
    |---------------------- | -------------- | ----|
    | MiddleLayer v2        |                |     |
    |                       [---> current ---]     |
    |                       |                |     |
    |                    downcast          upcast  |
    |                       |                ^     |
    |---------------------- | -------------- | ----|
                            |                |
    |---------------------- | -------------- | ----|
    | BottomLayer v1        |                |     |
    |                       \---> current ---/     |
    |                                              |
    |----------------------------------------------|

This method means you will only need to write one downcast, one current and one upcast
whenever you introduce a new version. This means you can instantly update all functions
without having to write every version!

The VersionControl keeps a `Dict` type but also tracks the version order.
This way, you can either get the VersionControl type to render the function for
the most recent supported version, or you can choose for yourself which version
you prefer to use.


# Making VersionControl

@docs VersionControl, withBottomLayer


# Adding more versions

@docs MiddleLayer, addMiddleLayer


# Getting functions

@docs toDict, fromVersion, mostRecentFromVerionList, fromVersionList


# Checking functions

@docs isSupported

-}

import Dict exposing (Dict)


{-| The bottom layer is the final version option.

If even this version is not approved, there will be no function to execute.

-}
type alias BottomLayer cin cout =
    { current : cin -> cout, version : String }


{-| The middle layer is an optional function to execute.

If the version is approved, it is executed - otherwise, the next version will be considered.

-}
type alias MiddleLayer cin cout din dout =
    { current : cin -> cout
    , downcast : cin -> din
    , upcast : dout -> cout
    , version : String
    }


{-| The VersionControl layer is the layer that keeps track of all potential versions.
-}
type VersionControl cin cout
    = VersionControl
        { latestVersion : cin -> cout
        , order : List String
        , versions : Dict String (cin -> cout)
        }


{-| Add an extra version to the VersionControl. This will completely change the input and output
of every function, as all functions will abide by the most recent version's specifics.
-}
addMiddleLayer : MiddleLayer cin cout din dout -> VersionControl din dout -> VersionControl cin cout
addMiddleLayer { current, downcast, upcast, version } (VersionControl d) =
    VersionControl
        { latestVersion = current
        , order = version :: d.order
        , versions =
            d.versions
                |> Dict.map (\_ f -> downcast >> f >> upcast)
                |> Dict.insert version current
        }


{-| Provided that a version has been passed to the VersionControl, you will receive the appropriate version.
-}
fromVersion : String -> VersionControl a b -> Maybe (a -> b)
fromVersion version (VersionControl { versions }) =
    Dict.get version versions


{-| Provided a list of versions, this function will provide a list of compatible versions to you in your preferred order.

If you just care about getting the most recent function, you will be better off using `mostRecentFromVersionList`,
but this function can help if you care about knowing which Matrix spec version you're using.

-}
fromVersionList : List String -> VersionControl a b -> List ( String, a -> b )
fromVersionList versionList vc =
    List.filterMap
        (\version ->
            vc
                |> fromVersion version
                |> Maybe.map (\f -> ( version, f ))
        )
        versionList


{-| Sometimes, you may not wish to "just" get the info.
Sometimes, all you're interested in, is whether a given version is supported.

In such a case, you can use this function to check whether a given version is supported.

-}
isSupported : String -> VersionControl a b -> Bool
isSupported version (VersionControl d) =
    Dict.member version d.versions


{-| Get a dict of all available functions.
-}
toDict : VersionControl a b -> Dict String (a -> b)
toDict (VersionControl d) =
    d.versions


{-| Get the most recent event based on a list of versions.
-}
mostRecentFromVersionList : List String -> VersionControl a b -> Maybe (a -> b)
mostRecentFromVersionList versionList ((VersionControl { order }) as vc) =
    order
        |> List.filter (\o -> List.member o versionList)
        |> List.filterMap (\v -> fromVersion v vc)
        |> List.head


{-| Sometimes, no changes are needed and a function works just the same as the one in the previous version.
In that case, you can amend with a `sameForVersion` function to indicate that the spec is
identical for this version.
-}
sameForVersion : String -> VersionControl a b -> VersionControl a b
sameForVersion version (VersionControl data) =
    VersionControl
        { data
            | order = version :: data.order
            , versions = Dict.insert version data.latestVersion data.versions
        }


{-| You cannot create an empty VersionControl layer, you must always start with a BottomLayer
and then stack MiddleLayer types on top until you've reached the version that you're happy with.
-}
withBottomLayer : BottomLayer a b -> VersionControl a b
withBottomLayer { current, version } =
    VersionControl
        { latestVersion = current
        , order = List.singleton version
        , versions = Dict.singleton version current
        }
