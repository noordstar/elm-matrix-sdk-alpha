module Internal.Tools.SpecEnums exposing (..)

import Json.Decode as D
import Json.Encode as E


{-| The kind of account - currently defined as regular users and guests.
-}
type AccountKind
    = Guest
    | User


{-| Encode the AccountKindtype into a JSON Value
-}
encodeAccountKind : AccountKind -> E.Value
encodeAccountKind =
    encodeEnum fromAccountKind


{-| Convert the AccountKind type into a string.
-}
fromAccountKind : AccountKind -> String
fromAccountKind enum =
    case enum of
        Guest ->
            "guest"

        User ->
            "user"


{-| Decodes the AccountKind type from a JSON String
-}
accountKindDecoder : D.Decoder AccountKind
accountKindDecoder =
    decodeEnum
        (\s ->
            case s of
                "guest" ->
                    D.succeed Guest

                "user" ->
                    D.succeed User

                _ ->
                    D.fail "Expected one of [guest, user]"
        )


{-| Algorithm used for storing backups.
-}
type BackupStorageAlgorithm
    = MegolmBackupV1Curve25519aesSHA2


{-| Encode the BackupStorageAlgorithmtype into a JSON Value
-}
encodeBackupStorageAlgorithm : BackupStorageAlgorithm -> E.Value
encodeBackupStorageAlgorithm =
    encodeEnum fromBackupStorageAlgorithm


{-| Convert the BackupStorageAlgorithm type into a string.
-}
fromBackupStorageAlgorithm : BackupStorageAlgorithm -> String
fromBackupStorageAlgorithm enum =
    case enum of
        MegolmBackupV1Curve25519aesSHA2 ->
            "m.megolm_backup.v1.curve25519-aes-sha2"


{-| Decodes the BackupStorageAlgorithm type from a JSON String
-}
backupStorageAlgorithmDecoder : D.Decoder BackupStorageAlgorithm
backupStorageAlgorithmDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.megolm_backup.v1.curve25519-aes-sha2" ->
                    D.succeed MegolmBackupV1Curve25519aesSHA2

                _ ->
                    D.fail "Expected one of [m.megolm_backup.v1.curve25519-aes-sha2]"
        )


{-| A type of condition that must be satisfied.
-}
type ConditionType
    = RoomMembershipCondition


{-| Encode the ConditionTypetype into a JSON Value
-}
encodeConditionType : ConditionType -> E.Value
encodeConditionType =
    encodeEnum fromConditionType


{-| Convert the ConditionType type into a string.
-}
fromConditionType : ConditionType -> String
fromConditionType enum =
    case enum of
        RoomMembershipCondition ->
            "m.room.membership"


{-| Decodes the ConditionType type from a JSON String
-}
conditionTypeDecoder : D.Decoder ConditionType
conditionTypeDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.room.membership" ->
                    D.succeed RoomMembershipCondition

                _ ->
                    D.fail "Expected one of [m.room.membership]"
        )


{-| The encryption algorithm an event is encrypted with.
-}
type EncryptionAlgorithm
    = OlmV1Curve25519aesSHA2
    | MegolmV1aesSHA2


{-| Encode the EncryptionAlgorithmtype into a JSON Value
-}
encodeEncryptionAlgorithm : EncryptionAlgorithm -> E.Value
encodeEncryptionAlgorithm =
    encodeEnum fromEncryptionAlgorithm


{-| Convert the EncryptionAlgorithm type into a string.
-}
fromEncryptionAlgorithm : EncryptionAlgorithm -> String
fromEncryptionAlgorithm enum =
    case enum of
        OlmV1Curve25519aesSHA2 ->
            "m.olm.v1.curve25519-aes-sha2"

        MegolmV1aesSHA2 ->
            "m.megolm.v1.aes-sha2"


