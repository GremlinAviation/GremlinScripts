---@diagnostic disable: lowercase-global
local Mock = require("lib.mock.Mock")
local Spy = require("lib.mock.Spy")
require("Scripts.Common.LuaClass")

Object = {
    className_ = "Object",
    Category = {
        VOID = 0,
        UNIT = 1,
        WEAPON = 2,
        STATIC = 3,
        BASE = 4,
        SCENERY = 5,
        CARGO = 6,
    },
    destroy = function(self) end,
    inAir = function()
        return false
    end,
    isExist = function(self) return true end,
    getByName = function(name)
        local _myObj = { className_ = "Object", name = "test" }
        ---@diagnostic disable-next-line: undefined-global
        class(_myObj, Object)
        return _myObj
    end,
    getCategory = function(_object)
        if _object.category ~= nil then
            return _object.category
        end

        if _object.className_ == "Unit" then
            return Object.Category.UNIT
        elseif _object.className_ == "Weapon" then
            return Object.Category.WEAPON
        elseif _object.className_ == "StaticObject" then
            return Object.Category.STATIC
        elseif _object.className_ == "Airbase" then
            return Object.Category.BASE
        elseif _object.className_ == "SceneryObject" then
            return Object.Category.SCENERY
        end

        return Object.Category.VOID
    end,
    getCoalition = function(self)
        return coalition.side.BLUE
    end,
    getCountry = function(name) return 2 end,
    getID = function(self) return 1 end,
    getName = function(self)
        if self.name ~= nil then
            return self.name
        else
            return "test"
        end
    end,
    getPoint = function(self)
        if self.point ~= nil then
            return self.point
        end

        return { x = 0, y = 0, z = 0 }
    end,
    getPosition = function(self)
        return {
            p = { x = 0, y = 0, z = 0 },
            x = { x = 0, y = 0, z = 0 },
        }
    end,
    getTypeName = function(self)
        if self.typeName ~= nil then
            return self.typeName
        end

        return "Test"
    end,
    getVelocity = function(self) return { x = 0, y = 0, z = 0 } end,
}
Airbase = {
    className_ = "Airbase",
    category = Object.Category.BASE,
}
Controller = {
    className_ = "Controller",
    destroy = function(self) end,
    setOption = function(self, _id, _value) end,
}
Group = {
    className_ = "Group",
    category = "helicopter",
    Category = {
        AIRPLANE = 0,
        HELICOPTER = 1,
        GROUND = 2,
        SHIP = 3,
        TRAIN = 4,
    },
    destroy = function(self) end,
    isExist = function(self)
        return true
    end,
    getByName = function(name)
        local _name = name
        if type(name) == "table" then
            _name = name:getName()
        else
            _name = tostring(name)
        end

        if mist.DBs.groupsByName[_name] ~= nil then
            return mist.DBs.groupsByName[_name]
        end

        return nil
    end,
    getCategory = function(self)
        if self.category then
            return self.category
        end

        return Group.Category.HELICOPTER
    end,
    getCoalition = function(self)
        return coalition.side.BLUE
    end,
    getController = function(self)
        return Controller
    end,
    getID = function(self)
        if self.id ~= nil then
            return self.id
        elseif self.groupId ~= nil then
            return self.groupId
        end

        return 1
    end,
    getName = function(self)
        if self.groupName ~= nil then
            return self.groupName
        end

        return "test"
    end,
    getUnit = function(self, idx)
        return self:getUnits()[idx]
    end,
    getUnits = function(self)
        if self.units ~= nil then
            return self.units
        end

        return {}
    end,
}
SceneryObject = {
    className_ = "SceneryObject",
    category = Object.Category.SCENERY,
}
Spot = {
    className_ = "Spot",
    destroy = function(self) end,
}
StaticObject = {
    className_ = "StaticObject",
    category = Object.Category.STATIC,
}
Unit = {
    className_ = "Unit",
    category = Object.Category.UNIT,
    Category = {
        AIRPLANE = 0,
        HELICOPTER = 1,
        GROUND_UNIT = 2,
        SHIP = 3,
        STRUCTURE = 4,
    },
    OpticType = {
        TV = 0,
        LLTV = 1,
        IR = 2,
    },
    RadarType = {
        AS = 0,
        SS = 1,
    },
    RefuelingSystem = {
        BOOM_AND_RECEPTACLE = 0,
        PROBE_AND_DROGUE = 1,
    },
    SensorType = {
        OPTIC = 0,
        RADAR = 1,
        IRST = 2,
        RWR = 3,
    },
    getByName = function(name)
        local _name = name
        if name ~= nil and type(name) ~= "string" then
            _name = name:getName()
        end

        if mist.DBs.unitsByName[_name] ~= nil then
            return mist.DBs.unitsByName[_name]
        end

        if Evac ~= nil then
            for _, _units in pairs(Evac._state.extractableNow) do
                if _units[_name] ~= nil and _units[_name][0] ~= nil then
                    return _units[_name][0].object or _units[_name][0]
                end
            end
        end

        return nil
    end,
    getCallsign = function(self)
        return "Test-1-1"
    end,
    getGroup = function(self)
        if self.groupName ~= nil then
            return Group.getByName(self.groupName)
        end

        return nil
    end,
    getID = function(self)
        if self.id ~= nil then
            return self.id
        end

        return 1
    end,
    getName = function(self)
        if self.unitName ~= nil then
            return self.unitName
        else
            return "test"
        end
    end,
    getPlayerName = function(_self)
        return "Al Gore"
    end,
    getTypeName = function(self)
        if self.type ~= nil then
            return self.type
        end

        return "UH-1H"
    end,
    isActive = function(self)
        return true
    end,
}
Warehouse = {
    className_ = "Warehouse",
    destroy = function(self) end,
}
Weapon = {
    className_ = "Weapon",
    category = Object.Category.WEAPON,
}

