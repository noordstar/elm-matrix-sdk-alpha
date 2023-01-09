module Internal.Api.Versions.Main exposing (..)

import Internal.Api.Versions.Api as Api
import Internal.Api.Versions.Objects as O
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias VersionsInput =
    String


type alias VersionsOutput =
    Task X.Error O.Versions


getVersions : VersionsInput -> VersionsOutput
getVersions baseUrl =
    Api.versionsV1 { baseUrl = baseUrl }
