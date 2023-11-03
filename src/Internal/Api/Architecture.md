# Elm architecture

Given that this document is rewritten during the refactor, this document is
intended as a comprehensive description of the HTTP Task build architecture of
the Elm SDK.

## How it used to work

This section describes the old architecture. Writing a summary helps point out the missteps and the potential for optimization.

### Context

The `Context` type was defined as follows:

```elm
type Context a
    = Context
        { accessToken : String
        , baseUrl : String
        , loginParts : Maybe LoginParts
        , sentEvent : String
        , timestamp : Timestamp
        , transactionId : String
        , userId : String
        , versions : List String
        }
```

Notice how `a` is a phantom type. The phantom type allows us to force the user to gather the correct data. For example, if our function requires the `accessToken` to be specified, we exclusively allow a `Context { a | accessToken : () }` type. This way, the compiler will ensure that the context always contains an access token before the function is run.

The `Context` type plays a central role in this architecture. It has a few upsides and downsides:

- ✅ The `Context` serves as a reliable representation of the vault's values. Even though the vault might not always have all information, the `Context`'s phantom types forces the developer to get all values that may not exist.

- ⛔ The`Context` is only a representation of the _current_ state. It fails to deliver prior information, like transaction ids that need to be remembered for failed executions.

### Task chains

Currently, every Matrix task is defined in a `TaskChain` alias:

```elm
type alias TaskChain err u a b =
    Context a -> Task (FailedChainPiece err u) (TaskChainPiece u a b)
```

Here, values `a` and `b` are phantom types. Value `err` represents an error type, and `u` represents a data type that updates our model.

Given a context (with a phantom type to ensure the presence of relevant info),
the function returns a `Task` that either breaks the chain or allows the
execution of another `TaskChain`, which is then combined using the
`Task.andThen` function.

To be exact, the two pieces of the `Task` were defined as follows:

#### Failed chain piece

The `FailedChainPiece` looks as follows:

```elm
type alias FailedChainPiece err u =
    { error : err, messages : List u }
```

There is no opportunity to change the progression of the chain, and everything stops here.

The library did offer functions to catch broken chains, and to fix them with a function that took the `err` value as an input and returned another task chain. However, generally speaking, a failed chain piece announces the end of a chain.

#### Task chain piece

The `TaskChainPiece` is a piece of the chain that has executed successfully. It looks as follows:

```elm
type alias TaskChainPiece u a b =
    { contextChange : Context a -> Context b
    , messages : List u
    }
```

The piece offers both a function to change the existing context, if necessary, and provides a list of messages that can be returned.

Once the chain has finished, all the messages of all the chain pieces are collected, put together in one large list and returned to the user. Ideally, the user would then feed all of them back into the Matrix Vault.


## What are some of the main issues

- The `Context` fails to remember values like transaction ids in a proper way.
- There needs to be an easily accessible way to determine what went wrong in task chains.
- The vocabulary is difficult to understand and some of the data types are similar enough to suggest that bloatware might come in.

## How to refactor

First off, the `Context` type needs to be removed.

### Vault is the (new) context

While building the `Context`, its values are derived from two sources:

1. The `Vault` type stores the information.
2. The information is gathered from the Matrix API using available information from the `Vault`.

When building a task chain, we start with an empty context of type `Context {}` and values are slowly added to that. Instead, we can add a phantom type to the `Vault` and then use the `Vault {}` to build the context.

Effectively, this means we no longer need to specify a separate data type that stores any relevant information that is already available in the `Vault`. Instead, the `Vault`'s phantom type specifies that functions can be used if and only if certain values are available.

The phantom type is exclusively an internal type and will therefore never be communicated to the end user of the library.
