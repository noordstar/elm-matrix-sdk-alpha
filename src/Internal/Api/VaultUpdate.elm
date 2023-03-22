module Internal.Api.VaultUpdate exposing (..)

import Internal.Api.Chain as Chain exposing (IdemChain, TaskChain)
import Internal.Api.Credentials as Credentials exposing (Credentials)
import Internal.Api.GetEvent.Main as GetEvent
import Internal.Api.GetMessages.Main as GetMessages
import Internal.Api.Invite.Main as Invite
import Internal.Api.JoinRoomById.Main as JoinRoomById
import Internal.Api.JoinedMembers.Main as JoinedMembers
import Internal.Api.Leave.Main as Leave
import Internal.Api.LoginWithUsernameAndPassword.Main as LoginWithUsernameAndPassword
import Internal.Api.Redact.Main as Redact
import Internal.Api.SendMessageEvent.Main as SendMessageEvent
import Internal.Api.SendStateKey.Main as SendStateKey
import Internal.Api.Sync.Main as Sync
import Internal.Api.Versions.Main as Versions
import Internal.Api.Versions.V1.Versions as V
import Internal.Tools.Context as Context exposing (VB, VBA, VBAT)
import Internal.Tools.Exceptions as X
import Internal.Tools.LoginValues exposing (AccessToken(..))
import Task exposing (Task)
import Time


type VaultUpdate
    = MultipleUpdates (List VaultUpdate)
      -- Updates as a result of API calls
    | GetEvent GetEvent.EventInput GetEvent.EventOutput
    | GetMessages GetMessages.GetMessagesInput GetMessages.GetMessagesOutput
    | InviteSent Invite.InviteInput Invite.InviteOutput
    | JoinedMembersToRoom JoinedMembers.JoinedMembersInput JoinedMembers.JoinedMembersOutput
    | JoinedRoom JoinRoomById.JoinRoomByIdInput JoinRoomById.JoinRoomByIdOutput
    | LeftRoom Leave.LeaveInput Leave.LeaveOutput
    | LoggedInWithUsernameAndPassword LoginWithUsernameAndPassword.LoginWithUsernameAndPasswordInput LoginWithUsernameAndPassword.LoginWithUsernameAndPasswordOutput
    | MessageEventSent SendMessageEvent.SendMessageEventInput SendMessageEvent.SendMessageEventOutput
    | RedactedEvent Redact.RedactInput Redact.RedactOutput
    | StateEventSent SendStateKey.SendStateKeyInput SendStateKey.SendStateKeyOutput
    | SyncUpdate Sync.SyncInput Sync.SyncOutput
      -- Updates as a result of getting data early
    | UpdateAccessToken String
    | UpdateVersions V.Versions


type alias FutureTask =
    Task X.Error VaultUpdate


{-| Turn an API Task into a taskchain.
-}
toChain : (cout -> Chain.TaskChainPiece VaultUpdate ph1 ph2) -> (Context.Context ph1 -> cin -> Task X.Error cout) -> cin -> TaskChain VaultUpdate ph1 ph2
toChain transform task input context =
    task context input
        |> Task.map transform


{-| Turn a chain of tasks into a full executable task.
-}
toTask : TaskChain VaultUpdate {} b -> FutureTask
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
accessToken : AccessToken -> TaskChain VaultUpdate (VB a) (VBA a)
accessToken ctoken =
    case ctoken of
        NoAccess ->
            X.NoAccessToken
                |> X.SDKException
                |> Task.fail
                |> always

        AccessToken t ->
            { contextChange = Context.setAccessToken { accessToken = t, loginParts = Nothing }
            , messages = []
            }
                |> Chain.TaskChainPiece
                |> Task.succeed
                |> always

        UsernameAndPassword { username, password, token, deviceId, initialDeviceDisplayName } ->
            case token of
                Just t ->
                    accessToken (AccessToken t)

                Nothing ->
                    loginWithUsernameAndPassword
                        { username = username
                        , password = password
                        , deviceId = deviceId
                        , initialDeviceDisplayName = initialDeviceDisplayName
                        }


{-| Get an event from the API.
-}
getEvent : GetEvent.EventInput -> IdemChain VaultUpdate (VBA { a | sentEvent : () })
getEvent input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = identity
                , messages = [ GetEvent input output ]
                }
        )
        GetEvent.getEvent
        input


{-| Get a list of messages from a room.
-}
getMessages : GetMessages.GetMessagesInput -> IdemChain VaultUpdate (VBA a)
getMessages input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = identity
                , messages = [ GetMessages input output ]
                }
        )
        GetMessages.getMessages
        input


{-| Get the supported spec versions from the homeserver.
-}
getVersions : TaskChain VaultUpdate { a | baseUrl : () } (VB a)
getVersions =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = Context.setVersions output.versions
                , messages = [ UpdateVersions output ]
                }
        )
        (\context _ -> Versions.getVersions context)
        ()


{-| Invite a user to a room.
-}
invite : Invite.InviteInput -> IdemChain VaultUpdate (VBA a)
invite input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = identity
                , messages = [ InviteSent input output ]
                }
        )
        Invite.invite
        input


