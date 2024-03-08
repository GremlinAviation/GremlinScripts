local inspect = require("inspect")
local log = mist.Logger:new("Gremlin Scripts", "info")

Gremlin = {
    Id = "Gremlin Script Tools",
    Version = "202403.01",

    -- Config
    Debug = false,
    Trace = false,

    -- Internal State
    alreadyInitialized = false,
    haveCSAR = false,
    haveCTLD = false,

    -- Enums
    Periods = {
        Second = 1,
        Minute = 60,
        Hour = 3600,
        Day = 86400,
    },
    SideToText = {
        [0] = "Neutral",
        [1] = "Red",
        [2] = "Blue",
    },

    -- Methods
    logError = function(toolId, message)
        log:error((toolId or Gremlin.Id) .. " | " .. message)
    end,
    logWarn = function(toolId, message)
        log:warn((toolId or Gremlin.Id) .. " | " .. message)
    end,
    logInfo = function(toolId, message)
        log:info((toolId or Gremlin.Id) .. " | " .. message)
    end,
    logDebug = function(toolId, message)
        if message and Gremlin.Debug then
            log:info((toolId or Gremlin.Id) .. " | " .. message)
        end
    end,
    logTrace = function(toolId, message)
        if message and Gremlin.Trace then
            log:info((toolId or Gremlin.Id) .. " | " .. message)
        end
    end,
    displayMessageTo = function(_name, _text, _time)
        if _name == "all" or _name == nil then
            trigger.action.outText(_text, _time)
        elseif coalition.side[_name] ~= nil then
            trigger.action.outTextForCoalition(coalition.side[_name], _text, _time)
        elseif country.by_country[_name] ~= nil then
            trigger.action.outTextForCountry(country.by_country[_name].WorldID, _text, _time)
        elseif type(_name) == "table" and _name.className_ == "Group" then
            trigger.action.outTextForGroup(_name:getID(), _text, _time)
        elseif mist.DBs.groupsByName[_name] ~= nil then
            trigger.action.outTextForGroup(mist.DBs.groupsByName[_name]:getID(), _text, _time)
        elseif type(_name) == "table" and _name.className_ == "Unit" then
            trigger.action.outTextForUnit(_name:getID(), _text, _time)
        elseif mist.DBs.unitsByName[_name] ~= nil then
            trigger.action.outTextForUnit(mist.DBs.unitsByName[_name]:getID(), _text, _time)
        else
            Gremlin.logError(Gremlin.Id, "Can't find object named " .. inspect(_name) .. " to display message to!\nMessage was: " .. _text)
        end
    end,
    parseFuncArgs = function (_args, _objs)
        local _out = {}
        for _, _arg in pairs(_args) do
            if type(_arg) == "string" then
                if string.sub(_arg, 1, 7) == "{unit}:" then
                    local _key = string.sub(_arg, 8)

                    table.insert(_out, _objs.unit[_key])
                elseif string.sub(_arg, 1, 8) == "{group}:" then
                    local _key = string.sub(_arg, 9)

                    table.insert(_out, _objs.group[_key])
                else
                    table.insert(_out, _arg)
                end
            else
                table.insert(_out, _arg)
            end
        end

        return _out
    end
}

function Gremlin:setup(config)
    assert(mist ~= nil,
        "\n\n** HEY MISSION-DESIGNER! **\n\nMission Script Tools (MiST) has not been loaded!\n\nMake sure MiST is running *before* running this script!\n")

    if Gremlin.alreadyInitialized and not config.forceReload then
        Gremlin.logInfo(Gremlin.Id, string.format("Bypassing initialization because Gremlin.alreadyInitialized = true"))
        return
    end

    ---@diagnostic disable-next-line: undefined-global
    if csar ~= nil then
        Gremlin.haveCSAR = true
    end

    ---@diagnostic disable-next-line: undefined-global
    if ctld ~= nil then
        Gremlin.haveCTLD = true
    end

    if config ~= nil then
        if config.debug ~= nil then
            Gremlin.Debug = config.debug
        end

        if config.trace ~= nil then
            Gremlin.Trace = config.trace
        end
    end

    Gremlin.alreadyInitialized = true
end
