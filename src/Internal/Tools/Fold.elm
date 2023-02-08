module Internal.Tools.Fold exposing (..)

{-| This module allows users to iterate over lists in more intelligent ways.
-}


type FoldingState a
    = Calculating a
    | AnswerFound a


type FoldingResponse a
    = ContinueWith a
    | AnswerWith a
    | AnswerWithPrevious


{-| Fold until a given condition is met.
The first argument is a function that returns a `Maybe b`. As soon as that value is `Nothing`, the function will ignore the rest of the list and return the most recent value.
-}
untilCompleted : ((a -> FoldingState b -> FoldingState b) -> FoldingState b -> List a -> FoldingState b) -> (a -> b -> FoldingResponse b) -> b -> List a -> b
untilCompleted folder updater startValue items =
    folder
        (\piece oldValue ->
            case oldValue of
                AnswerFound x ->
                    AnswerFound x

                Calculating x ->
                    case updater piece x of
                        ContinueWith y ->
                            Calculating y

                        AnswerWith y ->
                            AnswerFound y

                        AnswerWithPrevious ->
                            AnswerFound x
        )
        (Calculating startValue)
        items
        |> (\resp ->
                case resp of
                    Calculating x ->
                        x

                    AnswerFound x ->
                        x
           )
