module Internal.Api.LoginWithUsernameAndPassword.V1.Login exposing
    ( LoggedInResponse
    , encodeLoggedInResponse
    , loggedInResponseDecoder
    )

{-| Automatically generated 'Login'

Last generated at Unix time 1679075857

-}

import Internal.Tools.DecodeExtra exposing (opField)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| Confirmation that the user successfully logged in.
-}
type alias LoggedInResponse =
    { accessToken : String
    , homeServer : String
    , refreshToken : Maybe String
    , userId : String
    }


encodeLoggedInResponse : LoggedInResponse -> E.Value
encodeLoggedInResponse data =
    maybeObject
        [ ( "access_token", Just <| E.string data.accessToken )
        , ( "home_server", Just <| E.string data.homeServer )
        , ( "refresh_token", Maybe.map E.string data.refreshToken )
        , ( "user_id", Just <| E.string data.userId )
        ]


loggedInResponseDecoder : D.Decoder LoggedInResponse
loggedInResponseDecoder =
    D.map4
        (\a b c d ->
            { accessToken = a, homeServer = b, refreshToken = c, userId = d }
        )
        (D.field "access_token" D.string)
        (D.field "home_server" D.string)
        (opField "refresh_token" D.string)
        (D.field "user_id" D.string)
