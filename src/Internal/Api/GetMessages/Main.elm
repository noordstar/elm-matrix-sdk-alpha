module Internal.Api.GetMessages.Main exposing (..)

import Internal.Api.GetMessages.Api as Api
import Internal.Api.GetMessages.V2.Upcast as U2
import Internal.Api.GetMessages.V3.Upcast as U3
import Internal.Api.GetMessages.V4.Upcast as U4
import Internal.Tools.Context as Context exposing (Context, VBA)
import Internal.Tools.Exceptions as X
import Internal.Tools.VersionControl as VC
import Task exposing (Task)


getMessages : Context (VBA a) -> GetMessagesInput -> Task X.Error GetMessagesOutput
getMessages context input =
    VC.withBottomLayer
        { current = Api.getMessagesV1
        , version = "r0.0.0"
        }
        |> VC.sameForVersion "r0.0.1"
        |> VC.sameForVersion "r0.1.0"
        |> VC.addMiddleLayer
            { downcast =
                \data ->
                    { direction = data.direction
                    , from = data.from
                    , limit = data.limit
                    , roomId = data.roomId
                    }
            , current = Api.getMessagesV2
            , upcast = identity -- TODO: Manually filter out events after "to", if possible.
            , version = "r0.2.0"
            }
        |> VC.addMiddleLayer
            { downcast =
                \data ->
                    { direction = data.direction
                    , from = data.from
                    , limit = data.limit
                    , roomId = data.roomId
                    , to = data.to
                    }
            , current = Api.getMessagesV3
            , upcast = identity -- TODO: Manually filter events based on filter input.
            , version = "r0.3.0"
            }
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.getMessagesV4
            , upcast = \f c -> Task.map U2.upcastMessagesResponse (f c)
            , version = "r0.4.0"
            }
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.getMessagesV5
            , upcast = \f c -> Task.map U3.upcastMessagesResponse (f c)
            , version = "r0.5.0"
            }
        |> VC.sameForVersion "r0.6.0"
        |> VC.sameForVersion "r0.6.1"
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.getMessagesV6
            , upcast = identity
            , version = "v1.1"
            }
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.getMessagesV7
            , upcast = \f c -> Task.map U4.upcastMessagesResponse (f c)
            , version = "v1.2"
            }
        |> VC.addMiddleLayer
            { downcast = identity
            , current = Api.getMessagesV8
            , upcast = identity
            , version = "v1.3"
            }
        |> VC.sameForVersion "v1.4"
        |> VC.sameForVersion "v1.5"
        |> VC.sameForVersion "v1.6"
        |> VC.mostRecentFromVersionList (Context.getVersions context)
        |> Maybe.withDefault (always <| always <| Task.fail X.UnsupportedSpecVersion)
        |> (|>) input
        |> (|>) context


type alias GetMessagesInput =
    Api.GetMessagesInputV4


type alias GetMessagesOutput =
    Api.GetMessagesOutputV4
