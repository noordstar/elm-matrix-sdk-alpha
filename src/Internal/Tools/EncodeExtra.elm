module Internal.Tools.EncodeExtra exposing (..)

import Json.Encode as E


{-| Create a body object based on optionally provided values.
-}
maybeObject : List ( String, Maybe E.Value ) -> E.Value
maybeObject =
    List.filterMap
        (\( name, value ) ->
            case value of
                Just v ->
                    Just ( name, v )

                _ ->
                    Nothing
        )
        >> E.object
