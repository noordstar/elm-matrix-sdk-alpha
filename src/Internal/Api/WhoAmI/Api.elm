module Internal.Api.WhoAmI.Api exposing (..)

import Internal.Api.Request as R
import Internal.Api.WhoAmI.V1.SpecObjects as SO1
import Internal.Api.WhoAmI.V2.SpecObjects as SO2
import Internal.Api.WhoAmI.V3.SpecObjects as SO3
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias WhoAmIInputV1 =
    ()


type alias WhoAmIOutputV1 =
    SO1.WhoAmIResponse


type alias WhoAmIOutputV2 =
    SO2.WhoAmIResponse


type alias WhoAmIOutputV3 =
    SO3.WhoAmIResponse


whoAmIV1 : WhoAmIInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error WhoAmIOutputV1
whoAmIV1 _ =
    R.callApi "GET" "/_matrix/client/r0/account/whoami"
        >> R.withAttributes [ R.accessToken ]
        >> R.toTask SO1.whoAmIResponseDecoder


whoAmIV2 : WhoAmIInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error WhoAmIOutputV2
whoAmIV2 _ =
    R.callApi "GET" "/_matrix/client/v3/account/whoami"
        >> R.withAttributes [ R.accessToken ]
        >> R.toTask SO2.whoAmIResponseDecoder


whoAmIV3 : WhoAmIInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error WhoAmIOutputV3
whoAmIV3 _ =
    R.callApi "GET" "/_matrix/client/v3/account/whoami"
        >> R.withAttributes [ R.accessToken ]
        >> R.toTask SO3.whoAmIResponseDecoder
