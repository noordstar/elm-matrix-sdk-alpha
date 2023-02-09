module Internal.Tools.DecodeExtra exposing (opField, opFieldWithDefault)

{-| Module that helps while decoding JSON.


# Optional field decoders

@docs opField, opFieldWithDefault

-}

import Json.Decode as D


{-| Add an optional field decoder. If the field exists, the decoder will fail
if the field doesn't decode properly.

This decoder standard out from `D.maybe <| D.field fieldName decoder` because
that will decode into a `Nothing` if the `decoder` fails. This function
will only decode into a `Nothing` if the field doesn't exist, and will fail if
`decoder` fails.

The function also returns Nothing if the field exists but it is null.

-}
opField : String -> D.Decoder a -> D.Decoder (Maybe a)
opField fieldName decoder =
    D.value
        |> D.field fieldName
        |> D.maybe
        |> D.andThen
            (\v ->
                case v of
                    Just _ ->
                        D.oneOf
                            [ D.null Nothing
                            , D.map Just decoder
                            ]
                            |> D.field fieldName

                    Nothing ->
                        D.succeed Nothing
            )


{-| Add an optional field decoder. If the field is not given, the decoder will
return a default value.
-}
opFieldWithDefault : String -> a -> D.Decoder a -> D.Decoder a
opFieldWithDefault fieldName default decoder =
    opField fieldName decoder |> D.map (Maybe.withDefault default)
