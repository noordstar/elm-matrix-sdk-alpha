module Internal.Values.Timeline exposing (..)
{-| The Timeline can be very complex, and it can be represented in surprisingly
complex manners. This module aims to provide one single Timeline type that
accepts the complex pieces of information from the API and contain it all in
a simple way to view events.
-}

import FastDict as Dict exposing (Dict)
import Internal.Tools.Iddict as Iddict exposing (Iddict)
import Internal.Tools.Filters.Main as Filter exposing (Filter)
import Internal.Tools.Iddict as Iddict

{-| A batch is a piece of the timeline that can be used to update the timeline.
-}
type Batch
    = BatchToken TokenValue (List TokenValue)
    | BatchSlice Batch Filter EventId (List EventId) TokenValue (List TokenValue)

{-| An event id is a raw value provided by the Matrix API. It points to an event
that is being stored elsewhere in the Matrix vault.
-}
type alias EventId = String

{-| A TokenValue is a raw value provided by the Matrix API. It is an opaque
value which indicates a point in the timeline and provides no other information.
-}
type alias TokenValue = String

{-| Central data type in the room.
-}
type alias Timeline =
    { mostRecentToken : TokenId
    , slices : Iddict Slice
    , tokenToId : Dict TokenValue TokenId
    , tokens : Iddict Token
    }

{-| Pointer to a specific token.
-}
type TokenId = TokenId Int

{-| Pointer to a specific slice on the timeline.
-}
type SliceId = SliceId Int

{-| Information of a specific slice on the timeline.
-}
type Slice
    = Slice
        { filter : Filter
        , head : EventId
        , next : List TokenId
        , previous : List TokenId
        , tail : List EventId
        }

{-| Information on a token, which is a point on the timeline. It might have
multiple TokenValue types point to it.
-}
type Token
    = Token
        { next : List SliceId
        , previous : List SliceId
        , head : TokenValue
        , tail : List TokenValue
        }

{-| Add a new batch to the timeline. Tokens that already existed, are ignored
but connected to the slices.

The function returns token ids to where the batch starts and ends, as well as
the renewed timeline.
-}
addBatch : Batch -> Timeline -> { start : TokenId, end : TokenId, timeline : Timeline }
addBatch batch timeline =
    case batch of
        BatchToken head tail ->
            case addToken (Token { next = [], previous = [], head = head, tail = tail }) timeline of
                ( tokenId, newTimeline ) ->
                    { start = tokenId, end = tokenId, timeline = newTimeline }
        
        BatchSlice b filter sHead sTail tHead tTail ->
            case addBatch b timeline of
                newBatch ->
                    let
                        slice : Slice
                        slice =
                            Slice
                                { filter = filter
                                , head = sHead
                                , next = []
                                , previous = []
                                , tail = sTail
                                }
                        
                        token : Token
                        token =
                            Token
                                { next = []
                                , previous = []
                                , head = tHead
                                , tail = tTail
                                }
                    in
                        case newBatch.timeline |> insertSlice slice |> Tuple.mapSecond (addToken token) of
                            ( sliceId, ( tokenId, newTimeline ) ) ->
                                { start = newBatch.start
                                , end = tokenId
                                , timeline =
                                    newTimeline
                                        |> connectToSlice newBatch.end sliceId
                                        |> connectToToken sliceId tokenId
                                }

{-| Add a new token to the timeline. If it already exists, this function does
nothing and instead returns the existing token id.
-}
addToken : Token -> Timeline -> ( TokenId, Timeline )
addToken ((Token { head, tail }) as token) timeline =
    case getTokenIdFromToken token timeline of
        Just tokenId ->
            ( tokenId
            , mapToken tokenId
                (\(Token tk) ->
                    case mergeUnique ( head, tail ) ( tk.head, tk.tail ) of
                        ( h, t ) ->
                            Token { tk | head = h, tail = t }
                )
                timeline
            )
        
        Nothing ->
            insertToken token timeline

{-| Sometimes two separate tokens point to the same location in the timeline.
You can add a new token value as an alias to the timeline using this function.
 -}
addTokenAlias : String -> String -> Timeline -> Timeline
addTokenAlias old new timeline =
    case Dict.get old timeline.tokenToId of
        Just tokenId ->
            timeline
                -- Update the token
                |> mapToken 
                    tokenId 
                    (\(Token t) ->
                        Token { t | head = new, tail = t.head :: t.tail }
                    )
                -- Add a token pointer for the new value
                |> (\tl -> { tl | tokenToId = Dict.insert new tokenId tl.tokenToId })
        
        Nothing ->
            timeline

{-| Connect a slice to a token to its right. The connection is established in
two directions.
-}
connectToToken : SliceId -> TokenId -> Timeline -> Timeline
connectToToken ((SliceId sliceId) as s) ((TokenId tokenId) as t) timeline =
    { timeline
    | slices =
        Iddict.map sliceId
            (\(Slice slice) ->
                if isConnectedToToken t slice.next then
                    Slice slice
                else
                    Slice { slice | next = t :: slice.next }
            )
            timeline.slices
    , tokens =
        Iddict.map tokenId
            (\(Token token) ->
                if isConnectedToSlice s token.previous then
                    Token token
                else
                    Token { token | previous = s :: token.previous }
            )
            timeline.tokens
    }

