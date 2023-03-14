module Internal.Api.Request exposing (..)

import Http
import Internal.Tools.Context as Context exposing (Context)
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Json.Encode as E
import Task exposing (Task)
import Url
import Url.Builder as UrlBuilder


type ApiCall ph
    = ApiCall
        { attributes : List ContextAttr
        , baseUrl : String
        , context : Context ph
        , method : String
        }


type alias Attribute a =
    Context a -> ContextAttr


type ContextAttr
    = BodyParam String E.Value
    | FullBody E.Value
    | Header Http.Header
    | NoAttr
    | QueryParam UrlBuilder.QueryParameter
    | ReplaceInUrl String String
    | Timeout Float
    | UrlPath String


callApi : String -> String -> Context { a | baseUrl : () } -> ApiCall { a | baseUrl : () }
callApi method path context =
    ApiCall
        { attributes =
            [ UrlPath path
            ]
        , baseUrl = Context.getBaseUrl context
        , context = context
        , method = method
        }



{- GETTING VALUES

   Once a user has finished building the ApiCall, we will build the task.
-}


toTask : D.Decoder a -> ApiCall ph -> Task X.Error a
toTask decoder (ApiCall data) =
    Http.task
        { method = data.method
        , headers =
            List.filterMap
                (\attr ->
                    case attr of
                        Header h ->
                            Just h

                        _ ->
                            Nothing
                )
                data.attributes
        , url = getUrl (ApiCall data)
        , body =
            data.attributes
                |> List.filterMap
                    (\attr ->
                        case attr of
                            FullBody v ->
                                Just v

                            _ ->
                                Nothing
                    )
                |> List.reverse
                |> List.head
                |> Maybe.withDefault
                    (List.filterMap
                        (\attr ->
                            case attr of
                                BodyParam key value ->
                                    Just ( key, value )

                                _ ->
                                    Nothing
                        )
                        data.attributes
                        |> E.object
                    )
                |> Http.jsonBody
        , resolver = rawApiCallResolver (always decoder)
        , timeout =
            data.attributes
                |> List.filterMap
                    (\attr ->
                        case attr of
                            Timeout t ->
                                Just t

                            _ ->
                                Nothing
                    )
                |> List.reverse
                |> List.head
        }


getUrl : ApiCall a -> String
getUrl (ApiCall { baseUrl, attributes }) =
    UrlBuilder.crossOrigin
        baseUrl
        (getPath attributes)
        (getQueryParams attributes)


getPath : List ContextAttr -> List String
getPath =
    List.foldl
        (\attr prior ->
            case attr of
                UrlPath posterior ->
                    posterior

                ReplaceInUrl from to ->
                    String.replace from to prior

                _ ->
                    prior
        )
        ""
        >> removeStartingSlashes
        >> String.split "/"


removeStartingSlashes : String -> String
removeStartingSlashes url =
    if String.startsWith "/" url then
        url
            |> String.dropLeft 1
            |> removeStartingSlashes

    else
        url


getQueryParams : List ContextAttr -> List UrlBuilder.QueryParameter
getQueryParams =
    List.filterMap
        (\attr ->
            case attr of
                QueryParam q ->
                    Just q

                _ ->
                    Nothing
        )



{- ATTRIBUTES

   The following functions can alter how an ApiCall behaves,
   and what information it will give to the Matrix API.
-}


withAttributes : List (Attribute a) -> ApiCall a -> ApiCall a
withAttributes attrs (ApiCall data) =
    ApiCall
        { attributes =
            attrs
                |> List.map (\attr -> attr data.context)
                |> List.append data.attributes
        , baseUrl = data.baseUrl
        , context = data.context
        , method = data.method
        }


accessToken : Attribute { a | accessToken : () }
accessToken =
    Context.getAccessToken
        >> (++) "Bearer "
        >> Http.header "Authorization"
        >> Header


bodyBool : String -> Bool -> Attribute a
bodyBool key value =
    bodyValue key (E.bool value)