{-| Decodes the EncryptionAlgorithm type from a JSON String
-}
encryptionAlgorithmDecoder : D.Decoder EncryptionAlgorithm
encryptionAlgorithmDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.olm.v1.curve25519-aes-sha2" ->
                    D.succeed OlmV1Curve25519aesSHA2

                "m.megolm.v1.aes-sha2" ->
                    D.succeed MegolmV1aesSHA2

                _ ->
                    D.fail "Expected one of [m.olm.v1.curve25519-aes-sha2, m.megolm.v1.aes-sha2]"
        )


{-| Whether an event should be formatted for a client or for federation purposes.
-}
type EventFormat
    = Client
    | Federation


{-| Encode the EventFormattype into a JSON Value
-}
encodeEventFormat : EventFormat -> E.Value
encodeEventFormat =
    encodeEnum fromEventFormat


{-| Convert the EventFormat type into a string.
-}
fromEventFormat : EventFormat -> String
fromEventFormat enum =
    case enum of
        Client ->
            "client"

        Federation ->
            "federation"


{-| Decodes the EventFormat type from a JSON String
-}
eventFormatDecoder : D.Decoder EventFormat
eventFormatDecoder =
    decodeEnum
        (\s ->
            case s of
                "client" ->
                    D.succeed Client

                "federation" ->
                    D.succeed Federation

                _ ->
                    D.fail "Expected one of [client, federation]"
        )


{-| How events are expected to be ordered.
-}
type EventOrder
    = Chronological
    | ReverseChronological


{-| Encode the EventOrdertype into a JSON Value
-}
encodeEventOrder : EventOrder -> E.Value
encodeEventOrder =
    encodeEnum fromEventOrder


{-| Convert the EventOrder type into a string.
-}
fromEventOrder : EventOrder -> String
fromEventOrder enum =
    case enum of
        Chronological ->
            "f"

        ReverseChronological ->
            "b"


{-| Decodes the EventOrder type from a JSON String
-}
eventOrderDecoder : D.Decoder EventOrder
eventOrderDecoder =
    decodeEnum
        (\s ->
            case s of
                "f" ->
                    D.succeed Chronological

                "b" ->
                    D.succeed ReverseChronological

                _ ->
                    D.fail "Expected one of [f, b]"
        )


{-| Key that defines a search request group.
-}
type GroupKey
    = RoomIDKey
    | SenderKey


{-| Encode the GroupKeytype into a JSON Value
-}
encodeGroupKey : GroupKey -> E.Value
encodeGroupKey =
    encodeEnum fromGroupKey


{-| Convert the GroupKey type into a string.
-}
fromGroupKey : GroupKey -> String
fromGroupKey enum =
    case enum of
        RoomIDKey ->
            "room_id"

        SenderKey ->
            "sender"


{-| Decodes the GroupKey type from a JSON String
-}
groupKeyDecoder : D.Decoder GroupKey
groupKeyDecoder =
    decodeEnum
        (\s ->
            case s of
                "room_id" ->
                    D.succeed RoomIDKey

                "sender" ->
                    D.succeed SenderKey

                _ ->
                    D.fail "Expected one of [room_id, sender]"
        )


{-| Whether guests are allowed to join.
-}
type GuestAccess
    = GuestsAreWelcome
    | GuestsAreForbidden


{-| Encode the GuestAccesstype into a JSON Value
-}
encodeGuestAccess : GuestAccess -> E.Value
encodeGuestAccess =
    encodeEnum fromGuestAccess


{-| Convert the GuestAccess type into a string.
-}
fromGuestAccess : GuestAccess -> String
fromGuestAccess enum =
    case enum of
        GuestsAreWelcome ->
            "can_join"

        GuestsAreForbidden ->
            "forbidden"


{-| Decodes the GuestAccess type from a JSON String
-}
guestAccessDecoder : D.Decoder GuestAccess
guestAccessDecoder =
    decodeEnum
        (\s ->
            case s of
                "can_join" ->
                    D.succeed GuestsAreWelcome

                "forbidden" ->
                    D.succeed GuestsAreForbidden

                _ ->
                    D.fail "Expected one of [can_join, forbidden]"
        )


