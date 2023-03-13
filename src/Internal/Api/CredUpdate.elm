module Internal.Api.CredUpdate exposing (..)

import Hash
import Html exposing (input)
import Internal.Api.Chain as Chain exposing (IdemChain, TaskChain)
import Internal.Api.Context as Context exposing (VB, VBA, VBAT)
import Internal.Api.GetEvent.Main as GetEvent
import Internal.Api.Invite.Main as Invite
import Internal.Api.JoinedMembers.Main as JoinedMembers
import Internal.Api.LoginWithUsernameAndPassword.Main as LoginWithUsernameAndPassword
import Internal.Api.Redact.Main as Redact
import Internal.Api.SendMessageEvent.Main as SendMessageEvent
import Internal.Api.SendStateKey.Main as SendStateKey
import Internal.Api.Sync.Main as Sync
import Internal.Api.Versions.Main as Versions
import Internal.Api.Versions.V1.Versions as V
import Internal.Tools.Exceptions as X
import Internal.Tools.LoginValues exposing (AccessToken(..))
import Internal.Tools.SpecEnums as Enums
import Json.Encode as E
import Task exposing (Task)
import Time


type CredUpdate
    = MultipleUpdates (List CredUpdate)
      -- Updates as a result of API calls
    | GetEvent GetEvent.EventInput GetEvent.EventOutput
    | InviteSent Invite.InviteInput Invite.InviteOutput
    | JoinedMembersToRoom JoinedMembers.JoinedMembersInput JoinedMembers.JoinedMembersOutput
    | LoggedInWithUsernameAndPassword LoginWithUsernameAndPassword.LoginWithUsernameAndPasswordInput LoginWithUsernameAndPassword.LoginWithUsernameAndPasswordOutput
    | MessageEventSent SendMessageEvent.SendMessageEventInput SendMessageEvent.SendMessageEventOutput
    | RedactedEvent Redact.RedactInput Redact.RedactOutput
    | StateEventSent SendStateKey.SendStateKeyInput SendStateKey.SendStateKeyOutput
    | SyncUpdate Sync.SyncInput Sync.SyncOutput
      -- Updates as a result of getting data early
    | UpdateAccessToken String
    | UpdateVersions V.Versions


type alias FutureTask =
    Task X.Error CredUpdate


{-| Turn a chain of tasks into a full executable task.
-}
toTask : TaskChain CredUpdate {} b -> FutureTask
toTask =
    Chain.toTask
        >> Task.map
            (\updates ->
                case updates of
                    [ item ] ->
                        item

                    _ ->
                        MultipleUpdates updates
            )


{-| Get a functional access token.
-}
accessToken : AccessToken -> TaskChain CredUpdate (VB a) (VBA a)
accessToken ctoken =
    case ctoken of
        NoAccess ->
            X.NoAccessToken
                |> X.SDKException
                |> Task.fail
                |> always

        AccessToken t ->
            { contextChange = Context.setAccessToken { accessToken = t, usernameAndPassword = Nothing }
            , messages = []
            }
                |> Chain.TaskChainPiece
                |> Task.succeed
                |> always

        UsernameAndPassword { username, password, token } ->
            case token of
                Just t ->
                    accessToken (AccessToken t)

                Nothing ->
                    loginWithUsernameAndPassword
                        { username = username, password = password }


type alias GetEventInput =
    { eventId : String, roomId : String }


{-| Get an event from the API.
-}
getEvent : GetEventInput -> IdemChain CredUpdate (VBA a)
getEvent { eventId, roomId } context =
    let
        input =
            { accessToken = Context.getAccessToken context
            , baseUrl = Context.getBaseUrl context
            , eventId = eventId
            , roomId = roomId
            }
    in
    input
        |> GetEvent.getEvent (Context.getVersions context)
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange = identity
                    , messages = [ GetEvent input output ]
                    }
            )


{-| Get the supported spec versions from the homeserver.
-}
getVersions : TaskChain CredUpdate { a | baseUrl : () } (VB a)
getVersions context =
    let
        input =
            Context.getBaseUrl context
    in
    Versions.getVersions input
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange = Context.setVersions output.versions
                    , messages = [ UpdateVersions output ]
                    }
            )


type alias InviteInput =
    { reason : Maybe String
    , roomId : String
    , userId : String
    }


{-| Invite a user to a room.
-}
invite : InviteInput -> IdemChain CredUpdate (VBA a)
invite { reason, roomId, userId } context =
    let
        input =
            { accessToken = Context.getAccessToken context
            , baseUrl = Context.getBaseUrl context
            , reason = reason
            , roomId = roomId
            , userId = userId
            }
    in
    input
        |> Invite.invite (Context.getVersions context)
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange = identity
                    , messages = [ InviteSent input output ]
                    }
            )


type alias JoinedMembersInput =
    { roomId : String }


joinedMembers : JoinedMembersInput -> IdemChain CredUpdate (VBA a)
joinedMembers { roomId } context =
    let
        input =
            { accessToken = Context.getAccessToken context
            , baseUrl = Context.getBaseUrl context
            , roomId = roomId
            }
    in
    input
        |> JoinedMembers.joinedMembers (Context.getVersions context)
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange = identity
                    , messages = [ JoinedMembersToRoom input output ]
                    }
            )


