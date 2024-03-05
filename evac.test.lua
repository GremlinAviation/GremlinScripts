local lu = require("luaunit_3_4")
require("DCS_header_extracted")
require("mist_4_5_122")
require("evac")

TestEvacExists = function()
    lu.assertNotIsNil(Evac, "Evac not properly loaded!")
end

TestZonesEvac = {
    testCreate = function()
        lu.assertEquals(Evac.zones.evac.create("test", trigger.smokeColor.Green, 2), nil)
    end
}

os.exit(lu.LuaUnit.run())
