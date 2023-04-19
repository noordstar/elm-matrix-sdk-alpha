module Internal.Api.VaultUpdate exposing (..)

import Internal.Api.Ban.Main as Ban
import Internal.Api.Chain as Chain exposing (IdemChain, TaskChain)
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
import Internal.Api.SetAccountData.Main as SetAccountData
import Internal.Api.Snackbar as Snackbar exposing (Snackbar)
import Internal.Api.Sync.Main as Sync
import Internal.Api.Versions.Main as Versions
import Internal.Api.Versions.V1.Versions as V
import Internal.Api.WhoAmI.Main as WhoAmI
import Internal.Tools.Context as Context exposing (VB, VBA, VBAT)
import Internal.Tools.Exceptions as X
import Internal.Tools.LoginValues exposing (AccessToken(..))
import Internal.Tools.Timestamp exposing (Timestamp)
import Task exposing (Task)
import Time


type alias Vnackbar a =
    Snackbar a VaultUpdate


type VaultUpdate
    = MultipleUpdates (List VaultUpdate)
      -- When a task fails, it is usually reported here
    | TaskFailed String (Vnackbar () -> Task Never VaultUpdate)
      -- Updates as a result of API calls
    | AccountDataSet SetAccountData.SetAccountInput SetAccountData.SetAccountOutput
    | BanUser Ban.BanInput Ban.BanOutput
    | CurrentTimestamp Timestamp
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
      -- Updates as a result of getting context information
    | UpdateAccessToken String
    | UpdateVersions V.Versions
    | UpdateWhoAmI WhoAmI.WhoAmIOutput
    | RemoveFailedTask Int


type alias FutureTask =
    Task Never VaultUpdate


{-| Turn an API Task into a taskchain.
-}
toChain : (Context.Context ph1 -> cin -> Task err cout) -> cin -> (cout -> Chain.TaskChainPiece VaultUpdate ph1 ph2) -> TaskChain err VaultUpdate ph1 ph2
toChain task input transform context =
    task context input
        |> Task.map transform
        |> Task.mapError (\e -> { error = e, messages = [] })


{-| Turn a chain of tasks into a full executable task.
-}
toTask : String -> (Vnackbar () -> TaskChain X.Error VaultUpdate {} b) -> Vnackbar () -> Task Never VaultUpdate
toTask debugText f snackbar =
    f snackbar
        |> Chain.toTask
        |> Task.onError
            (\{ messages } ->
                TaskFailed debugText (toTask debugText f)
                    :: messages
                    |> Task.succeed
            )
        |> Task.map
            (\updates ->
                case updates of
                    [ item ] ->
                        item

                    _ ->
                        MultipleUpdates updates
            )


{-| Get a functional access token.
-}
accessToken : AccessToken -> TaskChain X.Error VaultUpdate (VB a) (VBA { a | userId : () })
accessToken ctoken =
    case ctoken of
        NoAccess ->
            Chain.fail (X.SDKException X.NoAccessToken)

        RawAccessToken t ->
            { contextChange = Context.setAccessToken { accessToken = t, loginParts = Nothing }
            , messages = []
            }
                |> Chain.succeed
                |> Chain.andThen getWhoAmI

        DetailedAccessToken data ->
            Chain.succeed
                { contextChange =
                    Context.setAccessToken { accessToken = data.accessToken, loginParts = Nothing }
                        >> Context.setUserId data.userId
                , messages = []
                }

        UsernameAndPassword { username, password, token, deviceId, initialDeviceDisplayName, userId } ->
            case token of
                Just t ->
                    { contextChange = Context.setAccessToken { accessToken = t, loginParts = Nothing }
                    , messages = []
                    }
                        |> Chain.succeed
                        |> Chain.andThen (whoAmI userId)

                Nothing ->
                    { username = username
                    , password = password
                    , deviceId = deviceId
                    , initialDeviceDisplayName = initialDeviceDisplayName
                    }
                        |> loginWithUsernameAndPassword
                        |> Chain.andThen
                            (case userId of
                                Just user ->
                                    getWhoAmI |> Chain.otherwise (withUserId user)

                                Nothing ->
                                    getWhoAmI
                            )


{-| Ban a user from a room.
-}
ban : Ban.BanInput -> IdemChain X.Error VaultUpdate (VBA a)
ban input =
    toChain
        Ban.ban
        input
        (\output ->
            { contextChange = identity
            , messages = [ BanUser input output ]
            }
        )