{-| Error reason for a call hangup.
-}
type HangupReason
    = IceFailed
    | InviteTimeout


{-| Encode the HangupReasontype into a JSON Value
-}
encodeHangupReason : HangupReason -> E.Value
encodeHangupReason =
    encodeEnum fromHangupReason


{-| Convert the HangupReason type into a string.
-}
fromHangupReason : HangupReason -> String
fromHangupReason enum =
    case enum of
        IceFailed ->
            "ice_failed"

        InviteTimeout ->
            "invite_timeout"


{-| Decodes the HangupReason type from a JSON String
-}
hangupReasonDecoder : D.Decoder HangupReason
hangupReasonDecoder =
    decodeEnum
        (\s ->
            case s of
                "ice_failed" ->
                    D.succeed IceFailed

                "invite_timeout" ->
                    D.succeed InviteTimeout

                _ ->
                    D.fail "Expected one of [ice_failed, invite_timeout]"
        )


{-| The history visibility of a room.
-}
type HistoryVisibility
    = FromMomentOfInvite
    | FromMomentOfJoined
    | FullHistoryToMembers
    | FullHistoryToLiterallyEveryone


{-| Encode the HistoryVisibilitytype into a JSON Value
-}
encodeHistoryVisibility : HistoryVisibility -> E.Value
encodeHistoryVisibility =
    encodeEnum fromHistoryVisibility


{-| Convert the HistoryVisibility type into a string.
-}
fromHistoryVisibility : HistoryVisibility -> String
fromHistoryVisibility enum =
    case enum of
        FromMomentOfInvite ->
            "invited"

        FromMomentOfJoined ->
            "joined"

        FullHistoryToMembers ->
            "shared"

        FullHistoryToLiterallyEveryone ->
            "world_readable"


{-| Decodes the HistoryVisibility type from a JSON String
-}
historyVisibilityDecoder : D.Decoder HistoryVisibility
historyVisibilityDecoder =
    decodeEnum
        (\s ->
            case s of
                "invited" ->
                    D.succeed FromMomentOfInvite

                "joined" ->
                    D.succeed FromMomentOfJoined

                "shared" ->
                    D.succeed FullHistoryToMembers

                "world_readable" ->
                    D.succeed FullHistoryToLiterallyEveryone

                _ ->
                    D.fail "Expected one of [invited, joined, shared, world_readable]"
        )


{-| Flag to denote which thread roots are to be included.
-}
type IncludeThreads
    = IncludeAllThreads
    | IncludeParticipatedThreads


{-| Encode the IncludeThreadstype into a JSON Value
-}
encodeIncludeThreads : IncludeThreads -> E.Value
encodeIncludeThreads =
    encodeEnum fromIncludeThreads


{-| Convert the IncludeThreads type into a string.
-}
fromIncludeThreads : IncludeThreads -> String
fromIncludeThreads enum =
    case enum of
        IncludeAllThreads ->
            "all"

        IncludeParticipatedThreads ->
            "participated"


{-| Decodes the IncludeThreads type from a JSON String
-}
includeThreadsDecoder : D.Decoder IncludeThreads
includeThreadsDecoder =
    decodeEnum
        (\s ->
            case s of
                "all" ->
                    D.succeed IncludeAllThreads

                "participated" ->
                    D.succeed IncludeParticipatedThreads

                _ ->
                    D.fail "Expected one of [all, participated]"
        )


{-| The type of rules used for users wishing to join a room.
-}
type JoinRules
    = Public
    | Knock
    | Invite
    | Private
    | Restricted


{-| Encode the JoinRulestype into a JSON Value
-}
encodeJoinRules : JoinRules -> E.Value
encodeJoinRules =
    encodeEnum fromJoinRules


