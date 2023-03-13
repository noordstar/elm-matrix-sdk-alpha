module Internal.Api.Versions.Api exposing (..)

import Internal.Api.Request as R
import Internal.Api.Versions.V1.Versions as SO
import Internal.Tools.Exceptions as X
import Task exposing (Task)


versionsV1 : { baseUrl : String } -> Task X.Error SO.Versions
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
        , decoder = always SO.versionsDecoder
        }
