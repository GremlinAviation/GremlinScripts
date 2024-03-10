# Gremlin Scripts

This is the Gremlin Scripts repo! Everything you need to succeed with DCS mission scripting can be found within.

## Installation

Simply copy the contents of the `src` directory to your `Missions` folder in `Saved Games`. If you like, you can also grab MiST from this project's `lib` folder, though it's usually best to grab the latest version [directly from GitHub](https://github.com/mrSkortch/MissionScriptingTools).

Once you have the files in place, add a trigger to load MiST (follow its documentation for the best ways to do this), a second to load Gremlin Script Tools, and then a third to load the exact script you wish to use, such as Gremlin Evac. Once all three are loaded, the final step is to fully set up the script(s) to do their thing - see the relevant Configuration section, below, for more on this.

And that's it! The scripts are installed and working from this point on.

## Components

### gremlin.lua

The Gremlin Script Tools file provides common features that all Gremlin Scripts use to do their thing. It must be loaded after MiST, and before any other Gremlin Scripts components.

### evac.lua

The Gremlin Evac script sets up your missions to include evacuation scenarios. Simply call `Evac:setup({})` to get sane defualts, or customize everything by filling out the available options you wish to override.

#### Configuration

```lua
Evac:setup({
    beaconBatteryLife = 2,
    beaconSound = "test.ogg",
    carryLimits = {
        ["Test"] = 15,
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
        test = {
            units = 12,
            per = 5,
            period = Gremlin.Periods.Minute,
        },
    },
    startingZones = {
        { mode = Evac.modes.EVAC, name = "Test 1", smoke = trigger.smokeColors.Green, side = coalition.side.BLUE },
        { mode = Evac.modes.RELAY, name = "Test 2", smoke = trigger.smokeColors.Orange, side = coalition.side.BLUE },
        { mode = Evac.modes.SAFE, name = "Test 3", smoke = trigger.smokeColors.White, side = coalition.side.BLUE },
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

- `maxExtractable`: Provides a cap for automatically generated evacuees, by type; the script won't create more than allowed here
  - Default: `0` for everything

- `spawnWeight`: The average weight of an evacuee - the exact weight used will vary between 90% and 120% of this value
  - Default: `100`

- `spawnRates`: Describes how and when to spawn evacuee units/groups
  - Default: `{ _global = { units = 0, per = 0, period = Gremlin.Periods.Second } }` (everything at mission start)
  - Spec
    - key: Zone name
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
      - `smoke`: Smoke color, taken from `trigger.smokeColors`
      - `side`: Coalition, taken from `coalition.side`

## Development and Testing

Gremlin Scripts are fully tested before release. You can run these tests yourself by simply running `runtests.bat` at the top level of this project. It will run _all_ defined tests, at the moment, but that's fine since only Gremlin Evac is available today.

Development follows standard project rules for Git - create a fork, make your changes on a new branch, submit a PR on GitHub, and we'll review and do our best to merge. If none of these words make any sense to you, let us know and we'll help you figure something out.
