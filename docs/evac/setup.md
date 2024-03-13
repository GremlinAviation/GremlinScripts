<!-- markdownlint-disable MD041 -->
## Setup

### Configuration

```lua,editable
Evac:setup({
    beaconBatteryLife = 2,
    beaconSound = "test.ogg",
    carryLimits = {
        ["SH60B"] = 15,
    },
    idStart = 5,
    loadUnloadPerIndividual = 2,
    lossFlags = { 'GremlinEvacRedLoss', 'GremlinEvacBlueLoss' }
    lossThresholds = { 25, 25 },
    maxExtractable = {
        Generic = 12,
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

- `beaconBatteryLife`: How long beacons should broadcast once spawned, in minutes
  - Default: `30`

- `beaconSound`: The audio file name to play for radio beacons
  - Default: `beacon.ogg`

- `carryLimits`: Specifies the maximum capacity loadout per aircraft designator
  - Default: `{ ["C-130"] = 90, ["CH-47D"] = 44, ["CH-43E"] = 55, ["Mi-8MT"] = 24, ["Mi-24P"] = 5, ["Mi-24V"] = 5, ["Mi-26"] = 70, ["SH-60B"] = 5, ["UH-1H"] = 8, ["UH-60A"] = 11 }`

- `idStart`: The lowest ID number that Gremlin Evac will use to create units and groups
  - Default: `500`

- `loadUnloadPerIndividual`: The amount of time it takes to load/unload a single evacuee onto/from an aircraft, in seconds
  - Default: `30`

- `lossFlags`: Flags to tell the Mission Editor that one side or the other (or both!) has lost
  - Default: `{ 'GremlinEvacRedLoss', 'GremlinEvacBlueLoss' }`

- `lossThresholds`: The maximum percentage of evacuees that can be lost from any side
  - Default: `{ 25, 25 }`

- `maxExtractable`: Provides a cap for automatically generated evacuees, by type; the script won't create more than allowed here
  - Default: `0` for everything

- `spawnWeight`: The average weight of an evacuee - the exact weight used will vary between 90% and 120% of this value
  - Default: `100`

- `spawnRates`: Describes how and when to spawn evacuee units/groups
  - Default: `{ _global = { units = 0, per = 0, period = Gremlin.Periods.Second } }` (everything at mission start)
  - Spec
    - key: Zone name
    - value: table
      - key: Side ID
      - value: table
        - `units`: Number or composition of units to spawn
        - `per`: Number of periods to wait between spawns
          - `0`: At setup time, no repeat
          - `< 0`: After `math.abs(per)` periods, no repeat
          - `> 0`: Every `per` periods, until `maxExtractable` is reached
        - `period`: One of the `Gremlin.Periods` constants indicating how long a single period lasts

- `startingZones`: Registers zones for evacuation purposes during setup
  - Default: `{}`
  - Spec
    - key: ignored
    - value: table
      - `mode`: One of the `Evac.modes` constants, indicating what evacuation mode the zone should be registered using
      - `name`: Zone name - MUST MATCH THE MISSION EDITOR'S NAME FOR THE ZONE EXACTLY!
      - `smoke`: Smoke color, taken from `trigger.smokeColor`
      - `side`: Coalition, taken from `coalition.side`
