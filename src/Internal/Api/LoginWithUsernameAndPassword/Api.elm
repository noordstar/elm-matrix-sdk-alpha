module Internal.Api.LoginWithUsernameAndPassword.Api exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.V1.Login as SO1
import Internal.Api.LoginWithUsernameAndPassword.V2.SpecObjects as SO2
import Internal.Api.LoginWithUsernameAndPassword.V3.SpecObjects as SO3
import Internal.Api.LoginWithUsernameAndPassword.V4.SpecObjects as SO4
import Internal.Api.LoginWithUsernameAndPassword.V5.Login as SO5
import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Encode as E
import Task exposing (Task)


type alias LoginWithUsernameAndPasswordInputV1 =
    { password : String
    , username : String
    }


type alias LoginWithUsernameAndPasswordInputV2 =
    { deviceId : Maybe String
    , initialDeviceDisplayName : Maybe String
    , password : String
    , username : String
    }


type alias LoginWithUsernameAndPasswordOutputV1 =
    SO1.LoggedInResponse


type alias LoginWithUsernameAndPasswordOutputV2 =
    SO2.LoggedInResponse


type alias LoginWithUsernameAndPasswordOutputV3 =
    SO3.LoggedInResponse


type alias LoginWithUsernameAndPasswordOutputV4 =
    SO4.LoggedInResponse


type alias LoginWithUsernameAndPasswordOutputV5 =
    SO5.LoggedInResponse


loginWithUsernameAndPasswordV1 : LoginWithUsernameAndPasswordInputV1 -> Context { a | baseUrl : () } -> Task X.Error LoginWithUsernameAndPasswordOutputV1
loginWithUsernameAndPasswordV1 { username, password } =
    R.callApi "POST" "/_matrix/client/r0/login"
        >> R.withAttributes
            [ R.bodyString "password" password
            , R.bodyString "type" "m.login.password"
            , R.bodyString "user" username
            ]
        >> R.toTask SO1.loggedInResponseDecoder


loginWithUsernameAndPasswordV2 : LoginWithUsernameAndPasswordInputV2 -> Context { a | baseUrl : () } -> Task X.Error LoginWithUsernameAndPasswordOutputV2
loginWithUsernameAndPasswordV2 { deviceId, initialDeviceDisplayName, password, username } =
    R.callApi "POST" "/_matrix/client/r0/login"
        >> R.withAttributes
            [ R.bodyString "type" "m.login.password"
            , R.bodyString "user" username
            , R.bodyString "password" password
            , R.bodyOpString "device_id" deviceId
            , R.bodyOpString "initial_device_display_name" initialDeviceDisplayName
            ]
        >> R.toTask SO2.loggedInResponseDecoder


loginWithUsernameAndPasswordV3 : LoginWithUsernameAndPasswordInputV2 -> Context { a | baseUrl : () } -> Task X.Error LoginWithUsernameAndPasswordOutputV3
loginWithUsernameAndPasswordV3 { deviceId, initialDeviceDisplayName, password, username } =
    R.callApi "POST" "/_matrix/client/r0/login"
        >> R.withAttributes
            [ R.bodyString "type" "m.login.password"
            , R.bodyString "password" password
            , R.bodyOpString "device_id" deviceId
            , R.bodyOpString "initial_device_display_name" initialDeviceDisplayName
            , [ ( "type", E.string "m.id.user" )
              , ( "user", E.string username )
              ]
                |> E.object
                |> R.bodyValue "identifier"
            ]
        >> R.toTask SO3.loggedInResponseDecoder


loginWithUsernameAndPasswordV4 : LoginWithUsernameAndPasswordInputV2 -> Context { a | baseUrl : () } -> Task X.Error LoginWithUsernameAndPasswordOutputV4
loginWithUsernameAndPasswordV4 { deviceId, initialDeviceDisplayName, password, username } =
    R.callApi "POST" "/_matrix/client/r0/login"
        >> R.withAttributes
            [ R.bodyString "type" "m.login.password"
            , R.bodyString "password" password
            , R.bodyOpString "device_id" deviceId
            , R.bodyOpString "initial_device_display_name" initialDeviceDisplayName
            , [ ( "type", E.string "m.id.user" )
              , ( "user", E.string username )
              ]
                |> E.object
                |> R.bodyValue "identifier"
            ]
        >> R.toTask SO4.loggedInResponseDecoder


loginWithUsernameAndPasswordV5 : LoginWithUsernameAndPasswordInputV2 -> Context { a | baseUrl : () } -> Task X.Error LoginWithUsernameAndPasswordOutputV4
loginWithUsernameAndPasswordV5 { deviceId, initialDeviceDisplayName, password, username } =
    R.callApi "POST" "/_matrix/client/v3/login"
        >> R.withAttributes
            [ R.bodyString "type" "m.login.password"
            , R.bodyString "password" password
            , R.bodyOpString "device_id" deviceId
            , R.bodyOpString "initial_device_display_name" initialDeviceDisplayName
            , [ ( "type", E.string "m.id.user" )
              , ( "user", E.string username )
              ]
                |> E.object
                |> R.bodyValue "identifier"
            ]
        >> R.toTask SO4.loggedInResponseDecoder


loginWithUsernameAndPasswordV6 : LoginWithUsernameAndPasswordInputV2 -> Context { a | baseUrl : () } -> Task X.Error LoginWithUsernameAndPasswordOutputV5
loginWithUsernameAndPasswordV6 { deviceId, initialDeviceDisplayName, password, username } =
    R.callApi "POST" "/_matrix/client/v3/login"
        >> R.withAttributes
            [ R.bodyString "type" "m.login.password"
            , R.bodyString "password" password
            , R.bodyOpString "device_id" deviceId
            , R.bodyOpString "initial_device_display_name" initialDeviceDisplayName
            , R.bodyBool "refresh_token" True
            , [ ( "type", E.string "m.id.user" )
              , ( "user", E.string username )
              ]
                |> E.object
                |> R.bodyValue "identifier"
            ]
        >> R.toTask SO5.loggedInResponseDecoder



-- loginWithUsernameAndPasswordV5 : LoginWithUsernameAndPasswordInputV1 -> Context { a | baseUrl : () } -> Task X.Error LoginWithUsernameAndPasswordOutputV5
-- loginWithUsernameAndPasswordV5 { username, password } =
--     R.callApi "POST" "/_matrix/client/v3/login"
--         >> R.withAttributes
--             [ [ ( "type", E.string "m.id.user" )
--               , ( "user", E.string username )
--               ]
--                 |> E.object
--                 |> R.bodyValue "identifier"
--             , R.bodyString "password" password
--             , R.bodyString "type" "m.login.password"
--             ]
--         >> R.toTask SO.loggedInResponseDecoder