{-| Connect a token to a slice to its right. The connection is established in
two directions.
-}
connectToSlice : TokenId -> SliceId -> Timeline -> Timeline
connectToSlice ((TokenId tokenId) as t) ((SliceId sliceId) as s) timeline =
    { timeline
    | slices =
        Iddict.map sliceId
            (\(Slice slice) ->
                if isConnectedToToken t slice.previous then
                    Slice slice
                else
                    Slice { slice | previous = t :: slice.previous }
            )
            timeline.slices
    , tokens =
        Iddict.map tokenId
            (\(Token token) ->
                if isConnectedToSlice s token.next then
                    Token token
                else
                    Token { token | next = s :: token.next }
            )
            timeline.tokens
    }

{-| Get an empty timeline.
-}
empty : Timeline
empty =
    { mostRecentToken = TokenId 0
    , slices = Iddict.empty
    , tokenToId = Dict.empty
    , tokens = Iddict.empty
    }

{-| Get a slice of events from the timeline.
-}
getSlice : SliceId -> Timeline -> Maybe Slice
getSlice (SliceId key) { slices } =
    Iddict.get key slices

{-| Get a token based on its id.
-}
getTokenFromTokenId : TokenId -> Timeline -> Maybe Token
getTokenFromTokenId (TokenId tokenId) timeline =
    Iddict.get tokenId timeline.tokens

{-| Get a token based on its token value.
-}
getTokenFromTokenValue : TokenValue -> Timeline -> Maybe Token
getTokenFromTokenValue value timeline =
    timeline
        |> getTokenIdFromTokenValue value
        |> Maybe.andThen (\tid -> getTokenFromTokenId tid timeline)

{-| Get the token id based on a token value. The function returns Nothing if it
isn't on the timeline.
-}
getTokenIdFromTokenValue : TokenValue -> Timeline -> Maybe TokenId
getTokenIdFromTokenValue value timeline =
    Dict.get value timeline.tokenToId

{-| Get the token's id. The function returns Nothing if the token isn't on the
timeline.
-}
getTokenIdFromToken : Token -> Timeline -> Maybe TokenId
getTokenIdFromToken (Token { head, tail }) timeline =
    List.foldl
        (\value ptr ->
            case ptr of
                Nothing ->
                    getTokenIdFromTokenValue value timeline
                
                Just _ ->
                    ptr
        )
        Nothing (head :: tail)

{-| Insert a new slice into the timeline. This is a raw operation that should
never be exposed!
-}
insertSlice : Slice -> Timeline -> ( SliceId, Timeline )
insertSlice slice timeline =
    timeline.slices
        |> Iddict.insert slice
        |> Tuple.mapBoth SliceId (\x -> { timeline | slices = x })

{-| Insert a new token into the timeline. This is a raw operation that should
never be exposed!
-}
insertToken : Token -> Timeline -> ( TokenId, Timeline )
insertToken ((Token { head }) as token) timeline =
    case Iddict.insert token timeline.tokens of
        ( tokenId, tokens ) ->
            ( TokenId tokenId
            , { timeline
              | tokenToId = Dict.insert head (TokenId tokenId) timeline.tokenToId
              , tokens = tokens
              }
            )

{-| Whether a list contains a given slice id.
-}
isConnectedToSlice : SliceId -> List SliceId -> Bool
isConnectedToSlice (SliceId a) =
    List.any (\(SliceId b) -> a == b)

{-| Whether a list contains a given token id.
-}
isConnectedToToken : TokenId -> List TokenId -> Bool
isConnectedToToken (TokenId a) =
    List.any (\(TokenId b) -> a == b)

{-| Update an existing slice based on its id.
-}
mapSlice : SliceId -> (Slice -> Slice) -> Timeline -> Timeline
mapSlice (SliceId sliceId) f timeline =
    { timeline | slices = Iddict.map sliceId f timeline.slices }

{-| Update an existing token based on its id.
-}
mapToken : TokenId -> (Token -> Token) -> Timeline -> Timeline
mapToken (TokenId tokenId) f timeline =
    { timeline | tokens = Iddict.map tokenId f timeline.tokens }

{-| Merge two lists such that each element only appears once.
-}
mergeUnique : (a, List a) -> (a, List a) -> (a, List a)
mergeUnique (head, tail) (otherHead, otherTail) =
    otherTail
        |> List.filter (\e -> e /= otherHead)
        |> (::) otherHead
        |> List.filter (\e -> e /= head)
        |> List.filter (\e -> not <| List.member e tail )
        |> Tuple.pair head

{-| Turn a single slice into a batch.
-}
sliceToBatch : { start : String, filter : Filter, events : List EventId, end : String } -> Batch
sliceToBatch { start, filter, events, end } =
    case events of
        [] ->
            BatchToken end [ start ]
        
        head :: tail ->
            BatchSlice (BatchToken start []) filter head tail end []

{-| Turn a single token into a batch.
-}
tokenToBatch : String -> Batch
tokenToBatch value =
    BatchToken value []