{-| Get an event from the API.
-}
getEvent : GetEvent.EventInput -> IdemChain X.Error VaultUpdate (VBA { a | sentEvent : () })
getEvent input =
    toChain
        GetEvent.getEvent
        input
        (\output ->
            { contextChange = identity
            , messages = [ GetEvent input output ]
            }
        )


{-| Get a list of messages from a room.
-}
getMessages : GetMessages.GetMessagesInput -> IdemChain X.Error VaultUpdate (VBA a)
getMessages input =
    toChain
        GetMessages.getMessages
        input
        (\output ->
            { contextChange = identity
            , messages = [ GetMessages input output ]
            }
        )


getTimestamp : TaskChain err VaultUpdate a { a | timestamp : () }
getTimestamp =
    toChain
        (always <| always Time.now)
        ()
        (\output ->
            { contextChange = Context.setTimestamp output
            , messages = [ CurrentTimestamp output ]
            }
        )


{-| Get the supported spec versions from the homeserver.
-}
getVersions : TaskChain X.Error VaultUpdate { a | baseUrl : () } (VB a)
getVersions =
    toChain
        (\context _ -> Versions.getVersions context)
        ()
        (\output ->
            { contextChange = Context.setVersions output.versions
            , messages = [ UpdateVersions output ]
            }
        )


{-| Get a whoami to gain someone's identity.
-}
getWhoAmI : TaskChain X.Error VaultUpdate (VBA a) (VBA { a | userId : () })
getWhoAmI =
    toChain
        WhoAmI.whoAmI
        ()
        (\output ->
            { contextChange = Context.setUserId output.userId
            , messages = [ UpdateWhoAmI output ]
            }
        )


{-| Invite a user to a room.
-}
invite : Invite.InviteInput -> IdemChain X.Error VaultUpdate (VBA a)
invite input =
    toChain
        Invite.invite
        input
        (\output ->
            { contextChange = identity
            , messages = [ InviteSent input output ]
            }
        )


joinedMembers : JoinedMembers.JoinedMembersInput -> IdemChain X.Error VaultUpdate (VBA a)
joinedMembers input =
    toChain
        JoinedMembers.joinedMembers
        input
        (\output ->
            { contextChange = identity
            , messages = [ JoinedMembersToRoom input output ]
            }
        )


joinRoomById : JoinRoomById.JoinRoomByIdInput -> IdemChain X.Error VaultUpdate (VBA a)
joinRoomById input =
    toChain
        JoinRoomById.joinRoomById
        input
        (\output ->
            { contextChange = identity
            , messages = [ JoinedRoom input output ]
            }
        )


leave : Leave.LeaveInput -> IdemChain X.Error VaultUpdate (VBA a)
leave input =
    toChain
        Leave.leave
        input
        (\output ->
            { contextChange = identity
            , messages = [ LeftRoom input output ]
            }
        )


loginWithUsernameAndPassword : LoginWithUsernameAndPassword.LoginWithUsernameAndPasswordInput -> TaskChain X.Error VaultUpdate (VB a) (VBA a)
loginWithUsernameAndPassword input =
    toChain
        LoginWithUsernameAndPassword.loginWithUsernameAndPassword
        input
        (\output ->
            { contextChange =
                Context.setAccessToken
                    { accessToken = output.accessToken
                    , loginParts = Just input
                    }
            , messages = [ LoggedInWithUsernameAndPassword input output ]
            }
        )


{-| Make a VB-context based chain.
-}
makeVB : Vnackbar a -> TaskChain X.Error VaultUpdate {} (VB {})
makeVB snackbar =
    snackbar
        |> Snackbar.baseUrl
        |> withBaseUrl
        |> Chain.andThen (versions (Snackbar.versions snackbar))
        |> Chain.onError (\e -> Chain.fail (X.ContextFailed <| X.FailedVersions e))


{-| Make a VBA-context based chain.
-}
makeVBA : Vnackbar a -> TaskChain X.Error VaultUpdate {} (VBA { userId : () })
makeVBA snackbar =
    snackbar
        |> makeVB
        |> Chain.andThen (accessToken (Snackbar.accessToken snackbar))
        |> Chain.onError
            (\e ->
                case e of
                    X.ContextFailed _ ->
                        Chain.fail e

                    _ ->
                        Chain.fail <| X.ContextFailed <| X.FailedAccessToken e
            )


