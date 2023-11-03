module Internal.Tools.Filters.SimpleFilter exposing (..)
{-| The SimpleFilter tracks values that should or should not be monitored.
-}

import Dict exposing (Dict)

{-| SimpleFilter type that tracks items to include or exclude.
-}
type alias SimpleFilter a =
    { specificOnes : Dict a Bool
    , includeOthers : Bool
    }

all : SimpleFilter a
all =
    { specificOnes = Dict.empty
    , includeOthers = True
    }

{-| Use filter ones that are only available in the first filter.
-}
diff : SimpleFilter comparable -> SimpleFilter comparable -> SimpleFilter comparable
diff f1 f2 =
    { specificOnes =
        Dict.merge
            (\k v1 -> Dict.insert k (v1 && not f2.includeOthers))
            (\k v1 v2 -> Dict.insert k (v1 && not v2))
            (\k v2 -> Dict.insert k (f1.includeOthers && not v2))
            f1.specificOnes
            f2.specificOnes
            Dict.empty
    , includeOthers = f1.includeOthers && not f2.includeOthers
    }

{-| Form a filter that only shows the values that two filters have in common.
-}
intersect : SimpleFilter comparable -> SimpleFilter comparable -> SimpleFilter comparable
intersect f1 f2 =
    { specificOnes =
        Dict.merge
            (\key v1 -> Dict.insert key (v1 && f2.includeOthers))
            (\key v1 v2 -> Dict.insert key (v1 && v2))
            (\key v2 -> Dict.insert key (f1.includeOthers && v2))
            f1.specificOnes
            f2.specificOnes
            Dict.empty
    , includeOthers = f1.includeOthers && f2.includeOthers
    }

{-| Start with a filter that includes none.
-}
none : SimpleFilter a
none =
    { specificOnes = Dict.empty
    , includeOthers = False
    }

{-| Check whether a SimpleFilter is a subset of another filter.
-}
subset : SimpleFilter comparable -> SimpleFilter comparable -> Bool
subset small large =
    if small.includeOthers && not large.includeOthers then
        False
    else
        -- All elements of small are in large
        Dict.merge
            (\_ s ->
                if s && not large.includeOthers then
                    always False
                else
                    identity
            )
            (\_ s l ->
                if s && not l then
                    always False
                else
                    identity
            )
            (\_ l ->
                if small.includeOthers && not l then
                    always False
                else
                    identity
            )
            small.specificOnes
            large.specificOnes
            True

{-| Encode a SimpleFilter into a list of items to exclude.
-}
toExclude : SimpleFilter comparable -> Maybe (List comparable)
toExclude f =
    f.specificOnes
        |> Dict.filter (always not)
        |> Dict.keys
        |> Just

{-| Encode a SimpleFilter into a list of items to include.
-}
toInclude : SimpleFilter comparable -> Maybe (List comparable)
toInclude f =
    if f.includeOthers then
        Nothing
    else
        f.specificOnes
            |> Dict.filter (always identity)
            |> Dict.keys
            |> Just

{-| Create a SimpleFilter out of two optionally present lists.
-}
toSimpleFilter : Maybe (List comparable) -> Maybe (List comparable) -> SimpleFilter comparable
toSimpleFilter these notThese =
    let
        no : List comparable
        no = Maybe.withDefault [] notThese
    in
    case these of
        Just yes ->
            { specificOnes =
                Dict.union
                    (Dict.fromList ( List.map (\x -> Tuple.pair x False) no ))
                    (Dict.fromList ( List.map (\x -> Tuple.pair x True) yes ))
            , includeOthers = False
            }

        Nothing ->
            { specificOnes =
                no
                    |> List.map (\x -> Tuple.pair x False)
                    |> Dict.fromList
            , includeOthers = True
            }

{-| Form a filter that includes values if it is included in either filters.
-}
union : SimpleFilter comparable -> SimpleFilter comparable -> SimpleFilter comparable
union f1 f2 =
    { specificOnes =
        Dict.merge
            (\key v1 -> Dict.insert key (v1 || f2.includeOthers))
            (\key v1 v2 -> Dict.insert key (v1 || v2))
            (\key v2 -> Dict.insert key (f1.includeOthers || v2))
            f1.specificOnes
            f2.specificOnes
            Dict.empty
    , includeOthers = f1.includeOthers && f2.includeOthers
    }

{-| Add a value that should be included.
-}
with : comparable -> SimpleFilter comparable -> SimpleFilter comparable
with x f =
    { f | specificOnes = Dict.insert x True f.specificOnes }

{-| Include all values that haven't been mentioned.
-}
withOthers : SimpleFilter comparable -> SimpleFilter comparable
withOthers f =
    { f | includeOthers = True }

{-| Add a value that should be ignored.
-}
without : comparable -> SimpleFilter comparable -> SimpleFilter comparable
without x f =
    { f | specificOnes = Dict.insert x False f.specificOnes }

{-| Ignore all values that haven't been mentioned.
-}
withoutOthers : SimpleFilter comparable -> SimpleFilter comparable
withoutOthers f =
    { f | includeOthers = False }