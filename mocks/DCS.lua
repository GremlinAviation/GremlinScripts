local Mock = require("test.mock.Mock")
require("Scripts.Common.LuaClass")

Airbase = { className_ = "Airbase", categoryName = "BASE" }
Controller = { className_ = "Controller" }
Group = {
    className_ = "Group",
    isExist = function(self)
        return true
    end,
    getByName = function(name)
        local _group = { className_ = "Group", groupName = name }
        class(_group, Group)
        return _group
    end,
    getCategory = function(self, name)
        return 1
    end,
    getID = function(self)
        if self.id ~= nil then
            return self.id
        end

        return 1
    end,
    getName = function(self)
        if self.groupName ~= nil then
            return self.groupName
        end

        return "test"
    end,
    getUnits = function(self, name)
        local _unit = { className_ = "Unit", unitName = name }
        class(_unit, Unit)
        return { _unit }
    end,
}
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
    isExist = function(self) return true end,
    getByName = function(name)
        local _myObj = { className_ = "Object", name = "test" }
        class(_myObj, Object)
        return _myObj
    end,
    getCategory = function(_object)
        if _object.categoryName ~= nil then
            return Object.Category[_object.categoryName]
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
    getCountry = function(name) return 2 end,
    getID = function(self) return 1 end,
    getName = function(self)
        if self.name ~= nil then
            return self.name
        else
            return "test"
        end
    end,
    getPoint = function(self) return { x = 0, y = 0, z = 0 } end,
    getPosition = function(self) return { p = { x = 0, y = 0, z = 0 }, x = { x = 0, y = 0, z = 0 } } end,
    getTypeName = function(self) return "Test" end,
    getVelocity = function(self) return { x = 0, y = 0, z = 0 } end,
}
SceneryObject = { className_ = "SceneryObject", categoryName = "SCENERY" }
Spot = { className_ = "Spot" }
StaticObject = { className_ = "StaticObject", categoryName = "STATIC" }
Unit = {
    className_ = "Unit",
    categoryName = "UNIT",
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
        if type(name) ~= "string" then
            _name = name:getName()
        end

        for _zone, _units in pairs(Evac._state.extractableNow) do
            if _units[_name] ~= nil then
                local _unit = { className_ = "Unit", unitName = _name }
                class(_unit, Unit)
                return _unit
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

        local _group = { className_ = "Group", groupName = "test" }
        class(_group, Group)
        return _group
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
    getTypeName = function(self)
        if self.typeName ~= nil then
            return self.typeName
        else
            return "test"
        end
    end,
    isActive = function(self)
        return true
    end,
}
Warehouse = { className_ = "Warehouse" }
Weapon = { className_ = "Weapon", categoryName = "WEAPON" }

coalition = {
    addGroup = function() end,
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
                    verticies = {
                        { x = 100, y = 100 },
                        { x = 0,   y = 100 },
                        { x = 0,   y = 0 },
                        { x = 100, y = 0 },
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
    getHeight = function(point) return math.random(-100, 100) end,
    getSurfaceType = function(coord) return 1 end,
    SurfaceType = {
        LAND = 1,
        SHALLOW_WATER = 2,
        WATER = 3,
        ROAD = 4,
        RUNWAY = 5,
    },
}
timer = {
    getTime = function() return 0 end,
    scheduleFunction = function(func, args, time) end,
}
trigger = {
    action = {},
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
}

require("Scripts.ScriptingSystem")

trigger.action.outText = Mock()
trigger.action.outTextForCoalition = Mock()
trigger.action.outTextForCountry = Mock()
trigger.action.outTextForGroup = Mock()
trigger.action.outTextForUnit = Mock()
