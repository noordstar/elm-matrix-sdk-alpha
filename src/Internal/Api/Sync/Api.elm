module Internal.Api.Sync.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Exceptions as X
import Internal.Tools.SpecEnums as Enums
import Json.Decode as D
import Task exposing (Task)


type alias SyncInputV1 =
    { accessToken : String
    , baseUrl : String
    , filter : Maybe String
    , fullState : Maybe Bool
    , setPresence : Maybe Enums.UserPresence
    , since : Maybe String
    , timeout : Maybe Int
    }


syncV1 : D.Decoder a -> (a -> b) -> SyncInputV1 -> Task X.Error b
syncV1 decoder mapping data =
    R.rawApiCall
        { headers = R.WithAccessToken data.accessToken
        , method = "GET"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/v3/sync"
        , pathParams = []
        , queryParams =
            [ R.OpQueryParamString "filter" data.filter
            , R.OpQueryParamBool "full_state" data.fullState
            , R.OpQueryParamString "set_presence" (Maybe.map Enums.fromUserPresence data.setPresence)
            , R.OpQueryParamString "since" data.since
            , R.OpQueryParamInt "timeout" data.timeout
            ]
        , bodyParams = []
        , timeout =
            data.timeout
                |> Maybe.map ((+) 10000)
                |> Maybe.map toFloat
        , decoder = \_ -> D.map mapping decoder
        }