type alias LoginWithUsernameAndPasswordInput =
    { password : String
    , username : String
    }


loginWithUsernameAndPassword : LoginWithUsernameAndPasswordInput -> TaskChain CredUpdate (VB a) (VBA a)
loginWithUsernameAndPassword ({ username, password } as data) context =
    let
        input =
            { baseUrl = Context.getBaseUrl context
            , username = username
            , password = password
            }
    in
    input
        |> LoginWithUsernameAndPassword.loginWithUsernameAndPassword (Context.getVersions context)
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange =
                        Context.setAccessToken
                            { accessToken = output.accessToken
                            , usernameAndPassword = Just data
                            }
                    , messages = [ LoggedInWithUsernameAndPassword input output ]
                    }
            )


type alias RedactInput =
    { eventId : String
    , reason : Maybe String
    , roomId : String
    }


{-| Redact an event from a room.
-}
redact : RedactInput -> TaskChain CredUpdate (VBAT a) (VBA a)
redact { eventId, reason, roomId } context =
    let
        input =
            { accessToken = Context.getAccessToken context
            , baseUrl = Context.getBaseUrl context
            , eventId = eventId
            , reason = reason
            , roomId = roomId
            , txnId = Context.getTransactionId context
            }
    in
    input
        |> Redact.redact (Context.getVersions context)
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange = Context.removeTransactionId
                    , messages = [ RedactedEvent input output ]
                    }
            )


type alias SendMessageEventInput =
    { content : E.Value
    , eventType : String
    , roomId : String
    }


{-| Send a message event to a room.
-}
sendMessageEvent : SendMessageEventInput -> TaskChain CredUpdate (VBAT a) (VBA a)
sendMessageEvent { content, eventType, roomId } context =
    let
        input =
            { accessToken = Context.getAccessToken context
            , baseUrl = Context.getBaseUrl context
            , content = content
            , eventType = eventType
            , roomId = roomId
            , transactionId = Context.getTransactionId context
            }
    in
    input
        |> SendMessageEvent.sendMessageEvent (Context.getVersions context)
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange = Context.removeTransactionId
                    , messages = [ MessageEventSent input output ]
                    }
            )


type alias SendStateEventInput =
    { content : E.Value
    , eventType : String
    , roomId : String
    , stateKey : String
    }


{-| Send a state key event to a room.
-}
sendStateEvent : SendStateEventInput -> IdemChain CredUpdate (VBA a)
sendStateEvent { content, eventType, roomId, stateKey } context =
    let
        input =
            { accessToken = Context.getAccessToken context
            , baseUrl = Context.getBaseUrl context
            , content = content
            , eventType = eventType
            , roomId = roomId
            , stateKey = stateKey
            }
    in
    input
        |> SendStateKey.sendStateKey (Context.getVersions context)
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange = identity
                    , messages = [ StateEventSent input output ]
                    }
            )


type alias SyncInput =
    { filter : Maybe String
    , fullState : Maybe Bool
    , setPresence : Maybe Enums.UserPresence
    , since : Maybe String
    , timeout : Maybe Int
    }


{-| Sync the latest updates.
-}
sync : SyncInput -> IdemChain CredUpdate (VBA a)
sync data context =
    let
        input =
            { accessToken = Context.getAccessToken context
            , baseUrl = Context.getBaseUrl context
            , filter = data.filter
            , fullState = data.fullState
            , setPresence = data.setPresence
            , since = data.since
            , timeout = data.timeout
            }
    in
    input
        |> Sync.sync (Context.getVersions context)
        |> Task.map
            (\output ->
                Chain.TaskChainPiece
                    { contextChange = identity
                    , messages = [ SyncUpdate input output ]
                    }
            )


{-| Insert versions, or get them if they are not provided.
-}
versions : Maybe V.Versions -> TaskChain CredUpdate { a | baseUrl : () } (VB a)
versions mVersions =
    case mVersions of
        Just vs ->
            withVersions vs

        Nothing ->
            getVersions


{-| Create a task that insert the base URL into the context.
-}
withBaseUrl : String -> TaskChain CredUpdate a { a | baseUrl : () }
withBaseUrl baseUrl =
    { contextChange = Context.setBaseUrl baseUrl
    , messages = []
    }
        |> Chain.TaskChainPiece
        |> Task.succeed
        |> always


{-| Create a task that inserts a transaction id into the context.
-}
withTransactionId : (Int -> String) -> TaskChain CredUpdate a { a | transactionId : () }
withTransactionId toString =
    Time.now
        |> Task.map
            (\now ->
                { contextChange =
                    now
                        |> Time.posixToMillis
                        |> toString
                        |> Context.setTransactionId
                , messages = []
                }
                    |> Chain.TaskChainPiece
            )
        |> always


{-| Create a task that inserts versions into the context.
-}
withVersions : V.Versions -> TaskChain CredUpdate { a | baseUrl : () } (VB a)
withVersions vs =
    { contextChange = Context.setVersions vs.versions
    , messages = []
    }
        |> Chain.TaskChainPiece
        |> Task.succeed
        |> always
