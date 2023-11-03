module Internal.Tools.VaultResult exposing (..)

import Internal.Tools.Exceptions as X
import Task exposing (Task)


type Info b a
    = Info a
    | NoInfo
    | InfoFailed { status : LoadingError, retry : Task X.Error b }


type LoadingError
    = NeverRequested
