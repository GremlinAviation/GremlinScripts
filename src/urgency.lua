Urgency = {
    Id = 'Gremlin Urgency',
    Version = '202403.01',

    config = {
        adminPilotNames = {},
        countdowns = {},
    },

    _internal = {},
    _state = {
        alreadyInitialized = false,
        countdowns = {
            pending = {},
            active = {},
            done = {},
        },
    },
}

Urgency._internal.getAdminUnits = function()
    Gremlin.log.trace(Urgency.Id, string.format('Scanning For Admin Units'))

    local _units = {}

    for _name, _ in pairs(mist.DBs.unitsByName) do
        local _unit = Unit.getByName(_name)

        if _unit ~= nil and _unit.isExist ~= nil and _unit:isExist() and _unit.getPlayerName ~= nil then
            local _pilot = _unit:getPlayerName()
            if _pilot ~= nil and _pilot ~= '' then
                Gremlin.log.trace(Urgency.Id, string.format('Found A Pilot : %s (in %s)', _pilot, _name))

                for _, _adminName in pairs(Urgency.config.adminPilotNames) do
                    if _adminName == _pilot then
                        _units[_name] = _unit
                        break
                    end
                end
            end
        end
    end

    Gremlin.log.trace(Urgency.Id, string.format('Scan Complete : Found %i Active Admin Units', Gremlin.utils.countTableEntries(_units)))

    return _units
end

Urgency._internal.initMenu = function()
    Gremlin.log.trace(Urgency.Id, string.format('Building Menu'))

    for _name, _countdown in pairs(Urgency._state.countdowns.pending) do
        if _countdown.startTrigger.type == 'menu' then
            table.insert(Urgency._internal.menu, 1, {
                text = _countdown.startTrigger.value or ('Start Countdown: ' .. _name),
                func = Urgency._internal.startCountdown,
                args = { _name },
                when = {
                    func = function(_name)
                        return Urgency._state.countdowns.pending[_name] ~= nil
                    end,
                    args = { _name },
                    comp = 'equal',
                    value = true,
                }
            })
        end

        if _countdown.endTrigger.type == 'menu' then
            table.insert(Urgency._internal.menu, 2, {
                text = _countdown.endTrigger.value or ('Stop Countdown: ' .. _name),
                func = Urgency._internal.endCountdown,
                args = { _name },
                when = {
                    func = function(_name)
                        return Urgency._state.countdowns.active[_name] ~= nil
                    end,
                    args = { _name },
                    comp = 'equal',
                    value = true,
                },
            })
        end
    end

    Gremlin.log.trace(Urgency.Id, string.format('Menu Ready'))
end

Urgency._internal.updateF10 = function()
    Gremlin.log.trace(Urgency.Id, string.format('Updating Menu'))

    timer.scheduleFunction(Urgency._internal.updateF10, nil, timer.getTime() + 5)

    Gremlin.menu.updateF10(Urgency.Id, Urgency._internal.menu, Urgency._internal.getAdminUnits())
end

Urgency._internal.doCountdowns = function()
    Gremlin.log.trace(Urgency.Id, string.format('Checking Time Against Countdowns'))

    timer.scheduleFunction(Urgency._internal.doCountdowns, nil, timer.getTime() + 1)

    local _now = timer.getTime()

    for _name, _countdown in pairs(Urgency._state.countdowns.pending) do
        if (_countdown.startTrigger.type == 'time' and _countdown.startTrigger.value <= _now)
            or (_countdown.startTrigger.type == 'flag' and trigger.misc.getUserFlag(_countdown.startTrigger.value) ~= 0)
        then
            Urgency._internal.startCountdown(_name)
            Gremlin.log.trace(Urgency.Id, string.format('%s-Based Countdown Started : %s', _countdown.startTrigger.type, _name))
        end
    end

    for _name, _countdown in pairs(Urgency._state.countdowns.active) do
        local _endTime
        if _countdown.endTrigger.type == 'time' then
            _endTime = _countdown.endTrigger.value + _countdown.startedAt
        end

        for _time, _message in pairs(_countdown.messages) do
            if (_time >= 0 and _time + _countdown.startedAt <= _now) or (_endTime ~= nil and _time < 0 and _time + _endTime <= _now) then
                Urgency._state.countdowns.active[_name].messages[_time] = nil
                Gremlin.comms.displayMessageTo(_message.to, _message.text, _message.duration)
                Gremlin.log.trace(Urgency.Id, string.format('Sent Message : %s', _message.text))
            end
        end

        if _endTime ~= nil and _now >= _endTime then
            Urgency._internal.endCountdown(_name)
            Gremlin.log.trace(Urgency.Id, string.format('Time-Based Countdown Complete : %s', _name))
        end
    end

    Gremlin.log.trace(Urgency.Id, string.format('Time Checked Against Countdowns'))
end

Urgency._internal.startCountdown = function(_name)
    Gremlin.log.trace(Urgency.Id, string.format('Starting Countdown : %s', _name))

    local _now = timer.getTime()
    local _countdown = Urgency._state.countdowns.pending[_name]

    if _countdown ~= nil then
        _countdown.startedAt = _now
        Urgency._state.countdowns.active[_name] = _countdown
        Urgency._state.countdowns.pending[_name] = nil
        Gremlin.events.fire({ id = 'Urgency:CountdownStart', name = _name })
        trigger.action.setUserFlag(_countdown.startFlag, true)
        trigger.action.setUserFlag(_countdown.endFlag, false)
    end

    Gremlin.log.trace(Urgency.Id, string.format('Started Countdown : %s', _name))
end

