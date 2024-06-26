--[[--
Gremlin Evac

DO NOT EDIT THIS SCRIPT DIRECTLY! Things WILL break that way.

Instead!

When calling `Evac:setup()`, you can pass in a configuration table instead
of `nil`. Make your changes in the table you pass - defaults are already in
place if you want to leave those out.

An example, providing all the defaults, is available in the docs, or near
the end of this script.

@module Evac
--]]--
Evac = {
    -- Static Info

    Id = 'Gremlin Evac', -- Contains an identifier for this script
    Version = '202404.01', -- Contains the current script version

    -- Config

    config = {
        adminPilotNames = {},
        beaconBatteryLife = 0, -- How long a beacon should last, in minutes
        beaconSound = '', -- The audio file to play for beacons
        carryLimits = {}, -- The max carrying capacity of the aircraft in this misson; table should be a list of capacities keyed by the unit type name
        idStart = 0, -- Where to start counting when generating new units' and groups' IDs
        loadUnloadPerIndividual = 0, -- How long it takes to load one unit, in seconds
        lossFlags = {0, 0}, -- The Mission Editor flags to set when the players lose too many forces
        lossThresholds = {0, 0}, -- The percentage of evacuees that can be lost before mission loss
        maxExtractable = { -- The maximum number of each unit to generate when spawning units
            _global = {
                Generic = { 0, 0, [0] = 0 },
                Infantry = { 0, 0, [0] = 0 },
                M249 = { 0, 0, [0] = 0 },
                RPG = { 0, 0, [0] = 0 },
                StingerIgla = { 0, 0, [0] = 0 },
                ['2B11'] = { 0, 0, [0] = 0 },
                JTAC = { 0, 0, [0] = 0 },
            },
        },
        spawnRates = {}, -- How frequently to spawn new units, per zone
        spawnWeight = 0, -- The default weight of new units; exact weights will vary by unit
        winFlags = {0, 0}, -- The Mission Editor flags to set when the players evacuate enough forces
        winThresholds = {0, 0}, -- The percentage of evacuees that must be rescued before mission win
    },

    --- Enums.
    -- Ways to look up constants in Gremlin Evac.
    --
    -- @section Enums

    --- The modes that a zone can be in.
    --
    -- @table Evac.modes
    -- @int EVAC mode
    -- @int SAFE mode
    -- @int RELAY mode
    modes = {
        EVAC = 1, -- evac mode
        SAFE = 2, -- safe mode
        RELAY = 3, -- relay mode
    },
    --- Lookup table for modes to names.
    --
    -- @table Evac.modeToText
    modeToText = {
        'evac', -- evac mode
        'safe', -- safe mode
        'relay', -- relay mode
    },

    -- DO NOT USE / MODIFY THESE VALUES!

    --- @local Evac._internal
    _internal = {}, -- Internal Methods - AVOID USING / DO NOT MODIFY
    --- @local Evac._state
    _state = { -- Internal State - DO NOT USE / MODIFY
        alreadyInitialized = false,
        beacons = {},
        extractableNow = {},
        extractionUnits = {},
        frequencies = {
            uhf = {
                free = {},
                used = {}
            },
            vhf = {
                free = {},
                used = {}
            },
            fm = {
                free = {},
                used = {}
            }
        },
        lostEvacuees = {
            Generic = { 0, 0, [0] = 0 },
            Infantry = { 0, 0, [0] = 0 },
            M249 = { 0, 0, [0] = 0 },
            RPG = { 0, 0, [0] = 0 },
            StingerIgla = { 0, 0, [0] = 0 },
            ['2B11'] = { 0, 0, [0] = 0 },
            JTAC = { 0, 0, [0] = 0 },
        },
        smoke = {},
        spawns = {
            alreadySpawned = {
                Generic = { 0, 0, [0] = 0 },
                Infantry = { 0, 0, [0] = 0 },
                M249 = { 0, 0, [0] = 0 },
                RPG = { 0, 0, [0] = 0 },
                StingerIgla = { 0, 0, [0] = 0 },
                ['2B11'] = { 0, 0, [0] = 0 },
                JTAC = { 0, 0, [0] = 0 },
            },
            pending = {},
            active = {},
            completed = {},
            lastSpawned = {},
        },
        zones = {
            evac = {},
            relay = {},
            safe = {}
        },
    },
}

-- Methods

--[[--
Zone methods.
Methods for interacting with evacuation zones.

@section Zones
--]]--
Evac.zones = {
    -- Evac Zone methods
    evac = {
        --[[-- Mark a zone as part of the Evac ecosystem, and give it the evac mode

        @function            Evac.zones.evac.register
        @tparam  string      _zone   the zone name
        @tparam  number|nil  _smoke  the smoke color, taken from `trigger.smokeColor.*`
        @tparam  number      _side   the coalition, taken from `coalition.side.*`
        ]]
        register = function(_zone, _smoke, _side)
            Gremlin.log.trace(Evac.Id, string.format('Registering Evac Zone : %s, %i, %i', _zone, _smoke or -1, _side))

            return Evac._internal.zones.register(_zone, _smoke, _side, Evac.modes.EVAC)
        end,
        --[[-- Activate a zone for evacuation operations.

        @function               Evac.zones.evac.activate
        @tparam  string _zone   the zone name
        ]]
        activate = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Activating Evac Zone : %s', _zone))

            return Evac._internal.zones.activate(_zone, Evac.modes.EVAC)
        end,
        --[[-- Manually override the remaining units in a zone.

        @function             Evac.zones.evac.setRemaining
        @tparam  string       _zone                 the zone name
        @tparam  number       _side                 the coalition, taken from `coalition.side.*`
        @tparam  number       _country              the country, taken from `country.*`
        @tparam  number|table _numberOrComposition  the units to generate
        ]]
        setRemaining = function(_zone, _side, _country, _numberOrComposition)
            if type(_numberOrComposition) == "table" then
                Gremlin.log.trace(Evac.Id, string.format('Setting Remaining In Evac Zone : %s, %i, %i, %s', _zone, _side, _country, Gremlin.utils.inspect(_numberOrComposition)))
            else
                Gremlin.log.trace(Evac.Id, string.format('Setting Remaining In Evac Zone : %s, %i, %i, %i', _zone, _side, _country, _numberOrComposition))
            end

            return Evac._internal.zones.setRemaining(_zone, _side, _country, _numberOrComposition)
        end,
        --[[-- Count the number of evacuees in a zone.

        @function       Evac.zones.evac.count
        @tparam  string _zone   the zone name
        @treturn number         the number of evacuees in the zone
        ]]
        count = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Counting Evacuees In Evac Zone : %s', _zone))

            return Evac._internal.zones.count(_zone, Evac.modes.EVAC)
        end,
        --[[-- Check whether a given unit is in an evac zone.

        @function       Evac.zones.evac.isIn
        @tparam  string _unit   the unit name
        @treturn boolean        whether the unit is in an evac zone
        ]]
        isIn = function(_unit)
            Gremlin.log.trace(Evac.Id, string.format('Checking For Unit In Evac Zones : %s', _unit))

            return Evac._internal.zones.isIn(_unit, Evac.modes.EVAC)
        end,
        --[[-- Deactivate a zone for evacuation operations.

        @function       Evac.zones.evac.deactivate
        @tparam  string _zone   the zone name
        ]]
        deactivate = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Deactivating Evac Zone : %s', _zone))

            return Evac._internal.zones.deactivate(_zone, Evac.modes.EVAC)
        end,
        --[[-- Forget a zone once it should no longer be used as part of the Evac ecosystem.

        @function       Evac.zones.evac.unregister
        @tparam  string _zone   the zone name
        ]]
        unregister = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Unregistering Evac Zone : %s', _zone))

            return Evac._internal.zones.unregister(_zone, Evac.modes.EVAC)
        end
    },
    -- Relay Zone methods
    relay = {
        --[[-- Mark a zone as part of the Evac ecosystem, and give it the relay mode.

        @function       Evac.zones.relay.register
        @tparam  string _zone   the zone name
        @tparam  number _smoke  the smoke color, taken from `trigger.smokeColor.*`
        @tparam  number _side   the coalition, taken from `coalition.side.*`
        ]]
        register = function(_zone, _smoke, _side)
            Gremlin.log.trace(Evac.Id, string.format('Registering Relay Zone : %s, %i, %i', _zone, _smoke or -1, _side))

            return Evac._internal.zones.register(_zone, _smoke, _side, Evac.modes.RELAY)
        end,
        --[[-- Activate a zone for evacuation operations.

        @function       Evac.zones.relay.activate
        @tparam  string _zone   the zone name
        ]]
        activate = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Activating Relay Zone : %s', _zone))

            return Evac._internal.zones.activate(_zone, Evac.modes.RELAY)
        end,
        --[[-- Manually override the remaining units in a zone.

        @function             Evac.zones.relay.setRemaining
        @tparam  string       _zone                 the zone name
        @tparam  number       _side                 the coalition, taken from `coalition.side.*`
        @tparam  number       _country              the country, taken from `country.*`
        @tparam  number|table _numberOrComposition  the units to generate
        ]]
        setRemaining = function(_zone, _side, _country, _numberOrComposition)
            if type(_numberOrComposition) == "table" then
                Gremlin.log.trace(Evac.Id,
                    string.format('Setting Remaining In Relay Zone : %s, %i, %i, %s', _zone, _side, _country,
                        Gremlin.utils.inspect(_numberOrComposition)))
            else
                Gremlin.log.trace(Evac.Id, string.format('Setting Remaining In Relay Zone : %s, %i, %i, %i', _zone,
                    _side, _country, _numberOrComposition))
            end

            return Evac._internal.zones.setRemaining(_zone, _side, _country, _numberOrComposition)
        end,
        --[[-- Count the number of evacuees in a zone.

        @function       Evac.zones.relay.count
        @tparam  string _zone   the zone name
        @treturn number         the number of evacuees in the zone
        ]]
        count = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Counting Evacuees In Relay Zone : %s', _zone))

            return Evac._internal.zones.count(_zone, Evac.modes.RELAY)
        end,
        --[[-- Check whether a given unit is in a relay zone.

        @function       Evac.zones.relay.isIn
        @tparam  string _unit   the unit name
        @treturn boolean        whether the unit is in a relay zone
        ]]
        isIn = function(_unit)
            Gremlin.log.trace(Evac.Id, string.format('Checking For Unit In Relay Zones : %s', _unit))

            return Evac._internal.zones.isIn(_unit, Evac.modes.RELAY)
        end,
        --[[-- Deactivate a zone for evacuation operations.

        @function       Evac.zones.relay.deactivate
        @tparam  string _zone   the zone name
        ]]
        deactivate = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Deactivating Relay Zone : %s', _zone))

            return Evac._internal.zones.deactivate(_zone, Evac.modes.RELAY)
        end,
        --[[-- Forget a zone once it should no longer be used as part of the Evac ecosystem.

        @function       Evac.zones.relay.unregister
        @tparam  string _zone   the zone name
        ]]
        unregister = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Unregistering Relay Zone : %s', _zone))

            return Evac._internal.zones.unregister(_zone, Evac.modes.RELAY)
        end
    },
    -- Safe Zone methods
    safe = {
        --[[-- Mark a zone as part of the Evac ecosystem, and give it the safe mode.

        @function       Evac.zones.safe.register
        @tparam  string _zone   the zone name
        @tparam  number _smoke  the smoke color, taken from `trigger.smokeColor.*`
        @tparam  number _side   the coalition, taken from `coalition.side.*`
        ]]
        register = function(_zone, _smoke, _side)
            Gremlin.log.trace(Evac.Id, string.format('Registering Safe Zone : %s, %i, %i', _zone, _smoke or -1, _side))

            return Evac._internal.zones.register(_zone, _smoke, _side, Evac.modes.SAFE)
        end,
        --[[-- Activate a zone for evacuation operations.

        @function       Evac.zones.safe.activate
        @tparam  string _zone   the zone name
        ]]
        activate = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Activating Safe Zone : %s', _zone))

            return Evac._internal.zones.activate(_zone, Evac.modes.SAFE)
        end,
        --[[-- Count the number of evacuees in a zone.

        @function       Evac.zones.safe.count
        @tparam  string _zone   the zone name
        @treturn number         the number of evacuees in the zone
        ]]
        count = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Count Evacuees In Safe Zone : %s', _zone))

            return Evac._internal.zones.count(_zone, Evac.modes.SAFE)
        end,
        --[[-- Check whether a given unit is in a safe zone.

        @function       Evac.zones.safe.isIn
        @tparam  string _unit   the unit name
        @treturn boolean        whether the unit is in a safe zone
        ]]
        isIn = function(_unit)
            Gremlin.log.trace(Evac.Id, string.format('Checking For Unit In Safe Zones : %s', _unit))

            return Evac._internal.zones.isIn(_unit, Evac.modes.SAFE)
        end,
        --[[-- Deactivate a zone for evacuation operations.

        @function       Evac.zones.safe.deactivate
        @tparam  string _zone   the zone name
        ]]
        deactivate = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Deactivating Safe Zone : %s', _zone))

            return Evac._internal.zones.deactivate(_zone, Evac.modes.SAFE)
        end,
        --[[-- Forget a zone once it should no longer be used as part of the Evac ecosystem.

        @function       Evac.zones.safe.unregister
        @tparam  string _zone   the zone name
        ]]
        unregister = function(_zone)
            Gremlin.log.trace(Evac.Id, string.format('Unregistering Safe Zone : %s', _zone))

            return Evac._internal.zones.unregister(_zone, Evac.modes.SAFE)
        end
    }
}

