module Internal.Api.SetAccountData.Api exposing (..)

import Internal.Api.Request as R
import Internal.Tools.Context as Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Task exposing (Task)


type alias SetAccountDataInputV1 =
    { eventType : String
    , roomId : Maybe String
    , content : D.Value
    }


type alias SetAccountDataOutputV1 =
    ()


setAccountDataV1 : SetAccountDataInputV1 -> Context { a | accessToken : (), baseUrl : (), userId : () } -> Task X.Error SetAccountDataOutputV1
setAccountDataV1 { content, eventType, roomId } context =
    (case roomId of
        Just rId ->
            R.callApi "PUT" "/_matrix/client/r0/user/{userId}/rooms/{roomId}/account_data/{type}"
                >> R.withAttributes [ R.replaceInUrl "roomId" rId ]

        Nothing ->
            R.callApi "PUT" "/_matrix/client/r0/user/{userId}/account_data/{type}"
    )
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "type" eventType
            , R.replaceInUrl "userId" (Context.getUserId context)
            , R.fullBody content
            ]
        >> R.toTask (D.map (always ()) D.value)
        |> (|>) context


setAccountDataV2 : SetAccountDataInputV1 -> Context { a | accessToken : (), baseUrl : (), userId : () } -> Task X.Error SetAccountDataOutputV1
setAccountDataV2 { content, eventType, roomId } context =
    (case roomId of
        Just rId ->
            R.callApi "PUT" "/_matrix/client/v3/user/{userId}/rooms/{roomId}/account_data/{type}"
                >> R.withAttributes [ R.replaceInUrl "roomId" rId ]

        Nothing ->
            R.callApi "PUT" "/_matrix/client/v3/user/{userId}/account_data/{type}"
    )
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "type" eventType
            , R.replaceInUrl "userId" (Context.getUserId context)
            , R.fullBody content
            ]
        >> R.toTask (D.map (always ()) D.value)
        |> (|>) context
