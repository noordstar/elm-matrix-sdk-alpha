module Internal.Tools.LoginValues exposing (..)


type AccessToken
    = NoAccess
    | AccessToken String
    | UsernameAndPassword
        { deviceId : Maybe String
        , initialDeviceDisplayName : Maybe String
        , password : String
        , token : Maybe String
        , username : String
        }


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
        , deviceId = Nothing
        , initialDeviceDisplayName = Nothing
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

        UsernameAndPassword data ->
            UsernameAndPassword
                { data | token = Just s }


addUsernameAndPassword : { username : String, password : String } -> AccessToken -> AccessToken
addUsernameAndPassword { username, password } t =
    case t of
        NoAccess ->
            fromUsernameAndPassword username password

        AccessToken a ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = Just a
                , deviceId = Nothing
                , initialDeviceDisplayName = Nothing
                }

        UsernameAndPassword data ->
            UsernameAndPassword
                { data | username = username, password = password }


removeToken : AccessToken -> AccessToken
removeToken t =
    case t of
        NoAccess ->
            NoAccess

        AccessToken _ ->
            NoAccess

        UsernameAndPassword data ->
            UsernameAndPassword
                { data | token = Nothing }
