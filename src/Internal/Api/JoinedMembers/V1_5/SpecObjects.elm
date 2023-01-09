module Internal.Api.JoinedMembers.V1_5.SpecObjects exposing
    ( RoomMember
    , RoomMemberList
    , encodeRoomMember
    , encodeRoomMemberList
    , roomMemberDecoder
    , roomMemberListDecoder
    )

{-| Automatically generated 'SpecObjects'

Last generated at Unix time 1673279712

-}

import Dict exposing (Dict)
import Internal.Tools.DecodeExtra exposing (opField, opFieldWithDefault)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| User information of joined users.
-}
type alias RoomMember =
    { avatarUrl : Maybe String
    , displayName : Maybe String
    }


encodeRoomMember : RoomMember -> E.Value
encodeRoomMember data =
    maybeObject
        [ ( "avatar_url", Maybe.map E.string data.avatarUrl )
        , ( "display_name", Maybe.map E.string data.displayName )
        ]


roomMemberDecoder : D.Decoder RoomMember
roomMemberDecoder =
    D.map2
        (\a b ->
            { avatarUrl = a, displayName = b }
        )
        (opField "avatar_url" D.string)
        (opField "display_name" D.string)


{-| The dictionary containing all room member data.
-}
type alias RoomMemberList =
    { joined : Dict String RoomMember
    }


encodeRoomMemberList : RoomMemberList -> E.Value
encodeRoomMemberList data =
    maybeObject
        [ ( "joined", Just <| E.dict identity encodeRoomMember data.joined )
        ]


roomMemberListDecoder : D.Decoder RoomMemberList
roomMemberListDecoder =
    D.map
        (\a ->
            { joined = a }
        )
        (opFieldWithDefault "joined" Dict.empty (D.dict roomMemberDecoder))
