local lu = require('luaunit_3_4')
local inspect = require('inspect')
local Spy = require('lib.mock.Spy')

table.unpack = table.unpack or unpack
unpack = table.unpack

require('mocks.DCS')
require('mist_4_5_122')
require('gremlin')
require('evac')

mist.scheduleFunction = Spy(mist.scheduleFunction)
Gremlin.log.error = Spy(Gremlin.log.error)
Gremlin.log.warn = Spy(Gremlin.log.warn)
Gremlin.log.info = Spy(Gremlin.log.info)
Gremlin.log.debug = Spy(Gremlin.log.debug)
Gremlin.log.trace = Spy(Gremlin.log.trace)

Gremlin:setup()

local _testZone = 'TestZone'
local _testZoneData = {
    name = _testZone,
    point = { x=0, y=0, z=0 },
    properties = {},
    verticies = {
        { x=100, y=0, z=100 },
        { x=-100, y=0, z=100 },
        { x=-100, y=0, z=-100 },
        { x=100, y=0, z=-100 },
    },
    x = 0,
    y = 0,
    z = 0,
}

local _testUnit = { className_ = 'Unit', groupName = 'Extraction Group 1', type = 'UH-1H', unitName = 'TestUnit1', unitId = 1, point = { x = 0, y = 0, z = 0 } }
---@diagnostic disable-next-line: undefined-global
class(_testUnit, Unit)

local _testUnit2 = { className_ = 'Unit', groupName = 'Extraction Group 1', type = 'UH-1H', unitName = 'TestUnit2', unitId = 2, point = { x = 0, y = 0, z = 0 } }
---@diagnostic disable-next-line: undefined-global
class(_testUnit2, Unit)

local _testUnit3 = { className_ = 'Unit', groupName = 'Evacuee Group 2', type = 'Ejected Pilot', unitName = 'TestUnit3', unitId = 3, point = { x = 0, y = 0, z = 0 } }
---@diagnostic disable-next-line: undefined-global
class(_testUnit3, Unit)
local _testEvacuee = { name = 'TestUnit3', type = 'Ejected Pilot', side = 2, text = 'Evacuee: Ejected Pilot #1', unitId = 3, object = _testUnit3 }

local _testGroup = { className_ = 'Group', groupName = 'Extraction Group 1', groupId = 1, units = { _testUnit, _testUnit2 } }
---@diagnostic disable-next-line: undefined-global
class(_testGroup, Group)

local _testGroup2 = { className_ = 'Group', groupName = 'Evacuee Group 2', groupId = 2, units = { _testUnit3 } }
---@diagnostic disable-next-line: undefined-global
class(_testGroup2, Group)

local setUp = function()
    -- MiST DBs
    mist.DBs.groupsByName[_testGroup.groupName] = _testGroup
    mist.DBs.groupsByName[_testGroup2.groupName] = _testGroup2
    mist.DBs.MEgroupsByName = mist.DBs.groupsByName
    mist.DBs.unitsByName[_testUnit.unitName] = _testUnit
    mist.DBs.unitsByName[_testUnit2.unitName] = _testUnit2
    mist.DBs.unitsByName[_testUnit3.unitName] = _testUnit3
    mist.DBs.MEunitsByName = mist.DBs.unitsByName
    mist.DBs.units = {
        Blue = {
            USA = {
                helicopter = {
                    [_testUnit:getGroup():getID()] = {
                        units = { _testUnit, _testUnit2 }
                    }
                }
            }
        }
    }
    mist.DBs.zonesByName = {
        [_testZone] = _testZoneData
    }

    -- Evac Settings
    Evac.maxExtractable[2]['Ejected Pilot'] = 250
    Evac.spawnRates = { _global = {
        { units = 0, per = 0, period = Gremlin.Periods.Second },
        { units = 0, per = 0, period = Gremlin.Periods.Second },
    } }
    Evac.zones.evac.register(_testZone, trigger.smokeColor.Green, 2)
    Evac._state.extractableNow[_testZone] = { [_testUnit3.unitName] = _testEvacuee }
    Evac._state.extractionUnits[_testUnit2.unitName] = { [0] = _testUnit2 }
    table.insert(Evac._state.frequencies.vhf.free, 840000)
    table.insert(Evac._state.frequencies.uhf.free, 277500000)
    table.insert(Evac._state.frequencies.fm.free, 32150000)
end

local tearDown = function()
    Evac.beaconBatteryLife = 0
    Evac.beaconSound = ''
    Evac.carryLimits = {}
    Evac.idStart = 0
    Evac.loadUnloadPerIndividual = 0
    Evac.lossFlags = { 0, 0 }
    Evac.maxExtractable = {
        {
            ['Ejected Pilot'] = 0,
            Infantry = 0,
            M249 = 0,
            RPG = 0,
            StingerIgla = 0,
            ['2B11'] = 0,
            JTAC = 0,
        },
        {
            ['Ejected Pilot'] = 0,
            Infantry = 0,
            M249 = 0,
            RPG = 0,
            StingerIgla = 0,
            ['2B11'] = 0,
            JTAC = 0,
        },
    }
    Evac.spawnRates = {}
    Evac.spawnWeight = 0

    Evac._state.alreadyInitialized = false
    Gremlin.alreadyInitialized = false

    Evac._state.frequencies.vhf = { free = {}, used = {} }
    Evac._state.frequencies.uhf = { free = {}, used = {} }
    Evac._state.frequencies.fm = { free = {}, used = {} }

    Evac._state.beacons = {}
    Evac._state.extractionUnits[_testUnit.unitName] = nil
    Evac._state.extractableNow[_testZone] = {}
    Evac._state.zones.evac = {}
    Evac._state.zones.relay = {}
    Evac._state.zones.safe = {}
    Evac._state.spawns.alreadySpawned = {
        {
            ['Ejected Pilot'] = 0,
            Infantry = 0,
            ['2B11'] = 0,
            StingerIgla = 0,
            RPG = 0,
            M249 = 0,
            JTAC = 0,
        },
        {
            ['Ejected Pilot'] = 0,
            Infantry = 0,
            ['2B11'] = 0,
            StingerIgla = 0,
            RPG = 0,
            M249 = 0,
            JTAC = 0,
        },
    }
    Evac._state.spawns.lastChecked = {}

    mist.nextUnitId = 1
    mist.nextGroupId = 1

    mist.DBs.zonesByName = {}
    mist.DBs.units = {}
    mist.DBs.unitsByName[_testUnit.unitName] = nil
    mist.DBs.unitsByName[_testUnit2.unitName] = nil
    mist.DBs.unitsByName[_testUnit3.unitName] = nil
    mist.DBs.MEunitsByName = mist.DBs.unitsByName
    mist.DBs.groupsByName[_testGroup.groupName] = nil
    mist.DBs.MEgroupsByName = mist.DBs.groupsByName

    mist.scheduleFunction:reset()
    Gremlin.log.error:reset()
    Gremlin.log.warn:reset()
    Gremlin.log.info:reset()
    Gremlin.log.debug:reset()
    Gremlin.log.trace:reset()
    trigger.action.setUnitInternalCargo:reset()
    trigger.action.outText:reset()
    trigger.action.outTextForCoalition:reset()
    trigger.action.outTextForCountry:reset()
    trigger.action.outTextForGroup:reset()
    trigger.action.outTextForUnit:reset()
end

