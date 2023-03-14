module Internal.Api.Versions.Main exposing (..)

import Internal.Api.Versions.Api as Api
import Internal.Api.Versions.V1.Versions as SO
import Internal.Tools.Context exposing (Context)
import Internal.Tools.Exceptions as X
import Task exposing (Task)


type alias VersionsInput =
    ()


type alias VersionsOutput =
    SO.Versions


getVersions : Context { a | baseUrl : () } -> Task X.Error VersionsOutput
getVersions context =
    Api.versionsV1 context
