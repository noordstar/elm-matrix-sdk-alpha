module Internal.Api.Helpers exposing (..)

import Http
import Internal.Tools.Exceptions as X
import Process
import Task exposing (Task)


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
