module Internal.Api.Versions.Api exposing (..)

import Internal.Api.Request as R
import Internal.Api.Versions.V1.Versions as SO
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


versionsV1 : Context { a | baseUrl : () } -> Task X.Error SO.Versions
versionsV1 =
    R.callApi "GET" "/_matrix/client/versions"
        >> R.toTask SO.versionsDecoder
