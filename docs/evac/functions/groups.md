<!-- markdownlint-disable MD041 -->
### Functions » Groups

#### `Evac.groups.spawn(_side, _numberOrComposition, _country, _zone, _scatterRadius)`

Spawns evacuees manually. `_side` is the Group's `coalition.side`, `_numberOrComposition` follows the same rules as [`Evac.zones.evac.setRemaining()`](./zones.md#sample-composition), `_country` is the `country` for the Group, `_zone` is the Zone name to spawn the evacuees into, and `_scatterRadius` is the distance between spawned Units on the map.

#### `Evac.groups.list(_zone)`

Returns a list of all Groups in a Zone. `_zone` is the name of the Zone to search.

#### `Evac.groups.count(_zone)`

Returns a count of all Groups in a Zone. `_zone` is the name of the Zone to search.