{-| Convert the JoinRules type into a string.
-}
fromJoinRules : JoinRules -> String
fromJoinRules enum =
    case enum of
        Public ->
            "public"

        Knock ->
            "knock"

        Invite ->
            "invite"

        Private ->
            "private"

        Restricted ->
            "restricted"


{-| Decodes the JoinRules type from a JSON String
-}
joinRulesDecoder : D.Decoder JoinRules
joinRulesDecoder =
    decodeEnum
        (\s ->
            case s of
                "public" ->
                    D.succeed Public

                "knock" ->
                    D.succeed Knock

                "invite" ->
                    D.succeed Invite

                "private" ->
                    D.succeed Private

                "restricted" ->
                    D.succeed Restricted

                _ ->
                    D.fail "Expected one of [public, knock, invite, private, restricted]"
        )


{-| Given type that a user may log in with.
-}
type LoginType
    = Password
    | SSO
    | Token


{-| Encode the LoginTypetype into a JSON Value
-}
encodeLoginType : LoginType -> E.Value
encodeLoginType =
    encodeEnum fromLoginType


{-| Convert the LoginType type into a string.
-}
fromLoginType : LoginType -> String
fromLoginType enum =
    case enum of
        Password ->
            "m.login.password"

        SSO ->
            "m.login.sso"

        Token ->
            "m.login.token"


{-| Decodes the LoginType type from a JSON String
-}
loginTypeDecoder : D.Decoder LoginType
loginTypeDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.login.password" ->
                    D.succeed Password

                "m.login.sso" ->
                    D.succeed SSO

                "m.login.token" ->
                    D.succeed Token

                _ ->
                    D.fail "Expected one of [m.login.password, m.login.sso, m.login.token]"
        )


{-| The membership state of a user in a room.
-}
type MembershipState
    = Invited
    | Joined
    | Knocked
    | Left
    | Banned


{-| Encode the MembershipStatetype into a JSON Value
-}
encodeMembershipState : MembershipState -> E.Value
encodeMembershipState =
    encodeEnum fromMembershipState


{-| Convert the MembershipState type into a string.
-}
fromMembershipState : MembershipState -> String
fromMembershipState enum =
    case enum of
        Invited ->
            "invite"

        Joined ->
            "join"

        Knocked ->
            "knock"

        Left ->
            "leave"

        Banned ->
            "ban"


{-| Decodes the MembershipState type from a JSON String
-}
membershipStateDecoder : D.Decoder MembershipState
membershipStateDecoder =
    decodeEnum
        (\s ->
            case s of
                "invite" ->
                    D.succeed Invited

                "join" ->
                    D.succeed Joined

                "knock" ->
                    D.succeed Knocked

                "leave" ->
                    D.succeed Left

                "ban" ->
                    D.succeed Banned

                _ ->
                    D.fail "Expected one of [invite, join, knock, leave, ban]"
        )


{-| The type of message sent in an `m.room.message` event.
-}
type MessageType
    = Text
    | Emote
    | Notice
    | Image
    | File
    | Audio
    | Location
    | Video
    | VerificationRequest
    | ServerNotice


{-| Encode the MessageTypetype into a JSON Value
-}
encodeMessageType : MessageType -> E.Value
encodeMessageType =
    encodeEnum fromMessageType


{-| Convert the MessageType type into a string.
-}
fromMessageType : MessageType -> String
fromMessageType enum =
    case enum of
        Text ->
            "m.text"

        Emote ->
            "m.emote"

        Notice ->
            "m.notice"

        Image ->
            "m.image"

        File ->
            "m.file"

        Audio ->
            "m.audio"

        Location ->
            "m.location"

        Video ->
            "m.video"

        VerificationRequest ->
            "m.key.verification.request"

        ServerNotice ->
            "m.server_notice"


