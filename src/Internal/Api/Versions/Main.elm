module Internal.Api.Versions.Main exposing (..)

import Internal.Api.Versions.Api as Api
import Internal.Api.Versions.V1.Versions as SO
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias VersionsInput =
    String


type alias VersionsOutput =
    SO.Versions


getVersions : VersionsInput -> Task X.Error VersionsOutput
getVersions baseUrl =
    Api.versionsV1 { baseUrl = baseUrl }
