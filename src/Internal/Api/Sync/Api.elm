module Internal.Api.Sync.Api exposing (..)

import Internal.Api.Request as R
import Internal.Api.Sync.V1.SpecObjects as SO1
import Internal.Api.Sync.V2.SpecObjects as SO2
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Internal.Tools.SpecEnums as Enums
import Task exposing (Task)


type alias SyncInputV1 =
    { filter : Maybe String
    , fullState : Maybe Bool
    , setPresence : Maybe Enums.UserPresence
    , since : Maybe String
    , timeout : Maybe Int
    }


type alias SyncOutputV1 =
    SO1.Sync


type alias SyncOutputV2 =
    SO2.Sync


syncV1 : SyncInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error SyncOutputV1
syncV1 data =
    R.callApi "GET" "/_matrix/client/v3/sync"
        >> R.withAttributes
            [ R.accessToken
            , R.queryOpString "filter" data.filter
            , R.queryOpBool "full_state" data.fullState
            , R.queryOpString "set_presence" (Maybe.map Enums.fromUserPresence data.setPresence)
            , R.queryOpString "since" data.since
            , R.queryOpInt "timeout" data.timeout
            , R.timeout <| Maybe.map ((*) 1000 >> toFloat) <| data.timeout
            ]
        >> R.toTask SO1.syncDecoder


syncV2 : SyncInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error SyncOutputV2
syncV2 data =
    R.callApi "GET" "/_matrix/client/v3/sync"
        >> R.withAttributes
            [ R.accessToken
            , R.queryOpString "filter" data.filter
            , R.queryOpBool "full_state" data.fullState
            , R.queryOpString "set_presence" (Maybe.map Enums.fromUserPresence data.setPresence)
            , R.queryOpString "since" data.since
            , R.queryOpInt "timeout" data.timeout
            , R.timeout <| Maybe.map ((*) 1000 >> toFloat) <| data.timeout
            ]
        >> R.toTask SO2.syncDecoder
