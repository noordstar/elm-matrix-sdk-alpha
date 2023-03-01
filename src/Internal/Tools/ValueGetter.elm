module Internal.Tools.ValueGetter exposing (..)

{-| This module creates task pipelines that help gather information
in the Matrix API.

For example, it might happen that you need to make multiple API calls:

  - Authenticate
  - Log in
  - Get a list of channels
  - Send a message in every room

For each of these API requests, you might need certain information like
which spec version the homeserver supports.

This module takes care of this. That way, functions can be written simply by
saying "I need THESE values" and you will then be able to assign them to each
HTTP call that needs that value.

-}

import Task exposing (Task)


{-| A ValueGetter x type takes care of values that MIGHT be available.
If a value is not available, then the task can be used to get a new value.
-}
type alias ValueGetter x a =
    { value : Maybe a, getValue : Task x a }


{-| Convert a `ValueGetter` type to a task. If a previous value has already been given,
then use that value. Otherwise, use the `getValue` task to get a new value.
-}
toTask : ValueGetter x a -> Task x a
toTask { value, getValue } =
    Maybe.map Task.succeed value
        |> Maybe.withDefault getValue


withInfo : (a -> Task x result) -> ValueGetter x a -> Task x result
withInfo task info1 =
    Task.andThen
        (\a ->
            task a
        )
        (toTask info1)


withInfo2 :
    (a -> b -> Task x result)
    -> ValueGetter x a
    -> ValueGetter x b
    -> Task x result
withInfo2 task info1 info2 =
    Task.andThen
        (\a ->
            Task.andThen
                (\b ->
                    task a b
                )
                (toTask info2)
        )
        (toTask info1)


withInfo3 :
    (a -> b -> c -> Task x result)
    -> ValueGetter x a
    -> ValueGetter x b
    -> ValueGetter x c
    -> Task x result
withInfo3 task info1 info2 info3 =
    Task.andThen
        (\a ->
            Task.andThen
                (\b ->
                    Task.andThen
                        (\c ->
                            task a b c
                        )
                        (toTask info3)
                )
                (toTask info2)
        )
        (toTask info1)


withInfo4 :
    (a -> b -> c -> d -> Task x result)
    -> ValueGetter x a
    -> ValueGetter x b
    -> ValueGetter x c
    -> ValueGetter x d
    -> Task x result
withInfo4 task info1 info2 info3 info4 =
    Task.andThen
        (\a ->
            Task.andThen
                (\b ->
                    Task.andThen
                        (\c ->
                            Task.andThen
                                (\d ->
                                    task a b c d
                                )
                                (toTask info4)
                        )
                        (toTask info3)
                )
                (toTask info2)
        )
        (toTask info1)


withInfo5 :
    (a -> b -> c -> d -> e -> Task x result)
    -> ValueGetter x a
    -> ValueGetter x b
    -> ValueGetter x c
    -> ValueGetter x d
    -> ValueGetter x e
    -> Task x result
withInfo5 task info1 info2 info3 info4 info5 =
    Task.andThen
        (\a ->
            Task.andThen
                (\b ->
                    Task.andThen
                        (\c ->
                            Task.andThen
                                (\d ->
                                    Task.andThen
                                        (\e ->
                                            task a b c d e
                                        )
                                        (toTask info5)
                                )
                                (toTask info4)
                        )
                        (toTask info3)
                )
                (toTask info2)
        )
        (toTask info1)


withInfo6 :
    (a -> b -> c -> d -> e -> f -> Task x result)
    -> ValueGetter x a
    -> ValueGetter x b
    -> ValueGetter x c
    -> ValueGetter x d
    -> ValueGetter x e
    -> ValueGetter x f
    -> Task x result
withInfo6 task info1 info2 info3 info4 info5 info6 =
    Task.andThen
        (\a ->
            Task.andThen
                (\b ->
                    Task.andThen
                        (\c ->
                            Task.andThen
                                (\d ->
                                    Task.andThen
                                        (\e ->
                                            Task.andThen
                                                (\f ->
                                                    task a b c d e f
                                                )
                                                (toTask info6)
                                        )
                                        (toTask info5)
                                )
                                (toTask info4)
                        )
                        (toTask info3)
                )
                (toTask info2)
        )
        (toTask info1)


withInfo7 :
    (a -> b -> c -> d -> e -> f -> g -> Task x result)
    -> ValueGetter x a
    -> ValueGetter x b
    -> ValueGetter x c
    -> ValueGetter x d
    -> ValueGetter x e
    -> ValueGetter x f
    -> ValueGetter x g
    -> Task x result
withInfo7 task info1 info2 info3 info4 info5 info6 info7 =
    Task.andThen
        (\a ->
            Task.andThen
                (\b ->
                    Task.andThen
                        (\c ->
                            Task.andThen
                                (\d ->
                                    Task.andThen
                                        (\e ->
                                            Task.andThen
                                                (\f ->
                                                    Task.andThen
                                                        (\g ->
                                                            task a b c d e f g
                                                        )
                                                        (toTask info7)
                                                )
                                                (toTask info6)
                                        )
                                        (toTask info5)
                                )
                                (toTask info4)
                        )
                        (toTask info3)
                )
                (toTask info2)
        )
        (toTask info1)


withInfo8 :
    (a -> b -> c -> d -> e -> f -> g -> h -> Task x result)
    -> ValueGetter x a
    -> ValueGetter x b
    -> ValueGetter x c
    -> ValueGetter x d
    -> ValueGetter x e
    -> ValueGetter x f
    -> ValueGetter x g
    -> ValueGetter x h
    -> Task x result
withInfo8 task info1 info2 info3 info4 info5 info6 info7 info8 =
    Task.andThen
        (\a ->
            Task.andThen
                (\b ->
                    Task.andThen
                        (\c ->
                            Task.andThen
                                (\d ->
                                    Task.andThen
                                        (\e ->
                                            Task.andThen
                                                (\f ->
                                                    Task.andThen
                                                        (\g ->
                                                            Task.andThen
                                                                (\h ->
                                                                    task a b c d e f g h
                                                                )
                                                                (toTask info8)
                                                        )
                                                        (toTask info7)
                                                )
                                                (toTask info6)
                                        )
                                        (toTask info5)
                                )
                                (toTask info4)
                        )
                        (toTask info3)
                )
                (toTask info2)
        )
        (toTask info1)
