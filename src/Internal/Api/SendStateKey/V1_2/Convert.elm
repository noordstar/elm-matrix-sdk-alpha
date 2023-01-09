module Internal.Api.SendStateKey.V1_2.Convert exposing (..)

import Internal.Api.SendStateKey.V1_2.Objects as O
import Internal.Api.SendStateKey.V1_2.SpecObjects as SO


convert : SO.EventResponse -> O.EventResponse
convert =
    identity
