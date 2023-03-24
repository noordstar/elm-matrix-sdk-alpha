module Internal.Api.WhoAmI.V2.Upcast exposing (..)

import Internal.Api.WhoAmI.V1.SpecObjects as PO
import Internal.Api.WhoAmI.V2.SpecObjects as SO


upcastWhoAmIResponse : PO.WhoAmIResponse -> SO.WhoAmIResponse
upcastWhoAmIResponse old =
    { userId = old.userId, deviceId = Nothing }