Test0ZonesEvac = {
    setUp = setUp,
    test0Register = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.evac, { [_testZone] = { active = false, mode = 1, name = _testZone, side = 2, smoke = 0 } })

        -- TEST
        lu.assertEquals(Evac.zones.evac.register('test2', trigger.smokeColor.Orange, 1), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.evac, {
            [_testZone] = { active = false, mode = 1, name = _testZone, side = 2, smoke = 0 },
            test2 = { active = false, mode = 1, name = 'test2', side = 1, smoke = 3 },
        })
    end,
    test1Activate = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.evac, { [_testZone] = { active = false, mode = 1, name = _testZone, side = 2, smoke = 0 } })

        -- TEST
        lu.assertEquals(Evac.zones.evac.activate(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.evac, { [_testZone] = { active = true, mode = 1, name = _testZone, side = 2, smoke = 0 } })
    end,
    test2SetRemainingNumber = function()
        -- INIT
        Evac.beaconBatteryLife = 30

        trigger.action.outTextForGroup:whenCalled({
            with = { _testUnit:getGroup():getID(), 'Evacuation Beacons:\nGroup #8 - Beacon #1 (840.00 kHz - 277.50 / 32.15 MHz)\n', 20 },
            thenReturn = nil,
        })

        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 840000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 277500000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 1, true, 32150000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.evac.setRemaining(_testZone, 2, 2, 1), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.extractableNow[_testZone], { ['Evacuee: Ejected Pilot #2'] = { unitName = 'Evacuee: Ejected Pilot #2', type = 'Ejected Pilot', unitId = 2, weight = 0 } })

        Evac.beaconBatteryLife = 0
    end,
    test3SetRemainingComposition = function()
        -- INIT
        Evac.beaconBatteryLife = 30

        trigger.action.outTextForGroup:whenCalled({
            with = { _testUnit:getGroup():getID(), 'Evacuation Beacons:\nGroup #8 - Beacon #1 (840.00 kHz - 277.50 / 32.15 MHz)\n', 20 },
            thenReturn = nil,
        })

        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 840000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 277500000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 1, true, 32150000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.evac.setRemaining(_testZone, 2, 2, { {} }), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.extractableNow[_testZone],
            { ['Evacuee: Ejected Pilot #2'] = { unitName = 'Evacuee: Ejected Pilot #2', type = 'Ejected Pilot', unitId = 2, weight = 0 } })
    end,
    test4Count = function()
        -- INIT
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.evac.count(_testZone), 1)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test5IsIn = function()
        -- INIT
        lu.assertEquals(Evac.zones.evac.activate(_testZone), nil)
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.evac.isIn(_testUnit.unitName), true)
        lu.assertEquals(Evac.zones.evac.isIn('Evacuee: Ejected Pilot #710'), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test6Deactivate = function()
        -- INIT
        lu.assertEquals(Evac.zones.evac.activate(_testZone), nil)
        lu.assertEquals(Evac._state.zones.evac, { [_testZone] = { active = true, mode = 1, name = _testZone, side = 2, smoke = 0 } })

        -- TEST
        lu.assertEquals(Evac.zones.evac.deactivate(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.evac, { [_testZone] = { active = false, mode = 1, name = _testZone, side = 2, smoke = 0 } })
    end,
    test7Unregister = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.evac, { [_testZone] = { active = false, mode = 1, name = _testZone, side = 2, smoke = 0 } })

        -- TEST
        lu.assertEquals(Evac.zones.evac.unregister(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.evac, {})
    end,
    tearDown = tearDown,
}

Test1ZonesRelay = {
    setUp = setUp,
    test0Register = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.relay, {})

        -- TEST
        lu.assertEquals(Evac.zones.relay.register(_testZone, trigger.smokeColor.Green, 2), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.relay, { [_testZone] = { active = false, mode = 3, name = _testZone, side = 2, smoke = 0 } })
    end,
    test1Activate = function()
        -- INIT
        lu.assertEquals(Evac.zones.relay.register(_testZone, trigger.smokeColor.Green, 2), nil)
        lu.assertEquals(Evac._state.zones.relay, { [_testZone] = { active = false, mode = 3, name = _testZone, side = 2, smoke = 0 } })

        -- TEST
        lu.assertEquals(Evac.zones.relay.activate(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.relay, { [_testZone] = { active = true, mode = 3, name = _testZone, side = 2, smoke = 0 } })
    end,
    test2SetRemainingNumber = function()
        -- INIT
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.relay.setRemaining(_testZone, 2, 2, 1), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.extractableNow[_testZone],
            { ['Evacuee: Ejected Pilot #2'] = { unitName = 'Evacuee: Ejected Pilot #2', type = 'Ejected Pilot', unitId = 2, weight = 0 } })
    end,
    test3SetRemainingComposition = function()
        -- INIT
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.relay.setRemaining(_testZone, 2, 2, { {} }), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.extractableNow[_testZone],
            { ['Evacuee: Ejected Pilot #2'] = { unitName = 'Evacuee: Ejected Pilot #2', type = 'Ejected Pilot', unitId = 2, weight = 0 } })
    end,
    test4Count = function()
        -- INIT
        Evac._state.zones.relay[_testZone] = _testZoneData
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.relay.count(_testZone), 1)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test5IsIn = function()
        -- INIT
        Evac._state.zones.relay[_testZone] = _testZoneData
        lu.assertEquals(Evac.zones.relay.register(_testZone, trigger.smokeColor.Green, 2), nil)
        lu.assertEquals(Evac.zones.relay.activate(_testZone), nil)
        -- lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.relay.isIn(_testUnit.unitName), true)
        lu.assertEquals(Evac.zones.relay.isIn('Evacuee: Ejected Pilot #710'), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test6Deactivate = function()
        -- INIT
        Evac._state.zones.relay[_testZone] = _testZoneData
        lu.assertEquals(Evac.zones.relay.activate(_testZone), nil)
        lu.assertEquals(Evac._state.zones.relay, { [_testZone] = Gremlin.utils.mergeTables(_testZoneData, { active = true }) })

        -- TEST
        lu.assertEquals(Evac.zones.relay.deactivate(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.relay, { [_testZone] = _testZoneData })
    end,
    test7Unregister = function()
        -- INIT
        Evac._state.zones.relay[_testZone] = _testZoneData
        lu.assertEquals(Evac._state.zones.relay, { [_testZone] = _testZoneData })

        -- TEST
        lu.assertEquals(Evac.zones.relay.unregister(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.relay, {})
    end,
    tearDown = tearDown,
}

Test2ZonesSafe = {
    setUp = setUp,
    test0Register = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.safe, {})

        -- TEST
        lu.assertEquals(Evac.zones.safe.register(_testZone, trigger.smokeColor.Green, 2), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.safe, { [_testZone] = { active = false, mode = 2, name = _testZone, side = 2, smoke = 0 } })
    end,
    test1Activate = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.safe, {})
        lu.assertEquals(Evac.zones.safe.register(_testZone, trigger.smokeColor.Green, 2), nil)
        lu.assertEquals(Evac._state.zones.safe, { [_testZone] = { active = false, mode = 2, name = _testZone, side = 2, smoke = 0 } })

        -- TEST
        lu.assertEquals(Evac.zones.safe.activate(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.safe, { [_testZone] = { active = true, mode = 2, name = _testZone, side = 2, smoke = 0 } })
    end,
    test2Count = function()
        -- INIT
        Evac._state.zones.safe[_testZone] = _testZoneData
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.safe.count(_testZone), 1)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test3IsIn = function()
        -- INIT
        lu.assertEquals(Evac.zones.safe.register(_testZone, trigger.smokeColor.Green, 2), nil)
        lu.assertEquals(Evac.zones.safe.activate(_testZone), nil)
        lu.assertEquals(Evac._state.extractableNow[_testZone], {})
        Evac._state.extractableNow[_testZone] = { [_testUnit3.unitName] = _testEvacuee }
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.zones.safe.isIn(_testUnit.unitName), true)
        lu.assertEquals(Evac.zones.safe.isIn('Evacuee: Ejected Pilot #710'), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test4Deactivate = function()
        -- INIT
        lu.assertEquals(Evac.zones.safe.register(_testZone, trigger.smokeColor.Green, 2), nil)
        lu.assertEquals(Evac.zones.safe.activate(_testZone), nil)
        lu.assertEquals(Evac._state.zones.safe, { [_testZone] = { active = true, mode = 2, name = _testZone, side = 2, smoke = 0 } })

        -- TEST
        lu.assertEquals(Evac.zones.safe.deactivate(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.safe, { [_testZone] = { active = false, mode = 2, name = _testZone, side = 2, smoke = 0 } })
    end,
    test5Unregister = function()
        -- INIT
        Evac._state.zones.safe[_testZone] = _testZoneData
        lu.assertEquals(Evac._state.zones.safe, { [_testZone] = _testZoneData })

        -- TEST
        lu.assertEquals(Evac.zones.safe.unregister(_testZone), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.safe, {})
    end,
    tearDown = tearDown,
}

Test3Units = {
    setUp = setUp,
    test0Register = function()
        -- INIT
        Evac._state.extractionUnits = {}
        lu.assertEquals(Evac._state.extractionUnits[_testUnit2.unitName], nil)

        -- TEST
        lu.assertEquals(Evac.units.register(_testUnit2), nil)

        -- SIDE EFFECTS
        lu.assertNotEquals(Evac._state.extractionUnits[_testUnit2.unitName], nil)
    end,
    test1FindEvacuees = function()
        -- INIT
        local _args = { _testUnit:getGroup():getID(), 'No Active Evacuation Beacons', 15 }
        trigger.action.outTextForGroup:whenCalled({ with = _args, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac.units.findEvacuees(_testUnit.unitName), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.outTextForGroup.assertAnyCallMatches,
            trigger.action.outTextForGroup,
            { arguments = _args }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.outTextForGroup.spy.calls)))
    end,
    test2LoadEvacuees = function()
        -- INIT
        local _args = {_testUnit:getID(), "Your aircraft isn't rated for evacuees in this mission!", timer.getTime() + 1 }
        trigger.action.outTextForUnit:whenCalled({ with = _args, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac.units.loadEvacuees(_testUnit.unitName), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.outTextForUnit.assertAnyCallMatches,
            trigger.action.outTextForUnit,
            _args
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.outTextForUnit.spy.calls)))
    end,
    test3UnloadEvacuees = function()
        -- INIT
        local _args = {_testUnit:getID(), 'Not in an active relay or safe zone! Try looking elsewhere.', 5 }
        trigger.action.outTextForUnit:whenCalled({ with = _args, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac.units.unloadEvacuees(_testUnit.unitName), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.outTextForUnit.assertAnyCallMatches,
            trigger.action.outTextForUnit,
            _args
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.outTextForUnit.spy.calls)))
    end,
    test4CountEvacuees = function()
        -- INIT
        local _args = {_testUnit:getID(), 'You are currently carrying 0 evacuees.', timer.getTime() + 1 }
        trigger.action.outTextForUnit:whenCalled({ with = _args, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac.units.countEvacuees(_testUnit.unitName), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.outTextForUnit.assertAnyCallMatches,
            trigger.action.outTextForUnit,
            { arguments = _args }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.outTextForUnit.spy.calls)))
    end,
    test5Count = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac.units.count(_testZone), 2)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test6Unregister = function()
        -- INIT
        lu.assertEquals(Evac.units.register(_testUnit2), nil)
        lu.assertNotEquals(Evac._state.extractionUnits[_testUnit2.unitName], nil)

        -- TEST
        lu.assertEquals(Evac.units.unregister(_testUnit2), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.extractionUnits[_testUnit2.unitName], nil)
    end,
    tearDown = tearDown,
}

