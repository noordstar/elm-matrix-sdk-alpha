module Internal.Api.Snackbar exposing (..)

{-| The snackbar module helps wraps relevant credentials, access tokens, refresh tokens and more around internal types.

Vault, Room and Event types don't need access to API tokens,
but a user may way to redact an event, leave a room or reject an invite.
In such a case, the `Snackbar` type is a bowl of token candies that you can wrap
around any data type.

That way, you can both access the type within AND carry the tokens on every type
without needing to update every data type whenever any of the tokens change.

-}

import Dict exposing (Dict)
import Internal.Api.Versions.V1.Versions as V
import Internal.Tools.LoginValues as Login exposing (AccessToken(..))
import Task exposing (Task)


type Snackbar a vu
    = Snackbar
        { access : AccessToken
        , content : a
        , failedTasks : Dict Int ( String, Snackbar () vu -> Task Never vu )
        , failedTasksOffset : Int
        , homeserver : String
        , transactionOffset : Int
        , vs : Maybe V.Versions
        }


accessToken : Snackbar a vu -> AccessToken
accessToken (Snackbar { access }) =
    access


addFailedTask : (Int -> ( String, Snackbar () vu -> Task Never vu )) -> Snackbar a vu -> Snackbar a vu
addFailedTask taskWithId (Snackbar ({ failedTasks, failedTasksOffset } as data)) =
    Snackbar
        { data
            | failedTasks = Dict.insert failedTasksOffset (taskWithId failedTasksOffset) failedTasks
            , failedTasksOffset = failedTasksOffset + 1
        }


addToken : String -> Snackbar a vu -> Snackbar a vu
addToken token (Snackbar ({ access } as data)) =
    Snackbar { data | access = Login.addToken token access }


addUsernameAndPassword : { username : String, password : String } -> Snackbar a vu -> Snackbar a vu
addUsernameAndPassword uap (Snackbar ({ access } as data)) =
    Snackbar { data | access = Login.addUsernameAndPassword uap access }


addVersions : V.Versions -> Snackbar a vu -> Snackbar a vu
addVersions vs (Snackbar data) =
    Snackbar { data | vs = Just vs }


addWhoAmI : { w | userId : String, deviceId : Maybe String } -> Snackbar a vu -> Snackbar a vu
addWhoAmI whoami (Snackbar ({ access } as data)) =
    Snackbar { data | access = Login.addWhoAmI whoami access }


baseUrl : Snackbar a vu -> String
baseUrl (Snackbar { homeserver }) =
    homeserver


errors : Snackbar a vu -> List String
errors (Snackbar { failedTasks }) =
    Dict.values failedTasks |> List.map Tuple.first


getFailedTasks : Snackbar a vu -> List (Snackbar () vu -> Task Never vu)
getFailedTasks (Snackbar { failedTasks }) =
    Dict.values failedTasks |> List.map Tuple.second


getTransactionOffset : Snackbar a vu -> Int
getTransactionOffset (Snackbar { transactionOffset }) =
    transactionOffset


init : { baseUrl : String, content : a } -> Snackbar a vu
init data =
    Snackbar
        { access = NoAccess
        , content = data.content
        , failedTasks = Dict.empty
        , failedTasksOffset = 0
        , homeserver = data.baseUrl
        , transactionOffset = 0
        , vs = Nothing
        }


map : (a -> b) -> Snackbar a vu -> Snackbar b vu
map f (Snackbar data) =
    Snackbar
        { access = data.access
        , content = f data.content
        , failedTasks = data.failedTasks
        , failedTasksOffset = 0
        , homeserver = data.homeserver
        , transactionOffset = data.transactionOffset
        , vs = data.vs
        }


mapList : (a -> List b) -> Snackbar a vu -> List (Snackbar b vu)
mapList f (Snackbar data) =
    List.map (withCandyFrom (Snackbar data)) (f data.content)


mapMaybe : (a -> Maybe b) -> Snackbar a vu -> Maybe (Snackbar b vu)
mapMaybe f (Snackbar data) =
    Maybe.map (withCandyFrom (Snackbar data)) (f data.content)


removedAccessToken : Snackbar a vu -> AccessToken
removedAccessToken (Snackbar { access }) =
    Login.removeToken access


removeFailedTask : Int -> Snackbar a vu -> Snackbar a vu
removeFailedTask i (Snackbar ({ failedTasks } as data)) =
    Snackbar { data | failedTasks = Dict.remove i failedTasks }


setTransactionOffset : Int -> Snackbar a vu -> Snackbar a vu
setTransactionOffset i (Snackbar data) =
    Snackbar { data | transactionOffset = max (data.transactionOffset + 1) (i + 1) }


userId : Snackbar a vu -> Maybe String
userId (Snackbar { access }) =
    Login.getUserId access


versions : Snackbar a vu -> Maybe V.Versions
versions (Snackbar { vs }) =
    vs


withCandyFrom : Snackbar b vu -> a -> Snackbar a vu
withCandyFrom snackbar x =
    map (always x) snackbar


withoutCandy : Snackbar a vu -> a
withoutCandy (Snackbar { content }) =
    content


withoutContent : Snackbar a vu -> Snackbar () vu
withoutContent =
    map (always ())
