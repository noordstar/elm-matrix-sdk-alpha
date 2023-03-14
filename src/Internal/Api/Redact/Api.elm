module Internal.Api.Redact.Api exposing (..)

import Internal.Api.Redact.V1.SpecObjects as SO1
import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias RedactInputV1 =
    { roomId : String
    , eventId : String
    , reason : Maybe String
    }


type alias RedactOutputV1 =
    SO1.Redaction


redactV1 : RedactInputV1 -> Context { a | accessToken : (), baseUrl : (), transactionId : () } -> Task X.Error RedactOutputV1
redactV1 { eventId, reason, roomId } =
    R.callApi "PUT" "/_matrix/client/r0/rooms/{roomId}/redact/{eventId}/{txnId}"
        >> R.withAttributes
            [ R.accessToken
            , R.withTransactionId
            , R.replaceInUrl "eventId" eventId
            , R.replaceInUrl "roomId" roomId
            , R.bodyOpString "reason" reason
            ]
        >> R.toTask SO1.redactionDecoder


redactV2 : RedactInputV1 -> Context { a | accessToken : (), baseUrl : (), transactionId : () } -> Task X.Error RedactOutputV1
redactV2 { eventId, reason, roomId } =
    R.callApi "PUT" "/_matrix/client/v3/rooms/{roomId}/redact/{eventId}/{txnId}"
        >> R.withAttributes
            [ R.accessToken
            , R.withTransactionId
            , R.replaceInUrl "eventId" eventId
            , R.replaceInUrl "roomId" roomId
            , R.bodyOpString "reason" reason
            ]
        >> R.toTask SO1.redactionDecoder