Test4Groups = {
    setUp = setUp,
    test0SpawnNumber = function()
        -- INIT
        Evac.beaconBatteryLife = 30

        trigger.action.outTextForGroup:whenCalled({
            with = { _testUnit:getGroup():getID(), 'Evacuation Beacons:\nGroup #8 - Beacon #1 (840.00 kHz - 277.50 / 32.15 MHz)\n', 20 },
            thenReturn = nil,
        })

        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 840000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 277500000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 1, true, 32150000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        -- TEST
        lu.assertAlmostEquals(Evac.groups.spawn(coalition.side.BLUE, 2, country.USA, _testZone, 5), {
            visible = false,
            hidden = true,
            units = {
                {
                    heading = 0,
                    name = 'Evacuee: Ejected Pilot #2',
                    playerCanDrive = false,
                    skill = 'Excellent',
                    type = 'Ejected Pilot',
                    unitId = 2,
                    x = -28,
                    y = 1
                },
                {
                    heading = 0,
                    name = 'Evacuee: Ejected Pilot #4',
                    playerCanDrive = false,
                    skill = 'Excellent',
                    type = 'Ejected Pilot',
                    unitId = 4,
                    x = -26,
                    y = 2
                },
            },
            name = 'Evacuee Group 2',
            groupId = 2,
            category = Group.Category.GROUND,
            country = 2,
            x = 0,
            y = 0,
        }, 50)

        -- SIDE EFFECTS
        Evac.beaconBatteryLife = 0
    end,
    test1SpawnComposition = function()
        -- INIT
        Evac.beaconBatteryLife = 30

        trigger.action.outTextForGroup:whenCalled({
            with = {_testUnit:getGroup():getID(), 'Evacuation Beacons:\nGroup #8 - Beacon #1 (840.00 kHz - 277.50 / 32.15 MHz)\n', 20 },
            thenReturn = nil,
        })

        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 840000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 277500000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 1, true, 32150000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        -- TEST
        lu.assertAlmostEquals(Evac.groups.spawn(coalition.side.BLUE, { {} }, country.USA, _testZone, 5), {
            visible = false,
            hidden = true,
            units = {
                {
                    heading = 0,
                    name = 'Evacuee: Ejected Pilot #2',
                    playerCanDrive = false,
                    skill = 'Excellent',
                    type = 'Ejected Pilot',
                    unitId = 2,
                    x = -26,
                    y = 2
                },
            },
            name = 'Evacuee Group 2',
            groupId = 2,
            category = Group.Category.GROUND,
            country = 2,
            x = 0,
            y = 0,
        }, 50)

        -- SIDE EFFECTS
        Evac.beaconBatteryLife = 0
    end,
    test2List = function()
        -- INIT
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac.groups.list(_testZone), { _testGroup, _testGroup })

        -- SIDE EFFECTS
        -- N/A?
    end,
    test3Count = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac.groups.count(_testZone), 2)

        -- SIDE EFFECTS
        -- N/A?
    end,
    tearDown = tearDown,
}

