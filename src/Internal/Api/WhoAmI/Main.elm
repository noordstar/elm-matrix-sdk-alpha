module Internal.Api.WhoAmI.Main exposing (..)

import Internal.Api.WhoAmI.Api as Api
import Internal.Api.WhoAmI.V2.Upcast as U2
import Internal.Api.WhoAmI.V3.Upcast as U3
import Internal.Tools.Context as Context exposing (Context, VBA)
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


whoAmI : Context (VBA a) -> WhoAmIInput -> Task X.Error WhoAmIOutput
whoAmI context input =
    VC.withBottomLayer
        { current = Api.whoAmIV1
        , version = "r0.3.0"
        }
        |> VC.sameForVersion "r0.4.0"
        |> VC.sameForVersion "r0.5.0"
        |> VC.sameForVersion "r0.6.0"
        |> VC.sameForVersion "r0.6.1"
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.whoAmIV2
            , upcast = \f c -> Task.map U2.upcastWhoAmIResponse (f c)
            , version = "v1.1"
            }
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.whoAmIV3
            , upcast = \f c -> Task.map U3.upcastWhoAmIResponse (f c)
            , version = "v1.2"
            }
        |> VC.sameForVersion "v1.3"
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.sameForVersion "v1.6"
        |> VC.sameForVersion "v1.7"
        |> VC.sameForVersion "v1.8"
        |> VC.mostRecentFromVersionList (Context.getVersions context)
        |> Maybe.withDefault (always <| always <| Task.fail X.UnsupportedSpecVersion)
        |> (|>) input
        |> (|>) context


type alias WhoAmIInput =
    Api.WhoAmIInputV1


type alias WhoAmIOutput =
    Api.WhoAmIOutputV3
