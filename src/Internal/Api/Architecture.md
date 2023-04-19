# Elm architecture

To support the complex ways that the Matrix API runs, standard Elm tasks have gained an increased amount of complexity.
This effectively:

1. Helps the Elm compiler recognize mistakes.
2. Helps the SDK developer chain multiple tasks together efficiently.

## How the Matrix tasks work

Whenever the user attempts to run a Matrix task, it has two types of information:

### Task input

The task input is input that the function uses to access information. It has the following properties:

- If the task is attempted at a later time, these values will remain unchanged.
- If these values do not exist, the task cannot be executed.

### Context

The context is the bundle of tokens, values and information that the Vault has at the moment. It has the following properties:

- If the task is attempted at a later time, these values will change according to the Vault's latest token collection.
- If these values do not exist, the task can get them as a sub-task before getting the actual data.

## Task chains

A task chain is a chain of tasks that are run in sequential order. Traditionally, in a chain of length `n`, the first `n-1` tasks add information to the context, and the last chain actually runs the task.


