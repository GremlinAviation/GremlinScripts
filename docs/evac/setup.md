<!-- markdownlint-disable MD041 -->
## Setup

### Configuration

```lua,editable
Evac:setup({
    adminPilotNames = { 'Walter White' },
    beaconBatteryLife = 30,
    beaconSound = 'beacon.ogg',
    carryLimits = {
        ['C-130'] = 90,
        ['CH-43E'] = 55,
        ['CH-47D'] = 44,
        ['Hercules'] = 90,
        ['Mi-8MT'] = 24,
        ['Mi-24P'] = 5,
        ['Mi-24V'] = 5,
        ['Mi-26'] = 70,
        ['SH-60B'] = 5,
        ['SH60B'] = 5,
        ['UH-1H'] = 8,
        ['UH-60L'] = 11,
    },
    idStart = 50000,
    loadUnloadPerIndividual = 30,
    lossFlags = { 'GremlinEvacRedLoss', 'GremlinEvacBlueLoss' },
    lossThresholds = { 25, 25 },
    maxExtractable = {
        _global = {
            Generic = { 0, 0, [0] = 0 },
            Infantry = { 0, 0, [0] = 0 },
            M249 = { 0, 0, [0] = 0 },
            RPG = { 0, 0, [0] = 0 },
            StingerIgla = { 0, 0, [0] = 0 },
            ['2B11'] = { 0, 0, [0] = 0 },
            JTAC = { 0, 0, [0] = 0 },
        },
    },
    spawnRates = {
        _global = {
            {
                side = coalition.side.NEUTRAL,
                units = 0,
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            },
            {
                side = coalition.side.RED,
                units = 0,
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            },
            {
                side = coalition.side.BLUE,
                units = 0,
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            },
        },
    },
    spawnWeight = 100,
    startingUnits = { 'helicargo1', 'helicargo2', 'MedEvac1', 'MedEvac2', 'MedEvac3' },
    startingZones = {
        { mode = Evac.modes.EVAC,  name = "Test 1", smoke = trigger.smokeColor.Green,  side = coalition.side.BLUE, active = true },
        { mode = Evac.modes.RELAY, name = "Test 2", smoke = trigger.smokeColor.Orange, side = coalition.side.BLUE, active = true },
        { mode = Evac.modes.SAFE,  name = "Test 3", smoke = trigger.smokeColor.White,  side = coalition.side.BLUE },
    },
    winFlags = { 'GremlinEvacRedWin', 'GremlinEvacBlueWin' },
    winThresholds = { 75, 75 },
})
```

- `adminPilotNames`: Pilots to consider admins, with bonus menu items available.
  - Default: `{}`

- `beaconBatteryLife`: How long beacons should broadcast once spawned, in minutes
  - Default: `30`

- `beaconSound`: The audio file name to play for radio beacons
  - Default: `beacon.ogg`

- `carryLimits`: Specifies the maximum capacity loadout per aircraft designator
  - Default: `{ ["C-130"] = 90, ["CH-47D"] = 44, ["CH-43E"] = 55, ["Mi-8MT"] = 24, ["Mi-24P"] = 5, ["Mi-24V"] = 5, ["Mi-26"] = 70, ["SH60B"] = 5, ["UH-1H"] = 8, ["UH-60L"] = 11 }`

- `idStart`: The lowest ID number that Gremlin Evac will use to create units and groups
  - Default: `50000`

- `loadUnloadPerIndividual`: The amount of time it takes to load/unload a single evacuee onto/from an aircraft, in seconds
  - Default: `30`

- `lossFlags`: Flags to tell the Mission Editor that one side or the other (or both!) has lost
  - Default: `{ 'GremlinEvacRedLoss', 'GremlinEvacBlueLoss' }`

- `lossThresholds`: The maximum percentage of evacuees that can be lost from any side
  - Default: `{ 25, 25 }`

- `maxExtractable`: Provides a cap for automatically generated evacuees, by zone/type/side; the script won't create more than allowed here
  - Default: `0` for everything

- `spawnRates`: Describes how and when to spawn evacuee units/groups
  - Default: `{ _global = { units = 0, per = 0, period = Gremlin.Periods.Second } }` (everything at mission start)
  - Spec
    - key: Zone name
    - value: table
      - key: index
      - value: table
        - `side`: The side ID for spawning
        - `units`: Number or composition of units to spawn
        - `startTrigger`: Trigger to start spawning
        - `spawnTrigger`: Trigger to actually spawn units
        - `endTrigger`: Trigger to stop spawning
  - Notes:
    - Triggers:
      - `{ type = 'time', value = 900 }`: seconds since mission start
      - `{ type = 'time', value = { after = 15, period = Gremlin.Periods.Minute } }`: another way to say time since mission start
      - `{ type = 'repeat', value = { per = 5, period = Gremlin.Periods.Minute } }`: every `per` `period`s
      - `{ type = 'flag', value = 7 }`: flag goes truthy
      - `{ type = 'event', value = { id = 'Evac:Spawn', filter = function(event) return true end } }`: event triggered
      - `{ type = 'menu', value = 'Spawn Bonus Evacuees' }`: menu item selected
      - `{ type = 'limits', value = 50 }`: `value`% of allowed evacuees spawned

- `spawnWeight`: The average weight of an evacuee - the exact weight used will vary between 90% and 120% of this value
  - Default: `100`

- `startingUnits`: Registers units for evacuation purposes during setup
  - Default: `{}`

- `startingZones`: Registers zones for evacuation purposes during setup
  - Default: `{}`
  - Spec
    - key: ignored
    - value: table
      - `mode`: One of the `Evac.modes` constants, indicating what evacuation mode the zone should be registered using
      - `name`: Zone name - MUST MATCH THE MISSION EDITOR'S NAME FOR THE ZONE EXACTLY!
      - `smoke`: Smoke color, taken from `trigger.smokeColor`
      - `side`: Coalition, taken from `coalition.side`

- `winFlags`: Flags to tell the Mission Editor that one side or the other (or both!) has won
  - Default: `{ 'GremlinEvacRedWin', 'GremlinEvacBlueWin' }`

- `winThresholds`: The minimum percentage of evacuees that must be saved to win, per side
  - Default: `{ 75, 75 }`
