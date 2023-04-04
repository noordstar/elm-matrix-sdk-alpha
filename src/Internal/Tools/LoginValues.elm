module Internal.Tools.LoginValues exposing (..)


type AccessToken
    = NoAccess
    | RawAccessToken String
    | DetailedAccessToken
        { accessToken : String
        , userId : String
        , deviceId : Maybe String
        }
    | UsernameAndPassword
        { deviceId : Maybe String
        , initialDeviceDisplayName : Maybe String
        , password : String
        , token : Maybe String
        , username : String
        , userId : Maybe String
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
        , userId = Nothing
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

getUserId : AccessToken -> Maybe String
getUserId t =
    case t of
        NoAccess ->
            Nothing
        
        RawAccessToken _ ->
            Nothing
        
        DetailedAccessToken { userId } ->
            Just userId
        
        UsernameAndPassword { userId } ->
            userId

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
                , userId = Nothing
                }

        DetailedAccessToken { accessToken, deviceId, userId } ->
            UsernameAndPassword
                { username = username
                , password = password
                , token = Just accessToken
                , deviceId = deviceId
                , initialDeviceDisplayName = Nothing
                , userId = Just userId
                }

        UsernameAndPassword data ->
            UsernameAndPassword
                { data | username = username, password = password }


addWhoAmI : { a | deviceId : Maybe String, userId : String } -> AccessToken -> AccessToken
addWhoAmI { deviceId, userId } t =
    case t of
        NoAccess ->
            NoAccess

        RawAccessToken a ->
            DetailedAccessToken
                { accessToken = a
                , deviceId = deviceId
                , userId = userId
                }

        DetailedAccessToken data ->
            DetailedAccessToken { data | deviceId = deviceId, userId = userId }

        UsernameAndPassword data ->
            UsernameAndPassword { data | deviceId = deviceId, userId = Just userId }


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
