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
type as a message to the Credentials to update certain information.

-}

import Internal.Tools.Context as Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias TaskChain u a b =
    Context a -> Task X.Error (TaskChainPiece u a b)


type alias IdemChain u a =
    TaskChain u a a


type TaskChainPiece u a b
    = TaskChainPiece
        { contextChange : Context a -> Context b
        , messages : List u
        }


{-| Chain two tasks together. The second task will only run if the first one succeeds.
-}
andThen : TaskChain u b c -> TaskChain u a b -> TaskChain u a c
andThen f2 f1 =
    \context ->
        f1 context
            |> Task.andThen
                (\(TaskChainPiece old) ->
                    context
                        |> old.contextChange
                        |> f2
                        |> Task.map
                            (\(TaskChainPiece new) ->
                                TaskChainPiece
                                    { contextChange = old.contextChange >> new.contextChange
                                    , messages = List.append old.messages new.messages
                                    }
                            )
                )


{-| Optionally run a task that may provide additional information.

If the provided chain fails, it will be ignored. This way, the chain can be tasked
without needlessly breaking the whole chain if anything breaks in here.

You cannot use this function to execute a task chain that adds or removes context.

-}
maybe : IdemChain u a -> IdemChain u a
maybe f =
    { contextChange = identity
    , messages = []
    }
        |> TaskChainPiece
        |> Task.succeed
        |> always
        |> Task.onError
        |> (>>) f


{-| If the TaskChain fails, run this task otherwise.
-}
otherwise : TaskChain u a b -> TaskChain u a b -> TaskChain u a b
otherwise f2 f1 context =
    Task.onError (always <| f2 context) (f1 context)


{-| Once all the pieces of the chain have been assembled, you can turn it into a task.

The compiler will fail if the chain is missing a vital piece of information.

-}
toTask : TaskChain u {} b -> Task X.Error (List u)
toTask f1 =
    Context.init
        |> f1
        |> Task.map
            (\(TaskChainPiece data) ->
                data.messages
            )


{-| If the TaskChain fails, this function will get it to retry.

When set to 1 or lower, the task will only try once.

-}
tryNTimes : Int -> TaskChain u a b -> TaskChain u a b
tryNTimes n f context =
    if n <= 1 then
        f context

    else
        (\_ -> tryNTimes (n - 1) f context)
            |> Task.onError
            |> (|>) (f context)
