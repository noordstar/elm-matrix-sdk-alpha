module Internal.Api.GetMessages.Api exposing (..)

import Internal.Api.GetMessages.V1.SpecObjects as SO1
import Internal.Api.GetMessages.V2.SpecObjects as SO2
import Internal.Api.GetMessages.V3.SpecObjects as SO3
import Internal.Api.GetMessages.V4.SpecObjects as SO4
import Internal.Api.Request as R
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Internal.Tools.SpecEnums as Enums
import Task exposing (Task)


type alias GetMessagesInputV1 =
    { direction : Enums.EventOrder
    , from : Maybe String
    , limit : Maybe Int
    , roomId : String
    }


type alias GetMessagesInputV2 =
    { direction : Enums.EventOrder
    , from : Maybe String
    , limit : Maybe Int
    , roomId : String
    , to : Maybe String
    }


type alias GetMessagesInputV3 =
    { direction : Enums.EventOrder
    , filter : Maybe String
    , from : Maybe String
    , limit : Maybe Int
    , roomId : String
    , to : Maybe String
    }


type alias GetMessagesInputV4 =
    { direction : Enums.EventOrder
    , filter : Maybe String
    , from : Maybe String
    , limit : Maybe Int
    , roomId : String
    , to : Maybe String
    }


type alias GetMessagesOutputV1 =
    SO1.MessagesResponse


type alias GetMessagesOutputV2 =
    SO2.MessagesResponse


type alias GetMessagesOutputV3 =
    SO3.MessagesResponse


type alias GetMessagesOutputV4 =
    SO4.MessagesResponse


getMessagesV1 : GetMessagesInputV1 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetMessagesOutputV1
getMessagesV1 { direction, from, limit, roomId } =
    case from of
        Just f ->
            R.callApi "GET" "/_matrix/client/r0/rooms/{roomId}/messages"
                >> R.withAttributes
                    [ R.accessToken
                    , R.replaceInUrl "roomId" roomId
                    , R.queryString "dir" (Enums.fromEventOrder direction)
                    , R.queryString "from" f
                    , R.queryOpInt "limit" limit
                    ]
                >> R.toTask SO1.messagesResponseDecoder

        Nothing ->
            always <| Task.fail X.UnsupportedSpecVersion


getMessagesV2 : GetMessagesInputV2 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetMessagesOutputV1
getMessagesV2 { direction, from, limit, roomId, to } =
    case from of
        Just f ->
            R.callApi "GET" "/_matrix/client/r0/rooms/{roomId}/messages"
                >> R.withAttributes
                    [ R.accessToken
                    , R.replaceInUrl "roomId" roomId
                    , R.queryString "dir" (Enums.fromEventOrder direction)
                    , R.queryString "from" f
                    , R.queryOpInt "limit" limit
                    , R.queryOpString "to" to
                    ]
                >> R.toTask SO1.messagesResponseDecoder

        Nothing ->
            always <| Task.fail X.UnsupportedSpecVersion


getMessagesV3 : GetMessagesInputV3 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetMessagesOutputV1
getMessagesV3 { direction, filter, from, limit, roomId, to } =
    case from of
        Just f ->
            R.callApi "GET" "/_matrix/client/r0/rooms/{roomId}/messages"
                >> R.withAttributes
                    [ R.accessToken
                    , R.replaceInUrl "roomId" roomId
                    , R.queryString "dir" (Enums.fromEventOrder direction)
                    , R.queryString "from" f
                    , R.queryOpInt "limit" limit
                    , R.queryOpString "filter" filter
                    , R.queryOpString "to" to
                    ]
                >> R.toTask SO1.messagesResponseDecoder

        Nothing ->
            always <| Task.fail X.UnsupportedSpecVersion


getMessagesV4 : GetMessagesInputV3 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetMessagesOutputV2
getMessagesV4 { direction, filter, from, limit, roomId, to } =
    case from of
        Just f ->
            R.callApi "GET" "/_matrix/client/r0/rooms/{roomId}/messages"
                >> R.withAttributes
                    [ R.accessToken
                    , R.replaceInUrl "roomId" roomId
                    , R.queryString "dir" (Enums.fromEventOrder direction)
                    , R.queryString "from" f
                    , R.queryOpInt "limit" limit
                    , R.queryOpString "filter" filter
                    , R.queryOpString "to" to
                    ]
                >> R.toTask SO2.messagesResponseDecoder

        Nothing ->
            always <| Task.fail X.UnsupportedSpecVersion


getMessagesV5 : GetMessagesInputV3 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetMessagesOutputV3
getMessagesV5 { direction, filter, from, limit, roomId, to } =
    case from of
        Just f ->
            R.callApi "GET" "/_matrix/client/r0/rooms/{roomId}/messages"
                >> R.withAttributes
                    [ R.accessToken
                    , R.replaceInUrl "roomId" roomId
                    , R.queryString "dir" (Enums.fromEventOrder direction)
                    , R.queryString "from" f
                    , R.queryOpInt "limit" limit
                    , R.queryOpString "filter" filter
                    , R.queryOpString "to" to
                    ]
                >> R.toTask SO3.messagesResponseDecoder

        Nothing ->
            always <| Task.fail X.UnsupportedSpecVersion


getMessagesV6 : GetMessagesInputV3 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetMessagesOutputV3
getMessagesV6 { direction, filter, from, limit, roomId, to } =
    case from of
        Just f ->
            R.callApi "GET" "/_matrix/client/v3/rooms/{roomId}/messages"
                >> R.withAttributes
                    [ R.accessToken
                    , R.replaceInUrl "roomId" roomId
                    , R.queryString "dir" (Enums.fromEventOrder direction)
                    , R.queryString "from" f
                    , R.queryOpInt "limit" limit
                    , R.queryOpString "filter" filter
                    , R.queryOpString "to" to
                    ]
                >> R.toTask SO3.messagesResponseDecoder

        Nothing ->
            always <| Task.fail X.UnsupportedSpecVersion


getMessagesV7 : GetMessagesInputV3 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetMessagesOutputV4
getMessagesV7 { direction, filter, from, limit, roomId, to } =
    case from of
        Just f ->
            R.callApi "GET" "/_matrix/client/v3/rooms/{roomId}/messages"
                >> R.withAttributes
                    [ R.accessToken
                    , R.replaceInUrl "roomId" roomId
                    , R.queryString "dir" (Enums.fromEventOrder direction)
                    , R.queryString "from" f
                    , R.queryOpInt "limit" limit
                    , R.queryOpString "filter" filter
                    , R.queryOpString "to" to
                    ]
                >> R.toTask SO4.messagesResponseDecoder

        Nothing ->
            always <| Task.fail X.UnsupportedSpecVersion


getMessagesV8 : GetMessagesInputV4 -> Context { a | accessToken : (), baseUrl : () } -> Task X.Error GetMessagesOutputV4
getMessagesV8 { direction, filter, from, limit, roomId, to } =
    R.callApi "GET" "/_matrix/client/v3/rooms/{roomId}/messages"
        >> R.withAttributes
            [ R.accessToken
            , R.replaceInUrl "roomId" roomId
            , R.queryString "dir" (Enums.fromEventOrder direction)
            , R.queryOpString "from" from
            , R.queryOpInt "limit" limit
            , R.queryOpString "filter" filter
            , R.queryOpString "to" to
            ]
        >> R.toTask SO4.messagesResponseDecoder
