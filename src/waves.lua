Waves = {
    Id = 'Gremlin Waves',
    Version = '202404.01',

    config = {
        adminPilotNames = {},
        waves = {}
    },

    _state = {
        alreadyInitialized = false,
        paused = false,
    },
    _internal = {},
}

Waves._internal.spawnWave = function(_name, _wave)
    Gremlin.log.trace(Waves.Id, string.format('Started Spawning Wave : %s', _name))

    for _groupName, _groupData in pairs(_wave.groups) do
        local _spawnZone = trigger.misc.getZone(_groupData.zone)

        if _spawnZone == nil then
            Gremlin.log.error(Waves.Id, "Can't find zone called " .. _groupData.zone)
            return
        end

        local _pos2 = {
            x = _spawnZone.point.x,
            y = _spawnZone.point.z
        }
        local _alt = land.getHeight(_pos2)
        local _pos3 = {
            x = _pos2.x,
            y = _alt,
            z = _pos2.y
        }
        ---@diagnostic disable-next-line: deprecated
        local _angle = math.atan2(_pos3.z, _pos3.x)

        local _units = {}
        for _unitType, _unitCount in pairs(_groupData.units) do
            for i = 1, _unitCount do
                local _xOffset = math.cos(_angle) * math.random(_groupData.scatter.min, _groupData.scatter.max)
                local _yOffset = math.sin(_angle) * math.random(_groupData.scatter.min, _groupData.scatter.max)

                table.insert(_units, {
                    type = _unitType,
                    name = string.format('%s: %s: %s %i', _name, _groupName, _unitType, i),
                    skill = 'Excellent',
                    playerCanDrive = false,
                    x = _pos3.x + _xOffset,
                    y = _pos3.z + _yOffset,
                    heading = _angle
                })
            end
        end

        local _groupTask = _groupData.task
        if _groupTask == nil then
            if _groupData.category == Group.Category.AIRPLANE then
                _groupTask = 'CAS'
            elseif _groupData.category == Group.Category.GROUND then
                _groupTask = 'Ground Nothing'
            elseif _groupData.category == Group.Category.HELICOPTER then
                _groupTask = 'Transport'
            elseif _groupData.category == Group.Category.SHIP then
                _groupTask = 'Ground Nothing' -- Maybe?
            elseif _groupData.category == Group.Category.TRAIN then
                _groupTask = 'Ground Nothing'
            else
                _groupTask = ''
            end
        end

        local _group = mist.dynAdd({
            visible = true,
            hidden = false,
            uncontrolled = false,
            uncontrollable = false,
            units = _units,
            name = string.format('%s: %s', _name, _groupName),
            task = _groupTask,
            route = _groupData.route or {},
            category = _groupData.category,
            country = _groupData.country,
            x = _pos3.x,
            y = _pos3.z,
        })
        Gremlin.events.fire({ id = 'Waves:GroupSpawn', wave = _name, group = _groupName })

        -- Apparently, ships in particular don't like having their AI messed with.
        -- We'll leave them be just following their routes.
        if _group ~= nil and _groupData.category ~= Group.Category.SHIP and type(_groupData.orders) == 'table' and #_groupData.orders > 0 then
            local _groupObj = Group.getByName(_group.name)

            if _groupObj ~= nil then
                trigger.action.activateGroup(_groupObj)

                timer.scheduleFunction(function()
                    local _controller = _groupObj:getController()
                    if _controller ~= nil then
                        Gremlin.log.trace(Waves.Id, string.format('Activating Group AI : %s', _group.name))

                        _controller:setOnOff(true)
                        _controller:setTask({
                            id = 'ComboTask',
                            params = {
                                tasks = _groupData.orders,
                            },
                        })
                    end
                end, nil, timer.getTime() + 1)
            end
        end
    end

    Gremlin.events.fire({ id = 'Waves:WaveSpawn', wave = _name })
    Gremlin.log.trace(Waves.Id, string.format('Finished Spawning Wave : %s', _name))
end

Waves._internal.getAdminUnits = function()
    Gremlin.log.trace(Waves.Id, string.format('Scanning For Connected Admins'))

    local _units = {}

    for _name, _ in pairs(mist.DBs.unitsByName) do
        local _unit = Unit.getByName(_name)

        if _unit ~= nil and _unit.isExist ~= nil and _unit:isExist() and _unit.getPlayerName ~= nil then
            local _pilot = _unit:getPlayerName()
            if _pilot ~= nil and _pilot ~= '' then
                for _, _adminName in pairs(Waves.config.adminPilotNames) do
                    if _adminName == _pilot then
                        _units[_name] = _unit
                        break
                    end
                end
            end
        end
    end

    Gremlin.log.trace(Waves.Id, string.format('Scan Complete : Found %i Active Admin Units', Gremlin.utils.countTableEntries(_units)))

    return _units
end

Waves._internal.initMenu = function()
    Gremlin.log.trace(Waves.Id, string.format('Building Menu'))

    for _name, _wave in pairs(Waves.config.waves) do
        if _wave.trigger.type == 'menu' then
            table.insert(Waves._internal.menu, {
                text = _wave.trigger.value or ('Send In Reinforcements : ' .. _name),
                func = Waves._internal.menuWave,
                args = { _name },
                when = {
                    func = function(_name)
                        return not Waves._state.paused and not Waves.config.waves[_name].trigger.fired
                    end,
                    args = { _name },
                    comp = 'equal',
                    value = true,
                }
            })
        end
    end

    Gremlin.log.trace(Waves.Id, string.format('Menu Ready'))