Test5Internal0Aircraft = {
    setUp = setUp,
    test0GetZone = function()
        -- INIT
        lu.assertEquals(Evac.zones.evac.activate(_testZone), nil)

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.getZone(_testUnit.unitName), _testZone)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test1InZone = function()
        -- INIT
        lu.assertEquals(Evac.zones.evac.activate(_testZone), nil)

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.inZone(_testUnit.unitName, _testZone), true)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test2InAir = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.inAir(_testUnit.unitName), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test3HeightDifference = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.heightDifference(_testUnit.unitName), _testUnit:getPoint().y)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test4LoadEvacuees = function()
        -- INIT
        local _args = {_testUnit:getID(), 'Not in an active evac or relay zone! Try looking elsewhere.', 5 }
        trigger.action.outTextForUnit:whenCalled({ with = _args, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.loadEvacuees(_testUnit.unitName, 1), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.outTextForUnit.assertAnyCallMatches,
            trigger.action.outTextForUnit,
            _args
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.outTextForUnit.spy.calls)))
    end,
    test5CountEvacuees = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.countEvacuees(_testZone), 0)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test6CalculateWeight = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.calculateWeight(_testZone), 0)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test7AdaptWeight = function()
        -- INIT
        trigger.action.setUnitInternalCargo:whenCalled({ with = { _testUnit.unitName, 0 }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.adaptWeight(_testUnit.unitName), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.setUnitInternalCargo.assertAnyCallMatches,
            trigger.action.setUnitInternalCargo,
            { arguments = { _testUnit.unitName, 0 } }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.setUnitInternalCargo.spy.calls)))
    end,
    test8UnloadEvacuees = function()
        -- INIT
        local _args = {_testUnit:getID(), 'Not in an active relay or safe zone! Try looking elsewhere.', 5 }
        trigger.action.outTextForUnit:whenCalled({ with = _args, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac._internal.aircraft.unloadEvacuees(_testUnit.unitName), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.outTextForUnit.assertAnyCallMatches,
            trigger.action.outTextForUnit,
            _args
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.outTextForUnit.spy.calls)))
    end,
    tearDown = tearDown,
}

