<!-- markdownlint-disable MD041 -->
### Events

#### `Gremlin.events.on(_eventId, _fn)`

Calls `_fn(_event)` when an event's ID (that is, its type) matches `_eventId`; returns an `_index` value that will let you _unregister_ the event handler using `Gremlin.events.off()` when you no longer need it.

This is an improved interface that avoids calling functions that don't handle certain event types anyway; said another way, it's more efficient than what DCS or MiST currently support with their event handler systems.

#### `Gremlin.events.off(_eventId, _index)`

Stops calling the `_eventId` handler whose `_index` is given; the only safe way to stop listening for events.

#### `Gremlin.events.fire(_event)`

Another improvement on the DCS event system, this lets you fire off your own events. In fact, the official Gremlin scripts use this to provide support for events in their own code.

> Note: you can only receive these custom-fired events if you register an event handler using `Gremlin.events.on()`!
