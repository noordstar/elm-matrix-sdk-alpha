# Filters need more specification

Given that all data in Elm is immutable, it is VERY important that we shape our 
data model the right way.

The Matrix spec doesn't seem sufficiently clear on how certain endpoints 
cooperate with the usage of filters, however, and this may raise some 
misrepresentation.

I have no familiarity with the 
[Server-Server API](https://spec.matrix.org/v1.6/server-server-api) and I'm 
basing my perspective of the timeline purely on the linear timeline as presented
in the [Client-Server API](https://spec.matrix.org/v1.6/client-server-api).
Section [7.6 Syncing](https://spec.matrix.org/v1.6/client-server-api/#syncing)
suggests that batch tokens can be seen as marked waypoints between two events,
and that the timeline can be seen as one with a 
[strict total ordering](https://en.wikipedia.org/wiki/Total_order#Strict_and_non-strict_total_orders).

# Filters and endpoints

Currently, three endpoints support filters:

- [`/sync`](https://spec.matrix.org/v1.6/client-server-api/#get_matrixclientv3sync)
- [`/messages`](https://spec.matrix.org/v1.6/client-server-api/#get_matrixclientv3roomsroomidmessages)
- [`/context`](https://spec.matrix.org/v1.6/client-server-api/#get_matrixclientv3roomsroomidcontexteventid)

## /sync

The `/sync` endpoint gets you the latest events in the timeline, as long as
they match the criteria of the filter. From my understanding, the endpoint is 
defined as follows:

![Representation of the /sync endpoint.](/development/issues/img/sync.png)

As you can see:

1. With no filter, the endpoint is clear.
2. With a filter, the endpoint is clear if the most recent event on the 
timeline meets the filter's criteria.
3. With a filter, the endpoint is **NOT** clear if the most recent event 
doesn't meet the filter's criteria.

There are points to be made that the `next_batch` token is set at the end of 
the timeline, but it can also make sense to return the `next_batch` token at 
the most recent event that matches the filter.

The spec doesn't seem to suggest either.

## /messages

The `/messages` endpoint is a little trickier, and some of the inputs aren't 
exactly clear. What should happen when the user inserts invalid input?

![Representation of all possible inputs for the /messages endpoint.](/development/issues/img/messages.png)

When asking people in the 
[Matrix spec channel](https://matrix.to/#/#matrix-spec:matrix.org):

1.  Some have argued that the endpoint should return no events, as the 
homeserver should stop iteration once it has _passed_ the `to` token.

2. Some have implied that the endpoint should iterate until it has reached any 
of the limits, as the batch tokens are opaque and homeservers shouldn't be 
expected to know the relative position of two tokens.

However, when using filters, **another** issue rises of where tokens should 
start and end:

![Representation of what the /messages endpoint returns given certain filters.](/development/issues/img/messages2.png)

As can be seen, the spec doesn't seem to verify where the `end` token should 
point to. For the **circles only** filter, there's an argument to be made to 
put the `end` batch token right after the last event: that way, we wouldn't 
skip the next **square** and **star** event in case we switch to a different 
filter.

## /context

If we jump to an event on the timeline, we are able to get the context of the 
event and see what events have been sent around the same time.

![Representation of what the /messages endpoint returns given certain filters.](/development/issues/img/context.png)

At first, the issues may seem similar to the ones presented in the `/messages` 
endpoint. However, the `/context` endpoint has the major disadvantage that it 
doesn't show the relative location of the endpoint on the timeline.

### An example

Suppose we joined a public room yesterday, then turned off our client during 
the night, and turned it back on today. During the night, some people sent so 
many events that the `/sync` endpoint has announced a gap to us this morning.

However, in one of the most recent events, one of the room members replies to 
some event in the past! Luckily, we can use `/context` to jump to that event - 
but where in the timeline is this event located? Was this event sent last 
night, or before we joined the room yesterday?

![Representation of what the /messages endpoint returns given certain filters.](/development/issues/img/context2.png)

Since batch tokens are opaque values, we as the client cannot use them to 
determine where the messages is located relative to the timeline that we're 
familiar to. Or can we?

This behaviour heavily depends on how `/messages` works on undefined values:

1. If the endpoint stops as soon as it's _passed_ the `to` token, then one can 
take two batch tokens _(e.g. `batch_token_1` and `batch_token_5`)_ and call the 
endpoint once in both directions. _(Backwards and forwards)_ One of two will 
return an empty list of events, which hints at the relative position of the two 
tokens.

2. If the endpoint only stops _at_ the `to` token, then the only way to 
determine the relative position of the event is to keep paginating `/messages` 
in either direction until you hit familiar events. _(Unrelated note: this can 
be improved by picking a filter as specific as possible that eventually hits 
one of our familiar events.)_

# To summarize

At first, I wrote an [issue for a spec clarification]() on this, but now it seems that it's necessary to write an MSC about it. I'd like to get feedback though, so here's an open letter to all interested people first!

The MSC would probably be a request to clarify filtering in the spec. It won't be just a clarification though, as it would mean setting so many specifics that it's likely at least one client will not have implemented them accordingly.

