local lu = require("luaunit_3_4")

local PATH = string.gsub(debug.getinfo(1).source, "^@(.+[\\/])[^\\/]+$", "%1");

local testName
if #arg > 0 then
    testName = arg[1]
    if testName == nil or testName == "" then
        testName = "all"
    end
    table.remove(arg, 1)
else
    testName = "all"
end

local testsLoaded = false

if testName == "gremlin" or testName == "all" then
    dofile(PATH .. "gremlin.lua")
    testsLoaded = true
end
if testName == "evac" or testName == "all" then
    dofile(PATH .. "evac.lua")
    testsLoaded = true
end
if testName == "urgency" or testName == "all" then
    dofile(PATH .. "urgency.lua")
    testsLoaded = true
end
if testName == "waves" or testName == "all" then
    dofile(PATH .. "waves.lua")
    testsLoaded = true
end

if testsLoaded then
    os.exit(lu.LuaUnit.run())
else
    io.stderr:write("Sorry, but we don't have any tests for the '" .. testName .. "' script")
    os.exit(1)
end
