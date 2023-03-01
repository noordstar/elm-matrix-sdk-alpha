module Internal.Room exposing (..)

{-| The `Room` type represents a Matrix Room. In here, you will find utilities to ask information about a room.
-}

import Internal.Api.All as Api
import Internal.Api.PreApi.Objects.Versions as V
import Internal.Tools.Exceptions as X
import Internal.Tools.LoginValues exposing (AccessToken)
import Internal.Values.Room as Internal
import Json.Encode as E
import Task exposing (Task)


{-| The Room type.
-}
type Room
    = Room
        { room : Internal.Room
        , accessToken : AccessToken
        , baseUrl : String
        , versions : Maybe V.Versions
        }


init : { accessToken : AccessToken, baseUrl : String, versions : Maybe V.Versions } -> Internal.Room -> Room
init { accessToken, baseUrl, versions } room =
    Room
        { accessToken = accessToken
        , baseUrl = baseUrl
        , room = room
        , versions = versions
        }


{-| Get the room's id.
-}
roomId : Room -> String
roomId (Room { room }) =
    Internal.roomId room


sendEvent : Room -> { eventType : String, content : E.Value } -> Task X.Error Api.CredUpdate
sendEvent (Room { room, accessToken, baseUrl, versions }) { eventType, content } =
    Api.sendMessageEvent
        { accessToken = accessToken
        , baseUrl = baseUrl
        , content = content
        , eventType = eventType
        , roomId = Internal.roomId room
        , versions = versions
        , extraTransactionNoise = "content-value:<object>"
        }


sendMessage : Room -> String -> Task X.Error Api.CredUpdate
sendMessage (Room { room, accessToken, baseUrl, versions }) text =
    Api.sendMessageEvent
        { accessToken = accessToken
        , baseUrl = baseUrl
        , content =
            E.object
                [ ( "msgtype", E.string "m.text" )
                , ( "body", E.string text )
                ]
        , eventType = "m.room.message"
        , roomId = Internal.roomId room
        , versions = versions
        , extraTransactionNoise = "literal-message:" ++ text
        }
