local lu = require('luaunit_3_4')
local inspect = require('inspect')
local Mock = require('lib.mock.Mock')
local Spy = require('lib.mock.Spy')
local ValueMatcher = require('lib.mock.ValueMatcher')

table.unpack = table.unpack or unpack
unpack = table.unpack

require('mocks.DCS')
require('mist_4_5_126')
require('gremlin')
require('waves')

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
        { x = 100,  y = 0, z = 100 },
        { x = -100, y = 0, z = 100 },
        { x = -100, y = 0, z = -100 },
        { x = 100,  y = 0, z = -100 },
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

local _testUnit3 = { className_ = 'Unit', groupName = 'Gremlin Troop 2', type = 'Carrier Seaman', unitName = 'TestUnit3', unitId = 3, point = { x = 0, y = 0, z = 0 } }
---@diagnostic disable-next-line: undefined-global
class(_testUnit3, Unit)

local _testGroup = { className_ = 'Group', groupName = 'Gremlin Troop 1', groupId = 1, units = { _testUnit, _testUnit2 } }
---@diagnostic disable-next-line: undefined-global
class(_testGroup, Group)

local _testGroup2 = { className_ = 'Group', groupName = 'Gremlin Troop 2', groupId = 2, units = { _testUnit3 } }
---@diagnostic disable-next-line: undefined-global
class(_testGroup2, Group)

local _testWaveTimedName = 'Test Timed Wave'
local _testWaveTimed = {
    trigger = {
        type = 'time',
        value = 0,
    },
    groups = {
        ['F-14B'] = {
            category = Group.Category.AIRPLANE,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 15, max = 30 },
            orders = {},
            units = {
                ['F-14B'] = 3,
            },
        },
        ['Ground A'] = {
            category = Group.Category.GROUND,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 5, max = 10 },
            orders = {},
            units = {
                ['Infantry'] = 4,
            }
        },
        ['Ground B'] = {
            category = Group.Category.GROUND,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 5, max = 10 },
            orders = {},
            units = {
                ['RPG'] = 1,
                ['Infantry'] = 3,
                ['JTAC'] = 1,
            }
        },
    },
}
local _testWaveTimedGroupNames = {}
for _name, _ in pairs(_testWaveTimed.groups) do
    table.insert(_testWaveTimedGroupNames, _name)
end

local _testWaveMenuName = 'Test Menu Wave'
local _testWaveMenu = {
    trigger = {
        type = 'menu',
        value = 'Spawn The Spanish Inquisition',
    },
    groups = {
        ['F-14B'] = {
            category = Group.Category.AIRPLANE,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 15, max = 30 },
            orders = {},
            units = {
                ['F-14B'] = 3,
            },
        },
        ['Ground A'] = {
            category = Group.Category.GROUND,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 5, max = 10 },
            orders = {},
            units = {
                ['Infantry'] = 4,
            }
        },
        ['Ground B'] = {
            category = Group.Category.GROUND,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 5, max = 10 },
            orders = {},
            units = {
                ['RPG'] = 1,
                ['Infantry'] = 3,
                ['JTAC'] = 1,
            }
        },
    },
}
local _testWaveMenuGroupNames = {}
for _name, _ in pairs(_testWaveMenu.groups) do
    table.insert(_testWaveMenuGroupNames, _name)
end

local _testWaveEventName = 'Test Event Wave'
local _testWaveEvent = {
    trigger = {
        type = 'event',
        value = {
            id = world.event.S_EVENT_AI_ABORT_MISSION,
            filter = function(_event)
                if _event.initiator:getName() == _testUnit.unitName then
                    return true
                end

                return false
            end,
        },
    },
    groups = {
        ['F-14B'] = {
            category = Group.Category.AIRPLANE,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 15, max = 30 },
            orders = {},
            units = {
                ['F-14B'] = 3,
            },
        },
        ['Ground A'] = {
            category = Group.Category.GROUND,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 5, max = 10 },
            orders = {},
            units = {
                ['Infantry'] = 4,
            }
        },
        ['Ground B'] = {
            category = Group.Category.GROUND,
            country = country.USA,
            zone = _testZone,
            scatter = { min = 5, max = 10 },
            orders = {},
            units = {
                ['RPG'] = 1,
                ['Infantry'] = 3,
                ['JTAC'] = 1,
            }
        },
    },
}
local _testWaveEventGroupNames = {}
for _name, _ in pairs(_testWaveEvent.groups) do
    table.insert(_testWaveEventGroupNames, _name)
