module Internal.Api.Snackbar exposing (..)

{-| The snackbar module helps wraps relevant credentials, access tokens, refresh tokens and more around internal types.

Vault, Room and Event types don't need access to API tokens,
but a user may way to redact an event, leave a room or reject an invite.
In such a case, the `Snackbar` type is a bowl of token candies that you can wrap
around any data type.

That way, you can both access the type within AND carry the tokens on every type
without needing to update every data type whenever any of the tokens change.

-}

import Internal.Api.Versions.V1.Versions as V
import Internal.Tools.LoginValues as Login exposing (AccessToken(..))


type Snackbar a
    = Snackbar
        { access : AccessToken
        , content : a
        , homeserver : String
        , vs : Maybe V.Versions
        }


accessToken : Snackbar a -> AccessToken
accessToken (Snackbar { access }) =
    access


addToken : String -> Snackbar a -> Snackbar a
addToken token (Snackbar ({ access } as data)) =
    Snackbar { data | access = Login.addToken token access }


addUsernameAndPassword : { username : String, password : String } -> Snackbar a -> Snackbar a
addUsernameAndPassword uap (Snackbar ({ access } as data)) =
    Snackbar { data | access = Login.addUsernameAndPassword uap access }


addVersions : V.Versions -> Snackbar a -> Snackbar a
addVersions vs (Snackbar data) =
    Snackbar { data | vs = Just vs }


addWhoAmI : { w | userId : String, deviceId : Maybe String } -> Snackbar a -> Snackbar a
addWhoAmI whoami (Snackbar ({ access } as data)) =
    Snackbar { data | access = Login.addWhoAmI whoami access }


baseUrl : Snackbar a -> String
baseUrl (Snackbar { homeserver }) =
    homeserver


init : { baseUrl : String, content : a } -> Snackbar a
init data =
    Snackbar
        { access = NoAccess
        , content = data.content
        , homeserver = data.baseUrl
        , vs = Nothing
        }


map : (a -> b) -> Snackbar a -> Snackbar b
map f (Snackbar data) =
    Snackbar
        { access = data.access
        , content = f data.content
        , homeserver = data.homeserver
        , vs = data.vs
        }


mapList : (a -> List b) -> Snackbar a -> List (Snackbar b)
mapList f (Snackbar data) =
    List.map (withCandyFrom (Snackbar data)) (f data.content)


mapMaybe : (a -> Maybe b) -> Snackbar a -> Maybe (Snackbar b)
mapMaybe f (Snackbar data) =
    Maybe.map (withCandyFrom (Snackbar data)) (f data.content)


removedAccessToken : Snackbar a -> AccessToken
removedAccessToken (Snackbar { access }) =
    Login.removeToken access


userId : Snackbar a -> Maybe String
userId (Snackbar { access }) =
    Login.getUserId access


versions : Snackbar a -> Maybe V.Versions
versions (Snackbar { vs }) =
    vs


withCandyFrom : Snackbar b -> a -> Snackbar a
withCandyFrom snackbar x =
    map (always x) snackbar


withoutCandy : Snackbar a -> a
withoutCandy (Snackbar { content }) =
    content