Urgency._internal.endCountdown = function(_name)
    Gremlin.log.trace(Urgency.Id, string.format('Ending Countdown : %s', _name))

    local _now = timer.getTime()
    local _countdown = Urgency._state.countdowns.active[_name]

    if _countdown ~= nil then
        _countdown.endedAt = _now
        if _countdown.reuse then
            Urgency._state.countdowns.pending[_name] = _countdown
        else
            Urgency._state.countdowns.done[_name] = _countdown
        end
        Urgency._state.countdowns.active[_name] = nil
        Gremlin.events.fire({ id = 'Urgency:CountdownEnd', name = _name })
        trigger.action.setUserFlag(_countdown.startFlag, false)
        trigger.action.setUserFlag(_countdown.endFlag, true)
    end

    Gremlin.log.trace(Urgency.Id, string.format('Ended Countdown : %s', _name))
end

Urgency._internal.resetCountdowns = function()
    Gremlin.log.trace(Urgency.Id, string.format('Resetting Active Countdowns'))

    for _name, _countdown in pairs(Urgency._state.countdowns.active) do
        _countdown.startedAt = nil
        _countdown.endedAt = nil
        Urgency._state.countdowns.pending[_name] = _countdown
        Urgency._state.countdowns.active[_name] = nil
        trigger.action.setUserFlag(_countdown.startFlag, false)
        trigger.action.setUserFlag(_countdown.endFlag, false)
    end

    Gremlin.events.fire({ id = 'Urgency:CountdownsReset' })
    Gremlin.log.trace(Urgency.Id, string.format('Active Countdowns Reset'))
end

Urgency._internal.restoreCountdowns = function()
    Gremlin.log.trace(Urgency.Id, string.format('Restoring Configured Countdowns'))

    Urgency._state.countdowns.pending = {}
    Urgency._state.countdowns.active = {}
    Urgency._state.countdowns.done = {}

    for _name, _countdown in pairs(Urgency.config.countdowns) do
        Urgency._state.countdowns.pending[_name] = mist.utils.deepCopy(_countdown)
        trigger.action.setUserFlag(_countdown.startFlag, false)
        trigger.action.setUserFlag(_countdown.endFlag, false)
    end

    Gremlin.events.fire({ id = 'Urgency:CountdownsRestored' })
    Gremlin.log.trace(Urgency.Id, string.format('Restored Configured Countdowns'))
end

Urgency._internal.menu = {
    {
        text = 'Reset Active Countdowns',
        func = Urgency._internal.resetCountdowns,
        args = {},
        when = true,
    },
    {
        text = 'Reset All Countdowns',
        func = Urgency._internal.restoreCountdowns,
        args = {},
        when = true,
    },
}

Urgency._internal.handlers = {
    eventTriggers = {
        event = -1,
        fn = function(_event)
            Gremlin.log.trace(Urgency.Id, string.format('Checking Event Against Countdowns : %s', Gremlin.events.idToName[_event.id] or _event.id))

            for _name, _countdown in pairs(Urgency._state.countdowns.pending) do
                if _countdown.startTrigger.type == 'event'
                    and (
                        _countdown.startTrigger.value.id == _event.id
                        or _countdown.startTrigger.value.id == -1
                    )
                    and _countdown.startTrigger.value.filter(_event)
                then
                    Urgency._internal.startCountdown(_name)

                    Gremlin.log.trace(Urgency.Id, string.format('Started Countdown : %s', _name))
                end
            end

            for _name, _countdown in pairs(Urgency._state.countdowns.active) do
                if _countdown.endTrigger.type == 'event'
                    and (
                        _countdown.endTrigger.value.id == _event.id
                        or _countdown.endTrigger.value.id == -1
                    )
                    and _countdown.endTrigger.value.filter(_event)
                then
                    Urgency._internal.endCountdown(_name)

                    Gremlin.log.trace(Urgency.Id, string.format('Ended Countdown : %s', _name))
                end
            end
        end
    },
}

function Urgency:setup(config)
    if config == nil then
        config = {}
    end

    assert(Gremlin ~= nil,
        '\n\n** HEY MISSION-DESIGNER! **\n\nGremlin Script Tools has not been loaded!\n\nMake sure Gremlin Script Tools is loaded *before* running this script!\n')

    if not Gremlin.alreadyInitialized or config.forceReload then
        Gremlin:setup(config)
    end

    if Urgency._state.alreadyInitialized and not config.forceReload then
        Gremlin.log.info(Urgency.Id, string.format('Bypassing initialization because Urgency._state.alreadyInitialized = true'))
        return
    end

    Gremlin.log.info(Urgency.Id, string.format('Starting setup of %s version %s!', Urgency.Id, Urgency.Version))

    -- start configuration
    if not Urgency._state.alreadyInitialized or config.forceReload then
        Urgency.config.adminPilotNames = config.adminPilotNames or {}
        Urgency.config.countdowns = config.countdowns or {}

        Gremlin.log.debug(Urgency.Id, string.format('Configuration Loaded : %s', mist.utils.tableShowSorted(Urgency.config)))
    end
    -- end configuration

    Urgency._state.countdowns.pending = mist.utils.deepCopy(Urgency.config.countdowns)
    Urgency._internal.initMenu()

    timer.scheduleFunction(function()
        timer.scheduleFunction(Urgency._internal.doCountdowns, nil, timer.getTime() + 1)
        timer.scheduleFunction(Urgency._internal.updateF10, nil, timer.getTime() + 1)
    end, nil, timer.getTime() + 1)

    for _name, _def in pairs(Urgency._internal.handlers) do
        Urgency._internal.handlers[_name].id = Gremlin.events.on(_def.event, _def.fn)

        Gremlin.log.debug(Urgency.Id, string.format('Registered %s event handler', _name))
    end

    Gremlin.log.info(Urgency.Id, string.format('Finished setting up %s version %s!', Urgency.Id, Urgency.Version))

    Urgency._state.alreadyInitialized = true
end