Test5Internal1Beacons = {
    setUp = setUp,
    test0Spawn = function()
        -- INIT
        Evac.beaconBatteryLife = 30

        trigger.action.outTextForGroup:whenCalled({
            with = {_testUnit:getGroup():getID(), 'Evacuation Beacons:\nGroup #8 - Beacon #1 (840.00 kHz - 277.50 / 32.15 MHz)\n', 20 },
            thenReturn = nil,
        })

        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 840000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 277500000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 1, true, 32150000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        -- TEST
        lu.assertEquals(Evac._internal.beacons.spawn(_testZone, 2, 2, nil, nil), {
            battery = 1800,
            fm = 32150000,
            group = 'Group #2 - Beacon #1',
            side = 2,
            text = '840.00 kHz - 277.50 / 32.15 MHz',
            uhf = 277500000,
            vhf = 840000
        })

        -- SIDE EFFECTS
        Evac.beaconBatteryLife = 0
    end,
    test1GetFreeADFFrequencies = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.beacons.getFreeADFFrequencies(), {
            fm = 32150000,
            uhf = 277500000,
            vhf = 840000
        })

        -- SIDE EFFECTS
        -- N/A?
    end,
    test2List = function()
        -- INIT
        local _args = {_testUnit:getGroup():getID(), 'Evacuation Beacons:\nGroup #2 - Beacon #1 (840.00 kHz - 277.50 / 32.15 MHz)\n', 15 }

        Evac._internal.beacons.spawn(_testZone, coalition.side.BLUE, country.USA)
        trigger.action.outTextForGroup:whenCalled({ with = _args, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac._internal.beacons.list(_testUnit.unitName), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.outTextForGroup.assertAnyCallMatches,
            trigger.action.outTextForGroup,
            { arguments = _args }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.outTextForGroup.spy.calls)))
    end,
    test3Update = function()
        -- INIT
        local _radioGroup = {
            battery = 1800,
            fm = 32150000,
            group = 'Group #2 - Beacon #1',
            side = 2,
            text = '840.00 kHz - 277.50 / 32.15 MHz',
            uhf = 277500000,
            vhf = 840000
        }

        Evac.beaconBatteryLife = 30

        trigger.action.outTextForGroup:whenCalled({
            with = {_testUnit:getGroup():getID(), 'Evacuation Beacons:\nGroup #2 - Beacon #1 (840.00 kHz - 277.50 / 32.15 MHz)\n', 20 },
            thenReturn = nil,
        })

        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.stopRadioTransmission:whenCalled({
            with = { '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 840000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | VHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 0, true, 277500000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | UHF' },
            thenReturn = nil,
        })
        trigger.action.radioTransmission:whenCalled({
            with = { 'l10n/DEFAULT/', nil, 1, true, 32150000, 1000, '840.00 kHz - 277.50 / 32.15 MHz | FM' },
            thenReturn = nil,
        })

        lu.assertEquals(Evac._internal.beacons.spawn(_testZone, 2, 2, nil, nil), _radioGroup)

        -- TEST
        lu.assertEquals(Evac._internal.beacons.update(_radioGroup), true)

        -- SIDE EFFECTS
        Evac.beaconBatteryLife = 0
    end,
    test4KillDead = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.beacons.killDead(), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            timer.scheduleFunction.assertAnyCallMatches,
            timer.scheduleFunction,
            { arguments = { nil, {}, 0.01 } }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(timer.scheduleFunction.calls)))
    end,
    test5GenerateVHFrequencies = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.beacons.generateVHFrequencies(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.frequencies.vhf.free, {
            200000,
            210000,
            220000,
            230000,
            240000,
            250000,
            260000,
            270000,
            280000,
            290000,
            300000,
            310000,
            340000,
            350000,
            360000,
            370000,
            390000,
            400000,
            410000,
            450000,
            460000,
            480000,
            490000,
            500000,
            510000,
            530000,
            540000,
            550000,
            560000,
            570000,
            590000,
            600000,
            610000,
            620000,
            630000,
            640000,
            650000,
            660000,
            700000,
            710000,
            760000,
            780000,
            790000,
            800000,
            810000,
            820000,
            840000,
            850000,
            900000,
            1100000,
            1150000,
            1200000,
            1250000
        })
    end,
    test6GenerateUHFrequencies = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.beacons.generateUHFrequencies(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.frequencies.uhf.free, {
            220000000,
            220500000,
            221000000,
            221500000,
            222000000,
            222500000,
            223000000,
            223500000,
            224000000,
            224500000,
            225000000,
            225500000,
            226000000,
            226500000,
            227000000,
            227500000,
            228000000,
            228500000,
            229000000,
            229500000,
            230000000,
            230500000,
            231000000,
            231500000,
            232000000,
            232500000,
            233000000,
            233500000,
            234000000,
            234500000,
            235000000,
            235500000,
            236000000,
            236500000,
            237000000,
            237500000,
            238000000,
            238500000,
            239000000,
            239500000,
            240000000,
            240500000,
            241000000,
            241500000,
            242000000,
            242500000,
            243000000,
            243500000,
            244000000,
            244500000,
            245000000,
            245500000,
            246000000,
            246500000,
            247000000,
            247500000,
            248000000,
            248500000,
            249000000,
            249500000,
            250000000,
            250500000,
            251000000,
            251500000,
            252000000,
            252500000,
            253000000,
            253500000,
            254000000,
            254500000,
            255000000,
            255500000,
            256000000,
            256500000,
            257000000,
            257500000,
            258000000,
            258500000,
            259000000,
            259500000,
            260000000,
            260500000,
            261000000,
            261500000,
            262000000,
            262500000,
            263000000,
            263500000,
            264000000,
            264500000,
            265000000,
            265500000,
            266000000,
            266500000,
            267000000,
            267500000,
            268000000,
            268500000,
            269000000,
            269500000,
            270000000,
            270500000,
            271000000,
            271500000,
            272000000,
            272500000,
            273000000,
            273500000,
            274000000,
            274500000,
            275000000,
            275500000,
            276000000,
            276500000,
            277000000,
            277500000,
            278000000,
            278500000,
            279000000,
            279500000,
            280000000,
            280500000,
            281000000,
            281500000,
            282000000,
            282500000,
            283000000,
            283500000,
            284000000,
            284500000,
            285000000,
            285500000,
            286000000,
            286500000,
            287000000,
            287500000,
            288000000,
            288500000,
            289000000,
            289500000,
            290000000,
            290500000,
            291000000,
            291500000,
            292000000,
            292500000,
            293000000,
            293500000,
            294000000,
            294500000,
            295000000,
            295500000,
            296000000,
            296500000,
            297000000,
            297500000,
            298000000,
            298500000,
            299000000,
            299500000,
            300000000,
            300500000,
            301000000,
            301500000,
            302000000,
            302500000,
            303000000,
            303500000,
            304000000,
            304500000,
            305000000,
            305500000,
            306000000,
            306500000,
            307000000,
            307500000,
            308000000,
            308500000,
            309000000,
            309500000,
            310000000,
            310500000,
            311000000,
            311500000,
            312000000,
            312500000,
            313000000,
            313500000,
            314000000,
            314500000,
            315000000,
            315500000,
            316000000,
            316500000,
            317000000,
            317500000,
            318000000,
            318500000,
            319000000,
            319500000,
            320000000,
            320500000,
            321000000,
            321500000,
            322000000,
            322500000,
            323000000,
            323500000,
            324000000,
            324500000,
            325000000,
            325500000,
            326000000,
            326500000,
            327000000,
            327500000,
            328000000,
            328500000,
            329000000,
            329500000,
            330000000,
            330500000,
            331000000,
            331500000,
            332000000,
            332500000,
            333000000,
            333500000,
            334000000,
            334500000,
            335000000,
            335500000,
            336000000,
            336500000,
            337000000,
            337500000,
            338000000,
            338500000,
            339000000,
            339500000,
            340000000,
            340500000,
            341000000,
            341500000,
            342000000,
            342500000,
            343000000,
            343500000,
            344000000,
            344500000,
            345000000,
            345500000,
            346000000,
            346500000,
            347000000,
            347500000,
            348000000,
            348500000,
            349000000,
            349500000,
            350000000,
            350500000,
            351000000,
            351500000,
            352000000,
            352500000,
            353000000,
            353500000,
            354000000,
            354500000,
            355000000,
            355500000,
            356000000,
            356500000,
            357000000,
            357500000,
            358000000,
            358500000,
            359000000,
            359500000,
            360000000,
            360500000,
            361000000,
            361500000,
            362000000,
            362500000,
            363000000,
            363500000,
            364000000,
            364500000,
            365000000,
            365500000,
            366000000,
            366500000,
            367000000,
            367500000,
            368000000,
            368500000,
            369000000,
            369500000,
            370000000,
            370500000,
            371000000,
            371500000,
            372000000,
            372500000,
            373000000,
            373500000,
            374000000,
            374500000,
            375000000,
            375500000,
            376000000,
            376500000,
            377000000,
            377500000,
            378000000,
            378500000,
            379000000,
            379500000,
            380000000,
            380500000,
            381000000,
            381500000,
            382000000,
            382500000,
            383000000,
            383500000,
            384000000,
            384500000,
            385000000,
            385500000,
            386000000,
            386500000,
            387000000,
            387500000,
            388000000,
            388500000,
            389000000,
            389500000,
            390000000,
            390500000,
            391000000,
            391500000,
            392000000,
            392500000,
            393000000,
            393500000,
            394000000,
            394500000,
            395000000,
            395500000,
            396000000,
            396500000,
            397000000,
            397500000,
            398000000,
            398500000
        })
    end,
    test7GenerateFMFrequencies = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.beacons.generateFMFrequencies(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.frequencies.fm.free, {
            30000000,
            30050000,
            30100000,
            30150000,
            30200000,
            30250000,
            30300000,
            30350000,
            30400000,
            30450000,
            30500000,
            30550000,
            30600000,
            30650000,
            30700000,
            30750000,
            30800000,
            30850000,
            30900000,
            30950000,
            31000000,
            31050000,
            31100000,
            31150000,
            31200000,
            31250000,
            31300000,
            31350000,
            31400000,
            31450000,
            31500000,
            31550000,
            31600000,
            31650000,
            31700000,
            31750000,
            31800000,
            31850000,
            31900000,
            31950000,
            32000000,
            32050000,
            32100000,
            32150000,
            32200000,
            32250000,
            32300000,
            32350000,
            32400000,
            32450000,
            32500000,
            32550000,
            32600000,
            32650000,
            32700000,
            32750000,
            32800000,
            32850000,
            32900000,
            32950000,
            33000000,
            33050000,
            33100000,
            33150000,
            33200000,
            33250000,
            33300000,
            33350000,
            33400000,
            33450000,
            33500000,
            33550000,
            33600000,
            33650000,
            33700000,
            33750000,
            33800000,
            33850000,
            33900000,
            33950000,
            34000000,
            34050000,
            34100000,
            34150000,
            34200000,
            34250000,
            34300000,
            34350000,
            34400000,
            34450000,
            34500000,
            34550000,
            34600000,
            34650000,
            34700000,
            34750000,
            34800000,
            34850000,
            34900000,
            34950000,
            35000000,
            35050000,
            35100000,
            35150000,
            35200000,
            35250000,
            35300000,
            35350000,
            35400000,
            35450000,
            35500000,
            35550000,
            35600000,
            35650000,
            35700000,
            35750000,
            35800000,
            35850000,
            35900000,
            35950000,
            40000000,
            40050000,
            40100000,
            40150000,
            40200000,
            40250000,
            40300000,
            40350000,
            40400000,
            40450000,
            40500000,
            40550000,
            40600000,
            40650000,
            40700000,
            40750000,
            40800000,
            40850000,
            40900000,
            40950000,
            41000000,
            41050000,
            41100000,
            41150000,
            41200000,
            41250000,
            41300000,
            41350000,
            41400000,
            41450000,
            41500000,
            41550000,
            41600000,
            41650000,
            41700000,
            41750000,
            41800000,
            41850000,
            41900000,
            41950000,
            42000000,
            42050000,
            42100000,
            42150000,
            42200000,
            42250000,
            42300000,
            42350000,
            42400000,
            42450000,
            42500000,
            42550000,
            42600000,
            42650000,
            42700000,
            42750000,
            42800000,
            42850000,
            42900000,
            42950000,
            43000000,
            43050000,
            43100000,
            43150000,
            43200000,
            43250000,
            43300000,
            43350000,
            43400000,
            43450000,
            43500000,
            43550000,
            43600000,
            43650000,
            43700000,
            43750000,
            43800000,
            43850000,
            43900000,
            43950000,
            44000000,
            44050000,
            44100000,
            44150000,
            44200000,
            44250000,
            44300000,
            44350000,
            44400000,
            44450000,
            44500000,
            44550000,
            44600000,
            44650000,
            44700000,
            44750000,
            44800000,
            44850000,
            44900000,
            44950000,
            45000000,
            45050000,
            45100000,
            45150000,
            45200000,
            45250000,
            45300000,
            45350000,
            45400000,
            45450000,
            45500000,
            45550000,
            45600000,
            45650000,
            45700000,
            45750000,
            45800000,
            45850000,
            45900000,
            45950000,
            50000000,
            50050000,
            50100000,
            50150000,
            50200000,
            50250000,
            50300000,
            50350000,
            50400000,
            50450000,
            50500000,
            50550000,
            50600000,
            50650000,
            50700000,
            50750000,
            50800000,
            50850000,
            50900000,
            50950000,
            51000000,
            51050000,
            51100000,
            51150000,
            51200000,
            51250000,
            51300000,
            51350000,
            51400000,
            51450000,
            51500000,
            51550000,
            51600000,
            51650000,
            51700000,
            51750000,
            51800000,
            51850000,
            51900000,
            51950000,
            52000000,
            52050000,
            52100000,
            52150000,
            52200000,
            52250000,
            52300000,
            52350000,
            52400000,
            52450000,
            52500000,
            52550000,
            52600000,
            52650000,
            52700000,
            52750000,
            52800000,
            52850000,
            52900000,
            52950000,
            53000000,
            53050000,
            53100000,
            53150000,
            53200000,
            53250000,
            53300000,
            53350000,
            53400000,
            53450000,
            53500000,
            53550000,
            53600000,
            53650000,
            53700000,
            53750000,
            53800000,
            53850000,
            53900000,
            53950000,
            54000000,
            54050000,
            54100000,
            54150000,
            54200000,
            54250000,
            54300000,
            54350000,
            54400000,
            54450000,
            54500000,
            54550000,
            54600000,
            54650000,
            54700000,
            54750000,
            54800000,
            54850000,
            54900000,
            54950000,
            55000000,
            55050000,
            55100000,
            55150000,
            55200000,
            55250000,
            55300000,
            55350000,
            55400000,
            55450000,
            55500000,
            55550000,
            55600000,
            55650000,
            55700000,
            55750000,
            55800000,
            55850000,
            55900000,
            55950000,
            60000000,
            60050000,
            60100000,
            60150000,
            60200000,
            60250000,
            60300000,
            60350000,
            60400000,
            60450000,
            60500000,
            60550000,
            60600000,
            60650000,
            60700000,
            60750000,
            60800000,
            60850000,
            60900000,
            60950000,
            61000000,
            61050000,
            61100000,
            61150000,
            61200000,
            61250000,
            61300000,
            61350000,
            61400000,
            61450000,
            61500000,
            61550000,
            61600000,
            61650000,
            61700000,
            61750000,
            61800000,
            61850000,
            61900000,
            61950000,
            62000000,
            62050000,
            62100000,
            62150000,
            62200000,
            62250000,
            62300000,
            62350000,
            62400000,
            62450000,
            62500000,
            62550000,
            62600000,
            62650000,
            62700000,
            62750000,
            62800000,
            62850000,
            62900000,
            62950000,
            63000000,
            63050000,
            63100000,
            63150000,
            63200000,
            63250000,
            63300000,
            63350000,
            63400000,
            63450000,
            63500000,
            63550000,
            63600000,
            63650000,
            63700000,
            63750000,
            63800000,
            63850000,
            63900000,
            63950000,
            64000000,
            64050000,
            64100000,
            64150000,
            64200000,
            64250000,
            64300000,
            64350000,
            64400000,
            64450000,
            64500000,
            64550000,
            64600000,
            64650000,
            64700000,
            64750000,
            64800000,
            64850000,
            64900000,
            64950000,
            65000000,
            65050000,
            65100000,
            65150000,
            65200000,
            65250000,
            65300000,
            65350000,
            65400000,
            65450000,
            65500000,
            65550000,
            65600000,
            65650000,
            65700000,
            65750000,
            65800000,
            65850000,
            65900000,
            65950000,
            70000000,
            70050000,
            70100000,
            70150000,
            70200000,
            70250000,
            70300000,
            70350000,
            70400000,
            70450000,
            70500000,
            70550000,
            70600000,
            70650000,
            70700000,
            70750000,
            70800000,
            70850000,
            70900000,
            70950000,
            71000000,
            71050000,
            71100000,
            71150000,
            71200000,
            71250000,
            71300000,
            71350000,
            71400000,
            71450000,
            71500000,
            71550000,
            71600000,
            71650000,
            71700000,
            71750000,
            71800000,
            71850000,
            71900000,
            71950000,
            72000000,
            72050000,
            72100000,
            72150000,
            72200000,
            72250000,
            72300000,
            72350000,
            72400000,
            72450000,
            72500000,
            72550000,
            72600000,
            72650000,
            72700000,
            72750000,
            72800000,
            72850000,
            72900000,
            72950000,
            73000000,
            73050000,
            73100000,
            73150000,
            73200000,
            73250000,
            73300000,
            73350000,
            73400000,
            73450000,
            73500000,
            73550000,
            73600000,
            73650000,
            73700000,
            73750000,
            73800000,
            73850000,
            73900000,
            73950000,
            74000000,
            74050000,
            74100000,
            74150000,
            74200000,
            74250000,
            74300000,
            74350000,
            74400000,
            74450000,
            74500000,
            74550000,
            74600000,
            74650000,
            74700000,
            74750000,
            74800000,
            74850000,
            74900000,
            74950000,
            75000000,
            75050000,
            75100000,
            75150000,
            75200000,
            75250000,
            75300000,
            75350000,
            75400000,
            75450000,
            75500000,
            75550000,
            75600000,
            75650000,
            75700000,
            75750000,
            75800000,
            75850000,
            75900000,
            75950000
        })
    end,
    tearDown = tearDown,
}

