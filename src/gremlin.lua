--[[--
Gremlin.

DO NOT EDIT THIS SCRIPT DIRECTLY! Things WILL break that way.

Instead, pass a table to `Gremlin:setup()` with any options you wish to configure.

@module Gremlin
--]]--

if table.unpack == nil then
    table.unpack = unpack
end

Gremlin = {
    Id = 'Gremlin',
    Version = '202404.01',

    -- Config
    Debug = false,
    Trace = false,

    -- Internal State
    alreadyInitialized = false,
    haveCSAR = false,
    haveCTLD = false,
    haveMiST = false,
    haveMOOSE = false,

    --- Enums.
    --
    -- @section Enums

    --- Time period "constants", in seconds.
    --
    -- @table Gremlin.Periods
    Periods = {
        Second = 1, -- 1 second
        Minute = 60, -- 1 minute
        Hour = 3600, -- 1 hour
        Day = 86400, -- 1 day
    },
    --- Coalition name from ID.
    --
    -- @table Gremlin.SideToText
    SideToText = {
        [0] = 'Neutral', -- Neutral
        [1] = 'Red', -- Red
        [2] = 'Blue', -- Blue
    },

    --- Comms.
    -- Methods for handling communications with players.
    --
    -- @section Comms
    comms = {
        --- Display message to target.
        -- Finds a target by name, and then sends a text message.
        --
        -- @function Gremlin.comms.displayMessageTo
        -- @tparam string|Unit|Group _name  The name of the target to send a message to
        -- @tparam string            _text  The text to send
        -- @tparam number            _time  How long before the message should be dismissed
        displayMessageTo = function(_name, _text, _time)
            if _name == 'all' or _name == 'Neutral' or _name == nil then
                trigger.action.outText(_text, _time)
            elseif type(_name) == 'string' and coalition.side[string.upper(_name)] ~= nil then
                trigger.action.outTextForCoalition(coalition.side[string.upper(_name)], _text, _time)
            elseif type(_name) == 'string' and country[string.upper(_name)] ~= nil then
                trigger.action.outTextForCountry(country[string.upper(_name)], _text, _time)
            elseif type(_name) == 'table' and _name.className_ == 'Group' then
                trigger.action.outTextForGroup(_name:getID(), _text, _time)
            elseif type(_name) == 'string' and Group.getByName(_name) ~= nil then
                trigger.action.outTextForGroup(Group.getByName(_name):getID(), _text, _time)
            elseif type(_name) == 'table' and _name.className_ == 'Unit' then
                trigger.action.outTextForUnit(_name:getID(), _text, _time)
            elseif type(_name) == 'string' and Unit.getByName(_name) ~= nil then
                trigger.action.outTextForUnit(Unit.getByName(_name):getID(), _text, _time)
            else
                Gremlin.log.error(Gremlin.Id, string.format("Can't find object named %s to display message to!\nMessage was: %s", tostring(_name), _text))
            end
        end,
        --- Play sound file for target.
        -- Finds a target by name, then plays a sound file.
        --
        -- @function Gremlin.comms.playClipTo
        -- @tparam string|Unit|Group _name  The name of the target to play sound to
        -- @tparam string            _path  The filename of the audio clip to play
        playClipTo = function(_name, _path)
            if _name == 'all' or _name == 'Neutral' or _name == nil then
                trigger.action.outSound(_path)
            elseif type(_name) == 'string' and coalition.side[string.upper(_name)] ~= nil then
                trigger.action.outSoundForCoalition(coalition.side[string.upper(_name)], _path)
            elseif type(_name) == 'string' and country[string.upper(_name)] ~= nil then
                trigger.action.outSoundForCountry(country[string.upper(_name)], _path)
            elseif type(_name) == 'table' and _name.className_ == 'Group' then
                trigger.action.outSoundForGroup(_name:getID(), _path)
            elseif type(_name) == 'string' and Group.getByName(_name) ~= nil then
                trigger.action.outSoundForGroup(Group.getByName(_name):getID(), _path)
            elseif type(_name) == 'table' and _name.className_ == 'Unit' then
                trigger.action.outSoundForUnit(_name:getID(), _path)
            elseif type(_name) == 'string' and Unit.getByName(_name) ~= nil then
                trigger.action.outSoundForUnit(Unit.getByName(_name):getID(), _path)
            else
                Gremlin.log.error(Gremlin.Id, string.format("Can't find object named %s to play clip to!\nClip was: %s", tostring(_name), _path))
            end
        end,
    },
    --- Events.
    -- Methods for handling and firing events.
    --
    -- @section Events
    events = {
        _globalHandlers = {
            logEvents = {
                enabled = false,
                event = -1,
                fn = function(_event)
                    Gremlin.log.debug(Gremlin.Id, string.format('%s: %s\n', Gremlin.events.idToName[_event.id] or _event.id, Gremlin.utils.inspect(_event)))
                end
            },
        },
        --- Event name lookup.
        -- Not populated until setup is complete!
        --
        -- @table Gremlin.events.idToName
        idToName = {},
        _handlers = {},
        --- Register an event handler.
        --
        -- @function Gremlin.events.on
        -- @tparam  integer  _eventId  The DCS event ID to listen for
        -- @tparam  function _fn       The event handler to register
        -- @treturn integer            The handler index for later removal
        on = function(_eventId, _fn)
            if Gremlin.events._handlers[_eventId] == nil then
                Gremlin.events._handlers[_eventId] = {}
            end

            table.insert(Gremlin.events._handlers[_eventId], _fn)

            return #Gremlin.events._handlers[_eventId]
        end,
        --- Unregister an event handler.
        --
        -- @function Gremlin.events.off
        -- @tparam  integer  _eventId  The DCS event ID to stop listening for
        -- @tparam  integer  _index    The handler index to remove
        off = function(_eventId, _index)
            if Gremlin.events._handlers[_eventId] ~= nil and #Gremlin.events._handlers[_eventId] >= 0 then
                Gremlin.events._handlers[_eventId][_index] = nil
            end
        end,
        --- Fire an event.
        -- NOTE: Only works between scripts that register handlers.
        -- It cannot send events back to DCS proper.
        --
        -- @function Gremlin.events.fire
        -- @tparam table _event The event object to send to all relevant Gremlin handlers
        fire = function(_event)
            Gremlin.events._handler(_event)
        end,
        _handler = function(_event)
            for _, _handler in pairs(Gremlin.utils.mergeTables(Gremlin.events._handlers[_event.id] or {}, Gremlin.events._handlers[-1] or {})) do
                _handler(_event)
            end
        end,
    },
    --- Logging.
    -- Methods for logging things.
    --
    -- @section Log
    log = {
        --- Log a message at the error level.
        --
        -- @function Gremlin.log.error
        -- @tparam string toolId   The string identifying the source of the message
        -- @tparam string message  The message to log
        error = function(toolId, message)
            local _toolId = toolId
            local _message = message
            if _message == nil then
                _toolId = Gremlin.Id
                _message = toolId
            end
            env.error(tostring(_toolId) .. ' | ' .. tostring(timer.getTime()) .. ' | ' .. tostring(message))
        end,
        --- Log a message at the warn level.
        --
        -- @function Gremlin.log.warn
        -- @tparam string toolId   The string identifying the source of the message
        -- @tparam string message  The message to log
        warn = function(toolId, message)
            local _toolId = toolId
            local _message = message
            if _message == nil then
                _toolId = Gremlin.Id
                _message = toolId
            end
            env.warning(tostring(_toolId) .. ' | ' .. tostring(timer.getTime()) .. ' | ' .. tostring(message))
        end,
        --- Log a message at the info level.
        --
        -- @function Gremlin.log.info
        -- @tparam string toolId   The string identifying the source of the message
        -- @tparam string message  The message to log
        info = function(toolId, message)
            local _toolId = toolId
            local _message = message
            if _message == nil then
                _toolId = Gremlin.Id
                _message = toolId
            end
            env.info(tostring(_toolId) .. ' | ' .. tostring(timer.getTime()) .. ' | ' .. tostring(message))
        end,
        --- Log a message at the debug level.
        --
        -- @function Gremlin.log.debug
        -- @tparam string toolId   The string identifying the source of the message
        -- @tparam string message  The message to log
        debug = function(toolId, message)
            if Gremlin.Debug then
                local _toolId = toolId
                local _message = message
                if _message == nil then
                    _toolId = Gremlin.Id
                    _message = toolId
                end
                env.info('DEBUG: ' .. tostring(_toolId) .. ' | ' .. tostring(timer.getTime()) .. ' | ' .. tostring(message))
            end
        end,
        --- Log a message at the trace level.
        --
        -- @function Gremlin.log.trace
        -- @tparam string toolId   The string identifying the source of the message
        -- @tparam string message  The message to log
        trace = function(toolId, message)
            if Gremlin.Trace then
                local _toolId = toolId
                local _message = message
                if _message == nil then
                    _toolId = Gremlin.Id
                    _message = toolId
                end
                env.info('TRACE: ' .. tostring(_toolId) .. ' | ' .. tostring(timer.getTime()) .. ' | ' .. tostring(message))
            end
        end
    },
    --- Menu.
    -- Methods for setting up menus and keeping them up to date.
    --
    -- @section Menu
    menu = {
        --- Update the F10 menu.
        --
        -- @function Gremlin.menu.updateF10
        -- @tparam string toolId    A string indicating the top level menu to create
        -- @tparam table  commands  A table of menu items to sync
        -- @tparam table  forUnits  A list of units who should be given menu access
        updateF10 = function(toolId, commands, forUnits)
            Gremlin.log.trace(Gremlin.Id, string.format('Updating F10 Menu For %i Units', Gremlin.utils.countTableEntries(forUnits)))

            for _unitName, _extractor in pairs(forUnits) do
                local _unit = _extractor or Unit.getByName(_unitName)
                if _unit ~= nil and _unit.isExist ~= nil and _unit:isExist() then
                    local _groupId = _unit:getGroup():getID()
                    local _groupName = _unit:getGroup():getName()

                    local _rootPath
                    if Gremlin._state.menuAdded[toolId] == nil then
                        Gremlin._state.menuAdded[toolId] = {}
                    end
                    if Gremlin._state.menuAdded[toolId][_groupId] == nil then
                        _rootPath = missionCommands.addSubMenuForGroup(_groupId, toolId)
                        Gremlin._state.menuAdded[toolId][_groupId] = { root = _rootPath }
                        Gremlin.log.trace(Gremlin.Id, string.format('Added Root Menu For %s', toolId))
                    else
                        _rootPath = Gremlin._state.menuAdded[toolId][_groupId].root
                    end

                    for _cmdIdx, _command in pairs(commands) do
                        local _when = false
                        if type(_command.when) == 'boolean' then
                            _when = _command.when
                        elseif type(_command.when) == 'table' then
                            ---@diagnostic disable-next-line: undefined-field
                            local _whenArgs = Gremlin.utils.parseFuncArgs(_command.when.args, {
                                unit = _unit,
                                group = _unit:getGroup()
                            })

                            ---@diagnostic disable-next-line: undefined-field
                            if _command.when.func(table.unpack(_whenArgs)) == _command.when.value and _command.when.comp == 'equal' then
                                _when = true
                            ---@diagnostic disable-next-line: undefined-field
                            elseif _command.when.func(table.unpack(_whenArgs)) ~= _command.when.value and _command.when.comp == 'inequal' then
                                _when = true
                            end
                        end

                        if Gremlin._state.menuAdded[toolId][_groupId][_cmdIdx] ~= nil then
                            missionCommands.removeItemForGroup(_groupId, Gremlin._state.menuAdded[toolId][_groupId][_cmdIdx])
                        end

                        local _args = Gremlin.utils.parseFuncArgs(_command.args, {
                            unit = _unit,
                            group = _unit:getGroup()
                        })
                        if _when then
                            if type(_command.text) == "string" then
                                Gremlin._state.menuAdded[toolId][_groupId][_cmdIdx] = missionCommands.addCommandForGroup(_groupId, _command.text, _rootPath, function(_args) _command.func(table.unpack(_args)) end, _args)
                                Gremlin.log.trace(Gremlin.Id, string.format('Added Menu Item To Group %s (%s) : "%s"', _groupName, _unitName, _command.text))
                            else
                                Gremlin._state.menuAdded[toolId][_groupId][_cmdIdx] = missionCommands.addCommandForGroup(_groupId, _command.text(table.unpack(_args)), _rootPath, function(_args) _command.func(table.unpack(_args)) end, _args)
                                Gremlin.log.trace(Gremlin.Id, string.format('Added Menu Item To Group %s (%s) : "%s"', _groupName, _unitName, _command.text(table.unpack(_args))))
                            end
                        end
                    end
                end
            end
        end,
    },
    --- Utils.
    -- Methods for miscellaneous script activities.
    --
    -- @section Utils
    utils = {
        --- Check whether a trigger condition has been met.
        --
        -- @tparam  table  _trigger  The trigger definition table to check against
        -- @tparam  string _type     The trigger type to check for
        -- @tparam  any    _extra    Any extra data needed to perform the check, or nil
        -- @treturn boolean          Whether the trigger condition has been met
        checkTrigger = function(_trigger, _type, _extra)
            if _trigger.type == _type then
                if _trigger.type == 'event' then
                    return (_extra == nil or _extra == -1 or _trigger.value.id == _extra.id) and _trigger.value.filter(_extra or { id = -1 })
                elseif _trigger.type == 'flag' then
                    local _val = trigger.action.getUserFlag(_trigger.value)
                    trigger.action.setUserFlag(_trigger.value, false)

                    return _val > 0
                elseif _trigger.type == 'menu' then
                    return true
                elseif _trigger.type == 'repeat' then
                    return (_extra + (math.abs(_trigger.value.per) * _trigger.value.period)) <= timer.getTime()
                elseif _trigger.type == 'time' then
                    local _val
                    if type(_trigger.value) == 'number' then
                        _val = _trigger.value
                    else
                        _val = math.abs(_trigger.value.after or 0) * (_trigger.value.period or 0)
                    end

                    return _val <= timer.getTime()
                end
            end

            return false
        end,
        --- Count items in a table, numeric or otherwise.
        --
        -- @function Gremlin.utils.countTableEntries
        -- @tparam  table _tbl  The table to count entries within
        -- @treturn integer     The number of items in the table
        countTableEntries = function (_tbl)
            local _count = 0
            for _, _ in pairs(_tbl) do
                _count = _count + 1
            end
            return _count
        end,
        --- Get a list of zones a unit is in.
        --
        -- @function Gremlin.utils.getUnitZones
        -- @tparam  string _unit  The unit whose zones should be retrieved
        -- @treturn table         The list of unit zones
        getUnitZones = function(_unit)
            Gremlin.log.trace(Gremlin.Id, string.format('Grabbing Unit Zone Names : %s', _unit))

            local _outZones = {}
            local _unitObj = Unit.getByName(_unit)

            if _unitObj ~= nil then
                local _unitPoint = _unitObj:getPoint()

                for _zoneName, _ in pairs(mist.DBs.zonesByName) do
                    if mist.pointInZone(_unitPoint, _zoneName) then
                        table.insert(_outZones, _zoneName)
                    end
                end
            end

            return _outZones
        end,
        --- Flattens a table by removing the second level, rather than the first
        --
        -- @tparam  table         _tbl  The table to flatten
        -- @tparam  string|number _idx  The inner index to extract
        -- @treturn table               The flattened table
        innerSquash = function(_tbl, _idx)
            local _outTbl = {}

            for _key, _intermediate in pairs(_tbl) do
                _outTbl[_key] = _intermediate[_idx]
            end

            return _outTbl
        end,
        --- Get a mostly-Lua representation of a value.
        --
        -- @function Gremlin.utils.inspect
        -- @tparam  any     _value  The value to inspect
        -- @tparam  integer _depth  How deep we've already inspected; should be 0 or nil
        -- @treturn string          A string representation of the value
        inspect = function(_value, _depth)
            if _depth == nil then
                _depth = 0
            end

            if type(_value) == 'nil' then
                return 'nil'
            elseif type(_value) == 'number' or type(_value) == 'boolean' then
                return tostring(_value)
            elseif type(_value) == 'string' then
                return string.format("'%s'", _value)
            elseif type(_value) == 'table' then
                if _depth > 5 then
                    return '...'
                end

                local _contents = ''

                for _key, _val in pairs(_value) do
                    _contents = string.format('%s%s[%s] = %s,\n', _contents, string.rep('  ', _depth + 1), Gremlin.utils.inspect(_key, _depth + 1), Gremlin.utils.inspect(_val, _depth + 1))
                end

                return string.format('{\n%s%s}', _contents, string.rep('  ', _depth))
            elseif type(_value) == 'function' then
                return string.format('<function> %s', Gremlin.utils.inspect(debug.getinfo(_value), _depth + 1))
            elseif type(_value) == 'thread' or type(_value) == 'userdata' then
                return string.format('<%s> [opaque]', type(_value))
            end
        end,
        --- Searches a table for a value.
        --
        -- @function Gremlin.utils.isInTable
        -- @tparam  table _tbl     The table to search
        -- @tparam  any   _needle  The value to find
        -- @treturn boolean        Whether the needle was in the haystack
        isInTable = function(_tbl, _needle)
            for _, _straw in pairs(_tbl) do
                if _straw == _needle then
                    return true
                end
            end

            return false
        end,
        --- Parse arguments for things like menus.
        --
        -- @function Gremlin.utils.parseFuncArgs
        -- @tparam  table _args  The arguments to parse
        -- @tparam  table _objs  Values for substitution
        -- @treturn table        The final (usable) arguments
        parseFuncArgs = function(_args, _objs)
            local _out = {}
            for _, _arg in pairs(_args) do
                if type(_arg) == 'string' then
                    if string.sub(_arg, 1, 7) == '{unit}:' then
                        local _key = string.sub(_arg, 8)

                        Gremlin.log.trace(Gremlin.Id, string.format('Parsing Unit : %s, %s', _key, Gremlin.utils.inspect(_objs.unit)))

                        if _key == 'name' then
                            table.insert(_out, _objs.unit:getName())
                        else
                            table.insert(_out, _objs.unit[_key])
                        end
                    elseif string.sub(_arg, 1, 8) == '{group}:' then
                        local _key = string.sub(_arg, 9)

                        Gremlin.log.trace(Gremlin.Id, string.format('Parsing Group : %s, %s', _key, Gremlin.utils.inspect(_objs.group)))

                        if _key == 'name' then
                            table.insert(_out, _objs.group:getName())
                        else
                            table.insert(_out, _objs.group[_key])
                        end
                    else
                        Gremlin.log.trace(Gremlin.Id, string.format('Bare String : %s', _arg))

                        table.insert(_out, _arg)
                    end
                else
                    Gremlin.log.trace(Gremlin.Id, string.format('Raw Value : %s, %s', type(_arg), mist.utils.basicSerialize(_arg)))

                    table.insert(_out, _arg)
                end
            end

            return _out
        end,
        --- Combine two tables together.
        -- Doesn't care about integer versus string keys.
        --
        -- @function Gremlin.utils.mergeTables
        -- @tparam  table ...  One or more tables to combine together
        -- @treturn table      The final combined result
        mergeTables = function(...)
            local tbl1 = {}

            for _, tbl2 in pairs({...}) do
                for k, v in pairs(tbl2) do
                    if type(k) == 'number' then
                        table.insert(tbl1, v)
                    else
                        tbl1[k] = v
                    end
                end
            end

            return tbl1
        end,
        --- Calculate the positions of units to spawn.
        --
        -- @function Gremlin.utlis.spawnPoints
        -- @tparam number       _angle
        -- @tparam number|table _scatterRadius
        -- @tparam number       _counter
        -- @treturn number, number
        spawnPoints = function(_angle, _scatterRadius)
            local _xOffset, _yOffset

            if type(_scatterRadius) == 'table' then
                local _realRadius = math.min(math.max(_scatterRadius.max * math.sqrt(math.random()), _scatterRadius.min), _scatterRadius.max)
                _xOffset = math.cos(_angle) * _realRadius
                _yOffset = math.sin(_angle) * _realRadius
            else
                local _realRadius = _scatterRadius * math.sqrt(math.random())
                _xOffset = math.cos(_angle) * _realRadius
                _yOffset = math.sin(_angle) * _realRadius
            end

            return _xOffset, _yOffset
        end,
    },

    -- Internal State
    _state = {
        menuAdded = {},
    },
}