--[[--
Unit methods.
Methods for working with extraction units.

@section Units
--]]--
Evac.units = {
    --[[-- Registers a unit as an evacuation unit, capable of performing evacutions

    @function Evac.units.register
    @tparam string|table _unit   the name of the unit to register
    ]]
    register = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Registering Unit As Evacuation Unit : %s', tostring(_unit)))

        local _unitObj

        if type(_unit) == 'table' and _unit.getName ~= nil then
            _unitObj = _unit
            _unit = _unitObj:getName()
        else
            _unitObj = Unit.getByName(_unit)
        end

        Evac._state.extractionUnits[_unit] = {
            [0] = _unitObj
        }
    end,
    --[[-- Lists the currently active beacons broadcasting for the player's coalition

    @function Evac.units.findEvacuees
    @tparam string _unit   the name of the unit searching for beacons
    ]]
    findEvacuees = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Searching For Evacuation Beacons : %s', tostring(_unit)))

        Evac._internal.beacons.list(_unit)
    end,
    --[[-- Starts the evacuee loading process for a unit

    @function Evac.units.loadEvacuees
    @tparam string _unit   the name of the unit to load evacuees onto
    ]]
    loadEvacuees = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Starting Evacuee Loading Process : %s', _unit))

        local _unitObj = Unit.getByName(_unit)
        if _unitObj ~= nil then
            local _free = Evac.config.carryLimits[_unitObj:getTypeName()] or 0
            if _free == 0 then
                Gremlin.comms.displayMessageTo(_unit, "Your aircraft isn't rated for evacuees in this mission!", 1)
                return
            end

            _free = _free - Evac._internal.aircraft.countEvacuees(_unit)
            if _free <= 0 then
                Gremlin.comms.displayMessageTo(_unit, 'Already full! Unload, first!', 1)
                return
            end

            Evac._internal.aircraft.loadEvacuees(_unit, _free)
        else
            Gremlin.comms.displayMessageTo(_unit, "Your aircraft isn't rated for evacuees in this mission!", 1)
        end
    end,
    --[[-- Starts the evacuee unloading process for a unit

    @function Evac.units.unloadEvacuees
    @tparam string _unit   the name of the unit to unload evacuess from
    ]]
    unloadEvacuees = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Starting Evacuee Unloading Process : %s', _unit))

        Evac._internal.aircraft.unloadEvacuees(_unit)
    end,
    --[[-- Count the number of evacuees on board a given unit

    @function Evac.units.countEvacuees
    @tparam string _unit   the name of the unit to count evacuees aboard
    ]]
    countEvacuees = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Counting Evacuees Aboard : %s', _unit))

        local _count = Evac._internal.aircraft.countEvacuees(_unit)

        Gremlin.comms.displayMessageTo(_unit, 'You are currently carrying ' .. _count .. ' evacuees.', 1)
    end,
    --[[-- Count the number of units in a given zone

    @function Evac.units.count
    @tparam string _zone   the name of the zone to count units within
    @treturn number        the number of units in the zone
    ]]
    count = function(_zone)
        Gremlin.log.trace(Evac.Id, string.format('Counting Units In Zone : %s', _zone))

        return #(mist.getUnitsInZones(mist.makeUnitTable({'[all]'}, false), {_zone}, 'c'))
    end,
    --[[-- Unregisters a unit as an evacuation unit

    @function Evac.units.unregister
    @tparam string|table _unit   the name of the unit to unregister
    ]]
    unregister = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Unregistering Unit As Evacuation Unit : %s', tostring(_unit)))

        if type(_unit) == 'table' and _unit.getName ~= nil then
            _unit = _unit:getName()
        end

        Evac._state.extractionUnits[_unit] = nil
    end
}

