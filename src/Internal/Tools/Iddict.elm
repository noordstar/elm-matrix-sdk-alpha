module Internal.Tools.Iddict exposing (..)
{-| The id-dict stores values and gives them a unique id.
-}

import FastDict as Dict exposing (Dict)

type Iddict a
    = Iddict 
        { cursor : Int
        , dict : Dict Int a
        }

empty : Iddict a
empty =
    Iddict
        { cursor = 0
        , dict = Dict.empty
        }

get : Int -> Iddict a -> Maybe a
get k (Iddict { dict }) =
    Dict.get k dict

insert : a -> Iddict a -> (Int, Iddict a)
insert v (Iddict d) =
    ( d.cursor
    , Iddict { cursor = d.cursor + 1, dict = Dict.insert d.cursor v d.dict }
    )

keys : Iddict a -> List Int
keys (Iddict { dict }) =
    Dict.keys dict

remove : Int -> Iddict a -> Iddict a
remove k (Iddict d) =
    Iddict { d | dict = Dict.remove k d.dict }

values : Iddict a -> List a
values (Iddict { dict }) =
    Dict.values dict