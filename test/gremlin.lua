local lu = require('luaunit_3_4')
local inspect = require('inspect')
local Mock = require('lib.mock.Mock')
local Spy = require('lib.mock.Spy')
local ValueMatcher = require('lib.mock.ValueMatcher')

table.unpack = table.unpack or unpack
unpack = table.unpack

require('mocks.DCS')
require('mist_4_5_122')
require('gremlin')

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
    Gremlin.alreadyInitialized = false

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

TestGremlinMenu = {
    setUp = setUp,
    testUpdateF10 = function()
        -- INIT
        local _testCommands = {
            {
                text = 'Test String When True',
                func = Mock(),
                args = {},
                when = true,
            },
            {
                text = function() return 'Test Func When True' end,
                func = Mock(),
                args = {},
                when = true,
            },
            {
                text = 'Test String When False',
                func = Mock(),
                args = {},
                when = false,
            },
            {
                text = function() return 'Test Func When False' end,
                func = Mock(),
                args = {},
                when = false,
            },
        }
        local argsToMatcher = function(_args)
            for _pos, _arg in pairs(_args.arguments) do
                if type(_arg) == "table" then
                    _args.arguments[_pos] = ValueMatcher.anyTable
                elseif type(_arg) == "function" then
                    _args.arguments[_pos] = ValueMatcher.anyFunction
                end
            end

            return _args.arguments
        end

        missionCommands.addSubMenuForGroup:whenCalled({ with = { 1, Gremlin.Id }, thenReturn = { { Gremlin.Id } } })
        missionCommands.removeItemForGroup:whenCalled({ with = { 1, ValueMatcher.anyTable }, thenReturn = nil })
        for _, _command in pairs(_testCommands) do
            if type(_command.text) == 'function' then
                missionCommands.addCommandForGroup:whenCalled({ with = { 1, _command.text(), ValueMatcher.anyTable, ValueMatcher.anyFunction, ValueMatcher.anyTable }, thenReturn = { { Gremlin.Id, _command.text }, _command.text } })
            else
                missionCommands.addCommandForGroup:whenCalled({ with = { 1, _command.text, ValueMatcher.anyTable, ValueMatcher.anyFunction, ValueMatcher.anyTable }, thenReturn = { { Gremlin.Id, _command.text }, _command.text } })
            end
        end

        -- TEST
        lu.assertEquals(Gremlin.menu.updateF10({ Gremlin.Id, _testCommands, function()
            return {
                [_testUnit.unitName] = _testUnit,
                [_testUnit2.unitName] = _testUnit2,
            }
        end
        }), nil)

        -- SIDE EFFECTS
        local _status, _result = pcall(
            missionCommands.addSubMenuForGroup.assertAnyCallMatches,
            missionCommands.addSubMenuForGroup,
            { arguments = { 1, Gremlin.Id } }
        )
        lu.assertEquals(_status, true,
            string.format('%s\n%s', inspect(_result), inspect(missionCommands.addSubMenuForGroup.spy.calls)))

        for _, _command in pairs(_testCommands) do
            if _command.when == true then
                local _args = { arguments = { 1, _command.text, { Gremlin.Id }, _command.func, {} } }

                _status, _result = pcall(
                    missionCommands.addCommandForGroup.assertAnyCallMatches,
                    missionCommands.addCommandForGroup,
                    argsToMatcher(_args)
                )
                lu.assertEquals(_status, true, string.format('%s\n%s\n%s', inspect(_result), inspect(_args), inspect(missionCommands.addCommandForGroup.spy.calls)))
            end
        end
    end,
    tearDown = tearDown,
}

TestGremlinUtils = {
    setUp = setUp,
    testGetUnitZones = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.getUnitZones(_testUnit.unitName), { _testZone })

        -- SIDE EFFECTS
        -- N/A?
    end,
    tearDown = tearDown,
}
