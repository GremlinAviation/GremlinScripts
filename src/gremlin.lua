if table.unpack == nil then
    table.unpack = unpack
end

Gremlin = {
    Id = 'Gremlin Script Tools',
    Version = '202403.01',

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
        Day = 86400
    },
    SideToText = {
        [0] = 'Neutral',
        [1] = 'Red',
        [2] = 'Blue'
    },

    -- Methods
    events = {
        _globalHandlers = {
            logEvents = {
                enabled = false,
                event = -1,
                fn = function(_event)
                    Gremlin.log.debug(Gremlin.Id, string.format('%s: %s\n', Gremlin.events.idToName[_event.id], mist.utils.tableShowSorted(_event)))
                end
            },
        },
        idToName = {},
        _handlers = {},
        on = function(_eventId, _fn)
            if Gremlin.events._handlers[_eventId] == nil then
                Gremlin.events._handlers[_eventId] = {}
            end

            table.insert(Gremlin.events._handlers[_eventId], _fn)

            return #Gremlin.events._handlers[_eventId]
        end,
        off = function(_eventId, _index)
            if Gremlin.events._handlers[_eventId] ~= nil and #Gremlin.events._handlers[_eventId] >= 0 then
                Gremlin.events._handlers[_eventId][_index] = nil
            end
        end,
        _handler = function(_event)
            for _, _handler in pairs(Gremlin.utils.mergeTables(Gremlin.events._handlers[_event.id] or {},
                Gremlin.events._handlers[-1] or {})) do
                _handler(_event)
            end
        end
    },
    log = {
        error = function(toolId, message)
            local _toolId = toolId
            local _message = message
            if _message == nil then
                _toolId = Gremlin.Id
                _message = toolId
            end
            env.error(tostring(_toolId) .. ' | ' .. tostring(message))
        end,
        warn = function(toolId, message)
            local _toolId = toolId
            local _message = message
            if _message == nil then
                _toolId = Gremlin.Id
                _message = toolId
            end
            env.warning(tostring(_toolId) .. ' | ' .. tostring(message))
        end,
        info = function(toolId, message)
            local _toolId = toolId
            local _message = message
            if _message == nil then
                _toolId = Gremlin.Id
                _message = toolId
            end
            env.info(tostring(_toolId) .. ' | ' .. tostring(message))
        end,
        debug = function(toolId, message)
            if Gremlin.Debug then
                local _toolId = toolId
                local _message = message
                if _message == nil then
                    _toolId = Gremlin.Id
                    _message = toolId
                end
                env.info('DEBUG: ' .. tostring(_toolId) .. ' | ' .. tostring(message))
            end
        end,
        trace = function(toolId, message)
            if Gremlin.Trace then
                local _toolId = toolId
                local _message = message
                if _message == nil then
                    _toolId = Gremlin.Id
                    _message = toolId
                end
                env.info('TRACE: ' .. tostring(_toolId) .. ' | ' .. tostring(message))
            end
        end
    },
    menu = {
        updateF10 = function(args)
            local toolId, commands, getForUnits = table.unpack(args)
            local forUnits = getForUnits()

            Gremlin.log.trace(Gremlin.Id, string.format('Updating F10 Menu For %i Units', Gremlin.utils.countTableEntries(forUnits)))

            timer.scheduleFunction(Gremlin.menu.updateF10, {toolId, commands, forUnits}, timer.getTime() + 10)

            for _unitName, _extractor in pairs(forUnits) do
                local _unit = _extractor or Unit.getByName(_unitName)
                if _unit ~= nil and _unit:isExist() then
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
    utils = {
        countTableEntries = function (_tbl)
            local _count = 0
            for _, _ in pairs(_tbl) do
                _count = _count + 1
            end
            return _count
        end,
        displayMessageTo = function(_name, _text, _time)
            if _name == 'all' or _name == 'Neutral' or _name == nil then
                trigger.action.outText(_text, _time)
            elseif coalition.side[_name] ~= nil then
                trigger.action.outTextForCoalition(coalition.side[_name], _text, _time)
            elseif country.by_country[_name] ~= nil then
                trigger.action.outTextForCountry(country.by_country[_name].WorldID, _text, _time)
            elseif type(_name) == 'table' and _name.className_ == 'Group' then
                trigger.action.outTextForGroup(_name:getID(), _text, _time)
            elseif Group.getByName(_name) ~= nil then
                trigger.action.outTextForGroup(Group.getByName(_name):getID(), _text, _time)
            elseif type(_name) == 'table' and _name.className_ == 'Unit' then
                trigger.action.outTextForUnit(_name:getID(), _text, _time)
            elseif Unit.getByName(_name) ~= nil then
                trigger.action.outTextForUnit(Unit.getByName(_name):getID(), _text, _time)
            else
                Gremlin.log.error(Gremlin.Id, "Can't find object named " .. tostring(_name) ..
                    ' to display message to!\nMessage was: ' .. _text)
            end
        end,
        parseFuncArgs = function(_args, _objs)
            local _out = {}
            for _, _arg in pairs(_args) do
                if type(_arg) == 'string' then
                    if string.sub(_arg, 1, 7) == '{unit}:' then
                        local _key = string.sub(_arg, 8)

                        Gremlin.log.trace(Gremlin.Id, string.format('Parsing Unit : %s, %s', _key, mist.utils.tableShowSorted(_objs.unit)))

                        if _key == 'name' then
                            table.insert(_out, _objs.unit:getName())
                        else
                            table.insert(_out, _objs.unit[_key])
                        end
                    elseif string.sub(_arg, 1, 8) == '{group}:' then
                        local _key = string.sub(_arg, 9)

                        Gremlin.log.trace(Gremlin.Id, string.format('Parsing Group : %s, %s', _key, mist.utils.tableShowSorted(_objs.group)))

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
        end
    },

    -- Internal State
    _state = {
        menuAdded = {},
    },
}

function Gremlin:setup(config)
    assert(mist ~= nil,
        '\n\n** HEY MISSION-DESIGNER! **\n\nMission Script Tools (MiST) has not been loaded!\n\nMake sure MiST is running *before* running this script!\n')

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

    local _level = 'info'

    if config ~= nil then
        if config.debug ~= nil then
            Gremlin.Debug = config.debug
            _level = 'debug'
        end

        if config.trace ~= nil then
            Gremlin.Trace = config.trace
            _level = 'trace'
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

    mist.addEventHandler(Gremlin.events._handler)

    Gremlin.alreadyInitialized = true
end