{-| Decodes the MessageType type from a JSON String
-}
messageTypeDecoder : D.Decoder MessageType
messageTypeDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.text" ->
                    D.succeed Text

                "m.emote" ->
                    D.succeed Emote

                "m.notice" ->
                    D.succeed Notice

                "m.image" ->
                    D.succeed Image

                "m.file" ->
                    D.succeed File

                "m.audio" ->
                    D.succeed Audio

                "m.location" ->
                    D.succeed Location

                "m.video" ->
                    D.succeed Video

                "m.key.verification.request" ->
                    D.succeed VerificationRequest

                "m.server_notice" ->
                    D.succeed ServerNotice

                _ ->
                    D.fail "Expected one of [m.text, m.emote, m.notice, m.image, m.file, m.audio, m.location, m.video, m.key.verification.request, m.server_notice]"
        )


{-| The kind of push rule.
-}
type PushRuleKind
    = Override
    | Underride
    | Sender
    | Room
    | Content


{-| Encode the PushRuleKindtype into a JSON Value
-}
encodePushRuleKind : PushRuleKind -> E.Value
encodePushRuleKind =
    encodeEnum fromPushRuleKind


{-| Convert the PushRuleKind type into a string.
-}
fromPushRuleKind : PushRuleKind -> String
fromPushRuleKind enum =
    case enum of
        Override ->
            "override"

        Underride ->
            "underride"

        Sender ->
            "sender"

        Room ->
            "room"

        Content ->
            "content"


{-| Decodes the PushRuleKind type from a JSON String
-}
pushRuleKindDecoder : D.Decoder PushRuleKind
pushRuleKindDecoder =
    decodeEnum
        (\s ->
            case s of
                "override" ->
                    D.succeed Override

                "underride" ->
                    D.succeed Underride

                "sender" ->
                    D.succeed Sender

                "room" ->
                    D.succeed Room

                "content" ->
                    D.succeed Content

                _ ->
                    D.fail "Expected one of [override, underride, sender, room, content]"
        )


{-| The type of receipt indicating that a user has read one or more events in a room.
-}
type ReceiptType
    = Read
    | ReadPrivate
    | FullyRead


{-| Encode the ReceiptTypetype into a JSON Value
-}
encodeReceiptType : ReceiptType -> E.Value
encodeReceiptType =
    encodeEnum fromReceiptType


{-| Convert the ReceiptType type into a string.
-}
fromReceiptType : ReceiptType -> String
fromReceiptType enum =
    case enum of
        Read ->
            "m.read"

        ReadPrivate ->
            "m.read.private"

        FullyRead ->
            "m.fully_read"


{-| Decodes the ReceiptType type from a JSON String
-}
receiptTypeDecoder : D.Decoder ReceiptType
receiptTypeDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.read" ->
                    D.succeed Read

                "m.read.private" ->
                    D.succeed ReadPrivate

                "m.fully_read" ->
                    D.succeed FullyRead

                _ ->
                    D.fail "Expected one of [m.read, m.read.private, m.fully_read]"
        )


{-| Specified action whenever a key or a secret is requested.
-}
type RequestAction
    = Request
    | RequestCancellation


{-| Encode the RequestActiontype into a JSON Value
-}
encodeRequestAction : RequestAction -> E.Value
encodeRequestAction =
    encodeEnum fromRequestAction


{-| Convert the RequestAction type into a string.
-}
fromRequestAction : RequestAction -> String
fromRequestAction enum =
    case enum of
        Request ->
            "request"

        RequestCancellation ->
            "request_cancellation"


{-| Decodes the RequestAction type from a JSON String
-}
requestActionDecoder : D.Decoder RequestAction
requestActionDecoder =
    decodeEnum
        (\s ->
            case s of
                "request" ->
                    D.succeed Request

                "request_cancellation" ->
                    D.succeed RequestCancellation

                _ ->
                    D.fail "Expected one of [request, request_cancellation]"
        )