joinedMembers : JoinedMembers.JoinedMembersInput -> IdemChain VaultUpdate (VBA a)
joinedMembers input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = identity
                , messages = [ JoinedMembersToRoom input output ]
                }
        )
        JoinedMembers.joinedMembers
        input


joinRoomById : JoinRoomById.JoinRoomByIdInput -> IdemChain VaultUpdate (VBA a)
joinRoomById input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = identity
                , messages = [ JoinedRoom input output ]
                }
        )
        JoinRoomById.joinRoomById
        input


leave : Leave.LeaveInput -> IdemChain VaultUpdate (VBA a)
leave input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = identity
                , messages = [ LeftRoom input output ]
                }
        )
        Leave.leave
        input


loginWithUsernameAndPassword : LoginWithUsernameAndPassword.LoginWithUsernameAndPasswordInput -> TaskChain VaultUpdate (VB a) (VBA a)
loginWithUsernameAndPassword input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange =
                    Context.setAccessToken
                        { accessToken = output.accessToken
                        , loginParts = Just input
                        }
                , messages = [ LoggedInWithUsernameAndPassword input output ]
                }
        )
        LoginWithUsernameAndPassword.loginWithUsernameAndPassword
        input


{-| Make a VB-context based chain.
-}
makeVB : Credentials -> TaskChain VaultUpdate {} (VB {})
makeVB cred =
    cred
        |> Credentials.baseUrl
        |> withBaseUrl
        |> Chain.andThen (versions (Credentials.versions cred))


{-| Make a VBA-context based chain.
-}
makeVBA : Credentials -> TaskChain VaultUpdate {} (VBA {})
makeVBA cred =
    cred
        |> makeVB
        |> Chain.andThen (accessToken (Credentials.accessToken cred))


{-| Make a VBAT-context based chain.
-}
makeVBAT : (Int -> String) -> Credentials -> TaskChain VaultUpdate {} (VBAT {})
makeVBAT toString cred =
    cred
        |> makeVBA
        |> Chain.andThen (withTransactionId toString)


{-| Redact an event from a room.
-}
redact : Redact.RedactInput -> TaskChain VaultUpdate (VBAT a) (VBA a)
redact input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = Context.removeTransactionId
                , messages = [ RedactedEvent input output ]
                }
        )
        Redact.redact
        input
        |> Chain.tryNTimes 5


{-| Send a message event to a room.
-}
sendMessageEvent : SendMessageEvent.SendMessageEventInput -> TaskChain VaultUpdate (VBAT a) (VBA { a | sentEvent : () })
sendMessageEvent input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = Context.removeTransactionId >> Context.setSentEvent output.eventId
                , messages = [ MessageEventSent input output ]
                }
        )
        SendMessageEvent.sendMessageEvent
        input
        |> Chain.tryNTimes 5


{-| Send a state key event to a room.
-}
sendStateEvent : SendStateKey.SendStateKeyInput -> TaskChain VaultUpdate (VBA a) (VBA { a | sentEvent : () })
sendStateEvent input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = Context.setSentEvent output.eventId
                , messages = [ StateEventSent input output ]
                }
        )
        SendStateKey.sendStateKey
        input
        |> Chain.tryNTimes 5


{-| Sync the latest updates.
-}
sync : Sync.SyncInput -> IdemChain VaultUpdate (VBA a)
sync input =
    toChain
        (\output ->
            Chain.TaskChainPiece
                { contextChange = identity
                , messages = [ SyncUpdate input output ]
                }
        )
        Sync.sync
        input


{-| Insert versions, or get them if they are not provided.
-}
versions : Maybe V.Versions -> TaskChain VaultUpdate { a | baseUrl : () } (VB a)
versions mVersions =
    (case mVersions of
        Just vs ->
            withVersions vs

        Nothing ->
            getVersions
    )
        |> Chain.tryNTimes 5


{-| Create a task that insert the base URL into the context.
-}
withBaseUrl : String -> TaskChain VaultUpdate a { a | baseUrl : () }
withBaseUrl baseUrl =
    { contextChange = Context.setBaseUrl baseUrl
    , messages = []
    }
        |> Chain.TaskChainPiece
        |> Task.succeed
        |> always


{-| Create a task that inserts an event id into the context, as if it were just sent.
-}
withSentEvent : String -> TaskChain VaultUpdate a { a | sentEvent : () }
withSentEvent sentEvent =
    { contextChange = Context.setSentEvent sentEvent
    , messages = []
    }
        |> Chain.TaskChainPiece
        |> Task.succeed
        |> always


{-| Create a task that inserts a transaction id into the context.
-}
withTransactionId : (Int -> String) -> TaskChain VaultUpdate a { a | transactionId : () }
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
withVersions : V.Versions -> TaskChain VaultUpdate { a | baseUrl : () } (VB a)
withVersions vs =
    { contextChange = Context.setVersions vs.versions
    , messages = []
    }
        |> Chain.TaskChainPiece
        |> Task.succeed
        |> always