bodyInt : String -> Int -> Attribute a
bodyInt key value =
    bodyValue key (E.int value)


bodyOpBool : String -> Maybe Bool -> Attribute a
bodyOpBool key value =
    case value of
        Just b ->
            bodyBool key b

        Nothing ->
            always NoAttr


bodyOpInt : String -> Maybe Int -> Attribute a
bodyOpInt key value =
    case value of
        Just i ->
            bodyInt key i

        Nothing ->
            always NoAttr


bodyOpString : String -> Maybe String -> Attribute a
bodyOpString key value =
    case value of
        Just s ->
            bodyString key s

        Nothing ->
            always NoAttr


bodyOpValue : String -> Maybe E.Value -> Attribute a
bodyOpValue key value =
    case value of
        Just v ->
            bodyValue key v

        Nothing ->
            always NoAttr


bodyString : String -> String -> Attribute a
bodyString key value =
    bodyValue key (E.string value)


bodyValue : String -> E.Value -> Attribute a
bodyValue key value _ =
    BodyParam key value


fullBody : E.Value -> Attribute a
fullBody value _ =
    FullBody value


queryBool : String -> Bool -> Attribute a
queryBool key value _ =
    (if value then
        "true"

     else
        "false"
    )
        |> UrlBuilder.string key
        |> QueryParam


queryOpBool : String -> Maybe Bool -> Attribute a
queryOpBool key value =
    case value of
        Just b ->
            queryBool key b

        Nothing ->
            always NoAttr


queryInt : String -> Int -> Attribute a
queryInt key value _ =
    QueryParam <| UrlBuilder.int key value


queryOpInt : String -> Maybe Int -> Attribute a
queryOpInt key value =
    case value of
        Just i ->
            queryInt key i

        Nothing ->
            always NoAttr


queryOpString : String -> Maybe String -> Attribute a
queryOpString key value =
    case value of
        Just s ->
            queryString key s

        Nothing ->
            always NoAttr


queryString : String -> String -> Attribute a
queryString key value _ =
    QueryParam <| UrlBuilder.string key value


replaceInUrl : String -> String -> Attribute a
replaceInUrl key value _ =
    ReplaceInUrl ("{" ++ key ++ "}") (Url.percentEncode value)


timeout : Maybe Float -> Attribute a
timeout mf _ =
    case mf of
        Just f ->
            Timeout f

        Nothing ->
            NoAttr


withTransactionId : Attribute { a | transactionId : () }
withTransactionId =
    Context.getTransactionId >> ReplaceInUrl "txnId"


rawApiCallResolver : (Int -> D.Decoder a) -> Http.Resolver X.Error a
rawApiCallResolver decoder =
    Http.stringResolver
        (\response ->
            case response of
                Http.BadUrl_ s ->
                    Http.BadUrl s
                        |> X.InternetException
                        |> Err

                Http.Timeout_ ->
                    Http.Timeout
                        |> X.InternetException
                        |> Err

                Http.NetworkError_ ->
                    Http.NetworkError
                        |> X.InternetException
                        |> Err

                Http.BadStatus_ metadata body ->
                    decodeServerResponse (decoder metadata.statusCode) body

                Http.GoodStatus_ metadata body ->
                    decodeServerResponse (decoder metadata.statusCode) body
        )


decodeServerResponse : D.Decoder a -> String -> Result X.Error a
decodeServerResponse decoder body =
    case D.decodeString D.value body of
        Err e ->
            e
                |> D.errorToString
                |> X.ServerReturnsBadJSON
                |> X.SDKException
                |> Err

        Ok _ ->
            case D.decodeString decoder body of
                Ok v ->
                    Ok v

                Err err ->
                    -- The response is not valid!
                    -- Check if it is a valid error type as defined in spec.
                    case D.decodeString X.errorCatches body of
                        Ok v ->
                            Err (X.ServerException v)

                        Err _ ->
                            err
                                |> D.errorToString
                                |> X.ServerReturnsBadJSON
                                |> X.SDKException
                                |> Err