{-| Desired resizing method for images that do not fit.
-}
type ResizingMethod
    = Crop
    | Scale


{-| Encode the ResizingMethodtype into a JSON Value
-}
encodeResizingMethod : ResizingMethod -> E.Value
encodeResizingMethod =
    encodeEnum fromResizingMethod


{-| Convert the ResizingMethod type into a string.
-}
fromResizingMethod : ResizingMethod -> String
fromResizingMethod enum =
    case enum of
        Crop ->
            "crop"

        Scale ->
            "scale"


{-| Decodes the ResizingMethod type from a JSON String
-}
resizingMethodDecoder : D.Decoder ResizingMethod
resizingMethodDecoder =
    decodeEnum
        (\s ->
            case s of
                "crop" ->
                    D.succeed Crop

                "scale" ->
                    D.succeed Scale

                _ ->
                    D.fail "Expected one of [crop, scale]"
        )


{-| The type of condition that applies to a restricted room.
-}
type RestrictedCondition
    = ConditionRoomMembership


{-| Encode the RestrictedConditiontype into a JSON Value
-}
encodeRestrictedCondition : RestrictedCondition -> E.Value
encodeRestrictedCondition =
    encodeEnum fromRestrictedCondition


{-| Convert the RestrictedCondition type into a string.
-}
fromRestrictedCondition : RestrictedCondition -> String
fromRestrictedCondition enum =
    case enum of
        ConditionRoomMembership ->
            "m.room_membership"


{-| Decodes the RestrictedCondition type from a JSON String
-}
restrictedConditionDecoder : D.Decoder RestrictedCondition
restrictedConditionDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.room_membership" ->
                    D.succeed ConditionRoomMembership

                _ ->
                    D.fail "Expected one of [m.room_membership]"
        )


{-| Room presets that can be called upon room creation.
-}
type RoomPreset
    = PrivateChat
    | PublicChat
    | TrustedPrivateChat


{-| Encode the RoomPresettype into a JSON Value
-}
encodeRoomPreset : RoomPreset -> E.Value
encodeRoomPreset =
    encodeEnum fromRoomPreset


{-| Convert the RoomPreset type into a string.
-}
fromRoomPreset : RoomPreset -> String
fromRoomPreset enum =
    case enum of
        PrivateChat ->
            "private_chat"

        PublicChat ->
            "public_chat"

        TrustedPrivateChat ->
            "trusted_private_chat"


{-| Decodes the RoomPreset type from a JSON String
-}
roomPresetDecoder : D.Decoder RoomPreset
roomPresetDecoder =
    decodeEnum
        (\s ->
            case s of
                "private_chat" ->
                    D.succeed PrivateChat

                "public_chat" ->
                    D.succeed PublicChat

                "trusted_private_chat" ->
                    D.succeed TrustedPrivateChat

                _ ->
                    D.fail "Expected one of [private_chat, public_chat, trusted_private_chat]"
        )


{-| The stability of a given room version.
-}
type RoomVersionStability
    = Stable
    | Unstable


{-| Encode the RoomVersionStabilitytype into a JSON Value
-}
encodeRoomVersionStability : RoomVersionStability -> E.Value
encodeRoomVersionStability =
    encodeEnum fromRoomVersionStability


{-| Convert the RoomVersionStability type into a string.
-}
fromRoomVersionStability : RoomVersionStability -> String
fromRoomVersionStability enum =
    case enum of
        Stable ->
            "stable"

        Unstable ->
            "unstable"


{-| Decodes the RoomVersionStability type from a JSON String
-}
roomVersionStabilityDecoder : D.Decoder RoomVersionStability
roomVersionStabilityDecoder =
    decodeEnum
        (\s ->
            case s of
                "stable" ->
                    D.succeed Stable

                "unstable" ->
                    D.succeed Unstable

                _ ->
                    D.fail "Expected one of [stable, unstable]"
        )


