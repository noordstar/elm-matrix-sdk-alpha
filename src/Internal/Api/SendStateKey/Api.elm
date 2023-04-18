module Internal.Api.SendStateKey.Api exposing (..)

import Internal.Api.Request as R
import Internal.Api.SendStateKey.V1.SpecObjects as SO1
import Internal.Config.SpecErrors as SE
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias SendStateKeyInputV1 =
    { content : D.Value
    , eventType : String
    , roomId : String
    , stateKey : String
    }


type alias SendStateKeyOutputV1 =
    SO1.EventResponse


sendStateKeyV1 : SendStateKeyInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error SendStateKeyOutputV1
sendStateKeyV1 { content, eventType, roomId, stateKey } =
    R.callApi "PUT" "/_matrix/client/r0/rooms/{roomId}/state/{eventType}/{stateKey}"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "eventType" eventType
            , R.replaceInUrl "roomId" roomId
            , R.replaceInUrl "stateKey" stateKey
            , R.fullBody content
            , R.onStatusCode 400 (X.M_INVALID_PARAM { error = Just SE.invalidRequest })
            , R.onStatusCode 403 (X.M_FORBIDDEN { error = Just SE.sendNotAllowed })
            ]
        >> R.toTask SO1.eventResponseDecoder


sendStateKeyV2 : SendStateKeyInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error SendStateKeyOutputV1
sendStateKeyV2 { content, eventType, roomId, stateKey } =
    R.callApi "PUT" "/_matrix/client/v3/rooms/{roomId}/state/{eventType}/{stateKey}"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "eventType" eventType
            , R.replaceInUrl "roomId" roomId
            , R.replaceInUrl "stateKey" stateKey
            , R.fullBody content
            , R.onStatusCode 400 (X.M_INVALID_PARAM { error = Just SE.invalidRequest })
            , R.onStatusCode 403 (X.M_FORBIDDEN { error = Just SE.sendNotAllowed })
            ]
        >> R.toTask SO1.eventResponseDecoder
