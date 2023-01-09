module Internal.Api.Versions.Api exposing (..)

import Internal.Api.Request as R
import Internal.Api.Versions.Convert as C
import Internal.Api.Versions.Objects as O
import Internal.Api.Versions.SpecObjects as SO
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


versionsV1 : { baseUrl : String } -> Task X.Error O.Versions
versionsV1 data =
    R.rawApiCall
        { headers = R.NoHeaders
        , method = "GET"
        , baseUrl = data.baseUrl
        , path = "/_matrix/client/versions"
        , pathParams = []
        , queryParams = []
        , bodyParams = []
        , timeout = Nothing
        , decoder = \_ -> D.map C.convert SO.versionsDecoder
        }
