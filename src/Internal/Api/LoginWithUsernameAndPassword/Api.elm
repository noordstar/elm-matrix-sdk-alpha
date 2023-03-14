module Internal.Api.LoginWithUsernameAndPassword.Api exposing (..)

import Internal.Api.LoginWithUsernameAndPassword.V1.Login as SO
import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Encode as E
import Task exposing (Task)


type alias LoginWithUsernameAndPasswordInputV1 =
    { password : String
    , username : String
    }


type alias LoginWithUsernameAndPasswordOutputV1 =
    SO.LoggedInResponse


loginWithUsernameAndPasswordV1 : LoginWithUsernameAndPasswordInputV1 -> Context { a | baseUrl : () } -> Task X.Error LoginWithUsernameAndPasswordOutputV1
loginWithUsernameAndPasswordV1 { username, password } =
    R.callApi "POST" "/_matrix/client/v3/login"
        >> R.withAttributes
            [ [ ( "type", E.string "m.id.user" )
              , ( "user", E.string username )
              ]
                |> E.object
                |> R.bodyValue "identifier"
            , R.bodyString "password" password
            , R.bodyString "type" "m.login.password"
            ]
        >> R.toTask SO.loggedInResponseDecoder