Test5Internal2Smoke = {
    setUp = setUp,
    test0Refresh = function()
        -- INIT
        trigger.action.smoke:whenCalled({ with = { nil, trigger.smokeColor.Green }, thenReturn = nil })
        lu.assertEquals(Evac._internal.zones.activate(_testZone, Evac.modes.EVAC))

        -- TEST
        lu.assertEquals(Evac._internal.smoke.refresh(), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.smoke.assertAnyCallMatches,
            trigger.action.smoke,
            { arguments = { nil, trigger.smokeColor.Green } }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.smoke.spy.calls)))

        local _status, _result = pcall(
            timer.scheduleFunction.assertAnyCallMatches,
            timer.scheduleFunction,
            { arguments = { nil, nil, 300 } }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(timer.scheduleFunction.calls)))
    end,
    tearDown = tearDown,
}

Test5Internal3Zones = {
    setUp = setUp,
    test0Register = function()
        -- INIT
        local _testName = 'register'

        lu.assertEquals(Evac._state.zones.evac[_testName], nil)
        lu.assertEquals(Evac._state.extractableNow[_testName], nil)

        -- TEST
        lu.assertEquals(Evac._internal.zones.register(_testName, trigger.smokeColor.Green, coalition.side.BLUE, Evac.modes.EVAC), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.evac[_testName], {
            active = false,
            name = _testName,
            side = coalition.side.BLUE,
            smoke = trigger.smokeColor.Green,
            mode = Evac.modes.EVAC
        })
        lu.assertEquals(Evac._state.extractableNow[_testName], {})
    end,
    test1GenerateEvacueesByNumber = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertAlmostEquals(Evac._internal.zones.generateEvacuees(coalition.side.BLUE, 1, country.USA), {
            units = { { type = 'Ejected Pilot', unitId = 2, unitName = 'Evacuee: Ejected Pilot #2', weight = 0 } },
            groupId = 2,
            groupName = 'Evacuee Group 2',
            side = coalition.side.BLUE,
            country = country.USA,
            weight = 0,
        }, 50)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test2GenerateEvacueesByComposition = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertAlmostEquals(Evac._internal.zones.generateEvacuees(coalition.side.BLUE, { {} }, country.USA), {
            units = { { type = 'Ejected Pilot', unitId = 2, unitName = 'Evacuee: Ejected Pilot #2', weight = 0 } },
            groupId = 2,
            groupName = 'Evacuee Group 2',
            side = coalition.side.BLUE,
            country = country.USA,
            weight = 0,
        }, 50)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test3Activate = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.evac[_testZone].active, false)

        -- TEST
        lu.assertEquals(Evac._internal.zones.activate(_testZone, Evac.modes.EVAC), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.evac[_testZone].active, true)
    end,
    test4SetRemainingNumber = function()
        -- INIT
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac._internal.zones.setRemaining(_testZone, coalition.side.BLUE, country.USA, 1), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.extractableNow[_testZone], { ['Evacuee: Ejected Pilot #2'] = { type = 'Ejected Pilot', unitId = 2, unitName = 'Evacuee: Ejected Pilot #2', weight = 0 } })
    end,
    test5SetRemainingComposition = function()
        -- INIT
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac._internal.zones.setRemaining(_testZone, coalition.side.BLUE, country.USA, {{}}), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.extractableNow[_testZone], { ['Evacuee: Ejected Pilot #2'] = { type = 'Ejected Pilot', unitId = 2, unitName = 'Evacuee: Ejected Pilot #2', weight = 0 } })
    end,
    test6Count = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.zones.count(_testZone, Evac.modes.EVAC), 1)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test7IsIn = function()
        -- INIT
        lu.assertEquals(Evac._internal.zones.activate(_testZone, Evac.modes.EVAC), nil)

        -- TEST
        lu.assertEquals(Evac._internal.zones.isIn(_testUnit.unitName, Evac.modes.EVAC), true)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test8Deactivate = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.evac[_testZone].active, false)
        lu.assertEquals(Evac._internal.zones.activate(_testZone, Evac.modes.EVAC), nil)
        lu.assertEquals(Evac._state.zones.evac[_testZone].active, true)

        -- TEST
        lu.assertEquals(Evac._internal.zones.deactivate(_testZone, Evac.modes.EVAC), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.evac[_testZone].active, false)
    end,
    test9Unregister = function()
        -- INIT
        lu.assertEquals(Evac._state.zones.evac[_testZone], {
            active = false,
            name = _testZone,
            side = coalition.side.BLUE,
            smoke = trigger.smokeColor.Green,
            mode = Evac.modes.EVAC
        })
        lu.assertEquals(Evac._state.extractableNow[_testZone], { [_testUnit3.unitName] = _testEvacuee })

        -- TEST
        lu.assertEquals(Evac._internal.zones.unregister(_testZone, Evac.modes.EVAC), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.zones.evac[_testZone], nil)
        lu.assertEquals(Evac._state.extractableNow[_testZone], nil)
    end,
    tearDown = tearDown,
}

