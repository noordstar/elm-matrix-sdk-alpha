module Internal.Api.GetEvent.Api exposing (..)

import Internal.Api.GetEvent.V1.SpecObjects as SO1
import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias GetEventInputV1 =
    { eventId : String
    , roomId : String
    }


type alias GetEventOutputV1 =
    SO1.ClientEvent


getEventInputV1 : GetEventInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetEventOutputV1
getEventInputV1 data =
    R.callApi "GET" "/_matrix/client/v3/rooms/{roomId}/event/{eventId}"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "eventId" data.eventId
            , R.replaceInUrl "roomId" data.roomId
            ]
        >> R.toTask SO1.clientEventDecoder
