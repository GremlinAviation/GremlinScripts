<!-- markdownlint-disable MD041 -->
### Functions » Units

#### `Evac.units.register(_unit)`

Registers a Unit, either by name or object, as capable of picking up evacuees. Note that the Unit _MUST_ be one of your supported craft in your `carryLimits` config, or loading and unloading will not be available.

#### `Evac.units.findEvacuees(_unit)`

Lists the currently-active beacons broadcasting for the Unit's side. `_unit` is the name of the Unit doing the search.

#### `Evac.units.loadEvacuees(_unit)`

Starts the evacuee loading process for a Unit. `_unit` is the name of the Unit to load evacuees onto.

#### `Evac.units.unloadEvacuees(_unit)`

Starts the evacuee unloading process for a Unit. `_unit` is the name of the Unit to unload evacuees from.

#### `Evac.units.countEvacuees(_unit)`

Count the number of evacuees aboard a given Unit. `_unit` is the name of the Unit to count evacuees aboard.

#### `Evac.units.count(_zone)`

Count the number of Units in a given Zone. `_zone` is the name of the Zone to check.

#### `Evac.units.unregister(_unit)`

Removes a Unit from Gremlin Evac's internal state, making it no longer eligible for evacuation ops.
