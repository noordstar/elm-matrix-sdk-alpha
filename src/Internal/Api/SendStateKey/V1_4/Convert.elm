module Internal.Api.SendStateKey.V1_4.Convert exposing (..)

import Internal.Api.SendStateKey.V1_4.Objects as O
import Internal.Api.SendStateKey.V1_4.SpecObjects as SO


convert : SO.EventResponse -> O.EventResponse
convert =
    identity
