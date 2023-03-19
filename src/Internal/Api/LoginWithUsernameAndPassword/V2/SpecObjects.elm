module Internal.Api.LoginWithUsernameAndPassword.V2.SpecObjects exposing
    ( LoggedInResponse
    , encodeLoggedInResponse
    , loggedInResponseDecoder
    )

{-| Automatically generated 'Login'

Last generated at Unix time 1679075857

-}

import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| Confirmation that the user successfully logged in.
-}
type alias LoggedInResponse =
    { accessToken : String
    , deviceId : Maybe String
    , homeServer : String
    , refreshToken : Maybe String
    , userId : String
    }


encodeLoggedInResponse : LoggedInResponse -> E.Value
encodeLoggedInResponse data =
    maybeObject
        [ ( "access_token", Just <| E.string data.accessToken )
        , ( "device_id", Maybe.map E.string data.deviceId )
        , ( "home_server", Just <| E.string data.homeServer )
        , ( "refresh_token", Nothing )
        , ( "user_id", Just <| E.string data.userId )
        ]


loggedInResponseDecoder : D.Decoder LoggedInResponse
loggedInResponseDecoder =
    D.map5
        (\a b c d e ->
            { accessToken = a, deviceId = b, homeServer = c, refreshToken = d, userId = e }
        )
        (D.field "access_token" D.string)
        (D.map Just <| D.field "device_id" D.string)
        (D.field "home_server" D.string)
        (D.succeed Nothing)
        (D.field "user_id" D.string)
