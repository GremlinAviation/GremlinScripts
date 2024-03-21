<!-- markdownlint-disable MD041 -->
### Functions » Zones

#### `Evac.zones.evac.register(_zone, _smoke, _side)`

Registers an evacuation zone with Gremlin Evac so that it can spawn and track evacuees there.

#### `Evac.zones.relay.register(_zone, _smoke, _side)`

Registers a relay/staging zone with Gremlin Evac so that it can track evacuees there.

#### `Evac.zones.safe.register(_zone, _smoke, _side)`

Registers a safe zone with Gremlin Evac so that it can track evacuees there.

For all three of the above, `_zone` is the name of the zone to register, `_smoke` is the smoke color from `trigger.smokeColor`, and `_side` is taken from `coalition.side`.

---

#### `Evac.zones.evac.activate(_zone)`

Turns on evacuation automations for a given zone.

#### `Evac.zones.relay.activate(_zone)`

Turns on relay/staging automations for a given zone.

#### `Evac.zones.safe.activate(_zone)`

Turns on safe zone automations for a given zone.

For all three of the above, `_zone` is the zone name to activate.

---

#### `Evac.zones.evac.setRemaining(_zone, _side, _country, _numberOrComposition)`

Sets the number of waiting evacuees in the zone.

#### `Evac.zones.relay.setRemaining(_zone, _side, _country, _numberOrComposition)`

Sets the number of waiting evacuees in the zone.

For both of the above, `_zone` is the zone name to activate, `_side` is taken from `coalition.side`, `_country` is taken from the `country` table, and `_numberOrComposition` is (as its name suggests) either a number of evacuees to generate (these will all be of type `"Generic"`), or a table listing off the composition of the units to spawn (as its name also suggests).

##### Sample Composition

```lua,editable
Evac.zones.evac.setRemaining('test', coalition.side.BLUE, country.USA, {
    { type = 'Ejected Pilot', unitName = 'Karl Marx', unitId = 42, weight = 75 },
    { type = 'Infantry' },
    { type = 'JTAC' },
    {},
})
```

This will add a generic evacuee named Karl Marx, with associated ID and weight values, an infantry unit, a JTAC unit, and a second generic evacuee whose name is automatically generated. Note how none of the parameters are required if you just want a generic evacuee, though a unit composed entirely of generics is simpler to build with a number instead of a composition table.

---

#### `Evac.zones.evac.count(_zone)`

Gets an evacuee count for a given evacuation zone.

#### `Evac.zones.relay.count(_zone)`

Gets an evacuee count for a given relay/staging zone.

#### `Evac.zones.safe.count(_zone)`

Gets an evacuee count for a given safe zone.

For all three of the above, `_zone` is the zone name to count evacuees within.

---

#### `Evac.zones.evac.isIn(_unit)`

Gets a value indicating whether an evacuee is in a given evacuation zone.

#### `Evac.zones.relay.isIn(_unit)`

Gets a value indicating whether an evacuee is in a given relay/staging zone.

#### `Evac.zones.safe.isIn(_unit)`

Gets a value indicating whether an evacuee is in a given safe zone.

For all three of the above, `_unit` is the unit name to search for.

---

#### `Evac.zones.evac.deactivate(_zone)`

Turns off evacuation automations for a given zone.

#### `Evac.zones.relay.deactivate(_zone)`

Turns off relay/staging automations for a given zone.

#### `Evac.zones.safe.deactivate(_zone)`

Turns off safe zone automations for a given zone.

For all three of the above, `_zone` is the zone name to deactivate.

---

#### `Evac.zones.evac.unregister(_zone)`

Removes an evacuation zone from Evac's control.

#### `Evac.zones.relay.unregister(_zone)`

Removes a relay/staging zone from Evac's control.

#### `Evac.zones.safe.unregister(_zone)`

Removes a safe zone from Evac's control.

For all three of the above, `_zone` is the zone name to remove.
