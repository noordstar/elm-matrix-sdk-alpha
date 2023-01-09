module Internal.Api.SendStateKey.V1_5.Convert exposing (..)

import Internal.Api.SendStateKey.V1_5.Objects as O
import Internal.Api.SendStateKey.V1_5.SpecObjects as SO


convert : SO.EventResponse -> O.EventResponse
convert =
    identity
