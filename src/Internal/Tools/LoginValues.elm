module Internal.Tools.LoginValues exposing (..)


type AccessToken
    = NoAccess
    | RawAccessToken String
    | DetailedAccessToken
        { accessToken : String
        , userId : String
        , deviceId : String
        }
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
    RawAccessToken


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

        RawAccessToken token ->
            Just token

        DetailedAccessToken { accessToken } ->
            Just accessToken

        UsernameAndPassword { token } ->
            token


addToken : String -> AccessToken -> AccessToken
addToken s t =
    case t of
        NoAccess ->
            RawAccessToken s

        RawAccessToken _ ->
            RawAccessToken s

        DetailedAccessToken _ ->
            RawAccessToken s

        UsernameAndPassword data ->
            UsernameAndPassword
                { data | token = Just s }


addUsernameAndPassword : { username : String, password : String } -> AccessToken -> AccessToken
addUsernameAndPassword { username, password } t =
    case t of
        NoAccess ->
            fromUsernameAndPassword username password

        RawAccessToken a ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = Just a
                , deviceId = Nothing
                , initialDeviceDisplayName = Nothing
                }

        DetailedAccessToken { accessToken, deviceId } ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = Just accessToken
                , deviceId = Just deviceId
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

        RawAccessToken _ ->
            NoAccess

        DetailedAccessToken _ ->
            NoAccess

        UsernameAndPassword data ->
            UsernameAndPassword
                { data | token = Nothing }
