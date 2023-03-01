module Internal.Tools.LoginValues exposing (..)


type AccessToken
    = NoAccess
    | AccessToken String
    | UsernameAndPassword { username : String, password : String, token : Maybe String }


defaultAccessToken : AccessToken
defaultAccessToken =
    NoAccess


fromAccessToken : String -> AccessToken
fromAccessToken =
    AccessToken


fromUsernameAndPassword : String -> String -> AccessToken
fromUsernameAndPassword username password =
    UsernameAndPassword
        { username = username
        , password = password
        , token = Nothing
        }


getToken : AccessToken -> Maybe String
getToken t =
    case t of
        NoAccess ->
            Nothing

        AccessToken token ->
            Just token

        UsernameAndPassword { token } ->
            token


addToken : String -> AccessToken -> AccessToken
addToken s t =
    case t of
        NoAccess ->
            AccessToken s

        AccessToken _ ->
            AccessToken s

        UsernameAndPassword { username, password } ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = Just s
                }