Test5Internal4Utils = {
    setUp = setUp,
    test0EndIfLossesTooHigh = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { 1, true }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 2, true }, thenReturn = nil })

        Evac.lossFlags = { 1, 2 }
        Evac._state.lostEvacuees = {
            {
                ['Ejected Pilot'] = 25,
                Infantry = 25,
                ['2B11'] = 25,
                M249 = 25,
                RPG = 25,
                StingerIgla = 25,
                JTAC = 25,
            },
            {
                ['Ejected Pilot'] = 25,
                Infantry = 25,
                ['2B11'] = 25,
                M249 = 25,
                RPG = 25,
                StingerIgla = 25,
                JTAC = 25,
            },
        }

        -- TEST
        lu.assertEquals(Evac._internal.utils.endIfLossesTooHigh(), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            trigger.action.setUserFlag.assertAnyCallMatches,
            trigger.action.setUserFlag,
            { arguments = { 1, true } }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.setUserFlag.spy.calls)))

        _status, _result = pcall(
            trigger.action.setUserFlag.assertAnyCallMatches,
            trigger.action.setUserFlag,
            { arguments = { 2, true } }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.setUserFlag.spy.calls)))
    end,
    test1GetNextGroupId = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.utils.getNextGroupId(), Evac._internal.utils.currentGroup)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test2GetNextUnitId = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Evac._internal.utils.getNextUnitId(), Evac._internal.utils.currentUnit)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test3RandomizeWeight = function()
        -- INIT
        -- N/A?

        -- TEST A
        lu.assertEquals(Evac._internal.utils.randomizeWeight(), 0)

        -- TEST B
        lu.assertEquals(Evac._internal.utils.randomizeWeight(0), 0)

        -- TEST C
        lu.assertAlmostEquals(Evac._internal.utils.randomizeWeight(100), 100, 30)

        -- SIDE EFFECTS
        -- N/A?
    end,
    test4UnitDataToList = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertAlmostEquals(Evac._internal.utils.unitDataToList({{
            type = 'Test',
            unitId = 0,
            unitName = 'Test Unit'
        }}, { x = 0, y = 0, z = 0 }, 5), { {
            type = 'Test',
            unitId = 0,
            name = 'Test Unit',
            skill = 'Excellent',
            playerCanDrive = false,
            x = 0,
            y = 0,
            heading = 0,
        } }, 50)

        -- SIDE EFFECTS
        -- N/A?
    end,
    tearDown = tearDown,
}

Test5Internal5DoSpawns = {
    setUp = setUp,
    test0DoSpawnsFirstPass = function()
        -- INIT
        Evac.zones.evac.activate(_testZone)

        -- TEST
        lu.assertEquals(Evac._internal.doSpawns(), nil)

        -- SIDE EFFECTS
        lu.assertNotEquals(Evac._state.spawns.lastChecked[0], nil)
        lu.assertEquals(Evac._state.spawns.alreadySpawned, Evac.maxExtractable)
    end,
    test1DoSpawnsSecondPass = function()
        -- INIT
        Evac.zones.evac.activate(_testZone)

        -- TEST A
        lu.assertEquals(Evac._internal.doSpawns(), nil)

        -- SIDE EFFECTS A
        lu.assertNotEquals(Evac._state.spawns.lastChecked[0], nil)
        lu.assertEquals(Evac._state.spawns.alreadySpawned, Evac.maxExtractable)

        -- TEST B
        lu.assertEquals(Evac._internal.doSpawns(), nil)

        -- SIDE EFFECTS B
        lu.assertNotEquals(Evac._state.spawns.lastChecked[0], nil)
        lu.assertEquals(Evac._state.spawns.alreadySpawned, Evac.maxExtractable)
    end,
    tearDown = tearDown,
}

