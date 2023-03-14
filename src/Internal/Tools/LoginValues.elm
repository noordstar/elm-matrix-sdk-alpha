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


addUsernameAndPassword : { username : String, password : String } -> AccessToken -> AccessToken
addUsernameAndPassword { username, password } t =
    case t of
        NoAccess ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = Nothing
                }

        AccessToken a ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = Just a
                }

        UsernameAndPassword { token } ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = token
                }


removeToken : AccessToken -> AccessToken
removeToken t =
    case t of
        NoAccess ->
            NoAccess

        AccessToken _ ->
            NoAccess

        UsernameAndPassword { username, password } ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = Nothing
                }
