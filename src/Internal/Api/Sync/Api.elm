module Internal.Api.Sync.Api exposing (..)

import Internal.Api.Request as R
import Internal.Api.Sync.V1.SpecObjects as SO1
import Internal.Api.Sync.V2.SpecObjects as SO2
import Internal.Tools.Exceptions as X
import Internal.Tools.SpecEnums as Enums
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


type alias SyncOutputV1 =
    Task X.Error SO1.Sync


type alias SyncOutputV2 =
    Task X.Error SO2.Sync


syncV1 : SyncInputV1 -> SyncOutputV1
syncV1 data =
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
        , decoder = \_ -> SO1.syncDecoder
        }


syncV2 : SyncInputV1 -> SyncOutputV2
syncV2 data =
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
        , decoder = \_ -> SO2.syncDecoder
        }
