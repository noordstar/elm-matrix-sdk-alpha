module Internal.Api.LoginWithUsernameAndPassword.Api exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.V1.Login as SO
import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Json.Encode as E
import Task exposing (Task)

type alias LoginWithUsernameAndPasswordInputV1 =
    { baseUrl : String
    , password : String
    , username : String
    }

type alias LoginWithUsernameAndPasswordOutputV1 =
    SO.LoggedInResponse


loginWithUsernameAndPasswordV1 : LoginWithUsernameAndPasswordInputV1 -> Task X.Error LoginWithUsernameAndPasswordOutputV1
loginWithUsernameAndPasswordV1 data =
    R.rawApiCall
        { headers = R.NoHeaders
        , method = "POST"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/v3/login"
        , pathParams = []
        , queryParams = []
        , bodyParams =
            [ [ ( "type", E.string "m.id.user" )
                , ( "user", E.string data.username )
                ]
                |> E.object
                |> R.RequiredValue "identifier"
            , R.RequiredString "password" data.password
            , R.RequiredString "type" "m.login.password"
            ]
        , timeout = Nothing
        , decoder = always SO.loggedInResponseDecoder
        }

