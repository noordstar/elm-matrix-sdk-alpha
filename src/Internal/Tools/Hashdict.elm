module Internal.Tools.Hashdict exposing (..)

{-| This module abstracts the `Dict` type with one function that chooses the unique identifier for each type.

For example, this is used to store events by their event id, or store rooms by their room id.

-}

import Dict exposing (Dict)


type Hashdict a
    = Hashdict
        { hash : a -> String
        , values : Dict String a
        }


empty : (a -> String) -> Hashdict a
empty hash =
    Hashdict { hash = hash, values = Dict.empty }


get : String -> Hashdict a -> Maybe a
get k (Hashdict h) =
    Dict.get k h.values


insert : a -> Hashdict a -> Hashdict a
insert v (Hashdict h) =
    Hashdict { h | values = Dict.insert (h.hash v) v h.values }


keys : Hashdict a -> List String
keys (Hashdict h) =
    Dict.keys h.values


values : Hashdict a -> List a
values (Hashdict h) =
    Dict.values h.values