end

Waves._internal.updateF10 = function()
    Gremlin.log.trace(Waves.Id, string.format('Updating Menu'))

    timer.scheduleFunction(Waves._internal.updateF10, nil, timer.getTime() + 5)

    Gremlin.menu.updateF10(Waves.Id, Waves._internal.menu, Waves._internal.getAdminUnits())
end

Waves._internal.menuWave = function(_name)
    if not Waves._state.paused and not Waves.config.waves[_name].trigger.fired then
        Gremlin.log.trace(Waves.Id, string.format('Caling In Reinforcements : %s', _name))

        Waves.config.waves[_name].trigger.fired = true
        Waves._internal.spawnWave(_name, Waves.config.waves[_name])

        Gremlin.log.trace(Waves.Id, string.format('Reinforcements En Route : %s', _name))
    end
end

Waves._internal.timeWave = function()
    timer.scheduleFunction(Waves._internal.timeWave, nil, timer.getTime() + 1)

    if not Waves._state.paused then
        Gremlin.log.trace(Waves.Id, string.format('Checking On Next Wave'))

        for _name, _wave in pairs(Waves.config.waves) do
            if (_wave.trigger.type == 'time' and not _wave.trigger.fired and _wave.trigger.value <= timer.getTime())
                or (_wave.trigger.type == 'flag' and not _wave.trigger.fired and trigger.misc.getUserFlag(_wave.trigger.value) ~= 0)
            then
                Waves.config.waves[_name].trigger.fired = true
                Waves._internal.spawnWave(_name, _wave)
            end
        end
    end
end

Waves._internal.pause = function()
    Gremlin.log.trace(Waves.Id, string.format('Pausing Reinforcement Waves'))

    Gremlin.events.fire({ id = 'Waves:Paused' })
    Waves._state.paused = true
    Gremlin.menu.updateF10(Waves.Id, Waves._internal.menu, Waves._internal.getAdminUnits())
end

Waves._internal.unpause = function()
    Gremlin.log.trace(Waves.Id, string.format('Releasing Pending Reinforcement Waves'))

    Gremlin.events.fire({ id = 'Waves:Resumed' })
    Waves._state.paused = false
    Gremlin.menu.updateF10(Waves.Id, Waves._internal.menu, Waves._internal.getAdminUnits())
end

Waves._internal.menu = {
    {
        text = 'Pause Waves',
        func = Waves._internal.pause,
        args = {},
        when = {
            func = function() return Waves._state.paused end,
            args = {},
            comp = 'inequal',
            value = true
        },
    },
    {
        text = 'Resume Waves',
        func = Waves._internal.unpause,
        args = {},
        when = {
            func = function() return Waves._state.paused end,
            args = {},
            comp = 'equal',
            value = true
        },
    },
}

Waves._internal.handlers = {
    eventTriggers = {
        event = -1,
        fn = function(_event)
            if not Waves._state.paused then
                Gremlin.log.trace(Waves.Id, string.format('Checking Event Against Waves : %s', Gremlin.events.idToName[_event.id] or _event.id))

                for _name, _wave in pairs(Waves.config.waves) do
                    if _wave.trigger.type == 'event'
                        and (
                            _wave.trigger.value.id == _event.id
                            or _wave.trigger.value.id == -1
                        )
                        and _wave.trigger.value.filter(_event)
                    then
                        Waves.config.waves[_name].trigger.fired = true
                        Waves._internal.spawnWave(_name, _wave)
                    end
                end
            end
        end
    },
}

function Waves:setup(config)
    if config == nil then
        config = {}
    end

    assert(Gremlin ~= nil,
        '\n\n** HEY MISSION-DESIGNER! **\n\nGremlin Script Tools has not been loaded!\n\nMake sure Gremlin Script Tools is loaded *before* running this script!\n')

    if not Gremlin.alreadyInitialized or config.forceReload then
        Gremlin:setup(config)
    end

    if Waves._state.alreadyInitialized and not config.forceReload then
        Gremlin.log.info(Waves.Id, string.format('Bypassing initialization because Waves._state.alreadyInitialized = true'))
        return
    end

    Gremlin.log.info(Waves.Id, string.format('Starting setup of %s version %s!', Waves.Id, Waves.Version))

    -- start configuration
    if not Waves._state.alreadyInitialized or config.forceReload then
        Waves.config.adminPilotNames = config.adminPilotNames or {}
        Waves.config.waves = config.waves or {}

        Gremlin.log.debug(Waves.Id, string.format('Configuration Loaded : %s', mist.utils.tableShowSorted(Waves.config)))
    end
    -- end configuration

    Waves._internal.initMenu()

    timer.scheduleFunction(function()
        timer.scheduleFunction(Waves._internal.timeWave, nil, timer.getTime() + 1)
        timer.scheduleFunction(Waves._internal.updateF10, nil, timer.getTime() + 1)
    end, nil, timer.getTime() + 1)

    for _name, _def in pairs(Waves._internal.handlers) do
        Waves._internal.handlers[_name].id = Gremlin.events.on(_def.event, _def.fn)

        Gremlin.log.debug(Waves.Id, string.format('Registered %s event handler', _name))
    end

    Gremlin.log.info(Waves.Id, string.format('Finished setting up %s version %s!', Waves.Id, Waves.Version))

    Waves._state.alreadyInitialized = true
end