{-| Make a VBAT-context based chain.
-}
makeVBAT : (Int -> String) -> Vnackbar a -> TaskChain X.Error VaultUpdate {} (VBAT { userId : () })
makeVBAT toString snackbar =
    snackbar
        |> makeVBA
        |> Chain.andThen (withTransactionId toString)


{-| Redact an event from a room.
-}
redact : Redact.RedactInput -> TaskChain X.Error VaultUpdate (VBAT a) (VBA a)
redact input =
    toChain
        Redact.redact
        input
        (\output ->
            { contextChange = Context.removeTransactionId
            , messages = [ RedactedEvent input output ]
            }
        )
        |> Chain.tryNTimes 5


{-| Send a message event to a room.
-}
sendMessageEvent : SendMessageEvent.SendMessageEventInput -> TaskChain X.Error VaultUpdate (VBAT { a | timestamp : () }) (VBA { a | sentEvent : (), timestamp : () })
sendMessageEvent input =
    toChain
        SendMessageEvent.sendMessageEvent
        input
        (\output ->
            { contextChange = Context.removeTransactionId >> Context.setSentEvent output.eventId
            , messages = [ MessageEventSent input output ]
            }
        )
        |> Chain.tryNTimes 5


{-| Send a state key event to a room.
-}
sendStateEvent : SendStateKey.SendStateKeyInput -> TaskChain X.Error VaultUpdate (VBA { a | timestamp : () }) (VBA { a | sentEvent : (), timestamp : () })
sendStateEvent input =
    toChain
        SendStateKey.sendStateKey
        input
        (\output ->
            { contextChange = Context.setSentEvent output.eventId
            , messages = [ StateEventSent input output ]
            }
        )
        |> Chain.tryNTimes 5


setAccountData : SetAccountData.SetAccountInput -> IdemChain X.Error VaultUpdate (VBA { a | userId : () })
setAccountData input =
    toChain
        SetAccountData.setAccountData
        input
        (\output ->
            { contextChange = identity
            , messages = [ AccountDataSet input output ]
            }
        )


{-| Sync the latest updates.
-}
sync : Sync.SyncInput -> IdemChain X.Error VaultUpdate (VBA a)
sync input =
    toChain
        Sync.sync
        input
        (\output ->
            { contextChange = identity
            , messages = [ SyncUpdate input output ]
            }
        )


{-| Insert versions, or get them if they are not provided.
-}
versions : Maybe V.Versions -> TaskChain X.Error VaultUpdate { a | baseUrl : () } (VB a)
versions mVersions =
    (case mVersions of
        Just vs ->
            withVersions vs

        Nothing ->
            getVersions
    )
        |> Chain.tryNTimes 5


{-| Create a task to get a user's identity, if it is unknown.
-}
whoAmI : Maybe String -> TaskChain X.Error VaultUpdate (VBA a) (VBA { a | userId : () })
whoAmI muserId =
    case muserId of
        Just userId ->
            withUserId userId

        Nothing ->
            getWhoAmI


{-| Create a task that insert the base URL into the context.
-}
withBaseUrl : String -> TaskChain err VaultUpdate a { a | baseUrl : () }
withBaseUrl baseUrl =
    { contextChange = Context.setBaseUrl baseUrl
    , messages = []
    }
        |> Task.succeed
        |> always


{-| Create a task that inserts an event id into the context, as if it were just sent.
-}
withSentEvent : String -> TaskChain err VaultUpdate a { a | sentEvent : () }
withSentEvent sentEvent =
    { contextChange = Context.setSentEvent sentEvent
    , messages = []
    }
        |> Task.succeed
        |> always


{-| Create a task that inserts a transaction id into the context.
-}
withTransactionId : (Int -> String) -> TaskChain err VaultUpdate a { a | transactionId : () }
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
            )
        |> always


withUserId : String -> TaskChain err VaultUpdate a { a | userId : () }
withUserId userId =
    { contextChange = Context.setUserId userId
    , messages = []
    }
        |> Task.succeed
        |> always


{-| Create a task that inserts versions into the context.
-}
withVersions : V.Versions -> TaskChain err VaultUpdate a { a | versions : () }
withVersions vs =
    { contextChange = Context.setVersions vs.versions
    , messages = []
    }
        |> Task.succeed
        |> always
