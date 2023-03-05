module Internal.Api.PreApi.Main exposing (..)

{-| Certain values are required knowledge for (almost) every endpoint.
Some values aren't known right away, however.

This module takes care of values like access tokens, transaction ids and spec version lists
that the credentials type needs to know about before it can make a request.

-}

import Internal.Api.PreApi.Objects.Login as L
import Internal.Api.PreApi.Objects.Versions as V
import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Internal.Tools.LoginValues exposing (AccessToken(..))
import Internal.Tools.ValueGetter exposing (ValueGetter)
import Json.Encode as E
import Task
import Time


accessToken : String -> AccessToken -> ValueGetter X.Error String
accessToken baseUrl t =
    { value =
        case t of
            NoAccess ->
                Nothing

            AccessToken token ->
                Just token

            UsernameAndPassword { token } ->
                token
    , getValue =
        case t of
            UsernameAndPassword { username, password } ->
                R.rawApiCall
                    { headers = R.NoHeaders
                    , method = "POST"
                    , baseUrl = baseUrl
                    , path = "/_matrix/client/v3/login"
                    , pathParams = []
                    , queryParams = []
                    , bodyParams =
                        [ [ ( "type", E.string "m.id.user" )
                          , ( "user", E.string username )
                          ]
                            |> E.object
                            |> R.RequiredValue "identifier"
                        , R.RequiredString "password" password
                        , R.RequiredString "type" "m.login.password"
                        ]
                    , timeout = Nothing
                    , decoder = \_ -> L.loggedInResponseDecoder
                    }
                    |> Task.map .accessToken

            _ ->
                X.NoAccessToken
                    |> X.SDKException
                    |> Task.fail
    }


transactionId : (Int -> String) -> ValueGetter X.Error String
transactionId seeder =
    { value = Nothing
    , getValue =
        Time.now
            |> Task.map Time.posixToMillis
            |> Task.map seeder
    }


versions : String -> Maybe V.Versions -> ValueGetter X.Error V.Versions
versions baseUrl mVersions =
    { value = mVersions
    , getValue =
        R.rawApiCall
            { headers = R.NoHeaders
            , method = "GET"
            , baseUrl = baseUrl
            , path = "/_matrix/client/versions"
            , pathParams = []
            , queryParams = []
            , bodyParams = []
            , timeout = Nothing
            , decoder = \_ -> V.versionsDecoder
            }
    }