end

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

    Waves.config.waves = {
        time = {
            [_testWaveTimedName] = mist.utils.deepCopy(_testWaveTimed),
        },
        flag = {},
        menu = {
            [_testWaveMenuName] = mist.utils.deepCopy(_testWaveMenu),
        },
        event = {
            [_testWaveEventName] = mist.utils.deepCopy(_testWaveEvent),
        },
    }
end

local tearDown = function()
    Gremlin.alreadyInitialized = false
    Waves._internal.menu = { Waves._internal.menu[1], Waves._internal.menu[2] }
    Waves._state.alreadyInitialized = false
    Waves._state.paused = false
    Waves.config.adminPilotNames = {}
    Waves.config.waves = { time = {}, flag = {}, menu = {}, event = {} }

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
    timer.scheduleFunction:reset()
    trigger.action.activateGroup:reset()
    trigger.action.setUnitInternalCargo:reset()
    trigger.action.setUserFlag:reset()
    trigger.action.outText:reset()
    trigger.action.outTextForCoalition:reset()
    trigger.action.outTextForCountry:reset()
    trigger.action.outTextForGroup:reset()
    trigger.action.outTextForUnit:reset()
end

local function stripFuncs(_tbl)
    for _idx, _val in pairs(_tbl) do
        if type(_val) == 'table' then
            _tbl[_idx] = stripFuncs(_tbl[_idx])
        elseif type(_val) == 'function' then
            _tbl[_idx] = nil
        end
    end

    return _tbl
end

local function matcherForNameId(_tbl)
    return {
        isMatcher = true,
        match = function(value)
            if value.name == _tbl.name and value.id == _tbl.id then
                return true
            end

            return false, string.format('did not match:\n     was: %s\nexpected: %s', inspect(value), inspect(_tbl))
        end
    }
end

-- TestWavesInternalHandlers = {
--     setUp = setUp,
--     testEventTriggers = function()
--         -- INIT
--         -- N/A?

--         -- TEST
--         lu.assertEquals(Waves._internal.handlers.eventTriggers.fn({ id = world.event.S_EVENT_INVALID }), nil)

--         -- SIDE EFFECTS
--         -- N/A?
--     end,
--     tearDown = tearDown,
-- }

TestWavesInternalMethods = {
    setUp = setUp,
    testSpawnWave = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Waves._internal.spawnWave(_testWaveTimedName, _testWaveTimed), nil)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testGetAdminUnits = function()
        -- INIT
        Waves.config.adminPilotNames = { 'Al Gore' }

        -- TEST
        lu.assertEquals(Waves._internal.getAdminUnits(), { [_testUnit.unitName] = _testUnit, [_testUnit2.unitName] = _testUnit2, [_testUnit3.unitName] = _testUnit3 })

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInitMenu = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Waves._internal.initMenu(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Gremlin.utils.countTableEntries(Waves._internal.menu), 3)
        lu.assertEquals(stripFuncs(Waves._internal.menu[3]), {
            text = _testWaveMenu.trigger.value,
            args = { _testWaveMenuName },
            when = {
                args = { _testWaveMenuName },
                comp = 'equal',
                value = true,
            },
        })
    end,
    skip_testUpdateF10 = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Waves._internal.updateF10(), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            missionCommands.addCommandForGroup.assertAnyCallMatches,
            missionCommands.addCommandForGroup,
            { _testGroup.groupId, 'Pause Waves', { Waves.Id }, ValueMatcher.anyFunction, nil }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(missionCommands.addCommandForGroup.spy.calls)))

        _status, _result = pcall(
            missionCommands.addCommandForGroup.assertAnyCallMatches,
            missionCommands.addCommandForGroup,
            { _testGroup.groupId, 'Resume Waves', { Waves.Id }, ValueMatcher.anyFunction, nil }
        )
        lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(missionCommands.addCommandForGroup.spy.calls)))
    end,
    testMenuWave = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Waves._internal.menuWave(_testWaveMenuName), nil)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testTimeWave = function()
        -- INIT
        lu.assertEquals(Waves.config.waves.time[_testWaveTimedName].trigger.fired, nil)

        -- TEST
        lu.assertEquals(Waves._internal.timeWave(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Waves.config.waves.time[_testWaveTimedName].trigger.fired, true)
    end,
    testPause = function()
        -- INIT
        lu.assertEquals(Waves._state.paused, false)

        -- TEST
        lu.assertEquals(Waves._internal.pause(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Waves._state.paused, true)
    end,
    testUnpause = function()
        -- INIT
        Waves._state.paused = true

        -- TEST
        lu.assertEquals(Waves._internal.unpause(), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Waves._state.paused, false)
    end,
    tearDown = tearDown,
}
