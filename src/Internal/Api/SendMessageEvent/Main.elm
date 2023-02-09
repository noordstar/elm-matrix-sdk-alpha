module Internal.Api.SendMessageEvent.Main exposing (..)

import Internal.Api.SendMessageEvent.Api as Api
import Internal.Tools.VersionControl as VC
import Internal.Tools.Exceptions as X
import Task exposing (Task)


sendMessageEvent : List String -> Maybe (SendMessageEventInput -> SendMessageEventOutput)
sendMessageEvent versions =
    VC.withBottomLayer
        { current = Api.sendMessageEventV1
        , version = "r0.0.0"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV1
        , upcast   = identity
        , version  = "r0.0.1"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV1
        , upcast   = identity
        , version  = "r0.1.0"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV1
        , upcast   = identity
        , version  = "r0.2.0"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV1
        , upcast   = identity
        , version  = "r0.3.0"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV1
        , upcast   = identity
        , version  = "r0.5.0"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV1
        , upcast   = identity
        , version  = "r0.6.0"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV1
        , upcast   = identity
        , version  = "r0.6.1"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV2
        , upcast   = identity
        , version  = "v1.1"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV2
        , upcast   = identity
        , version  = "v1.2"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV2
        , upcast   = identity
        , version  = "v1.3"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV2
        , upcast   = identity
        , version  = "v1.4"
        }
    |> VC.addMiddleLayer
        { downcast = identity
        , current  = Api.sendMessageEventV2
        , upcast   = identity
        , version  = "v1.5"
        }
    |> VC.mostRecentFromVersionList versions


type alias SendMessageEventInput =
    Api.SendMessageEventInputV1


type alias SendMessageEventOutput =
    Api.SendMessageEventOutputV1
