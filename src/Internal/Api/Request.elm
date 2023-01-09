module Internal.Api.Request exposing (..)

import Http
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Json.Encode as E
import Process
import Task exposing (Task)
import Time
import Url.Builder as UrlBuilder


{-| Make a raw API call to a Matrix API.
-}
rawApiCall :
    { headers : Headers
    , method : String
    , baseUrl : String
    , path : String
    , pathParams : List ( String, String )
    , queryParams : List QueryParam
    , bodyParams : List BodyParam
    , timeout : Maybe Float
    , decoder : Int -> D.Decoder a
    }
    -> Task X.Error a
rawApiCall data =
    Http.task
        { method = data.method
        , headers = fromHeaders data.headers
        , url = buildUrl data.baseUrl data.path data.pathParams data.queryParams
        , body = toBody data.bodyParams
        , resolver = rawApiCallResolver data.decoder
        , timeout = data.timeout
        }


withRateLimits : Int -> Task X.Error a -> Task X.Error a
withRateLimits timeout task =
    Time.now
        |> Task.onError
            (\_ -> X.CouldntGetTimestamp |> X.SDKException |> Task.fail)
        |> Task.andThen
            (\now ->
                task
                    |> Task.onError
                        (\err ->
                            case err of
                                X.ServerException (X.M_LIMIT_EXCEEDED data) ->
                                    case data.retryAfterMs of
                                        Just t ->
                                            Process.sleep (toFloat t)
                                                |> Task.andThen (\_ -> Time.now)
                                                |> Task.andThen
                                                    (\newNow ->
                                                        let
                                                            diff : Int
                                                            diff =
                                                                timeout - (Time.posixToMillis newNow - Time.posixToMillis now)
                                                        in
                                                        if diff <= 0 then
                                                            Task.fail err

                                                        else
                                                            withRateLimits diff task
                                                    )

                                        Nothing ->
                                            Task.fail err

                                _ ->
                                    Task.fail err
                        )
            )


{-| Potential headers to go along with a Matrix API call.
-}
type Headers
    = NoHeaders
    | WithAccessToken String
    | WithContentType String
    | WithBoth { accessToken : String, contentType : String }


{-| Turn Headers into useful values
-}
fromHeaders : Headers -> List Http.Header
fromHeaders h =
    (case h of
        NoHeaders ->
            [ ( "Content-Type", "application/json" ) ]

        WithAccessToken token ->
            [ ( "Content-Type", "application/json" ), ( "Authorization", "Bearer " ++ token ) ]

        WithContentType contentType ->
            [ ( "Content-Type", contentType ) ]

        WithBoth data ->
            [ ( "Content-Type", data.contentType ), ( "Authorization", "Bearer " ++ data.accessToken ) ]
    )
        |> List.map (\( a, b ) -> Http.header a b)


{-| -}
type QueryParam
    = QueryParamString String String
    | OpQueryParamString String (Maybe String)
    | QueryParamInt String Int
    | OpQueryParamInt String (Maybe Int)
    | QueryParamBool String Bool
    | OpQueryParamBool String (Maybe Bool)


fromQueryParam : QueryParam -> Maybe UrlBuilder.QueryParameter
fromQueryParam param =
    case param of
        QueryParamString key value ->
            Just <| UrlBuilder.string key value

        OpQueryParamString key value ->
            Maybe.map (UrlBuilder.string key) value

        QueryParamInt key value ->
            Just <| UrlBuilder.int key value

        OpQueryParamInt key value ->
            Maybe.map (UrlBuilder.int key) value

        QueryParamBool key value ->
            if value then
                Just <| UrlBuilder.string key "true"

            else
                Just <| UrlBuilder.string key "false"

        OpQueryParamBool key value ->
            Maybe.andThen (QueryParamBool key >> fromQueryParam) value


fromQueryParams : List QueryParam -> List UrlBuilder.QueryParameter
fromQueryParams =
    List.map fromQueryParam
        >> List.filterMap identity


buildUrl : String -> String -> List ( String, String ) -> List QueryParam -> String
buildUrl baseUrl path pathParams queryParams =
    let
        fullPath : String
        fullPath =
            List.foldl
                (\( a, b ) -> String.replace ("{" ++ a ++ "}") b)
                path
                pathParams
                |> (\s ->
                        if String.startsWith "/" s then
                            String.dropLeft 1 s

                        else
                            s
                   )
    in
    UrlBuilder.crossOrigin baseUrl [ fullPath ] (fromQueryParams queryParams)


{-| Type that gathers all parameters that go in the request body.
-}
type BodyParam
    = OptionalString String (Maybe String)
    | RequiredString String String
    | OptionalInt String (Maybe Int)
    | RequiredInt String Int
    | OptionalValue String (Maybe E.Value)
    | RequiredValue String E.Value


encodeBodyParam : BodyParam -> ( String, Maybe E.Value )
encodeBodyParam b =
    case b of
        OptionalString h s ->
            ( h, Maybe.map E.string s )

        RequiredString h s ->
            ( h, Just <| E.string s )

        OptionalInt h i ->
            ( h, Maybe.map E.int i )

        RequiredInt h i ->
            ( h, Just <| E.int i )

        OptionalValue h v ->
            ( h, v )

        RequiredValue h v ->
            ( h, Just v )


toBody : List BodyParam -> Http.Body
toBody params =
    case params of
        (RequiredValue "*" v) :: [] ->
            Http.jsonBody v

        _ ->
            List.map encodeBodyParam params
                |> maybeObject
                |> Http.jsonBody


{-| Create a body object based on optionally provided values.
-}
maybeObject : List ( String, Maybe E.Value ) -> E.Value
maybeObject =
    List.filterMap
        (\( name, value ) ->
            case value of
                Just v ->
                    Just ( name, v )

                _ ->
                    Nothing
        )
        >> E.object


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
