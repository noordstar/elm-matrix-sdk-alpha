module Internal.Api.Chain exposing (..)

{-| This module aims to simplify chaining several API tasks together.

Chaining tasks together is usually done through the `Task` submodule of `elm/core`,
but this isn't always sufficient for getting complex chained tasks.

For example, suppose you need to run 3 consecutive tasks that each need an access
token, and only the 1st and the 3rd require another token. You will need to pass
on all necessary information, and preferably in a way that the compiler can
assure that the information is present when it arrives there. Using the `Task`
submodule, this can lead to indentation hell.

This module aims to allow for simple task chaining without adding too much complexity
if you wish to pass on values.

The model is like a snake:                              _____
                                                       /   o \
  /-|------------ | ------- | ------------- | -------- | |\/\/
 <  | accessToken | baseUrl | transactionId | API call | |------< Final API call
  \-|------------ | ------- | ------------- | -------- | |/\/\
                                                       \-----/

(You're not allowed to judge my ASCII art skills unless you submit a PR with a
superior ASCII snake model.)

Every task will add another value to an extensible record, which can be used
by later tasks in the chain. Additionally, every subtask can leave a `VaultUpdate`
type as a message to the Vault to update certain information.

-}

import Http
import Internal.Api.Helpers as Helpers
import Internal.Tools.Context as Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias TaskChain err u a b =
    Context a -> Task (FailedChainPiece err u) (TaskChainPiece u a b)


type alias IdemChain err u a =
    TaskChain err u a a


type alias CompleteChain u =
    TaskChain () u {} {}


type alias TaskChainPiece u a b =
    { contextChange : Context a -> Context b
    , messages : List u
    }


type alias FailedChainPiece err u =
    { error : err, messages : List u }


{-| Chain two tasks together. The second task will only run if the first one succeeds.
-}
andThen : TaskChain err u b c -> TaskChain err u a b -> TaskChain err u a c
andThen f2 f1 =
    \context ->
        f1 context
            |> Task.andThen
                (\old ->
                    context
                        |> old.contextChange
                        |> f2
                        |> Task.map
                            (\new ->
                                { contextChange = old.contextChange >> new.contextChange
                                , messages = List.append old.messages new.messages
                                }
                            )
                        |> Task.mapError
                            (\{ error, messages } ->
                                { error = error, messages = List.append old.messages messages }
                            )
                )


{-| Same as `andThen`, but the results are placed at the front of the list, rather than at the end.
-}
andBeforeThat : TaskChain err u b c -> TaskChain err u a b -> TaskChain err u a c
andBeforeThat f2 f1 =
    \context ->
        f1 context
            |> Task.andThen
                (\old ->
                    context
                        |> old.contextChange
                        |> f2
                        |> Task.map
                            (\new ->
                                { contextChange = old.contextChange >> new.contextChange
                                , messages = List.append new.messages old.messages
                                }
                            )
                        |> Task.mapError
                            (\{ error, messages } ->
                                { error = error, messages = List.append messages old.messages }
                            )
                )


{-| When an error has occurred, "fix" it with the following function.
-}
catchWith : (err -> TaskChainPiece u a b) -> TaskChain err u a b -> TaskChain err u a b
catchWith onErr f =
    onError (\e -> succeed <| onErr e) f


{-| Create a task chain that always fails.
-}
fail : err -> TaskChain err u a b
fail e _ =
    Task.fail { error = e, messages = [] }


{-| Optionally run a task that may provide additional information.

If the provided chain fails, it will be ignored. This way, the chain can be tasked
without needlessly breaking the whole chain if anything breaks in here.

You cannot use this function to execute a task chain that adds or removes context.

-}
maybe : IdemChain err u a -> IdemChain err u a
maybe f =
    { contextChange = identity
    , messages = []
    }
        |> succeed
        |> always
        |> onError
        |> (|>) f


{-| Map a value to a different one.
-}
map : (u1 -> u2) -> TaskChain err u1 a b -> TaskChain err u2 a b
map m f =
    \context ->
        f context
            |> Task.map
                (\{ contextChange, messages } ->
                    { contextChange = contextChange, messages = List.map m messages }
                )
            |> Task.mapError
                (\{ error, messages } ->
                    { error = error, messages = List.map m messages }
                )


{-| If the TaskChain errfails, run this task otherwise.
-}
otherwise : TaskChain err u a b -> TaskChain e u a b -> TaskChain err u a b
otherwise f2 f1 context =
    Task.onError (always <| f2 context) (f1 context)


{-| If all else fails, you can also just add the failing part to the succeeding part.
-}
otherwiseFail : IdemChain err u a -> IdemChain err (Result err u) a
otherwiseFail =
    map Ok
        >> catchWith
            (\err ->
                { contextChange = identity
                , messages = [ Err err ]
                }
            )


{-| If an error is raised, deal with it accordingly.
-}
onError : (err -> TaskChain err2 u a b) -> TaskChain err u a b -> TaskChain err2 u a b
onError onErr f =
    \context ->
        f context
            |> Task.onError
                (\{ error, messages } ->
                    succeed { contextChange = identity, messages = messages }
                        |> andThen (onErr error)
                        |> (|>) context
                )


{-| Create a task chain that always succeeds.
-}
succeed : { contextChange : Context a -> Context b, messages : List u } -> TaskChain err u a b
succeed d _ =
    Task.succeed d


{-| Once all the pieces of the chain have been assembled, you can turn it into a task.

The compiler will fail if the chain is missing a vital piece of information.

-}
toTask : TaskChain err u {} b -> Task (FailedChainPiece err u) (List u)
toTask f1 =
    Context.init
        |> f1
        |> Task.map .messages


{-| If the TaskChain errfails, this function will get it to retry.

When set to 1 or lower, the task will only try once.

-}
tryNTimes : Int -> TaskChain X.Error u a b -> TaskChain X.Error u a b
tryNTimes n f =
    if n <= 0 then
        f

    else
        onError
            (\e ->
                case e of
                    X.InternetException (Http.BadUrl _) ->
                        fail e

                    X.InternetException _ ->
                        tryNTimes (n - 1) f

                    X.SDKException (X.ServerReturnsBadJSON _) ->
                        tryNTimes (n - 1) f

                    X.SDKException _ ->
                        fail e

                    X.ServerException _ ->
                        fail e

                    X.ContextFailed _ ->
                        fail e

                    X.UnsupportedSpecVersion ->
                        fail e
            )
            f