--- Top Level methods.
--
-- @section TopLevel

--- Setup Gremlin.
--
-- @function Gremlin:setup
-- @tparam table config  The settings table to configure Gremlin using
function Gremlin:setup(config)
    if Gremlin.alreadyInitialized and not config.forceReload then
        Gremlin.log.info(Gremlin.Id, string.format('Bypassing initialization because Gremlin.alreadyInitialized = true'))
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

    ---@diagnostic disable-next-line: undefined-global
    if mist ~= nil then
        Gremlin.haveMiST = true
    end

    ---@diagnostic disable-next-line: undefined-global
    if BASE ~= nil then
        Gremlin.haveMOOSE = true
    end

    if config ~= nil then
        if config.debug ~= nil then
            Gremlin.Debug = config.debug
        end

        if config.trace ~= nil then
            Gremlin.Trace = config.trace
        end

        for _name, _def in pairs(Gremlin.events._globalHandlers) do
            if _def.enabled or (config.optionalFeatures ~= nil and config.optionalFeatures[_name] == true) then
                Gremlin.events.on(_def.event, _def.fn)

                Gremlin.log.debug(Gremlin.Id, string.format('Registered %s event handler', _name))
            end
        end
    end

    for _name, _id in pairs(world.event) do
        Gremlin.events.idToName[_id] = _name
    end

    do
        local handler = {}
        function handler:onEvent(event)
            Gremlin.events._handler(event)
        end
        world.addEventHandler(handler)
    end

    Gremlin.alreadyInitialized = true
end
