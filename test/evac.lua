local lu = require("luaunit_3_4")
local inspect = require("inspect")
require("mocks.DCS")
require("mist_4_5_122")
require("gremlin")
require("evac")

table.unpack = table.unpack or unpack

Test1ZonesEvac = {
    test0Register = function()
        lu.assertEquals(Evac._state.zones.evac, {})
        lu.assertEquals(Evac.zones.evac.register("test", trigger.smokeColor.Green, 2), nil)
        lu.assertEquals(Evac._state.zones.evac, { test = { active = false, mode = 1, name = "test", side = 2, smoke = 0 } })
    end,
    test1Activate = function()
        lu.assertEquals(Evac._state.zones.evac, { test = { active = false, mode = 1, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.evac.activate("test"), nil)
        lu.assertEquals(Evac._state.zones.evac, { test = { active = true, mode = 1, name = "test", side = 2, smoke = 0 } })
    end,
    test2SetRemainingNumber = function()
        lu.assertEquals(Evac._state.extractableNow["test"], {})
        lu.assertEquals(Evac.zones.evac.setRemaining("test", 2, 2, 1), nil)
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #2"] = { name = "Evacuee: Refugee #2", type = "Refugee", unitId = 2 } })
    end,
    test3SetRemainingComposition = function()
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #2"] = { name = "Evacuee: Refugee #2", type = "Refugee", unitId = 2 } })
        lu.assertEquals(Evac.zones.evac.setRemaining("test", 2, 2, { {} }), nil)
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #3"] = { name = "Evacuee: Refugee #3", type = "Refugee", unitId = 3 } })
    end,
    test4Count = function()
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #3"] = { name = "Evacuee: Refugee #3", type = "Refugee", unitId = 3 } })
        lu.assertEquals(Evac.zones.evac.count("test"), 1)
    end,
    test5IsIn = function()
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #3"] = { name = "Evacuee: Refugee #3", type = "Refugee", unitId = 3 } })
        lu.assertEquals(Evac.zones.evac.isIn("Evacuee: Refugee #3"), true)
    end,
    test6Deactivate = function()
        lu.assertEquals(Evac._state.zones.evac, { test = { active = true, mode = 1, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.evac.deactivate("test"), nil)
        lu.assertEquals(Evac._state.zones.evac, { test = { active = false, mode = 1, name = "test", side = 2, smoke = 0 } })
    end,
    test7Unregister = function()
        lu.assertEquals(Evac._state.zones.evac, { test = { active = false, mode = 1, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.evac.unregister("test"), nil)
        lu.assertEquals(Evac._state.zones.evac, {})
    end,
}

Test2ZonesRelay = {
    test0Register = function()
        lu.assertEquals(Evac._state.zones.relay, {})
        lu.assertEquals(Evac.zones.relay.register("test", trigger.smokeColor.Green, 2), nil)
        lu.assertEquals(Evac._state.zones.relay, { test = { active = false, mode = 3, name = "test", side = 2, smoke = 0 } })
    end,
    test1Activate = function()
        lu.assertEquals(Evac._state.zones.relay, { test = { active = false, mode = 3, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.relay.activate("test"), nil)
        lu.assertEquals(Evac._state.zones.relay, { test = { active = true, mode = 3, name = "test", side = 2, smoke = 0 } })
    end,
    test2SetRemainingNumber = function()
        lu.assertEquals(Evac._state.extractableNow["test"], {})
        lu.assertEquals(Evac.zones.relay.setRemaining("test", 2, 2, 1), nil)
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #4"] = { name = "Evacuee: Refugee #4", type = "Refugee", unitId = 4 } })
    end,
    test3SetRemainingComposition = function()
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #4"] = { name = "Evacuee: Refugee #4", type = "Refugee", unitId = 4 } })
        lu.assertEquals(Evac.zones.relay.setRemaining("test", 2, 2, { {} }), nil)
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #5"] = { name = "Evacuee: Refugee #5", type = "Refugee", unitId = 5 } })
    end,
    test4Count = function()
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #5"] = { name = "Evacuee: Refugee #5", type = "Refugee", unitId = 5 } })
        lu.assertEquals(Evac.zones.relay.count("test"), 1)
    end,
    test5IsIn = function()
        lu.assertEquals(Evac._state.extractableNow["test"],
            { ["Evacuee: Refugee #5"] = { name = "Evacuee: Refugee #5", type = "Refugee", unitId = 5 } })
        lu.assertEquals(Evac.zones.relay.isIn("Evacuee: Refugee #5"), true)
    end,
    test6Deactivate = function()
        lu.assertEquals(Evac._state.zones.relay, { test = { active = true, mode = 3, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.relay.deactivate("test"), nil)
        lu.assertEquals(Evac._state.zones.relay, { test = { active = false, mode = 3, name = "test", side = 2, smoke = 0 } })
    end,
    test7Unregister = function()
        lu.assertEquals(Evac._state.zones.relay, { test = { active = false, mode = 3, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.relay.unregister("test"), nil)
        lu.assertEquals(Evac._state.zones.relay, {})
    end,
}

Test3ZonesSafe = {
    test0Register = function()
        lu.assertEquals(Evac._state.zones.safe, {})
        lu.assertEquals(Evac.zones.safe.register("test", trigger.smokeColor.Green, 2), nil)
        lu.assertEquals(Evac._state.zones.safe, { test = { active = false, mode = 2, name = "test", side = 2, smoke = 0 } })
    end,
    test1Activate = function()
        lu.assertEquals(Evac._state.zones.safe, { test = { active = false, mode = 2, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.safe.activate("test"), nil)
        lu.assertEquals(Evac._state.zones.safe, { test = { active = true, mode = 2, name = "test", side = 2, smoke = 0 } })
    end,
    test2Count = function()
        lu.assertEquals(Evac._state.extractableNow["test"], {})
        lu.assertEquals(Evac.zones.safe.count("test"), 0)
    end,
    test3IsIn = function()
        lu.assertEquals(Evac._state.extractableNow["test"], {})
        lu.assertEquals(Evac.zones.safe.isIn("Evacuee: Refugee #710"), false)
    end,
    test4Deactivate = function()
        lu.assertEquals(Evac._state.zones.safe, { test = { active = true, mode = 2, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.safe.deactivate("test"), nil)
        lu.assertEquals(Evac._state.zones.safe, { test = { active = false, mode = 2, name = "test", side = 2, smoke = 0 } })
    end,
    test5Unregister = function()
        lu.assertEquals(Evac._state.zones.safe, { test = { active = false, mode = 2, name = "test", side = 2, smoke = 0 } })
        lu.assertEquals(Evac.zones.safe.unregister("test"), nil)
        lu.assertEquals(Evac._state.zones.safe, {})
    end,
}

Test4Units = {
    setUp = function()
        local _testUnit = { className_ = "Unit", typeName = "UH-1H", unitName = "test", unitId = 1 }
        class(_testUnit, Unit)

        mist.DBs.unitsByName["test"] = _testUnit
        mist.DBs.units = { [2] = { [2] = { ["UH-1H"] = { { units = { _testUnit } } } } } }
        Evac._state.extractableNow["test"] = {}
        Evac._state.extractionUnits["test"] = {
            test = { name = "test", type = "Refugee", side = 2, text = "Evacuee: Refugee #1", unitId = 1 },
        }
    end,
    test1FindEvacuees = function()
        local _args = { mist.DBs.unitsByName["test"]:getGroup():getID(), "No Active Radio Beacons", 20 }

        trigger.action.outTextForGroup:whenCalled({ with = _args, thenReturn = nil })

        lu.assertEquals(Evac.units.findEvacuees("test"), nil)

        local _status, _result = pcall(
            trigger.action.outTextForGroup.assertAnyCallMatches,
            trigger.action.outTextForGroup,
            { arguments = _args }
        )
        lu.assertEquals(_status, true, _result)
    end,
    test2LoadEvacuees = function()
        local _args = { mist.DBs.unitsByName["test"]:getID(), "Your aircraft isn't rated for evacuees in this mission!", timer.getTime() + 5 }

        trigger.action.outTextForUnit:whenCalled({ with = _args, thenReturn = nil })

        lu.assertEquals(Evac.units.loadEvacuees("test"), nil)

        local _status, _result = pcall(
            trigger.action.outTextForUnit.assertAnyCallMatches,
            trigger.action.outTextForUnit,
            { arguments = _args }
        )
        lu.assertEquals(_status, true, _result)
    end,
    test3UnloadEvacuees = function()
        lu.assertEquals(Evac.units.unloadEvacuees("test"), nil)
    end,
    test4CountEvacuees = function()
        local _args = { mist.DBs.unitsByName["test"]:getID(), "You are currently carrying 0 evacuees.", timer.getTime() + 5 }

        trigger.action.outTextForUnit:whenCalled({ with = _args, thenReturn = nil })

        lu.assertEquals(Evac.units.countEvacuees("test"), nil)

        local _status, _result = pcall(
            trigger.action.outTextForUnit.assertAnyCallMatches,
            trigger.action.outTextForUnit,
            { arguments = _args }
        )
        lu.assertEquals(_status, true, _result)
    end,
    test5Count = function()
        lu.assertEquals(Evac.units.count("test"), 1)
    end,
    tearDown = function()
        Evac._state.extractionUnits["test"] = nil
        Evac._state.extractableNow["test"] = {}
        mist.DBs.units = {}
        mist.DBs.unitsByName["test"] = nil
    end,
}

Test5Groups = {
    testSpawn = function() end,
    testList = function() end,
    testCount = function() end,
}

Test6Internal1Aircraft = {
    testGetZone = function() end,
    testInZone = function() end,
    testInAir = function() end,
    testHeightDifference = function() end,
    testLoadEvacuees = function() end,
    testCountEvacuees = function() end,
    testCalculateWeight = function() end,
    testAdaptWeight = function() end,
    testUnloadEvacuees = function() end,
}

Test6Internal2Beacons = {
    testSpawn = function() end,
    testGetFreeADFFrequencies = function() end,
    testList = function() end,
    testUpdate = function() end,
    testKillDead = function() end,
    testGenerateVHFrequencies = function() end,
    testGenerateUHFrequencies = function() end,
    testGenerateFMFrequencies = function() end,
}

Test6Internal3Smoke = {
    testRefresh = function() end,
}

Test6Internal4Zones = {
    testRegister = function() end,
    testGenerateEvacuees = function() end,
    testActivate = function() end,
    testSetRemaining = function() end,
    testCount = function() end,
    testIsIn = function() end,
    testDeactivate = function() end,
    testUnregister = function() end,
}

Test6Internal5Menu = {
    testAddToF10 = function() end,
}

Test6Internal6Utils = {
    testGetNextGroupId = function() end,
    testGetNextUnitId = function() end,
    testRandomizeWeight = function() end,
    testUnitDataToList = function() end,
}

Test7TopLevel = {
    testOnEvent = function() end,
    testSetup = function() end,
}

os.exit(lu.LuaUnit.run())
