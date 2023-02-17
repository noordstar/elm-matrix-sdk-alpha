module Internal.Api.Helpers exposing (..)

import Internal.Tools.Exceptions as X
import Process
import Task exposing (Task)
import Http

{-| Sometimes, a URL endpoint might be ratelimited. In such a case,
the homeserver tells the SDK to wait for a while and then send its response again.
-}
ratelimited : Task X.Error a -> Task X.Error a
ratelimited task =
    task
    |> Task.onError
        (\e ->
            case e of
                X.ServerException (X.M_LIMIT_EXCEEDED { retryAfterMs }) ->
                    case retryAfterMs of
                        Just interval ->
                            interval
                            |> (+) 1
                            |> toFloat
                            |> Process.sleep
                            |> Task.andThen (\_ -> task)
                            |> ratelimited

                        Nothing ->
                            Task.fail e
                
                X.InternetException (Http.BadStatus 429) ->
                    1000
                    |> Process.sleep
                    |> Task.andThen (\_ -> task)
                    |> ratelimited
                
                _ ->
                    Task.fail e
        )

{-| Sometimes, you don't really care if something went wrong - you just want to try again.

This task will only return an error if it went wrong on the n'th attempt.
-}
retryTask : Int -> Task x a -> Task x a
retryTask n task =
    if n <= 0 then
        task
    else
        Task.onError (\_ -> retryTask (n - 1) task ) task

