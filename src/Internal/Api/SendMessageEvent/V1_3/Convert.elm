module Internal.Api.SendMessageEvent.V1_3.Convert exposing (..)

import Internal.Api.SendMessageEvent.V1_3.Objects as O
import Internal.Api.SendMessageEvent.V1_3.SpecObjects as SO


convert : SO.EventResponse -> O.EventResponse
convert =
    identity