Test5Internal6Handlers = {
    setUp = setUp,
    test0FullLoss = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { 1, true }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 2, true }, thenReturn = nil })

        Evac.lossFlags = { 1, 2 }
        Evac._state.lostEvacuees = {
            {
                ['Ejected Pilot'] = 25,
                Infantry = 25,
                ['2B11'] = 25,
                M249 = 25,
                RPG = 25,
                StingerIgla = 25,
                JTAC = 25,
            },
            {
                ['Ejected Pilot'] = 25,
                Infantry = 25,
                ['2B11'] = 25,
                M249 = 25,
                RPG = 25,
                StingerIgla = 25,
                JTAC = 25,
            },
        }
        if Evac._state.extractionUnits[_testUnit.unitName] == nil then
            Evac._state.extractionUnits[_testUnit.unitName] = {
                [0] = _testUnit
            }
        end
        table.insert(Evac._state.extractionUnits[_testUnit.unitName], _testEvacuee)

        -- TEST
        lu.assertEquals(Evac._internal.handlers.fullLoss.fn({ id = world.event.S_EVENT_UNIT_LOST, initiator = _testUnit }))

        -- SIDE EFFECTS
        lu.assertEquals(Evac._state.extractionUnits[_testUnit.unitName], { [0] = _testUnit })
        lu.assertEquals(Evac._state.lostEvacuees[2]['Ejected Pilot'], 26)

        local _status, _result = pcall(
            trigger.action.setUserFlag.assertAnyCallMatches,
            trigger.action.setUserFlag,
            { arguments = { 1, true } }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.setUserFlag.spy.calls)))

        _status, _result = pcall(
            trigger.action.setUserFlag.assertAnyCallMatches,
            trigger.action.setUserFlag,
            { arguments = { 2, true } }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(trigger.action.setUserFlag.spy.calls)))
    end,
    tearDown = tearDown,
}

Test6TopLevel = {
    setUp = setUp,
    test0SetupNone = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacRedLoss', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacBlueLoss', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacRedWin', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacBlueWin', false }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac:setup(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac.beaconBatteryLife, 30)
        lu.assertEquals(Evac.beaconSound, 'beacon.ogg')
        lu.assertEquals(Evac.carryLimits, {
            ['C-130'] = 90,
            ['CH-47D'] = 44,
            ['CH-43E'] = 55,
            ['Hercules'] = 90,
            ['Mi-8MT'] = 24,
            ['Mi-24P'] = 5,
            ['Mi-24V'] = 5,
            ['Mi-26'] = 70,
            ['SH60B'] = 5,
            ['UH-1H'] = 8,
            ['UH-60L'] = 11,
        })
        lu.assertEquals(Evac.idStart, 50000)
        lu.assertEquals(Evac.loadUnloadPerIndividual, 30)
        lu.assertEquals(Evac.maxExtractable, {
            {
                ['Ejected Pilot'] = 0,
                Infantry = 0,
                M249 = 0,
                RPG = 0,
                StingerIgla = 0,
                ['2B11'] = 0,
                JTAC = 0,
            },
            {
                ['Ejected Pilot'] = 250,
                Infantry = 0,
                M249 = 0,
                RPG = 0,
                StingerIgla = 0,
                ['2B11'] = 0,
                JTAC = 0,
            },
        })
        lu.assertEquals(Evac.spawnRates, { _global = { { per = 0, period = 1, units = 0 }, { per = 0, period = 1, units = 0 } } })
        lu.assertEquals(Evac.spawnWeight, 100)
    end,
    test1SetupBlank = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacRedLoss', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacBlueLoss', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacRedWin', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacBlueWin', false }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac:setup({}), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac.beaconBatteryLife, 30)
        lu.assertEquals(Evac.beaconSound, 'beacon.ogg')
        lu.assertEquals(Evac.carryLimits, {
            ['C-130'] = 90,
            ['CH-47D'] = 44,
            ['CH-43E'] = 55,
            ['Hercules'] = 90,
            ['Mi-8MT'] = 24,
            ['Mi-24P'] = 5,
            ['Mi-24V'] = 5,
            ['Mi-26'] = 70,
            ['SH60B'] = 5,
            ['UH-1H'] = 8,
            ['UH-60L'] = 11,
        })
        lu.assertEquals(Evac.idStart, 50000)
        lu.assertEquals(Evac.loadUnloadPerIndividual, 30)
        lu.assertEquals(Evac.maxExtractable, {
            {
                ['Ejected Pilot'] = 0,
                Infantry = 0,
                M249 = 0,
                RPG = 0,
                StingerIgla = 0,
                ['2B11'] = 0,
                JTAC = 0,
            },
            {
                ['Ejected Pilot'] = 250,
                Infantry = 0,
                M249 = 0,
                RPG = 0,
                StingerIgla = 0,
                ['2B11'] = 0,
                JTAC = 0,
            },
        })
        lu.assertEquals(Evac.spawnRates, { _global = { { per = 0, period = 1, units = 0 }, { per = 0, period = 1, units = 0 } } })
        lu.assertEquals(Evac.spawnWeight, 100)
    end,
    test2SetupConfig = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacRedLoss', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacBlueLoss', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacRedWin', false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'GremlinEvacBlueWin', false }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Evac:setup({
            beaconBatteryLife = 2,
            beaconSound = 'test.ogg',
            carryLimits = {
                ['Test'] = 15,
            },
            idStart = 5,
            loadUnloadPerIndividual = 2,
            maxExtractable = {
                nil,
                {
                    ['Ejected Pilot'] = 12,
                    Infantry = 12,
                    M249 = 12,
                    RPG = 12,
                    StingerIgla = 12,
                    ['2B11'] = 12,
                    JTAC = 3,
                },
            },
            spawnWeight = 50,
            spawnRates = {
                [_testZone] = {
                    {
                        units = 0,
                        per = 0,
                        period = Gremlin.Periods.Second,
                    }, {
                        units = 12,
                        per = 5,
                        period = Gremlin.Periods.Minute,
                    },
                },
            },
        }), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Evac.beaconBatteryLife, 2)
        lu.assertEquals(Evac.beaconSound, 'test.ogg')
        lu.assertEquals(Evac.carryLimits, { Test = 15 })
        lu.assertEquals(Evac.idStart, 5)
        lu.assertEquals(Evac.loadUnloadPerIndividual, 2)
        lu.assertEquals(Evac.maxExtractable, {
            {
                ['Ejected Pilot'] = 0,
                Infantry = 0,
                ['2B11'] = 0,
                StingerIgla = 0,
                RPG = 0,
                M249 = 0,
                JTAC = 0,
            },
            {
                ['Ejected Pilot'] = 250,
                Infantry = 0,
                ['2B11'] = 0,
                StingerIgla = 0,
                RPG = 0,
                M249 = 0,
                JTAC = 0,
            },
        })
        lu.assertEquals(Evac.spawnRates, { [_testZone] = { { per = 0, period = 1, units = 0 }, { per = 5, period = 60, units = 12 } } })
        lu.assertEquals(Evac.spawnWeight, 50)
    end,
    tearDown = tearDown,
}
