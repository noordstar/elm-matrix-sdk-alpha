module Internal.Api.GetEvent.Api exposing (..)

import Internal.Api.GetEvent.V1.SpecObjects as SO1
import Internal.Api.Request as R
import Internal.Config.SpecErrors as SE
import Internal.Tools.Context as Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias GetEventInputV1 =
    { roomId : String
    }


type alias GetEventOutputV1 =
    SO1.ClientEvent


getEventInputV1 : GetEventInputV1 -> Context { a | accessToken : (), baseUrl : (), sentEvent : () } -> Task X.Error GetEventOutputV1
getEventInputV1 data context =
    context
        |> R.callApi "GET" "/_matrix/client/r0/rooms/{roomId}/event/{eventId}"
        |> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "eventId" (Context.getSentEvent context)
            , R.replaceInUrl "roomId" data.roomId
            , R.onStatusCode 404 (X.M_NOT_FOUND { error = Just SE.eventNotFound })
            ]
        |> R.toTask SO1.clientEventDecoder


getEventInputV2 : GetEventInputV1 -> Context { a | accessToken : (), baseUrl : (), sentEvent : () } -> Task X.Error GetEventOutputV1
getEventInputV2 data context =
    context
        |> R.callApi "GET" "/_matrix/client/v3/rooms/{roomId}/event/{eventId}"
        |> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "eventId" (Context.getSentEvent context)
            , R.replaceInUrl "roomId" data.roomId
            , R.onStatusCode 404 (X.M_NOT_FOUND { error = Just SE.eventNotFound })
            ]
        |> R.toTask SO1.clientEventDecoder
