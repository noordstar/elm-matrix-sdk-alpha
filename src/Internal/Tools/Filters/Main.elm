module Internal.Tools.Filters.Main exposing (..)
{-| This module contains the main functions used to get, manipulate and change
filters according to their needs.
-}

import Internal.Tools.Filters.Filter as F
import Internal.Tools.Filters.SimpleFilter as SF

type alias Filter = F.Filter

type alias SimpleFilter = SF.SimpleFilter String

{-| Filter that adds all occurrences by default, but leaves a few ones out.

When provided with an empty list, the filter allows all types.
-}
allExcept : List String -> SimpleFilter
allExcept =
    List.foldl SF.without SF.all

{-| Filter that removes everything by default, but leaves a few ones in.

When provided with an empty list, the filter allows nothing.
-}
only : List String -> SimpleFilter
only =
    List.foldl SF.with SF.none

fromSimpleFilter :
    { accountDataTypes : SimpleFilter
    , presence : { limit : Maybe Int, senders : SimpleFilter, types : SimpleFilter }
    , ephemeral : { limit : Maybe Int, senders : SimpleFilter, types : SimpleFilter }
    , roomIds : SimpleFilter
    , lazyLoadMembers : Bool
    , roomEvents : { limit : Maybe Int, senders : SimpleFilter, types : SimpleFilter }
    } -> Filter
fromSimpleFilter data =
    F.Filter
        { accountData =
            F.EventFilter
                { limit = Nothing
                , senders = SF.all
                , types = data.accountDataTypes
                }
        , presence =
            F.EventFilter
                { limit = data.presence.limit
                , senders = data.presence.senders
                , types = data.presence.types
                }
        , room =
            F.RoomFilter
                { accountData =
                    F.RoomEventFilter
                        { lazyLoadMembers = data.lazyLoadMembers
                        , limit = Nothing
                        , rooms = data.roomIds
                        , senders = SF.all
                        , types = data.accountDataTypes
                        }
                , ephemeral =
                    F.RoomEventFilter
                        { lazyLoadMembers = data.lazyLoadMembers
                        , limit = data.ephemeral.limit
                        , rooms = data.roomIds
                        , senders = data.ephemeral.senders
                        , types = data.ephemeral.types
                        }
                , rooms = data.roomIds
                , timeline = 
                    F.RoomEventFilter
                        { lazyLoadMembers = data.lazyLoadMembers
                        , limit = data.roomEvents.limit
                        , rooms = data.roomIds
                        , senders = data.roomEvents.senders
                        , types = data.roomEvents.types
                        }
                }
        }

{-| Get the intersection of two filters.
-}
intersect : Filter -> Filter -> Filter
intersect =
    F.intersectFilter
