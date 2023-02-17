module Internal.Tools.Exceptions exposing (ClientError(..), Error(..), ServerError(..), errorCatches, errorToString)

{-| This module contains all potential errors that may be passed around in the SDK.
-}

import Dict
import Http
import Internal.Config.ErrorStrings as ES
import Internal.Tools.DecodeExtra exposing (opField)
import Json.Decode as D
import Json.Encode as E

{-| Errors that may return in any circumstance:

- `InternetException` Errors that the `elm/http` library might raise.
- `SDKException` Errors that this SDK might raise if it doesn't like its own input
- `ServerException` Errors that the homeserver might bring
- `UnsupportedSpecVersion` This SDK does not support the needed spec versions for certain operations - usually because a homeserver is extremely old.
-}
type Error
    = InternetException Http.Error
    | SDKException ClientError
    | ServerException ServerError
    | UnsupportedSpecVersion


{-| Errors that this SDK might return if it doesn't like its own input, if it
notices some internal inconsistencies or if it cannot interpret the server's
input.

  - `ServerReturnsBadJSON` The homeserver sent JSON that does not parse.
  - `CouldntGetTimestamp` The Elm core somehow failed to get the current
    Unix timestamp.
  - `NotSupportedYet` Some part of the SDK is intended to be implemented - but it isn't yet.

-}
type ClientError
    = ServerReturnsBadJSON String
    | CouldntGetTimestamp
    | NotSupportedYet String


{-| Potential error codes that the server may return. If the error is not a
default one described in the Matrix Spec, it will be a `CustomServerError`
and provide with the custom string.
-}
type
    ServerError
    -- COMMON ERROR CODES
    -- These error codes can be returned by any API endpoint.
    -- See https://spec.matrix.org/v1.5/client-server-api/#common-error-codes
    = M_FORBIDDEN { error : Maybe String }
    | M_UNKNOWN_TOKEN { error : Maybe String, soft_logout : Maybe Bool }
    | M_MISSING_TOKEN { error : Maybe String, soft_logout : Maybe Bool }
    | M_BAD_JSON { error : Maybe String }
    | M_NOT_JSON { error : Maybe String }
    | M_NOT_FOUND { error : Maybe String }
    | M_LIMIT_EXCEEDED { error : Maybe String, retryAfterMs : Maybe Int }
    | M_UNKNOWN { error : Maybe String }
      -- OTHER ERROR CODES
      -- These error codes are specific to certain endpoints.
      -- See https://spec.matrix.org/v1.4/client-server-api/#other-error-codes
    | M_UNRECOGNIZED { error : Maybe String }
    | M_UNAUTHORIZED { error : Maybe String }
    | M_USER_DEACTIVATED { error : Maybe String }
    | M_USER_IN_USE { error : Maybe String }
    | M_INVALID_USERNAME { error : Maybe String }
    | M_ROOM_IN_USE { error : Maybe String }
    | M_INVALID_ROOM_STATE { error : Maybe String }
    | M_THREEPID_IN_USE { error : Maybe String }
    | M_THREEPID_NOT_FOUND { error : Maybe String }
    | M_THREEPID_AUTH_FAILED { error : Maybe String }
    | M_THREEPID_DENIED { error : Maybe String }
    | M_SERVER_NOT_TRUSTED { error : Maybe String }
    | M_UNSUPPORTED_ROOM_VERSION { error : Maybe String }
    | M_INCOMPATIBLE_ROOM_VERSION
        { error : Maybe String
        , room_version : Maybe String
        }
    | M_BAD_STATE { error : Maybe String }
    | M_GUEST_ACCESS_FORBIDDEN { error : Maybe String }
    | M_CAPTCHA_NEEDED { error : Maybe String }
    | M_CAPTCHA_INVALID { error : Maybe String }
    | M_MISSING_PARAM { error : Maybe String }
    | M_INVALID_PARAM { error : Maybe String }
    | M_TOO_LARGE { error : Maybe String }
    | M_EXCLUSIVE { error : Maybe String }
    | M_RESOURCE_LIMIT_EXCEEDED
        { error : Maybe String
        , adminContact : String
        }
    | M_CANNOT_LEAVE_SERVER_NOTICE_ROOM { error : Maybe String }
      -- Error codes that help understand the server's output
    | RequiresUserInteractiveAuthentication
        { completed : List String
        , flows : List (List String)
        , params : Dict.Dict String (Dict.Dict String String)
        , session : Maybe String
        }
      -- CUSTOM ERROR CODES
      -- These can be defined by custom homeserver implementations
    | CustomServerError
        { errcode : String
        , fullError : E.Value
        , statusCode : Int
        }


{-| Shortcut for the decoder of most errors defined in the Matrix spec
-}
standardErrorDescription : D.Decoder { error : Maybe String }
standardErrorDescription =
    D.map (\err -> { error = err }) (opField "error" D.string)