--[[--
Group methods.
Methods for interacting with evacuee groups.

@section Groups
--]]--
Evac.groups = {
    --[[-- Spawns generic evacuees when given a number for `_numberOrComposition`.
    For a mix of evac targets, pass a list of units to add instead.

    @function Evac.groups.spawn
    @tparam number       _side                the coalition ID to spawn evacuees under
    @tparam number|table _numberOrComposition the number of units to spawn, or a table describing the units' attributes
    @tparam number       _country             the country ID to spawn the evacuees under
    @tparam string       _zone                the name of the zone to spawn evacuees into
    @tparam number       _scatterRadius       the max distance from zone center to spawn units
    @treturn table|nil                        data about the group just spawned
    ]]
    spawn = function(_side, _numberOrComposition, _country, _zone, _scatterRadius)
        if type(_numberOrComposition) == 'table' then
            Gremlin.log.trace(Evac.Id, string.format('Spawning New Evacuee Group : %i, %s, %i, %s, %i', _side, Gremlin.utils.inspect(_numberOrComposition), _country, _zone, _scatterRadius))
        else
            Gremlin.log.trace(Evac.Id, string.format('Spawning New Evacuee Group : %i, %i, %i, %s, %i', _side, _numberOrComposition, _country, _zone, _scatterRadius))
        end

        local _groupData = Evac._internal.zones.generateEvacuees(_side, _numberOrComposition, _country)
        local _spawnZone = trigger.misc.getZone(_zone)

        if _spawnZone == nil then
            Gremlin.log.error(Evac.Id, "Can't find zone called " .. _zone)
            return
        end

        if _scatterRadius < 5 then
            _scatterRadius = 5
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

        local _group = {
            visible = false,
            hidden = true,
            units = Evac._internal.utils.unitDataToList(_side, _groupData.units, _pos3, _scatterRadius),
            name = _groupData.groupName,
            groupId = _groupData.groupId,
            category = Group.Category.GROUND,
            country = _groupData.country,
            x = _pos3.x,
            y = _pos3.z,
        }

        for _, _unit in pairs(_group.units) do
            mist.dynAddStatic(Gremlin.utils.mergeTables(_unit, { country = _groupData.country }))
        end

        for _, _unit in pairs(_groupData.units) do
            Evac._state.extractableNow[_zone][_unit.unitName] = _unit
        end

        Evac._internal.beacons.spawn(_zone, _side, _country)

        return _group
    end,
    --[[-- Returns a list of all groups in a zone.

    @function Evac.groups.list
    @tparam string _zone   the zone name to check for evacuee groups
    @treturn {string,...}  the list of groups in the zone
    ]]
    list = function(_zone)
        Gremlin.log.trace(Evac.Id, string.format('Listing Groups In Zone : %s', _zone))

        local groupsFound = {}
        local _unitsInZone = mist.getUnitsInZones(mist.makeUnitTable({'[all]'}, false), {_zone}, 'c')

        for _, _unit in pairs(_unitsInZone) do
            local _unitGroup = Unit.getByName(_unit):getGroup()
            local _found = false
            for _i = 1, #groupsFound do
                if groupsFound[_i].name == _unitGroup:getName() then
                    _found = true
                end
            end

            if not _found then
                groupsFound[#groupsFound + 1] = _unitGroup
            end
        end

        return groupsFound
    end,
    --[[-- Returns a count of all groups in a zone.

    @function Evac.groups.count
    @tparam  string  _zone  the zone name to check for evacuee groups
    @treturn number         the list of groups in the zone
    ]]
    count = function(_zone)
        Gremlin.log.trace(Evac.Id, string.format('Counting Groups In Zone : %s', _zone))

        return #(Evac.groups.list(_zone))
    end
}

--[[ --------------------------------------------------------------------- --
---- WE ALREADY SAID NOT TO EDIT THIS FILE, BUT ESPECIALLY NOT BELOW HERE! --
---- --------------------------------------------------------------------- ]]

--- Aircraft.
-- Internal methods for working with aircraft.
--
-- @local Evac._internal.aircraft
Evac._internal.aircraft = {
    inZone = function(_unit, _evacMode)
        Gremlin.log.trace(Evac.Id, string.format('Checking For Unit In Zones : %s, %s', _unit, tostring(_evacMode)))

        return Evac._internal.zones.isIn(_unit, _evacMode)
    end,
    inAir = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Checking Whether Unit Is In Air : %s', tostring(_unit)))

        if type(_unit) == 'string' then
            _unit = Unit.getByName(_unit)
        end

        if _unit:inAir() == false then
            Gremlin.log.trace(Evac.Id, string.format('DCS Says Not In Air : %s', _unit:getName()))

            return false
        end

        if mist.vec.mag(_unit:getVelocity()) < 0.05 and _unit:getPlayerName() ~= nil then
            Gremlin.log.trace(Evac.Id, string.format('Moving Too Slow (Not In Air) : %s', _unit:getName()))

            return false
        end

        Gremlin.log.trace(Evac.Id, string.format('Unit Is In Air : %s', _unit:getName()))

        return true
    end,
    heightDifference = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Calculating Unit Distance To Ground : %s', _unit))

        if type(_unit) == 'string' then
            _unit = Unit.getByName(_unit)
        end

        -- Adapted from CSAR and CTLD
        local _point = _unit:getPoint()
        return _point.y - land.getHeight({
            x = _point.x,
            y = _point.z
        })
    end,
    loadEvacuees = function(_unit, _number)
        Gremlin.log.trace(Evac.Id, string.format('Loading Evacuees Onto Unit : %s, %i', _unit, _number))

        local _zone = Evac._internal.utils.getUnitZone(_unit)

        if Evac._state.extractableNow[_zone] == nil or ((Evac._state.zones.evac[_zone] == nil or Evac._state.zones.evac[_zone].active == false) and (Evac._state.zones.relay[_zone] == nil or Evac._state.zones.relay[_zone].active == false)) then
            Gremlin.log.debug(Evac.Id, string.format('Loading Evacuees : %s is not an active or registered zone\nextractable - %s\nevac zone - %s\nrelay zone - %s', _zone, Gremlin.utils.inspect(Evac._state.extractableNow[_zone]), Gremlin.utils.inspect(Evac._state.zones.evac[_zone]), Gremlin.utils.inspect(Evac._state.zones.relay[_zone])))
            Gremlin.comms.displayMessageTo(_unit, 'Not in an active evac or relay zone! Try looking elsewhere.', 5)
            return
        end

        if Evac._internal.aircraft.inAir(_unit) then
            Gremlin.log.debug(Evac.Id, string.format('Loading Evacuees : %s is not on the ground', _unit))
            Gremlin.comms.displayMessageTo(_unit, 'You need to land, first! Unless you have some magic way to teleport them up? And no, these folks are in no condition for the hoist, so put that back up.', 5)
            return
        end

        _number = math.min(_number, Gremlin.utils.countTableEntries(Evac._state.extractableNow[_zone]))
        if _number < 1 then
            Gremlin.log.debug(Evac.Id, string.format('Loading Evacuees : %s is empty', _zone))
            Gremlin.comms.displayMessageTo(_unit, 'No evacuees to load here, pilot! Try looking elsewhere.', 5)
            return
        end

        local _timeout = Evac.config.loadUnloadPerIndividual * _number
        local _timeNow = math.floor(timer.getTime())
        mist.scheduleFunction(function(_start)
            local _left = math.floor((_start + _timeout) - timer.getTime())

            Gremlin.log.debug(Evac.Id, string.format('Loading Evacuees : %i seconds to finish', _left))

            local _message = string.format('%i seconds remaining to load %i evacuees', _left, _number)
            local _displayFor = 1

            if _left <= 0 then
                local _evacNameList = {}
                for _evacName, _ in pairs(Evac._state.extractableNow[_zone]) do
                    table.insert(_evacNameList, _evacName)
                end

                for _i = 1, _number do
                    local _randomIdx = math.random(#_evacNameList)
                    local _randomName = _evacNameList[_randomIdx]
                    local _evacuee = Evac._state.extractableNow[_zone][_randomName]
                    table.remove(_evacNameList, _randomIdx)
                    Evac._state.extractableNow[_zone][_randomName] = nil
                    Evac._state.extractionUnits[_unit][_randomName] = _evacuee
                end

                _message = 'Evacuee loading complete!'
                _displayFor = 5
            elseif math.fmod(_left, Evac.config.loadUnloadPerIndividual) == 0 then
                local _evacNameList = {}
                for _evacName, _ in pairs(Evac._state.extractableNow[_zone]) do
                    table.insert(_evacNameList, _evacName)
                end

                local _randomIdx = math.random(#_evacNameList)
                local _randomName = _evacNameList[_randomIdx]
                local _evacuee = Evac._state.extractableNow[_zone][_randomName]
                table.remove(_evacNameList, _randomIdx)
                Evac._state.extractableNow[_zone][_randomName] = nil
                Evac._state.extractionUnits[_unit][_randomName] = _evacuee
                _number = _number - 1
            end

            Evac._internal.aircraft.adaptWeight(_unit)

            Gremlin.log.debug(Evac.Id, string.format('Loading Evacuees : Sending %s to %s', _message, tostring(_unit)))

            Gremlin.events.fire({ id = 'Evac:UnitLoaded', zone = _zone, unit = _unit, number = _number })
            Gremlin.comms.displayMessageTo(_unit, _message, _displayFor)
        end, {_timeNow + 0.01}, _timeNow + 0.01, 1, _timeNow + _timeout + 0.02)
    end,
    countEvacuees = function(_unit)
        if type(_unit) == 'table'then
            if _unit.getName ~= nil then
                _unit = _unit:getName()
                Gremlin.log.trace(Evac.Id, string.format('Counting Evacuees Aboard Unit : %s', _unit:getName()))
            else
                Gremlin.log.trace(Evac.Id, string.format('Counting Evacuees Aboard Unit : %s', Gremlin.utils.inspect(_unit)))
            end
        else
            Gremlin.log.trace(Evac.Id, string.format('Counting Evacuees Aboard Unit : %s', Gremlin.utils.inspect(_unit)))
        end

        return Gremlin.utils.countTableEntries(Evac._state.extractionUnits[_unit] or { [0] = {} }) - 1
    end,
    calculateWeight = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Calculating Weight Of Unit : %s', _unit))

        local _calculated = 0

        if Gremlin.haveCSAR then
            ---@diagnostic disable-next-line: undefined-global
            _calculated = _calculated + (csar.weight * #(csar.inTransitGroups[_unit]))
        end

        if Gremlin.haveCTLD then
            ---@diagnostic disable-next-line: undefined-global
            _calculated = _calculated + ctld.getWeightOfCargo(_unit)
        end

        local _extracted = Evac._state.extractionUnits[_unit]

        if _extracted ~= nil then
            for _i, _evacuee in pairs(_extracted) do
                if _i ~= 0 then
                    _calculated = _calculated + (_evacuee.weight or Evac._internal.utils.randomizeWeight(Evac.config.spawnWeight))
                end
            end
        end

        return _calculated
    end,
    adaptWeight = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Adapting Unit Weight : %s', _unit))

        local _weight = Evac._internal.aircraft.calculateWeight(_unit)
        trigger.action.setUnitInternalCargo(_unit, _weight)
    end,
    unloadEvacuees = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Unloading Evacuees From Unit : %s', _unit))

        local _zone = Evac._internal.utils.getUnitZone(_unit)

        if (Evac._state.zones.safe[_zone] == nil or Evac._state.zones.safe[_zone].active == false) and (Evac._state.zones.relay[_zone] == nil or Evac._state.zones.relay[_zone].active == false) then
            Gremlin.log.debug(Evac.Id, string.format('Unloading Evacuees : %s is not an active or registered zone\nrelay zone - %s\nsafe zone - %s', _zone, Gremlin.utils.inspect(Evac._state.zones.relay[_zone]), Gremlin.utils.inspect(Evac._state.zones.safe[_zone])))
            Gremlin.comms.displayMessageTo(_unit, 'Not in an active relay or safe zone! Try looking elsewhere.', 5)
            return
        end

        if Evac._internal.aircraft.inAir(_unit) then
            Gremlin.log.debug(Evac.Id, string.format('Unloading Evacuees : %s is not on the ground', _unit))
            Gremlin.comms.displayMessageTo(_unit, "You need to land, first! Fastrope doesn't work with stretchers.", 5)
            return
        end

        local _number = Evac._internal.aircraft.countEvacuees(_unit)
        if _number < 1 then
            Gremlin.log.debug(Evac.Id, string.format('Unloading Evacuees : %s is empty', _unit))
            Gremlin.comms.displayMessageTo(_unit, 'No evacuees to unload?! Why are you even here, pilot?!', 5)
            return
        end

        local _timeout = Evac.config.loadUnloadPerIndividual * _number
        local _timeNow = math.floor(timer.getTime())
        mist.scheduleFunction(function(_start)
            local _left = math.floor((_start + _timeout) - timer.getTime())

            Gremlin.log.debug(Evac.Id, string.format('Unloading Evacuees : %f seconds to finish', _left))

            local _displayFor = 1
            local _message = string.format('%i seconds remaining to unload %i evacuees', _left, _number)

            if _left <= 0 then
                for _evacueeName, _evacuee in pairs(Evac._state.extractionUnits[_unit]) do
                    if _evacueeName ~= 0 then
                        Evac._state.extractableNow[_zone][_evacueeName] = _evacuee
                    end
                end

                Evac._state.extractionUnits[_unit] = {
                    [0] = Evac._state.extractionUnits[_unit][0]
                }
                Evac._internal.aircraft.adaptWeight(_unit)
                _message = 'Evacuee unloading complete!'
                _displayFor = 5
            elseif math.fmod(_left, Evac.config.loadUnloadPerIndividual) == 0 then
                for _evacueeName, _evacuee in pairs(Evac._state.extractionUnits[_unit]) do
                    if _evacueeName ~= 0 then
                        Evac._state.extractableNow[_zone][_evacueeName] = _evacuee
                        Evac._state.extractionUnits[_unit][_evacueeName] = nil
                        break
                    end
                end

                Evac._internal.aircraft.adaptWeight(_unit)

                _number = _number - 1
            end

            Gremlin.log.debug(Evac.Id, string.format('Unloading Evacuees : Sending %s to %s', _message, tostring(_unit)))

            Gremlin.events.fire({ id = 'Evac:UnitUnloaded', zone = _zone, unit = _unit, number = _number })
            Gremlin.comms.displayMessageTo(_unit, _message, _displayFor)
            Evac._internal.utils.endIfEnoughGotOut()
        end, { _timeNow + 0.01 }, _timeNow + 0.01, 1, _timeNow + _timeout + 0.02)
    end,
    getAdminUnits = function()
        Gremlin.log.trace(Evac.Id, string.format('Scanning For Admin Units'))

        local _units = {}

        for _name, _ in pairs(mist.DBs.unitsByName) do
            local _unit = Unit.getByName(_name)

            if _unit ~= nil and _unit.isExist ~= nil and _unit:isExist() and _unit.getPlayerName ~= nil then
                local _pilot = _unit:getPlayerName()
                if _pilot ~= nil and _pilot ~= '' then
                    Gremlin.log.trace(Evac.Id, string.format('Found A Pilot : %s (in %s)', _pilot, _name))

                    for _, _adminName in pairs(Evac.config.adminPilotNames) do
                        if _adminName == _pilot then
                            _units[_name] = _unit
                            break
                        end
                    end
                end
            end
        end

        Gremlin.log.trace(Evac.Id, string.format('Scan Complete : Found %i Active Admin Units', Gremlin.utils.countTableEntries(_units)))

        return _units
    end,
}

--- Beacons.
-- Internal methods for working with beacons.
--
-- @local Evac._internal.beacons
Evac._internal.beacons = {
    spawn = function(_zone, _side, _country, _batteryLife, _name)
        if _name == nil or _name == '' then
            _name = 'Beacon #' .. (#(Evac._state.beacons) + 1)
        end

        Gremlin.log.trace(Evac.Id, string.format('Spawning Evacuation Beacons : %s, %i, %i, %i, %s', _zone, _side, _country, _batteryLife or -2, _name))

        local _battery
        if _batteryLife == nil then
            _battery = timer.getTime() + (Evac.config.beaconBatteryLife * 60)
        else
            _battery = timer.getTime() + (_batteryLife * 60)
        end

        local _zonePos = mist.utils.zoneToVec3(_zone)
        local _groupId = Evac._internal.utils.getNextGroupId()
        local _unitId = Evac._internal.utils.getNextUnitId()
        local _freq = Evac._internal.beacons.getFreeADFFrequencies()
        local _freqsText = string.format('%.2f kHz - %.2f / %.2f MHz', (_freq.vhf or 30) / 1000, _freq.uhf / 1000000, _freq.fm / 1000000)

        local _radioGroup = {
            ['visible'] = false,
            ['hidden'] = false,
            ['units'] = {{
                ['y'] = _zonePos.z,
                ['type'] = 'TACAN_beacon',
                ['name'] = 'VHF Unit #' .. _unitId .. ' - ' .. _name .. ' [' .. _freqsText .. ']',
                ['heading'] = 0,
                ['playerCanDrive'] = true,
                ['skill'] = 'Excellent',
                ['x'] = _zonePos.x
            }, {
                ['y'] = _zonePos.z,
                ['type'] = 'TACAN_beacon',
                ['name'] = 'UHF Unit #' .. (_unitId + 1) .. ' - ' .. _name .. ' [' .. _freqsText .. ']',
                ['heading'] = 0,
                ['playerCanDrive'] = true,
                ['skill'] = 'Excellent',
                ['x'] = _zonePos.x
            }, {
                ['y'] = _zonePos.z,
                ['type'] = 'TACAN_beacon',
                ['name'] = 'FM Unit #' .. (_unitId + 2) .. ' - ' .. _name .. ' [' .. _freqsText .. ']',
                ['heading'] = 0,
                ['playerCanDrive'] = true,
                ['skill'] = 'Excellent',
                ['x'] = _zonePos.x
            }},
            ['name'] = 'Group #' .. _groupId .. ' - ' .. _name,
            ['task'] = {},
            ['category'] = Group.Category.GROUND,
            ['country'] = _country
        }

        mist.dynAdd(_radioGroup)

        local _beaconDetails = {
            vhf = _freq.vhf,
            uhf = _freq.uhf,
            fm = _freq.fm,
            group = _radioGroup.name,
            text = _freqsText,
            battery = _battery,
            side = _side
        }

        Evac._internal.beacons.update(_beaconDetails)
        table.insert(Evac._state.beacons, _beaconDetails)

        Gremlin.events.fire({ id = 'Evac:BeaconSpawn', zone = _zone, details = _beaconDetails })

        return _beaconDetails
    end,
    getFreeADFFrequencies = function()
        Gremlin.log.trace(Evac.Id, string.format('Looking Up Free ADF Frequencies'))

        if #Evac._state.frequencies.uhf.free <= 0 then
            Evac._state.frequencies.uhf.free = Evac._state.frequencies.uhf.used
            Evac._state.frequencies.uhf.used = {}
        end

        local _uhf = table.remove(Evac._state.frequencies.uhf.free, math.random(1, #Evac._state.frequencies.uhf.free))
        table.insert(Evac._state.frequencies.uhf.used, _uhf)

        if #Evac._state.frequencies.vhf.free <= 0 then
            Evac._state.frequencies.vhf.free = Evac._state.frequencies.vhf.used
            Evac._state.frequencies.vhf.used = {}
        end

        local _vhf = table.remove(Evac._state.frequencies.vhf.free, math.random(1, #Evac._state.frequencies.vhf.free))
        table.insert(Evac._state.frequencies.vhf.used, _vhf)

        if #Evac._state.frequencies.fm.free <= 0 then
            Evac._state.frequencies.fm.free = Evac._state.frequencies.fm.used
            Evac._state.frequencies.fm.used = {}
        end

        local _fm = table.remove(Evac._state.frequencies.fm.free, math.random(1, #Evac._state.frequencies.fm.free))
        table.insert(Evac._state.frequencies.fm.used, _fm)

        return {
            uhf = _uhf,
            vhf = _vhf,
            fm = _fm
        }
    end,
    list = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Listing Beacons For Unit : %s', tostring(_unit)))

        if _unit ~= nil then
            local _unitObj
            if type(_unit) == 'string' then
                _unitObj = Unit.getByName(_unit)
            else
                _unitObj = _unit
            end

            if _unitObj ~= nil then
                local _message
                for _x, _details in pairs(Evac._state.beacons) do
                    if _details.side == (Group.getCoalition(Unit.getGroup(_unitObj)) or 0) then
                        _message = string.format('%s%s (%s)\n', _message or '', _details.group, _details.text or '')
                    end
                end

                Gremlin.log.debug(Evac.Id, string.format('Got Beacon List For Unit : %s, %s', tostring(_unit), _message or 'none'))

                if _message ~= nil and _message ~= '' then
                    Gremlin.comms.displayMessageTo(_unitObj:getGroup(), 'Evacuation Beacons:\n' .. _message, 15)
                else
                    Gremlin.comms.displayMessageTo(_unitObj:getGroup(), 'No Active Evacuation Beacons', 15)
                end
            end
        end
    end,
    update = function(_beaconDetails)
        Gremlin.log.trace(Evac.Id, string.format('Updating Beacon Lifecycles : %s', Gremlin.utils.inspect(_beaconDetails)))

        local _radioGroup = Group.getByName(_beaconDetails.group)
        if _radioGroup == nil then
            return false
        end

        local _batteryLife = _beaconDetails.battery - timer.getTime()
        if _batteryLife < 1 and _beaconDetails.battery ~= -1 then
            trigger.action.stopRadioTransmission(_beaconDetails.text .. ' | VHF')
            trigger.action.stopRadioTransmission(_beaconDetails.text .. ' | UHF')
            trigger.action.stopRadioTransmission(_beaconDetails.text .. ' | FM')
            _radioGroup:destroy()

            Gremlin.events.fire({ id = 'Evac:BeaconDead', details = _beaconDetails })
            return false
        end

        local _controller = _radioGroup:getController()
        local _sound = 'l10n/DEFAULT/' .. Evac.config.beaconSound

        _controller:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)

        trigger.action.stopRadioTransmission(_beaconDetails.text .. ' | VHF')
        trigger.action.stopRadioTransmission(_beaconDetails.text .. ' | UHF')
        trigger.action.stopRadioTransmission(_beaconDetails.text .. ' | FM')
        trigger.action.radioTransmission(_sound, _radioGroup:getUnit(1):getPoint(), 0, true, _beaconDetails.vhf, 1000, _beaconDetails.text .. ' | VHF')
        trigger.action.radioTransmission(_sound, _radioGroup:getUnit(2):getPoint(), 0, true, _beaconDetails.uhf, 1000, _beaconDetails.text .. ' | UHF')
        trigger.action.radioTransmission(_sound, _radioGroup:getUnit(3):getPoint(), 1, true, _beaconDetails.fm, 1000, _beaconDetails.text .. ' | FM')

        return true
    end,
    killDead = function()
        Gremlin.log.trace(Evac.Id, string.format('Destroying Dead Beacons'))

        timer.scheduleFunction(Evac._internal.beacons.killDead, nil, timer.getTime() + 60)

        for _index, _beaconDetails in ipairs(Evac._state.beacons) do
            if _beaconDetails.battery - timer.getTime() <= 0 and _beaconDetails.battery ~= -1 then
                for _i, _freq in ipairs(Evac._state.frequencies.uhf.used) do
                    if _freq == _beaconDetails.uhf then
                        table.insert(Evac._state.frequencies.uhf.free, _freq)
                        table.remove(Evac._state.frequencies.uhf.used, _i)
                    end
                end

                for _i, _freq in ipairs(Evac._state.frequencies.vhf.used) do
                    if _freq == _beaconDetails.vhf then
                        table.insert(Evac._state.frequencies.vhf.free, _freq)
                        table.remove(Evac._state.frequencies.vhf.used, _i)
                    end
                end

                for _i, _freq in ipairs(Evac._state.frequencies.fm.used) do
                    if _freq == _beaconDetails.fm then
                        table.insert(Evac._state.frequencies.fm.free, _freq)
                        table.remove(Evac._state.frequencies.fm.used, _i)
                    end
                end

                Gremlin.events.fire({ id = 'Evac:BeaconDead', details = _beaconDetails })
                table.remove(Evac._state.beacons, _index)
            end
        end
    end,
    generateVHFrequencies = function()
        Gremlin.log.trace(Evac.Id, string.format('Calculating VHF Frequencies'))

        local _skipFrequencies = {745, -- Astrahan
        381, 384, 300.50, 312.5, 1175, 342, 735, 300.50, 353.00, 440, 795, 525, 520, 690, 625, 291.5, 300.50, 435,
                                  309.50, 920, 1065, 274, 312.50, 580, 602, 297.50, 750, 485, 950, 214, 1025, 730, 995,
                                  455, 307, 670, 329, 395, 770, 380, 705, 300.5, 507, 740, 1030, 515, 330, 309.5, 348,
                                  462, 905, 352, 1210, 942, 435, 324, 320, 420, 311, 389, 396, 862, 680, 297.5, 920,
                                  662, 866, 907, 309.5, 822, 515, 470, 342, 1182, 309.5, 720, 528, 337, 312.5, 830, 740,
                                  309.5, 641, 312, 722, 682, 1050, 1116, 935, 1000, 430, 577, 326 -- Nevada
        }

        Evac._state.frequencies.vhf.free = {}
        local _start = 200000

        while _start < 400000 do
            local _found = false
            for _, value in pairs(_skipFrequencies) do
                if value * 1000 == _start then
                    _found = true
                    break
                end
            end

            if _found == false then
                table.insert(Evac._state.frequencies.vhf.free, _start)
            end

            _start = _start + 10000
        end

        _start = 400000
        while _start < 850000 do
            local _found = false
            for _, value in pairs(_skipFrequencies) do
                if value * 1000 == _start then
                    _found = true
                    break
                end
            end

            if _found == false then
                table.insert(Evac._state.frequencies.vhf.free, _start)
            end

            _start = _start + 10000
        end

        _start = 850000
        while _start <= 1250000 do
            local _found = false
            for _, value in pairs(_skipFrequencies) do
                if value * 1000 == _start then
                    _found = true
                    break
                end
            end

            if _found == false then
                table.insert(Evac._state.frequencies.vhf.free, _start)
            end

            _start = _start + 50000
        end
    end,
    generateUHFrequencies = function()
        Gremlin.log.trace(Evac.Id, string.format('Calculating UHF Frequencies'))

        Evac._state.frequencies.uhf.free = {}
        local _start = 220000000

        while _start < 399000000 do
            table.insert(Evac._state.frequencies.uhf.free, _start)
            _start = _start + 500000
        end
    end,
    generateFMFrequencies = function()
        Gremlin.log.trace(Evac.Id, string.format('Calculating FM Frequencies'))

        Evac._state.frequencies.fm.free = {}
        local _start = 220000000

        while _start < 399000000 do
            _start = _start + 500000
        end

        for _first = 3, 7 do
            for _second = 0, 5 do
                for _third = 0, 9 do
                    for _fourth = 0, 1 do
                        local _frequency = ((1000 * _first) + (100 * _second) + (10 * _third) + (5 * _fourth)) * 10000
                        table.insert(Evac._state.frequencies.fm.free, _frequency)
                    end
                end
            end
        end
    end
}

--- Smoke.
-- Internal methods for working with smoke.
--
-- @local Evac._internal.smoke
Evac._internal.smoke = {
    refresh = function()
        Gremlin.log.trace(Evac.Id, string.format('Refreshing Smoke'))

        for _, _zoneData in pairs(Gremlin.utils.mergeTables(Evac._state.zones.evac, Evac._state.zones.relay, Evac._state.zones.safe)) do
            local _zone = trigger.misc.getZone(_zoneData.name)
            if _zone ~= nil and _zoneData.active and _zoneData.smoke ~= nil then
                local _pos2 = {
                    x = _zone.point.x,
                    y = _zone.point.z
                }
                local _alt = land.getHeight(_pos2)
                local _pos3 = {
                    x = _pos2.x,
                    y = _alt,
                    z = _pos2.y
                }

                trigger.action.smoke(_pos3, _zoneData.smoke)
            end
        end

        timer.scheduleFunction(Evac._internal.smoke.refresh, nil, timer.getTime() + 300)
    end
}

--- Zones.
-- Internal methods for working with zones.
--
-- @local Evac._internal.zones
Evac._internal.zones = {
    register = function(_zone, _smoke, _side, _evacMode)
        Gremlin.log.trace(Evac.Id, string.format('Registering Zone Internally : %s, %i, %i, %i', _zone, _smoke or -1, _side, _evacMode))

        Evac._state.zones[Evac.modeToText[_evacMode]][_zone] = {
            active = false,
            name = _zone,
            side = _side,
            smoke = _smoke,
            mode = _evacMode
        }
        Evac._state.extractableNow[_zone] = {}
        Gremlin.events.fire({ id = 'Evac:ZoneAdd', zone = _zone, mode = _evacMode })
    end,
    generateEvacuees = function(_side, _numberOrComposition, _country)
        if type(_numberOrComposition) == 'table' then
            Gremlin.log.trace(Evac.Id, string.format('Generating Evacuees : %i, %s, %i', _side, Gremlin.utils.inspect(_numberOrComposition), _country))
        else
            Gremlin.log.trace(Evac.Id, string.format('Generating Evacuees : %i, %i, %i', _side, _numberOrComposition, _country))
        end

        local _groupName = 'Evacuee Group'
        local _unitType = 'Generic'
        local _groupId = Evac._internal.utils.getNextGroupId()
        local _composition = {}
        local _troops = {}
        local _weight = 0

        if type(_numberOrComposition) == 'number' then
            for _i = 1, _numberOrComposition do
                _composition[_i] = {
                    type = _unitType
                }
            end
        else
            _composition = _numberOrComposition or {}
        end

        for _i, _unit in ipairs(_composition) do
            if _unit.type == nil then
                _unit.type = _unitType
            end
            if _unit.unitId == nil then
                _unit.unitId = Evac._internal.utils.getNextUnitId()
            end
            if _unit.unitName == nil then
                _unit.unitName = string.format('Evacuee: %s #%i', _unit.type, _unit.unitId)
            end
            if _unit.weight == nil then
                _unit.weight = Evac._internal.utils.randomizeWeight(Evac.config.spawnWeight)
            end

            _troops[_i] = _unit
            _weight = _weight + _unit.weight
        end

        return {
            units = _troops,
            groupId = _groupId,
            groupName = string.format('%s %i', _groupName, _groupId),
            side = _side,
            country = _country,
            weight = _weight
        }
    end,
    activate = function(_zone, _evacMode)
        Gremlin.log.trace(Evac.Id, string.format('Activating Zone Internally : %s, %i', _zone, _evacMode))

        if
            Evac.modeToText[_evacMode] ~= nil and
            Evac._state.zones[Evac.modeToText[_evacMode]] ~= nil and
            Evac._state.zones[Evac.modeToText[_evacMode]][_zone] ~= nil
        then
            Gremlin.events.fire({ id = 'Evac:ZoneActive', zone = _zone, mode = _evacMode })
            Evac._state.zones[Evac.modeToText[_evacMode]][_zone].active = true
        end
    end,
    setRemaining = function(_zone, _side, _country, _numberOrComposition)
        if type(_numberOrComposition) == 'table' then
            Gremlin.log.trace(Evac.Id,
                string.format('Setting Remaning Evacuees Internally : %s, %i, %i, %s', _zone, _side, _country,
                    Gremlin.utils.inspect(_numberOrComposition)))
        else
            Gremlin.log.trace(Evac.Id, string.format('Setting Remaning Evacuees Internally : %s, %i, %i, %i', _zone,
                _side, _country, _numberOrComposition))
        end

        for _unitName, _unit in pairs(Evac._state.extractableNow[_zone]) do
            if not Evac._internal.aircraft.inZone(_unitName, _zone) then
                local _newZone = Evac._internal.utils.getUnitZone(_unitName)

                if _newZone ~= nil and Evac._state.extractableNow[_newZone] ~= nil then
                    Evac._state.extractableNow[_newZone][_unitName] = _unit
                end
            else
                Unit.getByName(_unitName):destroy()
            end

            Evac._state.extractableNow[_zone][_unitName] = nil
        end

        Evac.groups.spawn(_side, _numberOrComposition, _country, _zone, 5)
    end,
    count = function(_zone, _evacMode)
        Gremlin.log.trace(Evac.Id, string.format('Counting Units In Zone Internally : %s, %i', _zone, _evacMode))

        local _count = 0

        if Evac._state.zones[Evac.modeToText[_evacMode]][_zone] ~= nil then
            -- Can't use # here, since the keys on this table are not integers, so we count instead
            for _, _ in pairs(Evac._state.extractableNow[_zone]) do
                _count = _count + 1
            end
        end

        return _count
    end,
    isIn = function(_unit, _evacMode)
        Gremlin.log.trace(Evac.Id, string.format('Checking Whether Unit Is In Zones Internally : %s, %s', _unit, tostring(_evacMode)))

        local _unitObj = Unit.getByName(_unit)

        if _unitObj ~= nil then
            if type(_evacMode) == 'string' then
                local _zone = _evacMode
                local _zoneData = Evac._state.zones.evac[_zone] or Evac._state.zones.relay[_zone] or Evac._state.zones.safe[_zone] or { active = false }
                local _zoneExists = trigger.misc.getZone(_zone) ~= nil
                local _unitPoint = _unitObj:getPoint()

                return _zoneExists and _zoneData.active and mist.pointInZone(_unitPoint, _zone)
            else
                for _, _zoneData in pairs(Evac._state.zones[Evac.modeToText[_evacMode]]) do
                    local _zoneExists = trigger.misc.getZone(_zoneData.name) ~= nil
                    if _zoneExists and _zoneData.active and mist.pointInZone(_unitObj:getPoint(), _zoneData.name) then
                        return true
                    end
                end
            end
        end

        return false
    end,
    deactivate = function(_zone, _evacMode)
        Gremlin.log.trace(Evac.Id, string.format('Deactivating Zone Internally : %s, %i', _zone, _evacMode))

        Gremlin.events.fire({ id = 'Evac:ZoneInactive', zone = _zone, mode = _evacMode })
        Evac._state.zones[Evac.modeToText[_evacMode]][_zone].active = false
    end,
    unregister = function(_zone, _evacMode)
        Gremlin.log.trace(Evac.Id, string.format('Unregistering Zone Internally : %s, %i', _zone, _evacMode))

        for _unit, _ in pairs(Evac._state.extractableNow[_zone]) do
            local _unitObj = Unit.getByName(_unit)
            if _unitObj ~= nil then
                _unitObj:destroy()
            end
        end

        Gremlin.events.fire({ id = 'Evac:ZoneRemove', zone = _zone, mode = _evacMode })
        Evac._state.extractableNow[_zone] = nil
        Evac._state.zones[Evac.modeToText[_evacMode]][_zone] = nil
    end
}

--- Menu.
-- Internal methods for working with the F10 menu.
--
-- @local Evac._internal.menu
Evac._internal.menu = {
    updateF10 = function()
        Gremlin.log.trace(Evac.Id, string.format('Updating Menu'))

        timer.scheduleFunction(Evac._internal.menu.updateF10, nil, timer.getTime() + 5)

        Gremlin.menu.updateF10(Evac.Id, Evac._internal.menu.commands, Evac._internal.utils.extractionUnitsToMenuUnits())
    end,
    commands = {{
        text = function(_unit)
            return string.format('Scan For Evacuation Beacons (%i aboard)', Evac._internal.aircraft.countEvacuees(_unit))
        end,
        func = Evac.units.findEvacuees,
        args = {'{unit}:name'},
        when = true
    }, {
        text = function(_unit)
            local _unitObj = Unit.getByName(_unit)
            if _unitObj ~= nil then
                local _zone = Evac._internal.utils.getUnitZone(_unit)
                local _seats = ((Evac.config.carryLimits[_unitObj:getTypeName()] or 0) - Evac._internal.aircraft.countEvacuees(_unit))
                return string.format('Load %i Evacuees (%i in area)', math.min(_seats, Gremlin.utils.countTableEntries(Evac._state.extractableNow[_zone])), Gremlin.utils.countTableEntries(Evac._state.extractableNow[_zone]))
            end
        end,
        func = Evac.units.loadEvacuees,
        args = {'{unit}:name'},
        when = {
            func = function(_unit)
                if not Evac._internal.aircraft.inAir(_unit) and (Evac.zones.evac.isIn(_unit) or Evac.zones.relay.isIn(_unit)) then
                    local _unitObj = Unit.getByName(_unit)
                    if _unitObj ~= nil then
                        local _zone = Evac._internal.utils.getUnitZone(_unit)
                        if _zone ~= nil then
                            local _seats = ((Evac.config.carryLimits[_unitObj:getTypeName()] or 0) - Evac._internal.aircraft.countEvacuees(_unit))
                            Gremlin.log.trace(Evac.Id, string.format('Recording Maximum Loadable : %i', _seats))
                            return (math.min(_seats, Gremlin.utils.countTableEntries(Evac._state.extractableNow[_zone])) > 0)
                        end
                    end
                end

                return false
            end,
            args = {'{unit}:name'},
            comp = 'equal',
            value = true
        }
    }, {
        text = function(_unit)
            return string.format('Unload %i Evacuees', Evac._internal.aircraft.countEvacuees(_unit))
        end,
        func = Evac.units.unloadEvacuees,
        args = {'{unit}:name'},
        when = {
            func = function(_unit)
                if not Evac._internal.aircraft.inAir(_unit) and (Evac.zones.safe.isIn(_unit) or Evac.zones.relay.isIn(_unit)) then
                    return Evac._internal.aircraft.countEvacuees(_unit)
                end

                return 0
            end,
            args = {'{unit}:name'},
            comp = 'inequal',
            value = 0
        }
    }}
}

--- Utilities.
-- Internal methods for miscellaneous purposes.
--
-- @local Evac._internal.utils
Evac._internal.utils = {
    currentGroup = Evac.config.idStart + 0,
    currentUnit = Evac.config.idStart + 0,
    endIfEnoughGotOut = function()
        Gremlin.log.trace(Evac.Id, string.format('Checking Whether To End The Mission'))

        local _saved = Evac._internal.utils.tallyEvacueesInZones(Evac._state.zones.safe)

        -- Only check red and blue - neutral coalition win isn't available in DCS
        for _side = 1, 2 do
            local _generic = 0
            local _infantry = 0
            local _2b11 = 0
            local _m249 = 0
            local _rpg = 0
            local _stingerIgla = 0
            local _jtac = 0

            for _, _maxExtract in pairs(Evac.config.maxExtractable) do
                _generic = _generic + _maxExtract.Generic[_side]
                _infantry = _infantry + _maxExtract.Infantry[_side]
                _2b11 = _2b11 + _maxExtract['2B11'][_side]
                _m249 = _m249 + _maxExtract.M249[_side]
                _rpg = _rpg + _maxExtract.RPG[_side]
                _stingerIgla = _stingerIgla + _maxExtract.StingerIgla[_side]
                _jtac = _jtac + _maxExtract.JTAC[_side]
            end

            _generic = _saved.Generic / _generic
            _infantry = _saved.Infantry / _infantry
            _2b11 = _saved['2B11'] / _2b11
            _m249 = _saved.M249 / _m249
            _rpg = _saved.RPG / _rpg
            _stingerIgla = _saved.StingerIgla / _stingerIgla
            _jtac = _saved.JTAC / _jtac

            local _combined = (_generic + _infantry + _2b11 + _m249 + _rpg + _stingerIgla + _jtac) / 7

            if (_combined > 0 and _combined >= (Evac.config.winThresholds[_side] / 100)) or
                (_generic > 0 and _generic >= (Evac.config.winThresholds[_side] / 100)) then
                Gremlin.events.fire({ id = 'Evac:Win', side = _side })
                trigger.action.setUserFlag(Evac.config.winFlags[_side], true)
            end
        end
    end,
    endIfLossesTooHigh = function()
        Gremlin.log.trace(Evac.Id, string.format('Checking Whether To End The Mission'))

        -- Only check red and blue - neutral coalition loss isn't available in DCS
        for _side = 1, 2 do
            local _generic = 0
            local _infantry = 0
            local _2b11 = 0
            local _m249 = 0
            local _rpg = 0
            local _stingerIgla = 0
            local _jtac = 0

            local _lost = Gremlin.utils.innerSquash(Evac._state.lostEvacuees, _side)

            for _, _maxExtract in pairs(Evac.config.maxExtractable) do
                local _limits = Gremlin.utils.innerSquash(_maxExtract, _side)

                _generic = _generic + _limits.Generic
                _infantry = _infantry + _limits.Infantry
                _2b11 = _2b11 + _limits['2B11']
                _m249 = _m249 + _limits.M249
                _rpg = _rpg + _limits.RPG
                _stingerIgla = _stingerIgla + _limits.StingerIgla
                _jtac = _jtac + _limits.JTAC
            end

            _generic = _lost.Generic / _generic
            _infantry = _lost.Infantry / _infantry
            _2b11 = _lost['2B11'] / _2b11
            _m249 = _lost.M249 / _m249
            _rpg = _lost.RPG / _rpg
            _stingerIgla = _lost.StingerIgla / _stingerIgla
            _jtac = _lost.JTAC / _jtac

            local _combined = (_generic + _infantry + _2b11 + _m249 + _rpg + _stingerIgla + _jtac) / 7

            if (_combined > 0 and _combined >= (Evac.config.lossThresholds[_side] / 100))
                or (_generic > 0 and _generic >= (Evac.config.lossThresholds[_side] / 100)) then
                    Gremlin.events.fire({ id = 'Evac:Loss', side = _side })
                    trigger.action.setUserFlag(Evac.config.lossFlags[_side], true)
            end
        end
    end,
    extractionUnitsToMenuUnits = function()
        local _menuUnits = {}

        for _unitName, _onBoard in pairs(Evac._state.extractionUnits) do
            _menuUnits[_unitName] = _onBoard[0]
        end

        return _menuUnits
    end,
    getNextGroupId = function()
        Gremlin.log.trace(Evac.Id, string.format('Getting Next Group ID'))

        Evac._internal.utils.currentGroup = Evac._internal.utils.currentGroup + 1

        return Evac._internal.utils.currentGroup
    end,
    getNextUnitId = function()
        Gremlin.log.trace(Evac.Id, string.format('Getting Next Unit ID'))

        Evac._internal.utils.currentUnit = Evac._internal.utils.currentUnit + 1

        return Evac._internal.utils.currentUnit
    end,
    getUnitZone = function(_unit)
        Gremlin.log.trace(Evac.Id, string.format('Getting Unit Zone : %s', _unit))

        local _zones = Gremlin.utils.getUnitZones(_unit)
        local _outZones = {}

        for _, _zone in pairs(_zones) do
            if Evac._state.zones.evac[_zone] ~= nil or Evac._state.zones.relay[_zone] ~= nil or Evac._state.zones.safe[_zone] ~= nil then
                table.insert(_outZones, _zone)
            end
        end

        Gremlin.log.debug(Evac.Id,
            string.format('Returning Unit Zone == %s : %s is in %s', _outZones[1], _unit,
                Gremlin.utils.inspect(_outZones)))

        return _outZones[1]
    end,
    randomizeWeight = function(_weight)
        Gremlin.log.trace(Evac.Id, string.format('Randomizing Weight : %i', _weight or -1))

        return (math.random(90, 120) * (_weight or Evac.config.spawnWeight)) / 100
    end,
    tallyEvacueesInZones = function(_zoneList)
        local _evacCounter = {
            Generic = 0,
            Infantry = 0,
            ['2B11'] = 0,
            M249 = 0,
            RPG = 0,
            StingerIgla = 0,
            JTAC = 0,
        }

        for _zone, _ in pairs(_zoneList) do
            for _, _evacuee in pairs(Evac._state.extractableNow[_zone] or {}) do
                _evacCounter[_evacuee.type] = (_evacCounter[_evacuee.type] or 0) + 1
            end
        end

        return _evacCounter
    end,
    unitDataToList = function(_side, _units, _point, _scatterRadius)
        Gremlin.log.trace(Evac.Id, string.format('Converting Evac Unit Descriptions To DCS Internal Specs'))

        local typeTranslation = {
            [0] = { -- Neutral
                Generic = 'Carrier Seaman',
                Infantry = 'Soldier AK',
                M249 = 'Soldier M249',
                RPG = 'Paratrooper RPG-16',
                StingerIgla = 'Igla manpad INS',
                ['2B11'] = '2B11 mortar',
                JTAC = 'JTAC',
            },
            [1] = { -- RedFor
                Generic = 'Carrier Seaman',
                Infantry = 'Soldier AK',
                M249 = 'Soldier M249',
                RPG = 'Paratrooper RPG-16',
                StingerIgla = 'Igla manpad INS',
                ['2B11'] = '2B11 mortar',
                JTAC = 'JTAC',
            },
            [2] = { -- BlueFor
                Generic = 'Carrier Seaman',
                Infantry = 'Soldier M4',
                M249 = 'Soldier M249',
                RPG = 'Soldier RPG',
                StingerIgla = 'Soldier stinger',
                ['2B11'] = '2B11 mortar',
                JTAC = 'JTAC',
            },
        }

        local _unitsOut = {}
        ---@diagnostic disable-next-line: deprecated
        local _angle = math.atan2(_point.z, _point.x)

        for _i, _unit in pairs(_units) do
            local _xOffset = math.cos(_angle) * math.random(_scatterRadius)
            local _yOffset = math.sin(_angle) * math.random(_scatterRadius)

            _unitsOut[_i] = {
                type = typeTranslation[_side][_unit.type],
                unitId = _unit.unitId,
                name = _unit.unitName,
                skill = 'Excellent',
                playerCanDrive = false,
                x = _point.x + _xOffset,
                y = _point.z + _yOffset,
                heading = _angle
            }

            if _unitsOut[_i].type == 'Carrier Seaman' then
                _unitsOut[_i].shape = 'carrier_seaman_USA'
                _unitsOut[_i].type = nil
            end
        end

        return _unitsOut
    end,
}

--- Auto-spawn.
-- Internal methods for managing spawn rules.
--
-- @local Evac._internal.spawns
Evac._internal.spawns = {
    timed = {
        iterate = function()
            Gremlin.log.trace(Evac.Id, string.format('Auto-Spawning Time-Based Units (As Needed)'))

            timer.scheduleFunction(Evac._internal.spawns.timed.iterate, nil, timer.getTime() + 1)

            for _zone, _rates in pairs(Evac._state.spawns.pending) do
                local _lastSpawned = Evac._state.spawns.lastSpawned[_zone] or 0

                for _idx, _rate in pairs(_rates) do
                    if Evac._internal.spawns.checkTrigger(_rate.startTrigger, 'time', nil)
                        or Evac._internal.spawns.checkTrigger(_rate.startTrigger, 'repeat', _lastSpawned)
                        or Evac._internal.spawns.checkTrigger(_rate.startTrigger, 'flag', nil) then
                            Evac._state.spawns.lastSpawned[_zone] = timer.getTime()
                            Evac._internal.spawns.start(_rate, _zone, _idx)
                    end
                end
            end

            for _zone, _rates in pairs(Evac._state.spawns.active) do
                local _lastSpawned = Evac._state.spawns.lastSpawned[_zone] or 0
                local _addedUnits = false

                if _zone == '_global' then
                    for _zoneName, _zoneData in pairs(Evac._state.zones.evac) do
                        if _zoneData.active then
                            _addedUnits = Evac._internal.spawns.timed.loop(_zoneName, _rates, _lastSpawned) or _addedUnits
                        end
                    end
                else
                    local _zoneData = Evac._state.zones.evac[_zone]
                    if _zoneData.active then
                        _addedUnits = Evac._internal.spawns.timed.loop(_zone, _rates, _lastSpawned)
                    end
                end

                if _addedUnits then
                    Evac._state.spawns.lastSpawned[_zone] = timer.getTime()
                end
            end

            Evac._state.spawns.lastSpawned[0] = timer.getTime()

            Gremlin.log.debug(Evac.Id, string.format('Finished Auto-Spawning Time-Based Units (As Needed)'))
        end,
        loop = function(_zone, _rates, _lastSpawned)
            Gremlin.log.debug(Evac.Id, string.format('Auto-Spawning In Zone : %s, %s, %s', _zone, Gremlin.utils.inspect(_rates), tostring(_lastSpawned)))

            local _addedUnits = false

            for _idx, _rate in pairs(_rates) do
                if Evac._internal.spawns.checkTrigger(_rate.spawnTrigger, 'time', nil)
                    or Evac._internal.spawns.checkTrigger(_rate.spawnTrigger, 'repeat', _lastSpawned)
                    or Evac._internal.spawns.checkTrigger(_rate.spawnTrigger, 'flag', nil) then
                        _addedUnits = Evac._internal.spawns.run(_rate, _zone, _idx) or _addedUnits
                end

                if Evac._internal.spawns.checkTrigger(_rate.endTrigger, 'time', nil)
                    or Evac._internal.spawns.checkTrigger(_rate.endTrigger, 'repeat', _lastSpawned)
                    or Evac._internal.spawns.checkTrigger(_rate.endTrigger, 'flag', nil) then
                        Evac._internal.spawns.finish(_rate, _zone, _idx)
                end
            end

            return _addedUnits
        end,
    },
    checkTrigger = function(_trigger, _type, _extra)
        if _trigger.type == _type then
            if Gremlin.utils.checkTrigger(_trigger, _type, _extra) then
                return true
            elseif _trigger.type == 'limits' then
                local _allowed = Evac._internal.spawns.allowed(_extra.zone, _extra.side)[0]
                local _remaining = Evac._internal.spawns.remaining(_extra.zone, _extra.side)[0]
                local _spawned = _allowed - _remaining
                local _ratio = _spawned / _allowed

                return _ratio >= (_trigger.value / 100)
            end
        end

        return false
    end,
    allowed = function(_zone, _side)
        Gremlin.log.debug(Evac.Id, string.format('Checking Whether We Can Spawn More Evacuees : %s side has %s out of %s already spawned', Gremlin.SideToText[_side], Gremlin.utils.inspect(Gremlin.utils.innerSquash(Evac._state.spawns.alreadySpawned, _side)), Gremlin.utils.inspect(Gremlin.utils.innerSquash(Evac.config.maxExtractable[_zone] or Evac.config.maxExtractable._global, _side))))

        local _allowed = Gremlin.utils.innerSquash(Evac.config.maxExtractable[_zone] or Evac.config.maxExtractable._global, _side)

        _allowed[0] = _allowed.Generic + _allowed.Infantry + _allowed.M249 + _allowed.RPG + _allowed.StingerIgla + _allowed['2B11'] + _allowed.JTAC

        Gremlin.log.debug(Evac.Id, string.format('Checked Whether We Can Spawn More Evacuees : remaining spawns are %s', Gremlin.utils.inspect(_allowed)))

        return _allowed
    end,
    remaining = function(_zone, _side)
        local _limits = Gremlin.utils.innerSquash(Evac.config.maxExtractable[_zone] or Evac.config.maxExtractable._global, _side)
        local _exists = Gremlin.utils.innerSquash(Evac._state.spawns.alreadySpawned, _side)

        Gremlin.log.debug(
            Evac.Id,
            string.format(
                'Checking Whether We Can Spawn More Evacuees : %s side has %s out of %s already spawned',
                Gremlin.SideToText[_side],
                Gremlin.utils.inspect(_exists),
                Gremlin.utils.inspect(_limits)
            )
        )

        local _haveLeft = {}

        _haveLeft.Generic = _limits.Generic - _exists.Generic
        _haveLeft.Infantry = _limits.Infantry - _exists.Infantry
        _haveLeft.M249 = _limits.M249 - _exists.M249
        _haveLeft.RPG = _limits.RPG - _exists.RPG
        _haveLeft.StingerIgla = _limits.StingerIgla - _exists.StingerIgla
        _haveLeft['2B11'] = _limits['2B11'] - _exists['2B11']
        _haveLeft.JTAC = _limits.JTAC - _exists.JTAC

        _haveLeft[0] = _haveLeft.Generic + _haveLeft.Infantry + _haveLeft.M249 + _haveLeft.RPG + _haveLeft.StingerIgla + _haveLeft['2B11'] + _haveLeft.JTAC

        Gremlin.log.debug(Evac.Id, string.format('Checked Whether We Can Spawn More Evacuees : remaining spawns are %s', Gremlin.utils.inspect(_haveLeft)))

        return _haveLeft
    end,
    preload = function()
        Gremlin.log.trace(Evac.Id, string.format('Preloading Spawn Rules'))

        local _counter = 0

        Evac._state.spawns = {
            alreadySpawned = {
                Generic = { 0, 0, [0] = 0 },
                Infantry = { 0, 0, [0] = 0 },
                M249 = { 0, 0, [0] = 0 },
                RPG = { 0, 0, [0] = 0 },
                StingerIgla = { 0, 0, [0] = 0 },
                ['2B11'] = { 0, 0, [0] = 0 },
                JTAC = { 0, 0, [0] = 0 },
            },
            pending = {},
            active = {},
            completed = {},
            lastSpawned = {},
        }

        for _zone, _rates in pairs(Evac.config.spawnRates) do
            Evac._state.spawns.pending[_zone] = Evac._state.spawns.pending[_zone] or {}

            for _idx, _rate in pairs(_rates) do
                table.insert(Evac._state.spawns.pending[_zone], _rate)
                _counter = _counter + 1

                if _rate.startTrigger.type == 'event' then
                    ---@diagnostic disable-next-line: undefined-field
                    Gremlin.events.on(_rate.startTrigger.value.id, function(_event)
                        ---@diagnostic disable-next-line: undefined-field
                        if _rate.startTrigger.value.filter(_event) then
                            Evac._internal.spawns.start(_rate, _zone, _idx)
                        end
                    end)
                elseif _rate.startTrigger.type == 'menu' then
                    Evac._internal.menu.commands[string.format('%s-%i-start', _zone, _idx)] = {
                        text = _rate.startTrigger.value or string.format('Activate Evacuee Spawn : %s %i', _zone, _idx),
                        func = Evac._internal.spawns.start,
                        args = { _rate, _zone, _idx },
                        when = {
                            func = function(_unit)
                                return Gremlin.utils.isInTable(Evac._internal.aircraft.getAdminList(), _unit)
                            end,
                            args = { '{unit}:name' },
                            comp = 'equal',
                            value = true,
                        }
                    }
                end
            end
        end

        Gremlin.log.trace(Evac.Id, string.format('Preloaded %i Spawn Rules', _counter))
    end,
    start = function(_rate, _zone, _idx)
        if Evac._state.spawns.active[_zone] == nil then
            Evac._state.spawns.active[_zone] = {}
        end

        if _rate.spawnTrigger.type == 'event' then
            ---@diagnostic disable-next-line: undefined-field
            _rate.spawnTrigger.storedAt = Gremlin.events.on(_rate.spawnTrigger.value.id, function(_event)
                ---@diagnostic disable-next-line: undefined-field
                if _rate.spawnTrigger.value.filter(_event) then
                    Evac._internal.spawns.by.event(_zone, _rate, _event)
                end
            end)
        elseif _rate.spawnTrigger.type == 'menu' then
            Evac._internal.menu.commands[string.format('%s-%i-spawn', _zone, _idx)] = {
                text = _rate.spawnTrigger.value or string.format('Spawn Evacuees : %s %i', _zone, _idx),
                func = Evac._internal.spawns.by.menu,
                args = { _zone, _rate },
                when = {
                    func = function(_unit)
                        return Gremlin.utils.isInTable(Evac._internal.aircraft.getAdminList(), _unit)
                    end,
                    args = { '{unit}:name' },
                    comp = 'equal',
                    value = true,
                }
            }
        end

        if _rate.endTrigger.type == 'event' then
            ---@diagnostic disable-next-line: undefined-field
            _rate.endTrigger.storedAt = Gremlin.events.on(_rate.endTrigger.value.id, function(_event)
                ---@diagnostic disable-next-line: undefined-field
                if _rate.endTrigger.value.filter(_event) then
                    Evac._internal.spawns.finish(_rate, _zone, _idx)
                end
            end)
        elseif _rate.endTrigger.type == 'menu' then
            Evac._internal.menu.commands[string.format('%s-%i-end', _zone, _idx)] = {
                text = _rate.endTrigger.value or string.format('Deactivate Evacuee Spawn : %s %i', _zone, _idx),
                func = Evac._internal.spawns.finish,
                args = { _rate, _zone, _idx },
                when = {
                    func = function(_unit)
                        return Gremlin.utils.isInTable(Evac._internal.aircraft.getAdminList(), _unit)
                    end,
                    args = { '{unit}:name' },
                    comp = 'equal',
                    value = true,
                }
            }
        end

        table.insert(Evac._state.spawns.active[_zone], _rate)

        if _rate.startTrigger.type == 'time' then
            Evac._state.spawns.pending[_zone][_idx] = nil
        end
    end,
    run = function(_rate, _zone, _idx)
        local _addedUnits = false
        local _spawnLimits = Evac._internal.spawns.remaining(_zone, _rate.side)

        -- Figure out what to spawn and where
        local _units
        if _rate.units == 0 then
            _units = {}
            for _type, _allowed in pairs(_spawnLimits) do
                if _type ~= 0 then
                    for i = 1, _allowed do
                        table.insert(_units, { type = _type })
                    end
                end
            end
        else
            _units = _rate.units
        end

        if type(_units) == 'number' then
            _units = math.min(_units, _spawnLimits[0])
        else
            local _have = { Generic = 0, Infantry = 0, M249 = 0, RPG = 0, StingerIgla = 0, ['2B11'] = 0, JTAC = 0 }

            for _i, _unit in pairs(_units) do
                if (_spawnLimits[_unit.type] or 0) <= (_have[_unit.type] or 0) then
                    -- Change the type to Generic, if possible, or remove it entirely otherwise
                    -- Tries to spawn the right number of units even if it can't spawn the exact types
                    if _unit.type ~= 'Generic' and _spawnLimits.Generic >= _have.Generic then
                        _units[_i] = Gremlin.utils.mergeTables(_unit, { type = 'Generic' })
                    else
                        _units[_i] = nil
                    end

                    _unit = _units[_i]
                end

                if _unit ~= nil then
                    _have[_unit.type] = (_have[_unit.type] or 0) + 1
                end
            end
        end

        -- Actually Spawn Units
        if type(_units) == 'number' and _units < 0 then
            local _spawned = #(Evac._state.extractableNow[_zone] or {})
            local _removed = 0

            for _idx, _unit in pairs(Evac._state.extractableNow[_zone]) do
                if _removed >= math.abs(_units) or _removed >= _spawned then
                    break
                end

                local _unitObj = Unit.getByName(_unit.unitName)
                if _unitObj ~= nil then
                    _unitObj:destroy()
                end

                Evac._state.extractableNow[_zone][_idx] = nil
                _removed = _removed + 1
            end

            Gremlin.events.fire({ id = 'Evac:Spawned', units = -_removed, zone = _zone })
            Gremlin.log.debug(Evac.Id, string.format('Removed %i evacuees from %s', _removed, _zone))
        else
            Evac.groups.spawn(_rate.side, _units, _rate.side, _zone, 5)
            _addedUnits = true

            if type(_units) == 'table' then
                Gremlin.events.fire({ id = 'Evac:Spawned', units = #_units, zone = _zone })
                Gremlin.log.debug(Evac.Id, string.format('Spawned %i evacuees in %s', #_units, _zone))
            else
                Gremlin.events.fire({ id = 'Evac:Spawned', units = _units, zone = _zone })
                Gremlin.log.debug(Evac.Id, string.format('Spawned %i evacuees in %s', _units, _zone))
            end
        end

        -- Maintain internal data structures
        if type(_units) == 'number' then
            Evac._state.spawns.alreadySpawned.Generic[_rate.side] = Evac._state.spawns.alreadySpawned.Generic[_rate.side] + _units
        elseif type(_units) == 'table' then
            for _, _unit in pairs(_units) do
                Evac._state.spawns.alreadySpawned[_unit.type][_rate.side] = Evac._state.spawns.alreadySpawned[_unit.type][_rate.side] + 1
            end
        end

        Gremlin.log.debug(Evac.Id, string.format('Evacuee Count Updated : now at %s out of %s', Gremlin.utils.inspect(Gremlin.utils.innerSquash(Evac._state.spawns.alreadySpawned, _rate.side)), Gremlin.utils.inspect(Gremlin.utils.innerSquash(Evac.config.maxExtractable[_zone] or Evac.config.maxExtractable._global, _rate.side))))

        return _addedUnits
    end,
    finish = function(_rate, _zone, _idx)
        if Evac._state.spawns.completed[_zone] == nil then
            Evac._state.spawns.completed[_zone] = {}
        end

        table.insert(Evac._state.spawns.completed[_zone], _rate)

        if _rate.spawnTrigger.type == 'event' then
            Gremlin.events.off(_rate.spawnTrigger.value.id, _rate.spawnTrigger.storedAt)
        elseif _rate.spawnTrigger.type == 'menu' then
            Evac._internal.menu.commands[string.format('%s-%i-spawn', _zone, _idx)] = nil
        end

        if _rate.endTrigger.type == 'event' then
            Gremlin.events.off(_rate.endTrigger.value.id, _rate.endTrigger.storedAt)
        elseif _rate.endTrigger.type == 'menu' then
            Evac._internal.menu.commands[string.format('%s-%i-end', _zone, _idx)] = nil
        end

        Evac._state.spawns.active[_zone][_idx] = nil
    end,
}

--- Event handlers.
-- Internal methods for working with events.
--
-- @local Evac._internal.handlers
Evac._internal.handlers = {
    fullLoss = {
        event = world.event.S_EVENT_UNIT_LOST,
        fn = function(_event)
            Gremlin.log.trace(Evac.Id, string.format('Handling Loss Event'))

            local _unit = _event.initiator

            if _unit ~= nil then
                local _name = _unit:getName()

                if Evac._state.extractionUnits[_name] ~= nil and Evac._internal.aircraft.countEvacuees(_name) > 0 then
                    local _side

                    if Evac._state.extractionUnits[_name][0] ~= nil then
                        _side = Group.getCoalition(Unit.getGroup(Evac._state.extractionUnits[_name][0]))
                    else
                        _side = 0
                    end

                    for _i, _evacuee in pairs(Evac._state.extractionUnits[_name]) do
                        if _i ~= 0 then
                            local _type = _evacuee.type

                            if _type == nil or not Gremlin.utils.isInTable({ 'Generic', '2B11', 'Infantry', 'RPG', 'M249', 'StingerIgla', 'JTAC' }, _type) then
                                _type = 'Generic'
                            end

                            if Evac._state.lostEvacuees[_type] == nil then
                                Evac._state.lostEvacuees[_type] = { 0, 0, [0] = 0 }
                            end

                            Evac._state.lostEvacuees[_type][_side] = (Evac._state.lostEvacuees[_type][_side] or 0) + 1
                        end
                    end

                    Gremlin.log.debug(Evac.Id, string.format('Lost Evacuee(s)! : %s', Evac._internal.aircraft.countEvacuees(_name)))

                    Gremlin.comms.displayMessageTo(Gremlin.SideToText[_side], string.format('We just lost %i evacuee(s)! Step it up, pilots!', Evac._internal.aircraft.countEvacuees(_name)), 15)

                    Evac._state.extractionUnits[_name] = {
                        [0] = Evac._state.extractionUnits[_name][0],
                    }
                    Evac._internal.utils.endIfLossesTooHigh()
                else
                    Gremlin.log.debug(Evac.Id, string.format('No evacuees were harmed in the making of this explosion : Unit %s Lost', _name))
                end
            end
        end
    },
    newPilot = {
        event = world.event.S_EVENT_BIRTH,
        fn = function(_event)
            Gremlin.log.trace(Evac.Id, string.format('Handling Birth Event'))

            local _unit = _event.initiator

            if _unit ~= nil then
                local _name = _unit:getName()

                if Evac._state.extractionUnits[_name] ~= nil then
                    Evac._state.extractionUnits[_name][0] = _unit

                    Gremlin.log.debug(Evac.Id, string.format('Everyone welcome our newest pilot! : Unit %s Occupied by %s', _name, _unit:getPlayerName() or 'Unknown?'))
                else
                    Gremlin.log.debug(Evac.Id, string.format('Not my circus, not my monkeys : Unit %s "Born"', _name))
                end
            end
        end
    },
}

--[[--
Top level methods.
Methods for interacting with Evac itself.

@section TopLevel
--]]--

--[[--
Setup Gremlin Evac.

The argument should contain a configuration table as shown below.

Example providing all the defaults:

```
Evac:setup({
    adminPilotNames = {},
    beaconBatteryLife = 30,
    beaconSound = 'beacon.ogg',
    carryLimits = {
        ['C-130'] = 90,
        ['CH-43E'] = 55,
        ['CH-47D'] = 44,
        ['Hercules'] = 90,
        ['Mi-8MT'] = 24,
        ['Mi-24P'] = 5,
        ['Mi-24V'] = 5,
        ['Mi-26'] = 70,
        ['SH-60B'] = 5,
        ['SH60B'] = 5,
        ['UH-1H'] = 8,
        ['UH-60L'] = 11,
    },
    idStart = 50000,
    loadUnloadPerIndividual = 30,
    lossFlags = { 'GremlinEvacRedLoss', 'GremlinEvacBlueLoss' },
    lossThresholds = { 25, 25 },
    maxExtractable = {
        _global = {
            ['Carrier Seaman'] = { 0, 0, [0] = 0 },
            Infantry = { 0, 0, [0] = 0 },
            M249 = { 0, 0, [0] = 0 },
            RPG = { 0, 0, [0] = 0 },
            StingerIgla = { 0, 0, [0] = 0 },
            ['2B11'] = { 0, 0, [0] = 0 },
            JTAC = { 0, 0, [0] = 0 },
        },
    },
    spawnRates = {
        _global = {
            {
                side = coalition.side.NEUTRAL,
                units = 0,
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            },
            {
                side = coalition.side.RED,
                units = 0,
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            },
            {
                side = coalition.side.BLUE,
                units = 0,
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            },
        },
    },
    spawnWeight = 100,
    startingUnits = {},
    startingZones = {},
    winFlags = { 'GremlinEvacRedWin', 'GremlinEvacBlueWin' },
    winThresholds = { 75, 75 },
})
```

`spawnRates` is a table whose keys are zone names, with one special zone
called `_global` that applies to the entire map. Each value is a table of sides
(the standard red = 1, blue = 2 approach), whose values are tables listing
the number or composition of units to generate, and how long to wait between
spawns. In English, it would probably be described as '{units} unit(s) every
{per} {period}(s)'. The special value 0 for `units` means 'as many as allowed';
negative values actually remove evacuees according to the same rules. `period`
should be a constant from `Gremlin.Periods`. `per` indicates how many periods
to wait between auto spawns; the special value 0 means 'mission start', while
positive values run every `per` `period`s, and negative means only spawn once
rather than repeatedly.

`startingZones` is also keyed by zone name, but the contents describe the
zone(s) themselves. Four keys are required: `mode` (one of the constants in
`Evac.modes`), `name`, `smoke` (one of the constants in `trigger.smokeColor`),
and `side` (the coalition number this zone should be attached to).

@function Evac:setup
@tparam table config   a configuration for Gremlin Evac
]]
function Evac:setup(config)
    if config == nil then
        config = {}
    end

    assert(Gremlin ~= nil,
        '\n\n** HEY MISSION-DESIGNER! **\n\nGremlin has not been loaded!\n\nMake sure Gremlin is loaded *before* running this script!\n')

    if not Gremlin.alreadyInitialized or config.forceReload then
        Gremlin:setup(config)
    end

    if Evac._state.alreadyInitialized and not config.forceReload then
        Gremlin.log.info(Evac.Id, string.format('Bypassing initialization because Evac._state.alreadyInitialized = true'))
        return
    end

    Gremlin.log.info(Evac.Id, string.format('Starting setup of %s version %s!', Evac.Id, Evac.Version))

    -- start configuration
    if not Evac._state.alreadyInitialized or config.forceReload then
        Evac.config.adminPilotNames = config.adminPilotNames or {}
        Evac.config.beaconBatteryLife = config.beaconBatteryLife or 30
        Evac.config.beaconSound = config.beaconSound or 'beacon.ogg'
        Evac.config.carryLimits = config.carryLimits or {
            ['C-130'] = 90,
            ['CH-43E'] = 55,
            ['CH-47D'] = 44,
            ['Hercules'] = 90,
            ['Mi-8MT'] = 24,
            ['Mi-24P'] = 5,
            ['Mi-24V'] = 5,
            ['Mi-26'] = 70,
            ['SH-60B'] = 5,
            ['SH60B'] = 5,
            ['UH-1H'] = 8,
            ['UH-60L'] = 11
        }
        Evac.config.idStart = config.idStart or 50000
        Evac.config.loadUnloadPerIndividual = config.loadUnloadPerIndividual or 30
        Evac.config.lossFlags = config.lossFlags or {'GremlinEvacRedLoss', 'GremlinEvacBlueLoss'}
        Evac.config.lossThresholds = config.lossThresholds or {25, 25}

        if config.maxExtractable ~= nil then
            Evac.config.maxExtractable = {}
            for _zone, _extractable in pairs(config.maxExtractable) do
                if _extractable ~= nil then
                    Evac.config.maxExtractable[_zone] = {
                        Generic = _extractable.Generic or { 0, 0, [0] = 0 },
                        Infantry = _extractable.Infantry or { 0, 0, [0] = 0 },
                        M249 = _extractable.M249 or { 0, 0, [0] = 0 },
                        RPG = _extractable.RPG or { 0, 0, [0] = 0 },
                        StingerIgla = _extractable.StingerIgla or { 0, 0, [0] = 0 },
                        ['2B11'] = _extractable['2B11'] or { 0, 0, [0] = 0 },
                        JTAC = _extractable.JTAC or { 0, 0, [0] = 0 },
                    }
                end
            end
        else
            Evac.config.maxExtractable = {
                _global = {
                    Generic = { 0, 0, [0] = 0 },
                    Infantry = { 0, 0, [0] = 0 },
                    M249 = { 0, 0, [0] = 0 },
                    RPG = { 0, 0, [0] = 0 },
                    StingerIgla = { 0, 0, [0] = 0 },
                    ['2B11'] = { 0, 0, [0] = 0 },
                    JTAC = { 0, 0, [0] = 0 },
                },
            }
        end

        Evac.config.spawnWeight = config.spawnWeight or 100
        Evac.config.spawnRates = config.spawnRates or {
            _global = {{
                side = coalition.side.NEUTRAL,
                units = 0, -- 0 loads all; + adds, - subtracts
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            }, {
                side = coalition.side.RED,
                units = 0, -- 0 loads all; + adds, - subtracts
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            }, {
                side = coalition.side.BLUE,
                units = 0, -- 0 loads all; + adds, - subtracts
                startTrigger = { type = 'time', value = 0 },
                spawnTrigger = { type = 'time', value = 0 },
                endTrigger = { type = 'limits', value = 100 },
            }}
        }

        if config.startingUnits ~= nil then
            for _, _unit in pairs(config.startingUnits) do
                Evac.units.register(_unit)
            end
        end

        if config.startingZones ~= nil then
            for _, _zone in pairs(config.startingZones) do
                local _mode = _zone.mode or Evac.modes.EVAC

                if Evac.modeToText[_mode] ~= nil then
                    Evac.zones[Evac.modeToText[_mode]].register(_zone.name, _zone.smoke, _zone.side)

                    if _zone.active then
                        Evac.zones[Evac.modeToText[_mode]].activate(_zone.name)
                    end
                else
                    Gremlin.log.error("Can't find " .. Gremlin.SideToText[_zone.side] .. ' zone ' .. _zone.name)
                end
            end
        end

        Evac.config.winFlags = config.winFlags or {'GremlinEvacRedWin', 'GremlinEvacBlueWin'}
        Evac.config.winThresholds = config.winThresholds or {75, 75}

        Gremlin.log.debug(Evac.Id, string.format('Configuration Loaded : %s', Gremlin.utils.inspect(Evac.config)))
    end
    -- end configuration

    trigger.action.setUserFlag(Evac.config.lossFlags[1], false)
    trigger.action.setUserFlag(Evac.config.lossFlags[2], false)
    trigger.action.setUserFlag(Evac.config.winFlags[1], false)
    trigger.action.setUserFlag(Evac.config.winFlags[2], false)

    Evac._internal.beacons.generateVHFrequencies()
    Evac._internal.beacons.generateUHFrequencies()
    Evac._internal.beacons.generateFMFrequencies()
    Evac._internal.spawns.preload()

    timer.scheduleFunction(function()
        timer.scheduleFunction(Evac._internal.spawns.timed.iterate, nil, timer.getTime() + 1)
        timer.scheduleFunction(Evac._internal.beacons.killDead, nil, timer.getTime() + 1)
        timer.scheduleFunction(Evac._internal.smoke.refresh, nil, timer.getTime() + 1)
        timer.scheduleFunction(Evac._internal.menu.updateF10, nil, timer.getTime() + 1)
    end, nil, timer.getTime() + 1)

    for _name, _def in pairs(Evac._internal.handlers) do
        Evac._internal.handlers[_name].id = Gremlin.events.on(_def.event, _def.fn)

        Gremlin.log.debug(Evac.Id, string.format('Registered %s event handler', _name))
    end

    Gremlin.log.info(Evac.Id, string.format('Finished setting up %s version %s!', Evac.Id, Evac.Version))

    Evac._state.alreadyInitialized = true
end
