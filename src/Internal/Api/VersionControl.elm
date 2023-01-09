module Internal.Api.VersionControl exposing (..)

import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias FinalPackage vin vout =
    { supportedVersions : List String
    , getEvent : String -> vin -> Task X.Error vout
    }


type alias SingleVersion pIn pOut cIn cOut =
    { version : String
    , downcast : cIn -> pIn
    , current : cIn -> Task X.Error cOut
    , upcast : pOut -> cOut
    }


firstVersion : SingleVersion () () vin vout -> FinalPackage vin vout
firstVersion packet =
    { supportedVersions = [ packet.version ]
    , getEvent =
        \version ->
            if packet.version == version then
                packet.current

            else
                \_ -> Task.fail X.UnsupportedVersion
    }


updateWith : SingleVersion pIn pOut vin vout -> FinalPackage pIn pOut -> FinalPackage vin vout
updateWith packet oldFinal =
    { supportedVersions = packet.version :: oldFinal.supportedVersions
    , getEvent =
        \version ->
            if packet.version == version then
                packet.current

            else
                packet.downcast >> oldFinal.getEvent version >> Task.map packet.upcast
    }


toFunction : FinalPackage vin vout -> List String -> vin -> Task X.Error vout
toFunction final versions x =
    let
        bestVersion : Maybe String
        bestVersion =
            versions
                |> List.filter (\c -> List.member c final.supportedVersions)
                |> List.head
    in
    case bestVersion of
        Nothing ->
            Task.fail X.UnsupportedVersion

        Just version ->
            final.getEvent version x
