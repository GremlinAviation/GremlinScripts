local lu = require('luaunit_3_4')
local Spy = require('lib.mock.Spy')

table.unpack = table.unpack or unpack
unpack = table.unpack

require('mocks.DCS')
require('mist_4_5_122')
require('gremlin')
require('urgency')

mist.scheduleFunction = Spy(mist.scheduleFunction)
Gremlin.log.error = Spy(Gremlin.log.error)
Gremlin.log.warn = Spy(Gremlin.log.warn)
Gremlin.log.info = Spy(Gremlin.log.info)
Gremlin.log.debug = Spy(Gremlin.log.debug)
Gremlin.log.trace = Spy(Gremlin.log.trace)

local _testZone = 'TestZone'
local _testZoneData = {
    name = _testZone,
    point = { x = 0, y = 0, z = 0 },
    properties = {},
    verticies = {
        { x = 100, y = 0, z = 100 },
        { x = -100, y = 0, z = 100 },
        { x = -100, y = 0, z = -100 },
        { x = 100, y = 0, z = -100 },
    },
    x = 0,
    y = 0,
    z = 0,
}

local _testUnit = { className_ = 'Unit', groupName = 'Gremlin Troop 1', type = 'UH-1H', unitName = 'TestUnit1', unitId = 1, point = { x = 0, y = 0, z = 0 } }
---@diagnostic disable-next-line: undefined-global
class(_testUnit, Unit)

local _testUnit2 = { className_ = 'Unit', groupName = 'Gremlin Troop 1', type = 'UH-1H', unitName = 'TestUnit2', unitId = 2, point = { x = 0, y = 0, z = 0 } }
---@diagnostic disable-next-line: undefined-global
class(_testUnit2, Unit)

local _testUnit3 = { className_ = 'Unit', groupName = 'Gremlin Troop 2', type = 'Ejected Pilot', unitName = 'TestUnit3', unitId = 3, point = { x = 0, y = 0, z = 0 } }
---@diagnostic disable-next-line: undefined-global
class(_testUnit3, Unit)

local _testGroup = { className_ = 'Group', groupName = 'Gremlin Troop 1', groupId = 1, units = { _testUnit, _testUnit2 } }
---@diagnostic disable-next-line: undefined-global
class(_testGroup, Group)

local _testGroup2 = { className_ = 'Group', groupName = 'Gremlin Troop 2', groupId = 2, units = { _testUnit3 } }
---@diagnostic disable-next-line: undefined-global
class(_testGroup2, Group)

local _testCountdownName = 'test'
local _testCountdown = {
    reuse = false,
    startTrigger = {
        type = 'time',
        value = 0,         -- mission start (or, well, as close as we can manage)
    },
    startFlag = 'MissionRunning',
    endTrigger = {
        type = 'time',
        value = 25200,         -- 7 hours
    },
    endFlag = 'MissionTimeout',
    messages = {
        [0] = { to = 'blue', text = 'Mission is a go! We only get seven hours to complete our objectives!', duration = 15 },
        [25200] = { to = 'all', text = "Time's up! Ending mission...", duration = 15 },
    },
}

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
end

local tearDown = function()
    Urgency._state.alreadyInitialized = false
    Urgency._state.countdowns = {
        pending = {},
        active = {},
        done = {},
    }
    Urgency.config.adminPilotNames = {}
    Urgency.config.countdowns = {}

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
    trigger.action.setUserFlag:reset()
    trigger.action.outText:reset()
    trigger.action.outTextForCoalition:reset()
    trigger.action.outTextForCountry:reset()
    trigger.action.outTextForGroup:reset()
    trigger.action.outTextForUnit:reset()
end

TestUrgencyInternal = {
    setUp = setUp,
    testGetAdminUnits = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Urgency._internal.getAdminUnits(), {})

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInitMenu = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Urgency._internal.initMenu(), nil)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testDoCountdowns = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.startFlag, true }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.endFlag, false }, thenReturn = nil })
        trigger.action.outTextForCoalition:whenCalled({ with = { coalition.side.BLUE, _testCountdown.messages[0].text, _testCountdown.messages[0].duration }, thenReturn = nil })

        Urgency._state.countdowns.pending[_testCountdownName] = mist.utils.deepCopy(_testCountdown)

        -- TEST
        lu.assertEquals(Urgency._internal.doCountdowns(), nil)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testStartCountdown = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.startFlag, true }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.endFlag, false }, thenReturn = nil })

        Urgency._state.countdowns.pending[_testCountdownName] = mist.utils.deepCopy(_testCountdown)

        -- TEST
        lu.assertEquals(Urgency._internal.startCountdown(_testCountdownName), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Urgency._state.countdowns.pending, {})
        lu.assertEquals(Urgency._state.countdowns.active, {
            [_testCountdownName] = Gremlin.utils.mergeTables(_testCountdown, { startedAt = 0 })
        })
    end,
    testEndCountdown = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.startFlag, false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.endFlag, true }, thenReturn = nil })

        Urgency._state.countdowns.active[_testCountdownName] = mist.utils.deepCopy(_testCountdown)

        -- TEST
        lu.assertEquals(Urgency._internal.endCountdown(_testCountdownName), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Urgency._state.countdowns.active, {})
        lu.assertEquals(Urgency._state.countdowns.done, {
            [_testCountdownName] = Gremlin.utils.mergeTables(_testCountdown, { endedAt = 0 })
        })
    end,
    testResetCountdowns = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.startFlag, true }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.endFlag, false }, thenReturn = nil })

        Urgency._state.countdowns.pending[_testCountdownName] = mist.utils.deepCopy(_testCountdown)

        -- TEST
        lu.assertEquals(Urgency._internal.resetCountdowns(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Urgency._state.countdowns.active, {})
        lu.assertEquals(Urgency._state.countdowns.pending, {
            [_testCountdownName] = mist.utils.deepCopy(_testCountdown)
        })
    end,
    testRestoreCountdowns = function()
        -- INIT
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.startFlag, false }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { _testCountdown.endFlag, false }, thenReturn = nil })

        Urgency.config.countdowns[_testCountdownName] = mist.utils.deepCopy(_testCountdown)
        Urgency._state.countdowns.pending[_testCountdownName] = mist.utils.deepCopy(_testCountdown)
        Urgency._state.countdowns.active[_testCountdownName] = mist.utils.deepCopy(_testCountdown)
        Urgency._state.countdowns.done[_testCountdownName] = mist.utils.deepCopy(_testCountdown)

        -- TEST
        lu.assertEquals(Urgency._internal.restoreCountdowns(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Urgency._state.countdowns.active, {})
        lu.assertEquals(Urgency._state.countdowns.done, {})
        lu.assertEquals(Urgency._state.countdowns.pending, {
            [_testCountdownName] = mist.utils.deepCopy(_testCountdown)
        })
    end,
    tearDown = tearDown,
}

TestUrgencyTopLevel = {
    setUp = setUp,
    testSetupNone = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Urgency:setup(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Urgency.config.adminPilotNames, {})
    end,
    testSetupBlank = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Urgency.setup({}), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Urgency.config.adminPilotNames, {})
    end,
    testSetupConfig = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Urgency:setup({
            adminPilotNames = {
                'Test Pilot 1',
                'Test Pilot 2',
            },
        }), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Urgency.config.adminPilotNames, {
            'Test Pilot 1',
            'Test Pilot 2',
        })
    end,
    tearDown = tearDown,
}