{-| The visibility of a room to users who are not a member of the room.
-}
type RoomVisibility
    = RoomPrivate
    | RoomPublic


{-| Encode the RoomVisibilitytype into a JSON Value
-}
encodeRoomVisibility : RoomVisibility -> E.Value
encodeRoomVisibility =
    encodeEnum fromRoomVisibility


{-| Convert the RoomVisibility type into a string.
-}
fromRoomVisibility : RoomVisibility -> String
fromRoomVisibility enum =
    case enum of
        RoomPrivate ->
            "private"

        RoomPublic ->
            "public"


{-| Decodes the RoomVisibility type from a JSON String
-}
roomVisibilityDecoder : D.Decoder RoomVisibility
roomVisibilityDecoder =
    decodeEnum
        (\s ->
            case s of
                "private" ->
                    D.succeed RoomPrivate

                "public" ->
                    D.succeed RoomPublic

                _ ->
                    D.fail "Expected one of [private, public]"
        )


{-| The order in which to search for results.
-}
type SearchOrdering
    = Recent
    | Rank


{-| Encode the SearchOrderingtype into a JSON Value
-}
encodeSearchOrdering : SearchOrdering -> E.Value
encodeSearchOrdering =
    encodeEnum fromSearchOrdering


{-| Convert the SearchOrdering type into a string.
-}
fromSearchOrdering : SearchOrdering -> String
fromSearchOrdering enum =
    case enum of
        Recent ->
            "recent"

        Rank ->
            "rank"


{-| Decodes the SearchOrdering type from a JSON String
-}
searchOrderingDecoder : D.Decoder SearchOrdering
searchOrderingDecoder =
    decodeEnum
        (\s ->
            case s of
                "recent" ->
                    D.succeed Recent

                "rank" ->
                    D.succeed Rank

                _ ->
                    D.fail "Expected one of [recent, rank]"
        )


{-| A session description type.
-}
type SessionDescriptionType
    = Answer
    | Offer


{-| Encode the SessionDescriptionTypetype into a JSON Value
-}
encodeSessionDescriptionType : SessionDescriptionType -> E.Value
encodeSessionDescriptionType =
    encodeEnum fromSessionDescriptionType


{-| Convert the SessionDescriptionType type into a string.
-}
fromSessionDescriptionType : SessionDescriptionType -> String
fromSessionDescriptionType enum =
    case enum of
        Answer ->
            "answer"

        Offer ->
            "offer"


{-| Decodes the SessionDescriptionType type from a JSON String
-}
sessionDescriptionTypeDecoder : D.Decoder SessionDescriptionType
sessionDescriptionTypeDecoder =
    decodeEnum
        (\s ->
            case s of
                "answer" ->
                    D.succeed Answer

                "offer" ->
                    D.succeed Offer

                _ ->
                    D.fail "Expected one of [answer, offer]"
        )


{-| A 3rd party medium that a user could use for authentication.
-}
type ThirdPartyMedium
    = Email
    | Msisdn


{-| Encode the ThirdPartyMediumtype into a JSON Value
-}
encodeThirdPartyMedium : ThirdPartyMedium -> E.Value
encodeThirdPartyMedium =
    encodeEnum fromThirdPartyMedium


{-| Convert the ThirdPartyMedium type into a string.
-}
fromThirdPartyMedium : ThirdPartyMedium -> String
fromThirdPartyMedium enum =
    case enum of
        Email ->
            "email"

        Msisdn ->
            "msisdn"


{-| Decodes the ThirdPartyMedium type from a JSON String
-}
thirdPartyMediumDecoder : D.Decoder ThirdPartyMedium
thirdPartyMediumDecoder =
    decodeEnum
        (\s ->
            case s of
                "email" ->
                    D.succeed Email

                "msisdn" ->
                    D.succeed Msisdn

                _ ->
                    D.fail "Expected one of [email, msisdn]"
        )


