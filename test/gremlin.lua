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

local _testUnit3 = { className_ = 'Unit', groupName = 'Gremlin Troop 2', type = 'Carrier Seaman', unitName = 'TestUnit3', unitId = 3, point = { x = 0, y = 0, z = 0 } }
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
    Gremlin._state.menuAdded = {}
    Gremlin.events._handlers = {}

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
    trigger.action.outSound:reset()
    trigger.action.outSoundForCoalition:reset()
    trigger.action.outSoundForCountry:reset()
    trigger.action.outSoundForGroup:reset()
    trigger.action.outSoundForUnit:reset()
    trigger.action.outText:reset()
    trigger.action.outTextForCoalition:reset()
    trigger.action.outTextForCountry:reset()
    trigger.action.outTextForGroup:reset()
    trigger.action.outTextForUnit:reset()
end

local assertMockCalledWith = function(_mock, _args)
    local _status, _result = pcall( _mock.assertAnyCallMatches, _mock, { arguments = _args } )
    return lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(_mock.spy.calls)))
end

local assertSpyCalledWith = function(_mock, _args)
    local _status, _result = pcall( _mock.assertAnyCallMatches, _mock, { arguments = _args } )
    return lu.assertEquals(_status, true, string.format('%s\n%s', inspect(_result), inspect(_mock.calls)))
end

