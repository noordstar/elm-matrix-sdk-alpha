module Matrix.Settings exposing (..)
{-| There are a lot of settings that you can change!

These settings change how the Vault interacts with the Matrix API.
You can adjust these values for performance reasons, for customizability, benchmarking,
or maybe just because you like it. :)

It is common to set all settings in the `init` function, but you can adjust all settings on the fly.
-}

import Internal.Vault exposing (Vault)

{-| When your Matrix client synchronizes with the homeserver, the homeserver often
responds quite quickly, giving all the information that you need.

Sometimes, the homeserver has nothing new to report, and instead makes you wait for a response.
This is called long-polling, and it's the homeserver waiting for an update to give to you.
Long-polling is very useful!

This setting sets a limit on how long the long-polling should last. It is smart
to make this equal to the interval at which you run the `sync` function.

**Default:** 10 (seconds)
-}
syncTimeout : Int -> Vault -> Vault
syncTimeout timeout =
    Internal.Vault.settings \data -> { data | syncTimeout = timeout }