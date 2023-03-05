module Internal.Api.PreApi.Objects.Login exposing
    ( DiscoveryInformation
    , HomeserverInformation
    , IdentityServerInformation
    , LoggedInResponse
    , discoveryInformationDecoder
    , encodeDiscoveryInformation
    , encodeHomeserverInformation
    , encodeIdentityServerInformation
    , encodeLoggedInResponse
    , homeserverInformationDecoder
    , identityServerInformationDecoder
    , loggedInResponseDecoder
    )

{-| Automatically generated 'Login'

Last generated at Unix time 1677859025

-}

import Internal.Tools.DecodeExtra exposing (opField)
import Internal.Tools.EncodeExtra exposing (maybeObject)
import Json.Decode as D
import Json.Encode as E


{-| Information that overwrites the credential's base url and more.
-}
type alias DiscoveryInformation =
    { mHomeserver : HomeserverInformation
    , mIdentityServer : Maybe IdentityServerInformation
    }


encodeDiscoveryInformation : DiscoveryInformation -> E.Value
encodeDiscoveryInformation data =
    maybeObject
        [ ( "m.homeserver", Just <| encodeHomeserverInformation data.mHomeserver )
        , ( "m.identity_server", Maybe.map encodeIdentityServerInformation data.mIdentityServer )
        ]


discoveryInformationDecoder : D.Decoder DiscoveryInformation
discoveryInformationDecoder =
    D.map2
        (\a b ->
            { mHomeserver = a, mIdentityServer = b }
        )
        (D.field "m.homeserver" homeserverInformationDecoder)
        (opField "m.identity_server" identityServerInformationDecoder)


{-| Used by clients to discover homeserver information.
-}
type alias HomeserverInformation =
    { baseUrl : String
    }


encodeHomeserverInformation : HomeserverInformation -> E.Value
encodeHomeserverInformation data =
    maybeObject
        [ ( "base_url", Just <| E.string data.baseUrl )
        ]


homeserverInformationDecoder : D.Decoder HomeserverInformation
homeserverInformationDecoder =
    D.map
        (\a ->
            { baseUrl = a }
        )
        (D.field "base_url" D.string)


{-| Used by clients to discover identity server information.
-}
type alias IdentityServerInformation =
    { baseUrl : String
    }


encodeIdentityServerInformation : IdentityServerInformation -> E.Value
encodeIdentityServerInformation data =
    maybeObject
        [ ( "base_url", Just <| E.string data.baseUrl )
        ]


identityServerInformationDecoder : D.Decoder IdentityServerInformation
identityServerInformationDecoder =
    D.map
        (\a ->
            { baseUrl = a }
        )
        (D.field "base_url" D.string)


{-| Confirmation that the user has successfully logged in.
-}
type alias LoggedInResponse =
    { accessToken : String
    , deviceId : String
    , expiresInMs : Maybe Int
    , refreshToken : Maybe String
    , userId : String
    , wellKnown : Maybe DiscoveryInformation
    }


encodeLoggedInResponse : LoggedInResponse -> E.Value
encodeLoggedInResponse data =
    maybeObject
        [ ( "access_token", Just <| E.string data.accessToken )
        , ( "device_id", Just <| E.string data.deviceId )
        , ( "expires_in_ms", Maybe.map E.int data.expiresInMs )
        , ( "refresh_token", Maybe.map E.string data.refreshToken )
        , ( "user_id", Just <| E.string data.userId )
        , ( "well_known", Maybe.map encodeDiscoveryInformation data.wellKnown )
        ]


loggedInResponseDecoder : D.Decoder LoggedInResponse
loggedInResponseDecoder =
    D.map6
        (\a b c d e f ->
            { accessToken = a, deviceId = b, expiresInMs = c, refreshToken = d, userId = e, wellKnown = f }
        )
        (D.field "access_token" D.string)
        (D.field "device_id" D.string)
        (opField "expires_in_ms" D.int)
        (opField "refresh_token" D.string)
        (D.field "user_id" D.string)
        (opField "well_known" discoveryInformationDecoder)