AI = {
    Option = {
        Air = {
            id = {
                ECM_USING = 13,
                FLARE_USING = 4,
                FORCED_ATTACK = 26,
                FORMATION = 5,
                JETT_TANKS_IF_EMPTY = 25,
                MISSILE_ATTACK = 18,
                NO_OPTION = -1,
                OPTION_RADIO_USAGE_CONTACT = 21,
                OPTION_RADIO_USAGE_ENGAGE = 22,
                OPTION_RADIO_USAGE_KILL = 23,
                PREFER_VERTICAL = 32,
                PROHIBIT_AA = 14,
                PROHIBIT_AB = 16,
                PROHIBIT_AG = 17,
                PROHIBIT_JETT = 15,
                PROHIBIT_WP_PASS_REPORT = 19,
                RADAR_USING = 3,
                REACTION_ON_THREAT = 1,
                ROE = 0,
                RTB_ON_BINGO = 6,
                RTB_ON_OUT_OF_AMMO = 10,
                SILENCE = 7
            },
            val = {
                ECM_USING = {
                    ALWAYS_USE = 3,
                    NEVER_USE = 0,
                    USE_IF_DETECTED_LOCK_BY_RADAR = 2,
                    USE_IF_ONLY_LOCK_BY_RADAR = 1
                },
                FLARE_USING = {
                    AGAINST_FIRED_MISSILE = 1,
                    NEVER = 0,
                    WHEN_FLYING_IN_SAM_WEZ = 2,
                    WHEN_FLYING_NEAR_ENEMIES = 3
                },
                MISSILE_ATTACK = {
                    HALF_WAY_RMAX_NEZ = 2,
                    MAX_RANGE = 0,
                    NEZ_RANGE = 1,
                    RANDOM_RANGE = 4,
                    TARGET_THREAT_EST = 3
                },
                RADAR_USING = {
                    FOR_ATTACK_ONLY = 1,
                    FOR_CONTINUOUS_SEARCH = 3,
                    FOR_SEARCH_IF_REQUIRED = 2,
                    NEVER = 0
                },
                REACTION_ON_THREAT = {
                    ALLOW_ABORT_MISSION = 4,
                    BYPASS_AND_ESCAPE = 3,
                    EVADE_FIRE = 2,
                    NO_REACTION = 0,
                    PASSIVE_DEFENCE = 1
                },
                ROE = {
                    OPEN_FIRE = 2,
                    OPEN_FIRE_WEAPON_FREE = 1,
                    RETURN_FIRE = 3,
                    WEAPON_FREE = 0,
                    WEAPON_HOLD = 4
                }
            }
        },
        Ground = {
            id = {
                AC_ENGAGEMENT_RANGE_RESTRICTION = 24,
                ALARM_STATE = 9,
                DISPERSE_ON_ATTACK = 8,
                ENGAGE_AIR_WEAPONS = 20,
                FORMATION = 5,
                NO_OPTION = -1,
                ROE = 0
            },
            val = {
                ALARM_STATE = {
                    AUTO = 0,
                    GREEN = 1,
                    RED = 2
                },
                ROE = {
                    OPEN_FIRE = 2,
                    RETURN_FIRE = 3,
                    WEAPON_HOLD = 4
                }
            }
        },
        Naval = {
            id = {
                NO_OPTION = -1,
                ROE = 0
            },
            val = {
                ROE = {
                    OPEN_FIRE = 2,
                    RETURN_FIRE = 3,
                    WEAPON_HOLD = 4
                }
            }
        }
    },
    Skill = {
        AVERAGE = "Average",
        CLIENT = "Client",
        EXCELLENT = "Excellent",
        GOOD = "Good",
        HIGH = "High",
        PLAYER = "Player"
    },
    Task = {
        AltitudeType = {
            BARO = "BARO",
            RADIO = "RADIO"
        },
        Designation = {
            AUTO = "Auto",
            IR_POINTER = "IR-Pointer",
            LASER = "Laser",
            NO = "No",
            WP = "WP"
        },
        OrbitPattern = {
            CIRCLE = "Circle",
            RACE_TRACK = "Race-Track"
        },
        TurnMethod = {
            FIN_POINT = "Fin Point",
            FLY_OVER_POINT = "Fly Over Point"
        },
        VehicleFormation = {
            CONE = "Cone",
            DIAMOND = "Diamond",
            ECHELON_LEFT = "EchelonL",
            ECHELON_RIGHT = "EchelonR",
            OFF_ROAD = "Off Road",
            ON_ROAD = "On Road",
            RANK = "Rank",
            VEE = "Vee"
        },
        WaypointType = {
            LAND = "Land",
            TAKEOFF = "TakeOff",
            TAKEOFF_PARKING = "TakeOffParking",
            TAKEOFF_PARKING_HOT = "TakeOffParkingHot",
            TURNING_POINT = "Turning Point"
        },
        WeaponExpend = {
            ALL = "All",
            FOUR = "Four",
            HALF = "Half",
            ONE = "One",
            QUARTER = "Quarter",
            TWO = "Two"
        }
    }
}
coalition = {
    addGroup = function(_country, _category, _group)
        local _groupObj = mist.utils.deepCopy(_group)
        ---@diagnostic disable-next-line: undefined-global
        class(_groupObj, Group)

        _groupObj.country = _country
        _groupObj.groupName = _groupObj.name

        for _idx, _unit in pairs(_groupObj.units) do
            ---@diagnostic disable-next-line: undefined-global
            class(_unit, Unit)

            _groupObj.units[_idx] = _unit
        end

        mist.DBs.groupsById[_group.groupId] = _groupObj
        mist.DBs.groupsByName[_group.name] = _groupObj
    end,
    addRefPoint = function() end,
    addStaticObject = function() end,
    add_dyn_group = function() end,
    checkChooseCargo = function() end,
    checkDescent = function() end,
    getAirbases = function() end,
    getAllDescents = function() end,
    getCountryCoalition = function() end,
    getDescentsOnBoard = function() end,
    getGroups = function() end,
    getMainRefPoint = function() end,
    getPlayers = function() end,
    getRefPoints = function() end,
    getServiceProviders = function() end,
    getStaticObjects = function() end,
    remove_dyn_group = function() end,
    service = {
        ATC = 0,
        AWACS = 1,
        FAC = 3,
        MAX = 4,
        TANKER = 2
    },
    side = {
        BLUE = 2,
        NEUTRAL = 0,
        RED = 1
    }
}
country = {
    ABKHAZIA = 18,
    AGGRESSORS = 7,
    ALGERIA = 70,
    ARGENTINA = 83,
    AUSTRALIA = 21,
    AUSTRIA = 23,
    BAHRAIN = 65,
    BELARUS = 24,
    BELGIUM = 11,
    BOLIVIA = 86,
    BRAZIL = 64,
    BULGARIA = 25,
    CANADA = 8,
    CHEZH_REPUBLIC = 26,
    CHILE = 63,
    CHINA = 27,
    CJTF_BLUE = 80,
    CJTF_RED = 81,
    CROATIA = 28,
    CUBA = 76,
    CYPRUS = 84,
    DENMARK = 13,
    ECUADOR = 90,
    EGYPT = 29,
    ETHIOPIA = 62,
    FINLAND = 30,
    FRANCE = 5,
    GDR = 78,
    GEORGIA = 16,
    GERMANY = 6,
    GHANA = 87,
    GREECE = 31,
    HONDURAS = 61,
    HUNGARY = 32,
    INDIA = 33,
    INDONESIA = 60,
    INSURGENTS = 17,
    IRAN = 34,
    IRAQ = 35,
    ISRAEL = 15,
    ITALIAN_SOCIAL_REPUBLIC = 69,
    ITALY = 20,
    JAPAN = 36,
    JORDAN = 59,
    KAZAKHSTAN = 37,
    KUWAIT = 71,
    LEBANON = 79,
    LIBYA = 58,
    MALAYSIA = 57,
    maxIndex = 90,
    MEXICO = 56,
    MOROCCO = 55,
    NIGERIA = 88,
    NORTH_KOREA = 38,
    NORWAY = 12,
    OMAN = 73,
    PAKISTAN = 39,
    PERU = 89,
    PHILIPPINES = 54,
    POLAND = 40,
    PORTUGAL = 77,
    QATAR = 72,
    ROMANIA = 41,
    RUSSIA = 0,
    SAUDI_ARABIA = 42,
    SERBIA = 43,
    SLOVAKIA = 44,
    SLOVENIA = 85,
    SOUTH_AFRICA = 75,
    SOUTH_KOREA = 45,
    SOUTH_OSETIA = 19,
    SPAIN = 9,
    SUDAN = 53,
    SWEDEN = 46,
    SWITZERLAND = 22,
    SYRIA = 47,
    THAILAND = 52,
    THE_NETHERLANDS = 10,
    THIRDREICH = 66,
    TUNISIA = 51,
    TURKEY = 3,
    UK = 4,
    UKRAINE = 1,
    UN_PEACEKEEPERS = 82,
    UNITED_ARAB_EMIRATES = 74,
    USA = 2,
    USSR = 68,
    VENEZUELA = 50,
    VIETNAM = 49,
    YEMEN = 48,
    YUGOSLAVIA = 67,
    by_country = {
        RUSSIA = {
            Awards = {
                {
                    countryID = 0,
                    name = "Courage Order",
                    nativeName = "Courage Order",
                    picture = "Russia/awards/RUS-01-CourageOrder.png",
                    threshold = 200
                },
            },
            InternationalName = "Russia",
            Name = "Russia",
            OldID = "Russia",
            Ranks = {
                {
                    name = "Second lieutenant",
                    nativeName = "Second lieutenant",
                    pictureRect = { 0, 0, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 0
                },
                {
                    name = "First lieutenant",
                    nativeName = "First lieutenant",
                    pictureRect = { 0, 32, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 15
                }, {
                name = "Captain",
                nativeName = "Captain",
                pictureRect = { 0, 64, 64, 32 },
                stripes = "Russia/stripes.png",
                threshold = 30
            }, {
                name = "Major",
                nativeName = "Major",
                pictureRect = { 0, 96, 64, 32 },
                stripes = "Russia/stripes.png",
                threshold = 60
            }, {
                name = "Lieutenant colonel",
                nativeName = "Lieutenant colonel",
                pictureRect = { 0, 128, 64, 32 },
                stripes = "Russia/stripes.png",
                threshold = 120
            }, {
                name = "Colonel",
                nativeName = "Colonel",
                pictureRect = { 0, 160, 64, 32 },
                stripes = "Russia/stripes.png",
                threshold = 240
            }
            },
            ShortName = "RUS",
            Troops = {},
            Units = {
                ADEquipments = {
                    ADEquipment = {}
                },
                Animals = {
                    Animal = {}
                },
                Cargos = {
                    Cargo = {
                        {
                            Name = "uh1h_cargo",
                            in_service = 0,
                            out_of_service = 40000
                        },
                    },
                },
                Cars = {
                    Car = {
                        {
                            Name = "Bunker",
                            in_service = 0,
                            out_of_service = 40000
                        },
                    },
                },
                Effects = {
                    Effect = {
                        {
                            Name = "big_smoke",
                            in_service = 0,
                            out_of_service = 40000,
                        },
                    },
                },
                Fortifications = {
                    Fortification = {
                        {
                            Name = ".Command Center",
                            in_service = 0,
                            out_of_service = 40000,
                        },
                    },
                },
                GrassAirfields = {
                    GrassAirfield = { {
                        Name = "GrassAirfield",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                Helicopters = {
                    Helicopter = { {
                        Name = "Ka-50",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-24V",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-8MT",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-26",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Ka-27",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-28N",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "UH-1H",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-24P",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                Heliports = {
                    Heliport = { {
                        Name = "FARP",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "SINGLE_HELIPAD",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                LTAvehicles = {
                    LTAvehicle = {}
                },
                Personnel = {
                    Personnel = {}
                },
                Planes = {
                    Plane = { {
                        Name = "A-10C",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-33",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-25",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-29S",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-29A",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-27",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-25TM",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-25T",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-31",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-27K",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-30",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tu-160",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-34",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tu-95MS",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tu-142",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-25PD",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tu-22M3",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "A-50",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Yak-40",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "An-26B",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "An-30M",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-17M4",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-23MLD",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-25RBT",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-24M",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-24MR",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "IL-78M",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "IL-76MD",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "L-39ZA",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "P-51D",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "L-39C",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Yak-52",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                Ships = {
                    Ship = { {
                        Name = "speedboat",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "KUZNECOW",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MOSCOW",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "PIOTR",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "ELNYA",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "ALBATROS",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "REZKY",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MOLNIYA",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "KILO",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "IMPROVED_KILO",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "ZWEZDNY",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "NEUSTRASH",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Dry-cargo ship-1",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Dry-cargo ship-2",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "HandyWind",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Seawise_Giant",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "BDK-775",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                Warehouses = {
                    Warehouse = { {
                        Name = "Warehouse",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tank",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = ".Ammunition depot",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tank 2",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tank 3",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                WWIIstructures = {
                    WWIIstructure = {}
                },
            },
            WorldID = 0,
            award_by_name = {
                ["Courage Order"] = {
                    countryID = 0,
                    name = "Courage Order",
                    nativeName = "Courage Order",
                    picture = "Russia/awards/RUS-01-CourageOrder.png",
                    threshold = 200
                },
            },
            flag = "FUI/Common/Flags/Russia.png",
            flag_small = "MissionEditor/data/images/flags/Russia.png",
            rank_by_name = {
                Captain = {
                    name = "Captain",
                    nativeName = "Captain",
                    pictureRect = { 0, 64, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 30
                },
                Colonel = {
                    name = "Colonel",
                    nativeName = "Colonel",
                    pictureRect = { 0, 160, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 240
                },
                ["First lieutenant"] = {
                    name = "First lieutenant",
                    nativeName = "First lieutenant",
                    pictureRect = { 0, 32, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 15
                },
                ["Lieutenant colonel"] = {
                    name = "Lieutenant colonel",
                    nativeName = "Lieutenant colonel",
                    pictureRect = { 0, 128, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 120
                },
                Major = {
                    name = "Major",
                    nativeName = "Major",
                    pictureRect = { 0, 96, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 60
                },
                ["Second lieutenant"] = {
                    name = "Second lieutenant",
                    nativeName = "Second lieutenant",
                    pictureRect = { 0, 0, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 0
                }
            },
            troop_by_name = {},
        },
    },
    by_idx = {
        {
            Awards = {
                {
                    countryID = 0,
                    name = "Courage Order",
                    nativeName = "Courage Order",
                    picture = "Russia/awards/RUS-01-CourageOrder.png",
                    threshold = 200
                },
            },
            InternationalName = "Russia",
            Name = "Russia",
            OldID = "Russia",
            Ranks = {
                {
                    name = "Second lieutenant",
                    nativeName = "Second lieutenant",
                    pictureRect = { 0, 0, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 0
                },
                {
                    name = "First lieutenant",
                    nativeName = "First lieutenant",
                    pictureRect = { 0, 32, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 15
                }, {
                name = "Captain",
                nativeName = "Captain",
                pictureRect = { 0, 64, 64, 32 },
                stripes = "Russia/stripes.png",
                threshold = 30
            }, {
                name = "Major",
                nativeName = "Major",
                pictureRect = { 0, 96, 64, 32 },
                stripes = "Russia/stripes.png",
                threshold = 60
            }, {
                name = "Lieutenant colonel",
                nativeName = "Lieutenant colonel",
                pictureRect = { 0, 128, 64, 32 },
                stripes = "Russia/stripes.png",
                threshold = 120
            }, {
                name = "Colonel",
                nativeName = "Colonel",
                pictureRect = { 0, 160, 64, 32 },
                stripes = "Russia/stripes.png",
                threshold = 240
            }
            },
            ShortName = "RUS",
            Troops = {},
            Units = {
                ADEquipments = {
                    ADEquipment = {}
                },
                Animals = {
                    Animal = {}
                },
                Cargos = {
                    Cargo = {
                        {
                            Name = "uh1h_cargo",
                            in_service = 0,
                            out_of_service = 40000
                        },
                    },
                },
                Cars = {
                    Car = {
                        {
                            Name = "Bunker",
                            in_service = 0,
                            out_of_service = 40000
                        },
                    },
                },
                Effects = {
                    Effect = {
                        {
                            Name = "big_smoke",
                            in_service = 0,
                            out_of_service = 40000,
                        },
                    },
                },
                Fortifications = {
                    Fortification = {
                        {
                            Name = ".Command Center",
                            in_service = 0,
                            out_of_service = 40000,
                        },
                    },
                },
                GrassAirfields = {
                    GrassAirfield = { {
                        Name = "GrassAirfield",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                Helicopters = {
                    Helicopter = { {
                        Name = "Ka-50",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-24V",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-8MT",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-26",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Ka-27",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-28N",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "UH-1H",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Mi-24P",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                Heliports = {
                    Heliport = { {
                        Name = "FARP",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "SINGLE_HELIPAD",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                LTAvehicles = {
                    LTAvehicle = {}
                },
                Personnel = {
                    Personnel = {}
                },
                Planes = {
                    Plane = { {
                        Name = "A-10C",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-33",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-25",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-29S",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-29A",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-27",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-25TM",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-25T",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-31",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-27K",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-30",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tu-160",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-34",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tu-95MS",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tu-142",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-25PD",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tu-22M3",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "A-50",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Yak-40",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "An-26B",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "An-30M",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-17M4",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-23MLD",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MiG-25RBT",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-24M",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Su-24MR",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "IL-78M",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "IL-76MD",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "L-39ZA",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "P-51D",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "L-39C",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Yak-52",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                Ships = {
                    Ship = { {
                        Name = "speedboat",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "KUZNECOW",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MOSCOW",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "PIOTR",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "ELNYA",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "ALBATROS",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "REZKY",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "MOLNIYA",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "KILO",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "IMPROVED_KILO",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "ZWEZDNY",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "NEUSTRASH",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Dry-cargo ship-1",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Dry-cargo ship-2",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "HandyWind",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Seawise_Giant",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "BDK-775",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                Warehouses = {
                    Warehouse = { {
                        Name = "Warehouse",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tank",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = ".Ammunition depot",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tank 2",
                        in_service = 0,
                        out_of_service = 40000
                    }, {
                        Name = "Tank 3",
                        in_service = 0,
                        out_of_service = 40000
                    } }
                },
                WWIIstructures = {
                    WWIIstructure = {}
                },
            },
            WorldID = 0,
            award_by_name = {
                ["Courage Order"] = {
                    countryID = 0,
                    name = "Courage Order",
                    nativeName = "Courage Order",
                    picture = "Russia/awards/RUS-01-CourageOrder.png",
                    threshold = 200
                },
            },
            flag = "FUI/Common/Flags/Russia.png",
            flag_small = "MissionEditor/data/images/flags/Russia.png",
            rank_by_name = {
                Captain = {
                    name = "Captain",
                    nativeName = "Captain",
                    pictureRect = { 0, 64, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 30
                },
                Colonel = {
                    name = "Colonel",
                    nativeName = "Colonel",
                    pictureRect = { 0, 160, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 240
                },
                ["First lieutenant"] = {
                    name = "First lieutenant",
                    nativeName = "First lieutenant",
                    pictureRect = { 0, 32, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 15
                },
                ["Lieutenant colonel"] = {
                    name = "Lieutenant colonel",
                    nativeName = "Lieutenant colonel",
                    pictureRect = { 0, 128, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 120
                },
                Major = {
                    name = "Major",
                    nativeName = "Major",
                    pictureRect = { 0, 96, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 60
                },
                ["Second lieutenant"] = {
                    name = "Second lieutenant",
                    nativeName = "Second lieutenant",
                    pictureRect = { 0, 0, 64, 32 },
                    stripes = "Russia/stripes.png",
                    threshold = 0
                }
            },
            troop_by_name = {},
        },
    },
    id = {
        ABKHAZIA = 18,
        AGGRESSORS = 7,
        ALGERIA = 70,
        ARGENTINA = 83,
        AUSTRALIA = 21,
        AUSTRIA = 23,
        BAHRAIN = 65,
        BELARUS = 24,
        BELGIUM = 11,
        BOLIVIA = 86,
        BRAZIL = 64,
        BULGARIA = 25,
        CANADA = 8,
        CHEZH_REPUBLIC = 26,
        CHILE = 63,
        CHINA = 27,
        CJTF_BLUE = 80,
        CJTF_RED = 81,
        CROATIA = 28,
        CUBA = 76,
        CYPRUS = 84,
        DENMARK = 13,
        ECUADOR = 90,
        EGYPT = 29,
        ETHIOPIA = 62,
        FINLAND = 30,
        FRANCE = 5,
        GDR = 78,
        GEORGIA = 16,
        GERMANY = 6,
        GHANA = 87,
        GREECE = 31,
        HONDURAS = 61,
        HUNGARY = 32,
        INDIA = 33,
        INDONESIA = 60,
        INSURGENTS = 17,
        IRAN = 34,
        IRAQ = 35,
        ISRAEL = 15,
        ITALIAN_SOCIAL_REPUBLIC = 69,
        ITALY = 20,
        JAPAN = 36,
        JORDAN = 59,
        KAZAKHSTAN = 37,
        KUWAIT = 71,
        LEBANON = 79,
        LIBYA = 58,
        MALAYSIA = 57,
        MEXICO = 56,
        MOROCCO = 55,
        NIGERIA = 88,
        NORTH_KOREA = 38,
        NORWAY = 12,
        OMAN = 73,
        PAKISTAN = 39,
        PERU = 89,
        PHILIPPINES = 54,
        POLAND = 40,
        PORTUGAL = 77,
        QATAR = 72,
        ROMANIA = 41,
        RUSSIA = 0,
        SAUDI_ARABIA = 42,
        SERBIA = 43,
        SLOVAKIA = 44,
        SLOVENIA = 85,
        SOUTH_AFRICA = 75,
        SOUTH_KOREA = 45,
        SOUTH_OSETIA = 19,
        SPAIN = 9,
        SUDAN = 53,
        SWEDEN = 46,
        SWITZERLAND = 22,
        SYRIA = 47,
        THAILAND = 52,
        THE_NETHERLANDS = 10,
        THIRDREICH = 66,
        TUNISIA = 51,
        TURKEY = 3,
        UK = 4,
        UKRAINE = 1,
        UNITED_ARAB_EMIRATES = 74,
        UN_PEACEKEEPERS = 82,
        USA = 2,
        USSR = 68,
        VENEZUELA = 50,
        VIETNAM = 49,
        YEMEN = 48,
        YUGOSLAVIA = 67
    },
    name = {
        "UKRAINE",
        "USA",
        "TURKEY",
        "UK",
        "FRANCE",
        "GERMANY",
        "AGGRESSORS",
        "CANADA",
        "SPAIN",
        "THE_NETHERLANDS",
        "BELGIUM",
        "NORWAY",
        "DENMARK",
        [0] = "RUSSIA",
        [15] = "ISRAEL",
        [16] = "GEORGIA",
        [17] = "INSURGENTS",
        [18] = "ABKHAZIA",
        [19] = "SOUTH_OSETIA",
        [20] = "ITALY",
        [21] = "AUSTRALIA",
        [22] = "SWITZERLAND",
        [23] = "AUSTRIA",
        [24] = "BELARUS",
        [25] = "BULGARIA",
        [26] = "CHEZH_REPUBLIC",
        [27] = "CHINA",
        [28] = "CROATIA",
        [29] = "EGYPT",
        [30] = "FINLAND",
        [31] = "GREECE",
        [32] = "HUNGARY",
        [33] = "INDIA",
        [34] = "IRAN",
        [35] = "IRAQ",
        [36] = "JAPAN",
        [37] = "KAZAKHSTAN",
        [38] = "NORTH_KOREA",
        [39] = "PAKISTAN",
        [40] = "POLAND",
        [41] = "ROMANIA",
        [42] = "SAUDI_ARABIA",
        [43] = "SERBIA",
        [44] = "SLOVAKIA",
        [45] = "SOUTH_KOREA",
        [46] = "SWEDEN",
        [47] = "SYRIA",
        [48] = "YEMEN",
        [49] = "VIETNAM",
        [50] = "VENEZUELA",
        [51] = "TUNISIA",
        [52] = "THAILAND",
        [53] = "SUDAN",
        [54] = "PHILIPPINES",
        [55] = "MOROCCO",
        [56] = "MEXICO",
        [57] = "MALAYSIA",
        [58] = "LIBYA",
        [59] = "JORDAN",
        [60] = "INDONESIA",
        [61] = "HONDURAS",
        [62] = "ETHIOPIA",
        [63] = "CHILE",
        [64] = "BRAZIL",
        [65] = "BAHRAIN",
        [66] = "THIRDREICH",
        [67] = "YUGOSLAVIA",
        [68] = "USSR",
        [69] = "ITALIAN_SOCIAL_REPUBLIC",
        [70] = "ALGERIA",
        [71] = "KUWAIT",
        [72] = "QATAR",
        [73] = "OMAN",
        [74] = "UNITED_ARAB_EMIRATES",
        [75] = "SOUTH_AFRICA",
        [76] = "CUBA",
        [77] = "PORTUGAL",
        [78] = "GDR",
        [79] = "LEBANON",
        [80] = "CJTF_BLUE",
        [81] = "CJTF_RED",
        [82] = "UN_PEACEKEEPERS",
        [83] = "ARGENTINA",
        [84] = "CYPRUS",
        [85] = "SLOVENIA",
        [86] = "BOLIVIA",
        [87] = "GHANA",
        [88] = "NIGERIA",
        [89] = "PERU",
        [90] = "ECUADOR"
    },
    names = {
        "UKRAINE",
        "USA",
        "TURKEY",
        "UK",
        "FRANCE",
        "GERMANY",
        "AGGRESSORS",
        "CANADA",
        "SPAIN",
        "THE_NETHERLANDS",
        "BELGIUM",
        "NORWAY",
        "DENMARK",
        [0] = "RUSSIA",
        [15] = "ISRAEL",
        [16] = "GEORGIA",
        [17] = "INSURGENTS",
        [18] = "ABKHAZIA",
        [19] = "SOUTH_OSETIA",
        [20] = "ITALY",
        [21] = "AUSTRALIA",
        [22] = "SWITZERLAND",
        [23] = "AUSTRIA",
        [24] = "BELARUS",
        [25] = "BULGARIA",
        [26] = "CHEZH_REPUBLIC",
        [27] = "CHINA",
        [28] = "CROATIA",
        [29] = "EGYPT",
        [30] = "FINLAND",
        [31] = "GREECE",
        [32] = "HUNGARY",
        [33] = "INDIA",
        [34] = "IRAN",
        [35] = "IRAQ",
        [36] = "JAPAN",
        [37] = "KAZAKHSTAN",
        [38] = "NORTH_KOREA",
        [39] = "PAKISTAN",
        [40] = "POLAND",
        [41] = "ROMANIA",
        [42] = "SAUDI_ARABIA",
        [43] = "SERBIA",
        [44] = "SLOVAKIA",
        [45] = "SOUTH_KOREA",
        [46] = "SWEDEN",
        [47] = "SYRIA",
        [48] = "YEMEN",
        [49] = "VIETNAM",
        [50] = "VENEZUELA",
        [51] = "TUNISIA",
        [52] = "THAILAND",
        [53] = "SUDAN",
        [54] = "PHILIPPINES",
        [55] = "MOROCCO",
        [56] = "MEXICO",
        [57] = "MALAYSIA",
        [58] = "LIBYA",
        [59] = "JORDAN",
        [60] = "INDONESIA",
        [61] = "HONDURAS",
        [62] = "ETHIOPIA",
        [63] = "CHILE",
        [64] = "BRAZIL",
        [65] = "BAHRAIN",
        [66] = "THIRDREICH",
        [67] = "YUGOSLAVIA",
        [68] = "USSR",
        [69] = "ITALIAN_SOCIAL_REPUBLIC",
        [70] = "ALGERIA",
        [71] = "KUWAIT",
        [72] = "QATAR",
        [73] = "OMAN",
        [74] = "UNITED_ARAB_EMIRATES",
        [75] = "SOUTH_AFRICA",
        [76] = "CUBA",
        [77] = "PORTUGAL",
        [78] = "GDR",
        [79] = "LEBANON",
        [80] = "CJTF_BLUE",
        [81] = "CJTF_RED",
        [82] = "UN_PEACEKEEPERS",
        [83] = "ARGENTINA",
        [84] = "CYPRUS",
        [85] = "SLOVENIA",
        [86] = "BOLIVIA",
        [87] = "GHANA",
        [88] = "NIGERIA",
        [89] = "PERU",
        [90] = "ECUADOR"
    },
    next_index = 91,
    add = function() end,
    get = function() end,
    next = function() end,
}
env = {
    mission = {
        coalition = {},
        triggers = {
            zones = {
                {
                    name = 'test',
                    x = 0,
                    y = 0,
                    z = 0,
                    verticies = {
                        { x = 100, y = 0, z = 100 },
                        { x = -100, y = 0, z = 100 },
                        { x = -100, y = 0, z = -100 },
                        { x = 100, y = 0, z = -100 },
                    }
                },
            },
        },
    },
    error = function(message, dialog) end,
    info = function(message, dialog) end,
    warning = function(message, dialog) end,
}
land = {
    getHeight = function(point) return 0 end,
    getSurfaceType = function(coord) return 1 end,
    SurfaceType = {
        LAND = 1,
        SHALLOW_WATER = 2,
        WATER = 3,
        ROAD = 4,
        RUNWAY = 5,
    },
}
missionCommands = {
    addCommand = Mock(),
    addCommandForCoalition = Mock(),
    addCommandForGroup = Mock(),
    addSubMenu = Mock(),
    addSubMenuForCoalition = Mock(),
    addSubMenuForGroup = Mock(),
    doAction = Mock(),
    removeItem = Mock(),
    removeItemForCoalition = Mock(),
    removeItemForGroup = Mock()
}
timer = {
    getTime = function() return 0 end,
    getAbsTime = function() return 0 end,
    scheduleFunction = Spy(function(func, args, time) end),
}
trigger = {
    action = {},
    misc = {
        getZone = function(_zone)
            return { point = { x = 0, y = 0, z = 0 } }
        end,
    },
    smokeColor = {
        Green = 0,
        Red = 1,
        White = 2,
        Orange = 3,
        Blue = 4,
    },
}
world = {
    getAirbases = function() return {} end,
    event = {
        S_EVENT_INVALID = 0,
        S_EVENT_SHOT = 1,
        S_EVENT_HIT = 2,
        S_EVENT_TAKEOFF = 3,
        S_EVENT_LAND = 4,
        S_EVENT_CRASH = 5,
        S_EVENT_EJECTION = 6,
        S_EVENT_REFUELING = 7,
        S_EVENT_DEAD = 8,
        S_EVENT_PILOT_DEAD = 9,
        S_EVENT_BASE_CAPTURED = 10,
        S_EVENT_MISSION_START = 11,
        S_EVENT_MISSION_END = 12,
        S_EVENT_TOOK_CONTROL = 13,
        S_EVENT_REFUELING_STOP = 14,
        S_EVENT_BIRTH = 15,
        S_EVENT_HUMAN_FAILURE = 16,
        S_EVENT_DETAILED_FAILURE = 17,
        S_EVENT_ENGINE_STARTUP = 18,
        S_EVENT_ENGINE_SHUTDOWN = 19,
        S_EVENT_PLAYER_ENTER_UNIT = 20,
        S_EVENT_PLAYER_LEAVE_UNIT = 21,
        S_EVENT_PLAYER_COMMENT = 22,
        S_EVENT_SHOOTING_START = 23,
        S_EVENT_SHOOTING_END = 24,
        S_EVENT_MARK_ADDED = 25,
        S_EVENT_MARK_CHANGE = 26,
        S_EVENT_MARK_REMOVED = 27,
        S_EVENT_KILL = 28,
        S_EVENT_SCORE = 29,
        S_EVENT_UNIT_LOST = 30,
        S_EVENT_LANDING_AFTER_EJECTION = 31,
        S_EVENT_PARATROOPER_LENDING = 32,
        S_EVENT_DISCARD_CHAIR_AFTER_EJECTION = 33,
        S_EVENT_WEAPON_ADD = 34,
        S_EVENT_TRIGGER_ZONE = 35,
        S_EVENT_LANDING_QUALITY_MARK = 36,
        S_EVENT_BDA = 37,
        S_EVENT_AI_ABORT_MISSION = 38,
        S_EVENT_DAYNIGHT = 39,
        S_EVENT_FLIGHT_TIME = 40,
        S_EVENT_PLAYER_SELF_KILL_PILOT = 41,
        S_EVENT_PLAYER_CAPTURE_AIRFIELD = 42,
        S_EVENT_EMERGENCY_LANDING = 43,
        S_EVENT_UNIT_CREATE_TASK = 44,
        S_EVENT_UNIT_DELETE_TASK = 45,
        S_EVENT_SIMULATION_START = 46,
        S_EVENT_WEAPON_REARM = 47,
        S_EVENT_WEAPON_DROP = 48,
        S_EVENT_UNIT_TASK_COMPLETE = 49,
        S_EVENT_UNIT_TASK_STAGE = 50,
        S_EVENT_MAC_SUBTASK_SCORE = 51,
        S_EVENT_MAC_EXTRA_SCORE = 52,
        S_EVENT_MISSION_RESTART = 53,
        S_EVENT_MISSION_WINNER = 54,
        S_EVENT_POSTPONED_TAKEOFF = 55,
        S_EVENT_POSTPONED_LAND = 56,
        S_EVENT_MAX = 57,
    },

}

require("Scripts.ScriptingSystem")

trigger.action.activateGroup = Mock()
trigger.action.deactivateGroup = Mock()
trigger.action.smoke = Mock()
trigger.action.outSound = Mock()
trigger.action.outSoundForCoalition = Mock()
trigger.action.outSoundForCountry = Mock()
trigger.action.outSoundForGroup = Mock()
trigger.action.outSoundForUnit = Mock()
trigger.action.outText = Mock()
trigger.action.outTextForCoalition = Mock()
trigger.action.outTextForCountry = Mock()
trigger.action.outTextForGroup = Mock()
trigger.action.outTextForUnit = Mock()
trigger.action.radioTransmission = Mock()
trigger.action.setUnitInternalCargo = Mock()
trigger.action.setUserFlag = Mock()
trigger.action.stopRadioTransmission = Mock()
