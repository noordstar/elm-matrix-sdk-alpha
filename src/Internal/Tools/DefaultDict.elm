module Internal.Tools.DefaultDict exposing (..)

import FastDict as Dict exposing (Dict)

{-| A dictionary of keys and values that includes a default when a key doesn't exist.
-}
type DefaultDict k v
    = DefaultDict
        { content : Dict k v
        , default : v
        }

{-| Create an empty dictionary that has a default value.
-}
empty : v -> DefaultDict k v
empty v =
    DefaultDict
        { content = Dict.empty
        , default = v
        }

{-| Get the value associated with the key. Uses the default if not found. -}
get : comparable -> DefaultDict comparable v -> v
get k (DefaultDict data) =
    Dict.get k data.content |> Maybe.withDefault data.default

{-| Insert a key-value pair into a dictionary with a default.
-}
insert : comparable -> v -> DefaultDict comparable v -> DefaultDict comparable v
insert k v (DefaultDict data) =
    DefaultDict { data | content = Dict.insert k v data.content }

{-| "Remove" a value by making its value synchronize with the default value.
-}
remove : comparable -> DefaultDict comparable v -> DefaultDict comparable v
remove k (DefaultDict data) =
    DefaultDict { data | content = Dict.remove k data.content }

{-| Update the default value of all unset keys.
-}
setDefault : v -> DefaultDict k v -> DefaultDict k v
setDefault v (DefaultDict data) =
    DefaultDict { data | default = v }

{-| Update the value of a dictionary. The returned (or received) value is `Nothing`,
it means the key synchronizes with the default value.
-}
update : comparable -> (Maybe v -> Maybe v) -> DefaultDict comparable v -> DefaultDict comparable v
update k fv (DefaultDict data) =
    DefaultDict { data | content = Dict.update k fv data.content }

{-| Update the default value.
-}
updateDefault : (v -> v) -> DefaultDict k v -> DefaultDict k v
updateDefault f (DefaultDict data) =
    DefaultDict { data | default = f data.default }