{-| Reason why a key was not sent.
-}
type UnavailableKey
    = BlacklistedKey
    | UnverifiedKey
    | UnauthorisedKey
    | UnavailableKey
    | NoOlm


{-| Encode the UnavailableKeytype into a JSON Value
-}
encodeUnavailableKey : UnavailableKey -> E.Value
encodeUnavailableKey =
    encodeEnum fromUnavailableKey


{-| Convert the UnavailableKey type into a string.
-}
fromUnavailableKey : UnavailableKey -> String
fromUnavailableKey enum =
    case enum of
        BlacklistedKey ->
            "m.blacklisted"

        UnverifiedKey ->
            "m.unverified"

        UnauthorisedKey ->
            "m.unauthorised"

        UnavailableKey ->
            "m.unavailable"

        NoOlm ->
            "m.no_olm"


{-| Decodes the UnavailableKey type from a JSON String
-}
unavailableKeyDecoder : D.Decoder UnavailableKey
unavailableKeyDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.blacklisted" ->
                    D.succeed BlacklistedKey

                "m.unverified" ->
                    D.succeed UnverifiedKey

                "m.unauthorised" ->
                    D.succeed UnauthorisedKey

                "m.unavailable" ->
                    D.succeed UnavailableKey

                "m.no_olm" ->
                    D.succeed NoOlm

                _ ->
                    D.fail "Expected one of [m.blacklisted, m.unverified, m.unauthorised, m.unavailable, m.no_olm]"
        )


{-| The type of user presence.
-}
type UserPresence
    = Offline
    | Online
    | UserUnavailable


{-| Encode the UserPresencetype into a JSON Value
-}
encodeUserPresence : UserPresence -> E.Value
encodeUserPresence =
    encodeEnum fromUserPresence


{-| Convert the UserPresence type into a string.
-}
fromUserPresence : UserPresence -> String
fromUserPresence enum =
    case enum of
        Offline ->
            "offline"

        Online ->
            "online"

        UserUnavailable ->
            "unavailable"


{-| Decodes the UserPresence type from a JSON String
-}
userPresenceDecoder : D.Decoder UserPresence
userPresenceDecoder =
    decodeEnum
        (\s ->
            case s of
                "offline" ->
                    D.succeed Offline

                "online" ->
                    D.succeed Online

                "unavailable" ->
                    D.succeed UserUnavailable

                _ ->
                    D.fail "Expected one of [offline, online, unavailable]"
        )


{-| Verification method to use.
-}
type VerificationMethod
    = SASv1
    | ReciprocateV1


{-| Encode the VerificationMethodtype into a JSON Value
-}
encodeVerificationMethod : VerificationMethod -> E.Value
encodeVerificationMethod =
    encodeEnum fromVerificationMethod


{-| Convert the VerificationMethod type into a string.
-}
fromVerificationMethod : VerificationMethod -> String
fromVerificationMethod enum =
    case enum of
        SASv1 ->
            "m.sas.v1"

        ReciprocateV1 ->
            "m.reciprocate.v1"


{-| Decodes the VerificationMethod type from a JSON String
-}
verificationMethodDecoder : D.Decoder VerificationMethod
verificationMethodDecoder =
    decodeEnum
        (\s ->
            case s of
                "m.sas.v1" ->
                    D.succeed SASv1

                "m.reciprocate.v1" ->
                    D.succeed ReciprocateV1

                _ ->
                    D.fail "Expected one of [m.sas.v1, m.reciprocate.v1]"
        )


{-| Decode a JSON string and interpret it as an enum
-}
decodeEnum : (String -> D.Decoder a) -> D.Decoder a
decodeEnum f =
    D.andThen f D.string


{-| Encode an enum into a JSON value
-}
encodeEnum : (a -> String) -> a -> E.Value
encodeEnum toString =
    toString >> E.string
