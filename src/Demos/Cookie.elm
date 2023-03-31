module Demos.Cookie exposing (main)

import Browser
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Internal.Tools.Exceptions as X
import Json.Decode as D
import Json.Encode as E
import Matrix exposing (VaultUpdate)
import Matrix.Event
import Matrix.Room
import Task
import Time
import Url


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }



-- MODEL


type Msg
    = Login { accessToken : String, baseUrl : String }
    | SendEventToRoom String
    | SyncVault
    | VaultUpdate (Result X.Error Matrix.VaultUpdate)
    | WriteAccessToken String
    | WriteBaseUrl String


type Model
    = LoginMenu { accessToken : String, baseUrl : String }
    | CookieView Matrix.Vault


init : () -> ( Model, Cmd Msg )
init _ =
    ( LoginMenu { accessToken = "", baseUrl = "" }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Login data, _ ) ->
            let
                vault : Matrix.Vault
                vault =
                    Matrix.fromAccessToken data
            in
            ( CookieView vault, Matrix.sync vault |> Task.attempt VaultUpdate )

        ( VaultUpdate _, LoginMenu _ ) ->
            ( model, Cmd.none )

        ( VaultUpdate u, CookieView vault ) ->
            case u of
                Ok vu ->
                    ( vault
                        |> Matrix.updateWith vu
                        |> CookieView
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        ( SendEventToRoom _, LoginMenu _ ) ->
            ( model, Cmd.none )

        ( SendEventToRoom roomId, CookieView vault ) ->
            ( model
            , vault
                |> Matrix.getRoomById roomId
                |> Maybe.map
                    (Matrix.Room.sendOneEvent
                        { content = E.object [ ( "body", E.string "I sent you a cookie! :)" ) ]
                        , eventType = "me.noordstar.demo_cookie"
                        , stateKey = Nothing
                        }
                        >> Task.attempt VaultUpdate
                    )
                |> Maybe.withDefault Cmd.none
            )

        ( SyncVault, LoginMenu _ ) ->
            ( model, Cmd.none )

        ( SyncVault, CookieView vault ) ->
            ( model, Matrix.sync vault |> Task.attempt VaultUpdate )

        ( WriteAccessToken s, LoginMenu data ) ->
            ( LoginMenu { data | accessToken = s }, Cmd.none )

        ( WriteAccessToken _, _ ) ->
            ( model, Cmd.none )

        ( WriteBaseUrl s, LoginMenu data ) ->
            ( LoginMenu { data | baseUrl = s }, Cmd.none )

        ( WriteBaseUrl _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        CookieView _ ->
            Time.every 5000 (always SyncVault)

        _ ->
            Sub.none



-- VIEW


cookies : List Matrix.Room.Room -> Dict String Int
cookies =
    let
        merge : Matrix.Room.Room -> Dict String Int -> Dict String Int
        merge room d =
            room
                |> Matrix.Room.mostRecentEvents
                |> List.filterMap
                    (\event ->
                        case Matrix.Event.eventType event of
                            "me.noordstar.demo_cookie" ->
                                Just (Matrix.Event.sender event)

                            _ ->
                                Nothing
                    )
                |> List.foldl
                    (\user users ->
                        case Dict.get user users of
                            Just i ->
                                Dict.insert user (i + 1) users

                            Nothing ->
                                Dict.insert user 1 users
                    )
                    d
    in
    List.foldl merge Dict.empty


view : Model -> Html Msg
view model =
    case model of
        LoginMenu ({ accessToken, baseUrl } as data) ->
            [ Html.span [] [ Html.text "Homeserver URL:" ]
            , Html.input
                [ Html.Events.onInput WriteBaseUrl
                , Html.Attributes.style "font-size" "20px"
                , Html.Attributes.style "width" "80%"
                ]
                [ Html.text baseUrl ]
            , Html.span [] [ Html.text "Access token:" ]
            , Html.input
                [ Html.Events.onInput WriteAccessToken
                , Html.Attributes.style "font-size" "20px"
                , Html.Attributes.style "width" "80%"
                ]
                [ Html.text accessToken ]
            , case ( Url.fromString baseUrl, accessToken ) of
                ( _, "" ) ->
                    Html.div [ Html.Attributes.style "height" "30px" ] []

                ( Nothing, _ ) ->
                    Html.div [ Html.Attributes.style "height" "30px" ] []

                ( Just _, _ ) ->
                    Html.button
                        [ Html.Attributes.style "font-size" "20px"
                        , Html.Attributes.style "height" "30px"
                        , Html.Events.onClick (Login data)
                        ]
                        [ Html.text "Access" ]
            ]
                |> Html.div
                    [ Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "flex-flow" "column nowrap"
                    , Html.Attributes.style "justify-content" "space-evenly"
                    , Html.Attributes.style "align-items" "center"
                    , Html.Attributes.style "font-size" "20px"
                    , Html.Attributes.style "height" "250px"
                    , Html.Attributes.style "background-color" "antiquewhite"
                    ]

        CookieView vault ->
            case Matrix.getRooms vault of
                [] ->
                    Html.text "Loading rooms..."
                        |> List.singleton
                        |> Html.div
                            [ Html.Attributes.style "display" "flex"
                            , Html.Attributes.style "flex-flow" "column nowrap"
                            , Html.Attributes.style "justify-content" "space-evenly"
                            , Html.Attributes.style "align-items" "center"
                            , Html.Attributes.style "font-size" "20px"
                            , Html.Attributes.style "background-color" "antiquewhite"
                            ]

                _ :: _ ->
                    [ vault
                        |> Matrix.getRooms
                        |> cookies
                        |> Debug.log "Cookies: "
                        |> Dict.toList
                        |> List.map
                            (\( user, amount ) ->
                                case amount of
                                    0 ->
                                        user ++ " didn't send you any cookies."

                                    1 ->
                                        user ++ " sent you a cookie! 🍪"

                                    2 ->
                                        user ++ " sent you 2 cookies! 🍪🍪"

                                    _ ->
                                        user ++ " sent you " ++ String.fromInt amount ++ " cookies! 🍪🍪🍪"
                            )
                        |> List.map Html.text
                        |> List.map List.singleton
                        |> List.map (Html.p [])
                        |> Html.div []
                    , vault
                        |> Matrix.getRooms
                        |> List.map
                            (\room ->
                                let
                                    roomName : String
                                    roomName =
                                        room
                                            |> Matrix.Room.stateEvent { eventType = "m.room.name", stateKey = "" }
                                            |> Maybe.andThen
                                                (\event ->
                                                    case D.decodeValue (D.field "name" D.string) (Matrix.Event.content event) of
                                                        Ok title ->
                                                            Just title

                                                        Err _ ->
                                                            Nothing
                                                )
                                            |> Maybe.withDefault (Matrix.Room.roomId room)
                                in
                                [ Html.text roomName
                                , Html.text "Click here to send a cookie to everyone in this room!"
                                ]
                                    |> List.map List.singleton
                                    |> List.map (Html.span [])
                                    |> Html.span
                                        [ Html.Events.onClick <| SendEventToRoom <| Matrix.Room.roomId room
                                        , Html.Attributes.style "display" "flex"
                                        , Html.Attributes.style "flex-flow" "column nowrap"
                                        , Html.Attributes.style "justify-content" "space-evenly"
                                        , Html.Attributes.style "margin" "20px"
                                        , Html.Attributes.style "background-color" "beige"
                                        ]
                            )
                        |> Html.div []
                    ]
                        |> Html.div
                            [ Html.Attributes.style "display" "flex"
                            , Html.Attributes.style "flex-flow" "column nowrap"
                            , Html.Attributes.style "justify-content" "space-evenly"
                            , Html.Attributes.style "align-items" "center"
                            , Html.Attributes.style "font-size" "20px"
                            , Html.Attributes.style "background-color" "antiquewhite"
                            ]
