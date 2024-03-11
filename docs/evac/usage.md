<!-- markdownlint-disable MD041 -->
## Usage

For many use cases, you simply configure Gremlin Evac, and the script does the rest. When you want more power, you can use the various available [functions](./functions.md) to control the map. Below are some simple examples that might help you in this endeavor.

### Basic Setup

```lua,editable
Evac:setup({
    startingZones = {
        { mode = Evac.modes.EVAC, name = "Blue Evac", smoke = trigger.smokeColor.Green, side = coalition.side.BLUE },
        { mode = Evac.modes.RELAY, name = "Blue Relay", smoke = trigger.smokeColor.Orange, side = coalition.side.BLUE, active = true },
        { mode = Evac.modes.SAFE, name = "Blue Safe", smoke = trigger.smokeColor.White, side = coalition.side.BLUE, active = true },
        { mode = Evac.modes.EVAC, name = "Red Evac", smoke = trigger.smokeColor.Green, side = coalition.side.RED },
        { mode = Evac.modes.RELAY, name = "Red Relay", smoke = trigger.smokeColor.Orange, side = coalition.side.RED, active = true },
        { mode = Evac.modes.SAFE, name = "Red Safe", smoke = trigger.smokeColor.White, side = coalition.side.RED, active = true },
    },
})
```

Initializes Gremlin Evac with 6 zones, 4 of which are active at start. Three are RedFor, the other three are BlueFor. Two each are evacuation zones, two each are relay/staging zones, and the last two each are safe zones. All other settings are kept at the defaults.

### Full Setup

This example is also available on [the Setup page](./setup.md).

```lua,editable
Evac:setup({
    beaconBatteryLife = 2,
    beaconSound = "test.ogg",
    carryLimits = {
        ["SH60B"] = 15,
    },
    idStart = 5,
    loadUnloadPerIndividual = 2,
    maxExtractable = {
        Refugees = 12,
        Infantry = 12,
        M249 = 12,
        RPG = 12,
        StingerIgla = 12,
        ["2B11"] = 12,
        JTAC = 3,
    },
    spawnWeight = 50,
    spawnRates = {
        ["Test 1"] = {
            nil,
            {
                units = 12,
                per = 5,
                period = Gremlin.Periods.Minute,
            },
        },
    },
    startingZones = {
        { mode = Evac.modes.EVAC, name = "Test 1", smoke = trigger.smokeColor.Green, side = coalition.side.BLUE, active = true },
        { mode = Evac.modes.RELAY, name = "Test 2", smoke = trigger.smokeColor.Orange, side = coalition.side.BLUE, active = true },
        { mode = Evac.modes.SAFE, name = "Test 3", smoke = trigger.smokeColor.White, side = coalition.side.BLUE },
    },
})
```

Initializes Gremlin Evac, overriding all the defaults:

- any beacons are killed after 2 minutes (default is 30)
- the beacon sound file is changed to something mission specific
- the list of craft that can perform evac ops is reset to just the `SH60B` Unit type at a max loadout of 15 evacuees
- the starting ID is dropped from 500 to 5
- the time to takes to load or unload evacuees is set to 2 seconds per evacuee (down from 30 seconds)
- the maximums for generated evacuees are set to 12 for all roles except JTAC, which is set to 3 (default is 0)
- the average spawn weight is dropped from 100kg to 50kg
- the spawn rates are configured to spawn 12 Blue refugees every 5 minutes in the `Test 1` Zone (default is spawn all across all Zones at mission start)
- the starting Zones are set to three Blue Zones, two of which (evacuation and relay/staging) are active from mission start (default is no registered Zones)

### Manual Setup

Sometimes the built-in logic isn't enough for your mission. This example pulls in several functions to integrate with other parts of the game.

```lua,editable
Evac:setup()

Evac.zones.evac.register('Blue Evac 1', trigger.smokeColor.Blue, coalition.side.BLUE)
Evac.zones.evac.register('Blue Evac 2', trigger.smokeColor.Blue, coalition.side.BLUE)
Evac.zones.relay.register('Blue Relay 1', trigger.smokeColor.Orange, coalition.side.BLUE)
Evac.zones.relay.register('Blue Relay 2', trigger.smokeColor.Orange, coalition.side.BLUE)
Evac.zones.safe.register('Blue Safe', trigger.smokeColor.Green, coalition.side.BLUE)

Evac.zones.evac.register('Red Evac 1', trigger.smokeColor.Red, coalition.side.RED)
Evac.zones.evac.register('Red Evac 2', trigger.smokeColor.Red, coalition.side.RED)
Evac.zones.relay.register('Red Relay 1', trigger.smokeColor.Orange, coalition.side.RED)
Evac.zones.relay.register('Red Relay 2', trigger.smokeColor.Orange, coalition.side.RED)
Evac.zones.safe.register('Red Safe', trigger.smokeColor.Green, coalition.side.RED)

Evac.zones.evac.activate('Blue Evac 1')
Evac.zones.evac.activate('Blue Evac 2')
Evac.zones.relay.activate('Blue Relay 1')
Evac.zones.relay.activate('Blue Relay 2')

Evac.zones.evac.activate('Red Evac 1')
Evac.zones.evac.activate('Red Evac 2')
Evac.zones.relay.activate('Red Relay 1')
Evac.zones.relay.activate('Red Relay 2')

Evac.zones.evac.setRemaining('Blue Evac 1', coalition.side.BLUE, country.USA, {
    { type = 'Infantry' },
    { type = 'Infantry' },
    { type = 'Infantry' },
    { type = 'Infantry' },
    { type = 'Infantry' },
    { type = 'RPG' },
    { type = '2B11' },
})
Evac.zones.evac.setRemaining('Blue Evac 2', coalition.side.BLUE, country.USA, {
    { type = 'Infantry' },
    { type = 'Infantry' },
    { type = 'Infantry' },
    { type = 'Infantry' },
    { type = 'Infantry' },
    { type = 'RPG' },
    { type = 'M249' },
    { type = 'StingerIgla' },
    { type = '2B11' },
    { type = 'JTAC' },
})

Evac.zones.evac.setRemaining('Red Evac 1', coalition.side.RED, country.RUSSIA, 4)
Evac.zones.evac.setRemaining('Red Evac 2', coalition.side.RED, country.RUSSIA, 3)

Evac.units.loadEvacuees('MEDEVAC_BLUE_1')
Evac.units.loadEvacuees('MEDEVAC_BLUE_2')

Evac.units.loadEvacuees('MEDEVAC_RED_1')
Evac.units.loadEvacuees('MEDEVAC_RED_2')
```

This setup does a few things, in order:

1. sets up Gremlin Evac using all the defaults
2. registers 5 zones for blue evacuations, and 5 for red
3. activates the evac and relay Zones
4. manually spawns 17 blue evacuees, using composition tables
5. manually spawns 7 red evacuees, using numbers (makes all evacuees into refugees)
6. manually loads up evacuees onto various standby Units

Everything from there is either automatic from the script, or manual via additional triggers in the mission.
