module Internal.Api.WhoAmI.V3.Upcast exposing (..)

import Internal.Api.WhoAmI.V2.SpecObjects as PO
import Internal.Api.WhoAmI.V3.SpecObjects as SO


upcastWhoAmIResponse : PO.WhoAmIResponse -> SO.WhoAmIResponse
upcastWhoAmIResponse old =
    { deviceId = old.deviceId, isGuest = False, userId = old.userId }