{-| Dictionary of known errors that the homeserver may return.
The key is the error type, while the value is a function that reads all required
and optional fields from the response based on Matrix specifications.
-}
errorCatches : D.Decoder ServerError
errorCatches =
    D.oneOf
        [ errorDecoder "M_FORBIDDEN" M_FORBIDDEN standardErrorDescription
        , errorDecoder "M_UNKNOWN_TOKEN"
            M_UNKNOWN_TOKEN
            (D.map2
                (\err slg -> { error = err, soft_logout = slg })
                (opField "error" D.string)
                (opField "soft_logout" D.bool)
            )
        , errorDecoder "M_MISSING_TOKEN"
            M_MISSING_TOKEN
            (D.map2
                (\err slg -> { error = err, soft_logout = slg })
                (opField "error" D.string)
                (opField "soft_logout" D.bool)
            )
        , errorDecoder "M_BAD_JSON" M_BAD_JSON standardErrorDescription
        , errorDecoder "M_NOT_JSON" M_NOT_JSON standardErrorDescription
        , errorDecoder "M_NOT_FOUND" M_NOT_FOUND standardErrorDescription
        , errorDecoder "M_LIMIT_EXCEEDED"
            M_LIMIT_EXCEEDED
            (D.map2
                (\err rams -> { error = err, retryAfterMs = rams })
                (opField "error" D.string)
                (opField "retry_after_ms" D.int)
            )
        , errorDecoder "M_UNKNOWN" M_UNKNOWN standardErrorDescription
        , errorDecoder "M_UNRECOGNIZED" M_UNRECOGNIZED standardErrorDescription
        , errorDecoder "M_UNAUTHORIZED" M_UNAUTHORIZED standardErrorDescription
        , errorDecoder "M_USER_DEACTIVATED" M_USER_DEACTIVATED standardErrorDescription
        , errorDecoder "M_USER_IN_USE" M_USER_IN_USE standardErrorDescription
        , errorDecoder "M_INVALID_USERNAME" M_INVALID_USERNAME standardErrorDescription
        , errorDecoder "M_ROOM_IN_USE" M_ROOM_IN_USE standardErrorDescription
        , errorDecoder "M_INVALID_ROOM_STATE" M_INVALID_ROOM_STATE standardErrorDescription
        , errorDecoder "M_THREEPID_IN_USE" M_THREEPID_IN_USE standardErrorDescription
        , errorDecoder "M_THREEPID_NOT_FOUND" M_THREEPID_NOT_FOUND standardErrorDescription
        , errorDecoder "M_THREEPID_AUTH_FAILED" M_THREEPID_AUTH_FAILED standardErrorDescription
        , errorDecoder "M_THREEPID_DENIED" M_THREEPID_DENIED standardErrorDescription
        , errorDecoder "M_SERVER_NOT_TRUSTED" M_SERVER_NOT_TRUSTED standardErrorDescription
        , errorDecoder "M_UNSUPPORTED_ROOM_VERSION" M_UNSUPPORTED_ROOM_VERSION standardErrorDescription
        , errorDecoder "M_INCOMPATIBLE_ROOM_VERSION"
            M_INCOMPATIBLE_ROOM_VERSION
            (D.map2
                (\err rv -> { error = err, room_version = rv })
                (opField "error" D.string)
                (opField "room_version" D.string)
            )
        , errorDecoder "M_BAD_STATE" M_BAD_STATE standardErrorDescription
        , errorDecoder "M_GUEST_ACCESS_FORBIDDEN" M_GUEST_ACCESS_FORBIDDEN standardErrorDescription
        , errorDecoder "M_CAPTCHA_NEEDED" M_CAPTCHA_NEEDED standardErrorDescription
        , errorDecoder "M_CAPTCHA_INVALID" M_CAPTCHA_INVALID standardErrorDescription
        , errorDecoder "M_MISSING_PARAM" M_MISSING_PARAM standardErrorDescription
        , errorDecoder "M_INVALID_PARAM" M_INVALID_PARAM standardErrorDescription
        , errorDecoder "M_TOO_LARGE" M_TOO_LARGE standardErrorDescription
        , errorDecoder "M_EXCLUSIVE" M_EXCLUSIVE standardErrorDescription
        , errorDecoder "M_RESOURCE_LIMIT_EXCEEDED"
            M_RESOURCE_LIMIT_EXCEEDED
            (D.map2
                (\err ac -> { error = err, adminContact = ac })
                (opField "error" D.string)
                (D.field "admin_contact" D.string)
            )
        , errorDecoder "M_CANNOT_LEAVE_SERVER_NOTICE_ROOM" M_CANNOT_LEAVE_SERVER_NOTICE_ROOM standardErrorDescription
        ]


errorDecoder : String -> (a -> ServerError) -> D.Decoder a -> D.Decoder ServerError
errorDecoder name code decoder =
    D.field "errcode" D.string
        |> D.andThen
            (\errcode ->
                if errcode == name then
                    D.map code decoder

                else
                    D.fail "Not the right errcode"
            )


errorToString : Error -> String
errorToString e =
    case e of
        UnsupportedVersion ->
            ES.unsupportedVersion

        SDKException (ServerReturnsBadJSON s) ->
            ES.serverReturnsBadJSON s

        SDKException CouldntGetTimestamp ->
            ES.couldNotGetTimestamp

        ServerException (M_FORBIDDEN data) ->
            ES.serverSaysForbidden data.error

        -- ServerError (M_UNKNOWN_TOKEN data) ->
        _ ->
            "ERROR NEEDS STRING"