TestGremlinComms = {
    setUp = setUp,
    testDisplayMessageToAll = function()
        -- INIT
        trigger.action.outText:whenCalled({ with = { 'test all', 1 }, thenReturn = nil })
        trigger.action.outText:whenCalled({ with = { 'test neutral', 1 }, thenReturn = nil })
        trigger.action.outText:whenCalled({ with = { 'test nil', 1 }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.displayMessageTo('all', 'test all', 1), nil)
        lu.assertEquals(Gremlin.comms.displayMessageTo('Neutral', 'test neutral', 1), nil)
        lu.assertEquals(Gremlin.comms.displayMessageTo(nil, 'test nil', 1), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outText, { 'test all', 1 })
        assertMockCalledWith(trigger.action.outText, { 'test neutral', 1 })
        assertMockCalledWith(trigger.action.outText, { 'test nil', 1 })
    end,
    testDisplayMessageToCoalition = function()
        -- INIT
        trigger.action.outTextForCoalition:whenCalled({ with = { 1, 'test red', 1 }, thenReturn = nil })
        trigger.action.outTextForCoalition:whenCalled({ with = { 2, 'test blue', 1 }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.displayMessageTo('red', 'test red', 1), nil)
        lu.assertEquals(Gremlin.comms.displayMessageTo('blue', 'test blue', 1), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outTextForCoalition, { 1, 'test red', 1 })
        assertMockCalledWith(trigger.action.outTextForCoalition, { 2, 'test blue', 1 })
    end,
    testDisplayMessageToCountry = function()
        -- INIT
        trigger.action.outTextForCountry:whenCalled({ with = { 2, 'test USA', 1 }, thenReturn = nil })
        trigger.action.outTextForCountry:whenCalled({ with = { 0, 'test Russia', 1 }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.displayMessageTo('USA', 'test USA', 1), nil)
        lu.assertEquals(Gremlin.comms.displayMessageTo('Russia', 'test Russia', 1), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outTextForCountry, { 2, 'test USA', 1 })
        assertMockCalledWith(trigger.action.outTextForCountry, { 0, 'test Russia', 1 })
    end,
    testDisplayMessageToGroup = function()
        -- INIT
        trigger.action.outTextForGroup:whenCalled({ with = { 1, 'test group object', 1 }, thenReturn = nil })
        trigger.action.outTextForGroup:whenCalled({ with = { 2, 'test group name', 1 }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.displayMessageTo(_testGroup, 'test group object', 1), nil)
        lu.assertEquals(Gremlin.comms.displayMessageTo(_testGroup2.groupName, 'test group name', 1), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outTextForGroup, { 1, 'test group object', 1 })
        assertMockCalledWith(trigger.action.outTextForGroup, { 2, 'test group name', 1 })
    end,
    testDisplayMessageToUnit = function()
        -- INIT
        trigger.action.outTextForUnit:whenCalled({ with = { 1, 'test unit object', 1 }, thenReturn = nil })
        trigger.action.outTextForUnit:whenCalled({ with = { 1, 'test unit name', 1 }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.displayMessageTo(_testUnit, 'test unit object', 1), nil)
        lu.assertEquals(Gremlin.comms.displayMessageTo(_testUnit2.unitName, 'test unit name', 1), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outTextForUnit, { 1, 'test unit object', 1 })
        assertMockCalledWith(trigger.action.outTextForUnit, { 1, 'test unit name', 1 })
    end,
    testDisplayMessageToUnknown = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.comms.displayMessageTo('HammerTime', 'test unknown', 1), nil)

        -- SIDE EFFECTS
        assertSpyCalledWith(Gremlin.log.error,
            { Gremlin.Id, string.format("Can't find object named %s to display message to!\nMessage was: %s",
                tostring('HammerTime'), 'test unknown') })
    end,
    testPlayClipToAll = function()
        -- INIT
        trigger.action.outSound:whenCalled({ with = { 'test all' }, thenReturn = nil })
        trigger.action.outSound:whenCalled({ with = { 'test neutral' }, thenReturn = nil })
        trigger.action.outSound:whenCalled({ with = { 'test nil' }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.playClipTo('all', 'test all'), nil)
        lu.assertEquals(Gremlin.comms.playClipTo('Neutral', 'test neutral'), nil)
        lu.assertEquals(Gremlin.comms.playClipTo(nil, 'test nil'), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outSound, { 'test all' })
        assertMockCalledWith(trigger.action.outSound, { 'test neutral' })
        assertMockCalledWith(trigger.action.outSound, { 'test nil' })
    end,
    testPlayClipToCoalition = function()
        -- INIT
        trigger.action.outSoundForCoalition:whenCalled({ with = { 1, 'test red' }, thenReturn = nil })
        trigger.action.outSoundForCoalition:whenCalled({ with = { 2, 'test blue' }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.playClipTo('red', 'test red'), nil)
        lu.assertEquals(Gremlin.comms.playClipTo('blue', 'test blue'), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outSoundForCoalition, { 1, 'test red' })
        assertMockCalledWith(trigger.action.outSoundForCoalition, { 2, 'test blue' })
    end,
    testPlayClipToCountry = function()
        -- INIT
        trigger.action.outSoundForCountry:whenCalled({ with = { 2, 'test USA' }, thenReturn = nil })
        trigger.action.outSoundForCountry:whenCalled({ with = { 0, 'test Russia' }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.playClipTo('USA', 'test USA'), nil)
        lu.assertEquals(Gremlin.comms.playClipTo('Russia', 'test Russia'), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outSoundForCountry, { 2, 'test USA' })
        assertMockCalledWith(trigger.action.outSoundForCountry, { 0, 'test Russia' })
    end,
    testPlayClipToGroup = function()
        -- INIT
        trigger.action.outSoundForGroup:whenCalled({ with = { 1, 'test group object' }, thenReturn = nil })
        trigger.action.outSoundForGroup:whenCalled({ with = { 2, 'test group name' }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.playClipTo(_testGroup, 'test group object'), nil)
        lu.assertEquals(Gremlin.comms.playClipTo(_testGroup2.groupName, 'test group name'), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outSoundForGroup, { 1, 'test group object' })
        assertMockCalledWith(trigger.action.outSoundForGroup, { 2, 'test group name' })
    end,
    testPlayClipToUnit = function()
        -- INIT
        trigger.action.outSoundForUnit:whenCalled({ with = { 1, 'test unit object' }, thenReturn = nil })
        trigger.action.outSoundForUnit:whenCalled({ with = { 1, 'test unit name' }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.comms.playClipTo(_testUnit, 'test unit object'), nil)
        lu.assertEquals(Gremlin.comms.playClipTo(_testUnit2.unitName, 'test unit name'), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(trigger.action.outSoundForUnit, { 1, 'test unit object' })
        assertMockCalledWith(trigger.action.outSoundForUnit, { 1, 'test unit name' })
    end,
    testPlayClipToUnknown = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.comms.playClipTo('HammerTime', 'test unknown'), nil)

        -- SIDE EFFECTS
        assertSpyCalledWith(Gremlin.log.error, { Gremlin.Id, string.format("Can't find object named %s to play clip to!\nClip was: %s", tostring('HammerTime'), 'test unknown') })
    end,
    tearDown = tearDown,
}

TestGremlinEvents = {
    setUp = setUp,
    testOn = function()
        -- INIT
        local _testHandler = Spy(function() end)

        -- TEST
        lu.assertEquals(Gremlin.events.on('testEvent', _testHandler), 1)

        -- SIDE EFFECTS
        lu.assertEquals(Gremlin.events._handlers, { testEvent = { _testHandler } })
    end,
    testOff = function()
        -- INIT
        local _testHandler = Spy(function() end)
        Gremlin.events.on('testEvent', _testHandler)

        -- TEST
        lu.assertEquals(Gremlin.events.off('testEvent', 1), nil)

        -- SIDE EFFECTS
        lu.assertEquals(Gremlin.events._handlers, { testEvent = {} })
    end,
    testFire = function()
        -- INIT
        local _testHandler = Spy(function() end)
        Gremlin.events.on('testEvent', _testHandler)

        -- TEST
        lu.assertEquals(Gremlin.events.fire({ id = 'testEvent', params = {} }), nil)

        -- SIDE EFFECTS
        assertSpyCalledWith(_testHandler, { ValueMatcher.anyTable })
    end,
    tearDown = tearDown,
}

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

        missionCommands.addSubMenuForGroup:whenCalled({ with = { 1, Gremlin.Id }, thenReturn = { { Gremlin.Id } } })
        missionCommands.removeItemForGroup:whenCalled({ with = { 1, ValueMatcher.anyTable }, thenReturn = nil })
        for _, _command in pairs(_testCommands) do
            if type(_command.text) == 'function' then
                missionCommands.addCommandForGroup:whenCalled({ with = { 1, _command.text(), ValueMatcher.anyTable, ValueMatcher.anyFunction, ValueMatcher.anyTable }, thenReturn = { { Gremlin.Id, _command.text() }, _command.text() } })
            else
                missionCommands.addCommandForGroup:whenCalled({ with = { 1, _command.text, ValueMatcher.anyTable, ValueMatcher.anyFunction, ValueMatcher.anyTable }, thenReturn = { { Gremlin.Id, _command.text }, _command.text } })
            end
        end

        -- TEST
        lu.assertEquals(Gremlin.menu.updateF10(Gremlin.Id, _testCommands, {
            [_testUnit.unitName] = _testUnit,
            [_testUnit2.unitName] = _testUnit2,
        }), nil)

        -- SIDE EFFECTS
        assertMockCalledWith(missionCommands.addSubMenuForGroup, { 1, Gremlin.Id })

        for _, _command in pairs(_testCommands) do
            if _command.when == true then
                local _cmdText = _command.text
                if type(_cmdText) == 'function' then
                    _cmdText = _cmdText()
                end
                local _args = { 1, _cmdText, ValueMatcher.anyTable, ValueMatcher.anyFunction, ValueMatcher.anyTable }
                assertMockCalledWith(missionCommands.addCommandForGroup, _args)
            end
        end
    end,
    tearDown = tearDown,
}

TestGremlinUtils = {
    setUp = setUp,
    testCheckTriggerEvent = function()
        -- INIT
        local _testTriggerTrue = {
            type = 'event',
            value = { id = -1, filter = function() return true end},
        }
        local _testTriggerFalse = {
            type = 'event',
            value = { id = -1, filter = function() return false end},
        }

        -- TEST
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerTrue, 'event'), true)
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerFalse, 'event'), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testCheckTriggerFlag = function()
        -- INIT
        local _testTriggerTrue = {
            type = 'flag',
            value = 'True',
        }
        local _testTriggerFalse = {
            type = 'flag',
            value = 'False',
        }

        trigger.action.getUserFlag:whenCalled({ with = { 'True' }, thenReturn = { 1 } })
        trigger.action.getUserFlag:whenCalled({ with = { 'False' }, thenReturn = { 0 } })
        trigger.action.setUserFlag:whenCalled({ with = { 'True', ValueMatcher.anyBoolean }, thenReturn = nil })
        trigger.action.setUserFlag:whenCalled({ with = { 'False', ValueMatcher.anyBoolean }, thenReturn = nil })

        -- TEST
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerTrue, 'flag'), true)
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerFalse, 'flag'), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testCheckTriggerMenu = function()
        -- INIT
        local _testTriggerTrue = {
            type = 'menu',
            value = 'Test',
        }

        -- TEST
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerTrue, 'menu'), true)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testCheckTriggerRepeat = function()
        -- INIT
        local _testTriggerTrue = {
            type = 'repeat',
            value = { per = 0, period = Gremlin.Periods.Second },
        }
        local _testTriggerFalse = {
            type = 'repeat',
            value = { per = 100, period = Gremlin.Periods.Second },
        }

        -- TEST
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerTrue, 'repeat', 0), true)
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerFalse, 'repeat', 0), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testCheckTriggerTimeNumber = function()
        -- INIT
        local _testTriggerTrue = {
            type = 'time',
            value = 0,
        }
        local _testTriggerFalse = {
            type = 'time',
            value = 100,
        }

        -- TEST
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerTrue, 'time'), true)
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerFalse, 'time'), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testCheckTriggerTimeTable = function()
        -- INIT
        local _testTriggerTrue = {
            type = 'time',
            value = { after = 0, period = Gremlin.Periods.Second },
        }
        local _testTriggerFalse = {
            type = 'time',
            value = { after = 100, period = Gremlin.Periods.Second },
        }

        -- TEST
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerTrue, 'time'), true)
        lu.assertEquals(Gremlin.utils.checkTrigger(_testTriggerFalse, 'time'), false)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testCountTableEntries = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.countTableEntries({}), 0)
        lu.assertEquals(Gremlin.utils.countTableEntries({ 'test' }), 1)
        lu.assertEquals(Gremlin.utils.countTableEntries({ test = 'test' }), 1)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testGetUnitZones = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.getUnitZones(_testUnit.unitName), { _testZone })

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInspectNil = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.inspect(nil), 'nil')

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInnerSquash = function()
        -- INIT
        local _testTable = {
            a = { 'a', 'aa', 'aaa' },
            b = { 'b', 'bb', 'bbb' },
            c = { 'c', 'cc', 'ccc' },
        }

        -- TEST
        lu.assertEquals(Gremlin.utils.innerSquash(_testTable, 2), { a = 'aa', b = 'bb', c = 'cc' })

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInspectNumber = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.inspect(42), '42')

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInspectBoolean = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.inspect(true), 'true')
        lu.assertEquals(Gremlin.utils.inspect(false), 'false')

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInspectString = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.inspect('test'), "'test'")

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInspectTable = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.inspect({}), '{\n}')

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInspectFunction = function()
        -- INIT
        local _result = Gremlin.utils.inspect(Gremlin.utils.inspect)

        -- TEST
        lu.assertStrContains(_result, "%<function%> %{.+\n    %['short_src'%] = '.+\\src\\gremlin.lua',\n  }", true)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInspectThread = function()
        -- INIT
        local co = coroutine.create(function()
            print("hi")
        end)

        -- TEST
        lu.assertEquals(Gremlin.utils.inspect(co), '<thread> [opaque]')

        -- SIDE EFFECTS
        -- N/A?
    end,
    testInspectUserdata = function()
        -- INIT
        ---@diagnostic disable-next-line: deprecated
        local _userdata = newproxy(true)

        -- TEST
        lu.assertEquals(Gremlin.utils.inspect(_userdata), '<userdata> [opaque]')

        -- SIDE EFFECTS
        -- N/A?
    end,
    testIsInTable = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.isInTable({}, 'test'), false)
        lu.assertEquals(Gremlin.utils.isInTable({ 'test' }, 'test'), true)
        lu.assertEquals(Gremlin.utils.isInTable({ test = 'test' }, 'test'), true)

        -- SIDE EFFECTS
        -- N/A?
    end,
    testParseFuncArgs = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.parseFuncArgs({ '{unit}:name' }, { unit = _testUnit, group = _testGroup }), { _testUnit.unitName })
        lu.assertEquals(Gremlin.utils.parseFuncArgs({ '{group}:name' }, { unit = _testUnit, group = _testGroup }), { _testGroup.groupName })

        -- SIDE EFFECTS
        -- N/A?
    end,
    testMergeTables = function()
        -- INIT
        -- N/A?

        -- TEST
        lu.assertEquals(Gremlin.utils.mergeTables({ test1 = true, testOverwritten = false }, { test2 = true, testOverwritten = true }), { test1 = true, test2 = true, testOverwritten = true })

        -- SIDE EFFECTS
        -- N/A?
    end,
    tearDown = tearDown,
}
