<!-- markdownlint-disable MD041 -->
## Events

- `Evac:BeaconDead`
  - `details` - the beacon details table used internally
  - Fired when a beacon dies and gets removed from the map

- `Evac:BeaconSpawn`
  - `details` - the beacon details table used internally
  - `zone` - The zone the beacon was spawned into
  - Fired when a beacon spawns and gets added to the map

- `Evac:Loss`
  - `side` - The numeric ID of the coalition that lost
  - Fired when any side loses too many evacuees

- `Evac:Spawned`
  - `units` - The number of evacuees spawned
  - `zone` - The zone in which evacuees were spawned
  - Fired when evacuees spawn into the map

- `Evac:UnitLoaded`
  - `number` - The number of evacuees loaded
  - `unit` - The unit that did the loading
  - `zone` - The zone the evacuees were picked up from
  - Fired when evacuees are finished loading onto an evacuation unit

- `Evac:UnitUnloaded`
  - `number` - The number of evacuees unloaded
  - `unit` - The unit that did the unloading
  - `zone` - The zone the evacuees were dropped off
  - Fired when evacuees are finished unloading from an evacuation unit

- `Evac:Win`
  - `side` - The numeric ID of the coalition that won
  - Fired when any side rescues enough evacuees

- `Evac:ZoneActive`
  - `mode` - The Evac.modes integer dictating how evacuees should be handled in the zone
  - `zone` - The affected zone
  - Fired when a zone goes active

- `Evac:ZoneAdd`
  - `mode` - The Evac.modes integer dictating how evacuees should be handled in the zone
  - `zone` - The affected zone
  - Fired when a zone is added to Evac

- `Evac:ZoneInactive`
  - `mode` - The Evac.modes integer dictating how evacuees should be handled in the zone
  - `zone` - The affected zone
  - Fired when a zone goes inactive

- `Evac:ZoneRemove`
  - `mode` - The Evac.modes integer dictating how evacuees should be handled in the zone
  - `zone` - The affected zone
  - Fired when a zone is removed from Evac
