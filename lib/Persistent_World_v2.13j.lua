
--[[%%%%% -= PERSISTENT WORLD SCRIPT =- %%%%%

    Credits :
    JGi | Quéton 1-1
    [♥] Surrexen
    [♥] Pikey
    
--]]

--[[%%%%% CHANGELOG %%%%%

    2.13j
        Correction temporaire bug Event.target:getCoalition() sur world.event.S_EVENT_KILL

    2.13i
        Suppression des doublons, ajout unités spawés dans PWS.escapeTypeFromDeadList 

    2.13h
        Refactorisation globale, notamment 'spawned'
        Ajustements 'escapeTypeFromDeadList'
        Refonte 'GroundGroupSpawn()' & '_Tasks'
        Gestion groupes multi-unités

    2.13g
        Correction des fonctions 'spawned' pour spawn multi-unités
        
    2.13f
        Refonte des liste d'échappement
            escapeNameFromDeadList
            escapeTypeFromDeadList
            escapeNameFromBirthList
            escapeTextFromMarksList

        Modification crédits, plus grand chose à voir avec la base de Pikey
        Ajout sauvegarde des marqueurs, sauf si texte vide
        Refactorisation des fonctions:
            PWS_groundSpawn, 
            PWS_updateSpawnedTable, 
            PWS_updateMarksTable,
            PWS_ONDEADEVENTHANDLER:onEvent(Event)
            PWS_ONBIRTHEVENTHANDLER:onEvent(Event)
        
        Mise en cohérence de certains noms


    2.13e
        Modification task au spawn des groupes
            ROE : FreeFire
            Etat d'alerte : Rouge

    2.13d
        Ajout liste d'exclusion (en construction)
            > PWS.escapeNameFromDeadList & PWS.escapeNameFromBirthList non-fonctionnels
            > réglage direct dans les Events

    2.13c
        Suppression commentaires

    2.13b
        Ajout préfixe PWS.
        Suppression commentaires inutiles
        Ajout PWS.escapeNameFromDeadList / PWS.escapeNameFromBirthList
        Correction itérables PWS_GetTableLength(Table) > #PWS_Units
        Ajout event S_EVENT_UNIT_LOST & S_EVENT_KILL
        Ajout contrôle des doublons PWS_Units / PWS_Statics
--]]

--[[%%%%% TODO - NEXT FEATURES %%%%%
        Ctrl des doublons spawned/died
    Correction fonction et variable : PWS.
    Integration Tasks
    Integration suvegarde des scores

--]]

--%%%%% PARAMS %%%%%
    PWS = {}

    --> Temps entre deux sauvegardes (sec)
    --> Time between saves (in sec)
    PWS.SaveSchedule = 300

    --> /!\ Préfixe de la sauvegarde - à régler pour chaque mission
    --> Save file prefix - each mission needs a different setting
    PWS.saveFileName = "Plop"

    --> Activer sauvegarde unités detruites Bleu (true/false)
    --> If set to true, save blue coalition also.
    PWS.saveDeadBlue = false
    PWS.saveDeadRed = true

    --> Activer sauvegarde unités spawnées Bleu/rouge (true/false)
    --> If set to true, save blue coalition also.
    PWS.saveBirthBlue = true
    PWS.saveBirthRed = true

    --> Activer sauvegarde des Marks (true/false)
    --> If set to true, save Marks also.
    PWS.saveMarksBlue = true
    PWS.saveMarksRed = true


    --> Liste de nom à exclure de la save
    --> Names or prefix to escape save
    PWS.escapeNameFromDeadList = {
        "Wounded Pilot",
        "TTGT",
        "ttgt",
        "Training target",
        "Procedural",
    }
    PWS.escapeTypeFromDeadList = {
        "Forrestal",
        "CVN",
        "Stennis",
        "KUZNECOW",
        "CV_1143_5",
        "LHA_Tarawa",
        "hms_invincible",
        "ara_vdm",
    }

    PWS.escapeNameFromBirthList = {
        "Wounded Pilot",
        "TTGT",
        "ttgt",
        "Training target",
        "Procedural",
        "SOM",
        "som",
    }

    PWS.escapeTextFromMarksList = {
        "SOM",
        "som",
    }



--%%%%% VARIABLES %%%%%
    PWS_Spawned = {}
    PWS_Marks = {}

    --> Dossier de sauvegarde (défaut : \Save Games\DCS\Missions\_PWS_Saves)
    --> Save folder location
    PWS.saveFolder = lfs.writedir().."Missions\\_PWS_Saves\\"

    if PWS.saveFolder then
        lfs.mkdir(PWS.saveFolder)
    end
    PWS.deadUnitsSaveFile = PWS.saveFolder..PWS.saveFileName.."_PWS_Units.lua"
    PWS.deadStaticsSaveFile = PWS.saveFolder..PWS.saveFileName.."_PWS_Statics.lua"
    PWS.spawnedUnitsSaveFile = PWS.saveFolder..PWS.saveFileName.."_PWS_Spawned.lua"
    PWS.marksSaveFile = PWS.saveFolder..PWS.saveFileName.."_PWS_Marks.lua"
    --> debug
    --trigger.action.outText("Persistent World | WriteDir : "..lfs.writedir(),360)

--%%%%% TOOLKIT FUNCTIONS %%%%%
    --%%% SERIALIZE %%%
    function IntegratedbasicSerialize(s)
        if s == nil then
            return "\"\""
        else
            if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
                return tostring(s)
            elseif type(s) == 'string' then
                return string.format('%q', s)
            end
        end
    end

    function IntegratedserializeWithCycles(name, value, saved)
        local basicSerialize = function (o)
            if type(o) == "number" then
                return tostring(o)
            elseif type(o) == "boolean" then
                return tostring(o)
            else -- assume it is a string
                return IntegratedbasicSerialize(o)
            end
        end

        local t_str = {}
        saved = saved or {}       -- initial value
        if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
            table.insert(t_str, name .. " = ")
                if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
                    table.insert(t_str, basicSerialize(value) ..  "\n")
                else
                    if saved[value] then    -- value already saved?
                        table.insert(t_str, saved[value] .. "\n")
                    else
                        saved[value] = name   -- save name for next time
                        table.insert(t_str, "{}\n")
                            for k,v in pairs(value) do      -- save its fields
                                local fieldname = string.format("%s[%s]", name, basicSerialize(k))
                                table.insert(t_str, IntegratedserializeWithCycles(fieldname, v, saved))
                            end
                    end
                end
            return table.concat(t_str)
        else
            return ""
        end
    end

    --%%% FILE EXIST %%%
    function file_exists(name) --check if the file already exists for writing
        if lfs.attributes(name) then
        return true
        else
        return false end 
    end

    --%%% ECRITURE %%%
    function writemission(data, file)--Function for saving to file (commonly found)
        File = io.open(file, "w")
        File:write(data)
        File:close()
    end

    --%%% GROUND SPAWN %%%
    function PWS.GroundGroupSpawn(groupCoalition, groupName, wPoints, units, groupFreq)

        --%%% COALITION %%%
        if groupCoalition == "red" 
            or groupCoalition == "RED" 
            or groupCoalition == 1
            or groupCoalition == country.id.CJTF_RED
        then
            groupCoalition = country.id.CJTF_RED
        else
            groupCoalition = country.id.CJTF_BLUE
        end
    
        --%%% RADIO FREQUENCY %%%
        if not groupFreq then
            groupFreq = 121500000
        elseif groupFreq >= 108000000
            and groupFreq <= 399975000
        then
            groupFreq = groupFreq
        else
            groupFreq = 121500000
        end
    
        --%%% GROUP NAME %%%
        --groupName = groupName .." -"..math.random(01,99) --> On SOM Only
    
        --%%% OPTION %%%
        if wPoints == nil then wPoints = {} end
        _initWaypointName = "Spawn point"
        _waypointName = "Wp#"
        _heading = math.random(0,359)
        _coldAtStart = false
        _skill = "HIGH" --> PLAYER, CLIENT, AVERAGE, GOOD, HIGH, EXCELLENT
        _initPosY = units[1].posY or 0
        _initPosX = units[1].posX or 0
        _initSpeed = 0
        _holdPosition = false
        _goToWpt = false
        _goToWptFrom = 0
        _goToWptTo = 0
        _immortal = false
        _invisible = false
    
        --%%% TASKS %%%
        _initTasks = {
            [1] = {
                ["enabled"] = true,
                ["auto"] = false,
                ["id"] = "WrappedAction",
                ["number"] = 1,
                ["params"] = {
                    ["action"] = {
                        ["id"] = "Option",
                        ["params"] = {
                            --> Rules of engagement (hold : 4)
                            ["name"] = 0,
                            ["value"] = 0,
                        },--params
                    },--action
                },--params
            },
            [2] = {
                ["enabled"] = true,
                ["auto"] = false,
                ["id"] = "WrappedAction",
                ["number"] = 2,
                ["params"] = {
                    ["action"] = {
                        ["id"] = "Option",
                        ["params"] = {
                            --> Dispersion
                            ["name"] = 8,
                            ["value"] = 60,
                        }, -- end of ["params"]
                    }, -- end of ["action"]
                }, -- end of ["params"]
            }, -- end of [2]
            [3] = {
                ["enabled"] = true,
                ["auto"] = false,
                ["id"] = "WrappedAction",
                ["number"] = 3,
                ["params"] = {
                    ["action"] = {
                        ["id"] = "Option",
                        ["params"] = {
                            --> Distance d'engagement
                            ["name"] = 24,
                            ["value"] = 100,
                        }, -- end of ["params"]
                    }, -- end of ["action"]
                }, -- end of ["params"]
            }, -- end of [3]
            [4] = {
                ["number"] = 4,
                ["auto"] = false,
                ["id"] = "WrappedAction",
                ["enabled"] = true,
                ["params"] = {
                    ["action"] = {
                        ["id"] = "Option",
                        ["params"] = {
                            --> Etat d'alerte
                            ["name"] = 9,
                            ["value"] = 2,
                        }, -- end of ["params"]
                    }, -- end of ["action"]
                }, -- end of ["params"]
            }, -- end of [4]
            [5] = {
                ["enabled"] = true,
                ["auto"] = false,
                ["id"] = "FAC",
                ["number"] = 5,
                ["params"] = {
                    --> JTAC
                    ["number"] = math.random(1,9),
                    ["designation"] = "Auto",
                    ["modulation"] = 0,
                    ["callname"] = 12,
                    ["datalink"] = true,
                    ["frequency"] = groupFreq,
                }, -- end of ["params"]
            }, -- end of [5]
            [6] = {
                ["enabled"] = true,
                ["auto"] = false,
                ["id"] = "WrappedAction",
                ["number"] = 6,
                ["params"] = {
                    ["action"] = {
                        ["id"] = "SetFrequency",
                        ["params"] = {
                            ["power"] = 100,
                            ["modulation"] = 0,
                            ["frequency"] = groupFreq,
                        }, -- end of ["params"]
                    }, -- end of ["action"]
                }, -- end of ["params"]
            }, -- end of [6]
            [7] = {
                ["enabled"] = true,
                ["auto"] = false,
                ["id"] = "WrappedAction",
                ["number"] = 7,
                ["params"] = {
                    ["action"] = {
                        ["id"] = "SetInvisible",
                        ["params"] = {
                            ["value"] = _invisible,
                        },
                    },
                },
            },
            [8] = 
            {
                ["enabled"] = true,
                ["auto"] = false,
                ["id"] = "WrappedAction",
                ["number"] = 8,
                ["params"] = {
                    ["action"] = {
                        ["id"] = "SetImmortal",
                        ["params"] = 
                        {
                            ["value"] = _immortal,
                        },
                    },
                },
            },
            [9] = {
                ["enabled"] = _holdPosition,
                ["auto"] = false,
                ["id"] = "Hold",
                ["number"] = 9,
                ["params"] = {
                    ["templateId"] = "defaut",
                },
            },
            [10] = {
                ["enabled"] = _goToWpt,
                ["auto"] = false,
                ["id"] = "GoToWaypoint",
                ["number"] = 10,
                ["params"] = {
                    ["fromWaypointIndex"] = _goToWptFrom,
                    ["nWaypointIndx"] = _goToWptTo,
                },
            },
        }
        _tasks = {}
    
        --%%% ROUTE %%%
        _wPoints = {
            [1] = {
                --["alt"] = 5,
                ["type"] = "Turning Point",
                ["ETA"] = 0,
                ["alt_type"] = "BARO",
                ["formation_template"] = "",
                ["y"] = _initPosY,
                ["x"] = _initPosX,
                ["name"] = _initWaypointName,
                ["ETA_locked"] = true,
                ["speed"] = _initSpeed,
                ["action"] = "Off Road",
                ["task"] = {
                    ["id"] = "ComboTask",
                    ["params"] = {
                        ["tasks"] = _initTasks,
                    },
                },
                ["speed_locked"] = true,
            },
        }
    
        for i=2, #wPoints do
            _wPoints[#_wPoints+1] =  {
                --["alt"] = 5,
                ["type"] = "Turning Point",
                ["ETA"] = 0,
                ["alt_type"] = "BARO",
                ["formation_template"] = "",
                ["y"] = wPoints[i].posY or _initPosY + 2,
                ["x"] = wPoints[i].posX or _initPosX + 2,
                ["name"] = _waypointName..i,
                ["ETA_locked"] = true,
                ["speed"] = wPoints[i].speed or 15,
                ["action"] = "Off Road",
                ["task"] = {
                    ["id"] = "ComboTask",
                    ["params"] = {
                        ["tasks"] = _tasks
                    },
                },
                ["speed_locked"] = true,
            }
        end
    
        --%%% UNITS %%%
        _units = {}
        for i=1, #units do
            _units[#_units+1] = {
                ["skill"] = _skill, 
                ["coldAtStart"] = _coldAtStart,
                ["type"] = units[i].unitType or "Leclerc",
                ["unitId"] = math.random(1000,99999),
                ["y"] = units[i].posY,
                ["x"] = units[i].posX,
                ["name"] = units[i].unitName or groupName.."-"..i,
                ["heading"] = _heading,
                ["playerCanDrive"] = true,
            }
        end
        
        --%%% GROUP DATA %%%
        _groupData = {
            ["visible"] = false,
            ["hiddenOnPlanner"] = true,
            ["tasks"] = {},
            ["uncontrollable"] = false,
            ["task"] = "Pas de sol", --?
            ["taskSelected"] = true,
            ["route"] = {
                ["spans"] = {},
                ["points"] = _wPoints,
            },
            ["groupId"] = math.random(1000,99999),
            ["hidden"] = false,
            ["units"] = _units,
            ["y"] = _initPosY,
            ["x"] = _initPosX,
            ["name"] = groupName,
            ["start_time"] = 0,
        }
        
        --%%% SPAWNER %%%
        coalition.addGroup(groupCoalition, Group.Category.GROUND, _groupData)
    end

    --%%% LIST SPAWNED TABLE %%%
    function PWS.PrintSpawned()
        for i = 1, #PWS_Spawned do
            trigger.action.outText("Persistent World | PWS_Spawned["..i.."] : "..PWS_Spawned[i].unitGroupName,5)
            for i2 =1, #PWS_Spawned[i].units do
                trigger.action.outText("Persistent World | PWS_Spawned["..i.."] : "..PWS_Spawned[i].units[i2].unitName,5)
            end
        end
    end

    --%%% UPDATE SPAWNED TABLE %%%
    function PWS.UpdateSpawnedTable()
        --PWS.PrintSpawned()
        if PWS.saveBirthBlue == true or PWS.saveBirthRed == true then
            _tempTable = {}
            for i = 1, #PWS_Spawned do
                if PWS_Spawned[i].unitCoalition
                and PWS_Spawned[i].unitObjectCategory
                and PWS_Spawned[i].unitCategory
                and PWS_Spawned[i].unitGroupName
                and PWS_Spawned[i].units
                then
                    _tempUnitsTable = {}
                    _alive = 0
                    for i2=1, #PWS_Spawned[i].units do  
                        _currentUnit = Unit.getByName(PWS_Spawned[i].units[i2].unitName)
                        if _currentUnit and _currentUnit:getLife() >= 1 then
                            _alive = _alive+1
                            _currentPos = _currentUnit:getPoint()

                            _tempUnitsTable[#_tempUnitsTable+1] = {
                                unitType = PWS_Spawned[i].units[i2].unitType,
                                unitName = PWS_Spawned[i].units[i2].unitName,
                                posY = _currentPos.z,
                                posX = _currentPos.x,
                            }
                        else
                            --trigger.action.outText("Persistent World | Update Spawned : L'unité "..PWS_Spawned[i].units[i2].unitName.." n'existe plus",30)
                        end
                    end
                    if _alive > 0 then
                        _tempTable[#_tempTable+1] = {}
                        _tempTable[#_tempTable].unitCoalition = PWS_Spawned[i].unitCoalition
                        _tempTable[#_tempTable].unitObjectCategory = PWS_Spawned[i].unitObjectCategory
                        _tempTable[#_tempTable].unitCategory = PWS_Spawned[i].unitCategory
                        _tempTable[#_tempTable].unitGroupName = PWS_Spawned[i].unitGroupName
                        _tempTable[#_tempTable].units = _tempUnitsTable
                    else
                        --trigger.action.outText("Persistent World | Update Spawned : L'unité "..PWS_Spawned[i].unitGroupName.." n'existe plus",30)
                    end -- group alive
                else
                    --trigger.action.outText("Persistent World | Update Spawned : 1 loop skipped, a nil value ",5)
                end -- group exist
            end
            PWS_Spawned = _tempTable
            --trigger.action.outText("Persistent World | Update Spawned : complete",5)
        end
    end

    --%%% UPDATE MARKS TABLE %%%
    function PWS_updateMarksTable()
        if PWS.saveMarksBlue == true or PWS.saveMarksRed ==true then
            _tempTable = {}
            _worldMarks = world.getMarkPanels()

            for i = 1, #_worldMarks do
                if _worldMarks[i].text and _worldMarks[i].text ~= "" then
                    _match = 0
                    for y=1, #PWS.escapeTextFromMarksList do
                        if string.match(_worldMarks[i].text, PWS.escapeTextFromMarksList[y]) then _match = _match + 1 end
                    end
                    if _match ~= 0 then
                        --trigger.action.outText("Persistent World | Mark ignored", 5)
                    else
                        _tempTable[#_tempTable+1] = {}
                        _tempTable[#_tempTable].idx = _worldMarks[i].idx
                        _tempTable[#_tempTable].coalition = _worldMarks[i].coalition
                        _tempTable[#_tempTable].text = _worldMarks[i].text
                        _tempTable[#_tempTable].pos = _worldMarks[i].pos
                    end
                end
            end
            PWS_Marks = _tempTable
            --trigger.action.outText("Persistent World | Update Update Marks : complete",5)
        end
    end


    --%%% SAVE FUNCTION FOR UNITS %%%
    function PWS.SaveDeadUnits(timeloop, time)
        _deadUnitsStr = IntegratedserializeWithCycles("PWS_Units", PWS_Units)
        writemission(_deadUnitsStr, PWS.deadUnitsSaveFile)
        trigger.action.outText("Persistent World | Progress Has Been Saved", 2)
        env.info("Persistent World | Dead units Saved")
        return time + PWS.SaveSchedule
    end

    function PWS.SaveDeadUnitsNoArgs()
        _deadUnitsStr = IntegratedserializeWithCycles("PWS_Units", PWS_Units)
        writemission(_deadUnitsStr, PWS.deadUnitsSaveFile)
    end

    --%%% SAVE FUNCTION FOR STATICS %%%
    function PWS.SaveDeadStatics(timeloop, time)
        _deadStaticsStr = IntegratedserializeWithCycles("PWS_Statics", PWS_Statics)
        writemission(_deadStaticsStr, PWS.deadStaticsSaveFile)
        --trigger.action.outText("Progress Has Been Saved", 15)
        env.info("Persistent World | Dead statics Saved")
        return time + PWS.SaveSchedule
    end

    function PWS.SaveDeadStaticsNoArgs()
        _deadStaticsStr = IntegratedserializeWithCycles("PWS_Statics", PWS_Statics)
        writemission(_deadStaticsStr, PWS.deadStaticsSaveFile)
    end

    --%%% SAVE FUNCTION FOR SPAWNED %%%
    function PWS.SaveSpawned(timeloop, time)
        
        --PWS_updateSpawnedTable()
        PWS.UpdateSpawnedTable()
        
        _spawnedStr = IntegratedserializeWithCycles("PWS_Spawned", PWS_Spawned)
        writemission(_spawnedStr, PWS.spawnedUnitsSaveFile)
        --trigger.action.outText("Persistent World | Births Has Been Saved", 2)
        env.info("Persistent World | Spawned groups Saved")
        return time + PWS.SaveSchedule
    end

    function PWS.SaveSpawnedTableNoArgs()
        _spawnedStr = IntegratedserializeWithCycles("PWS_Spawned", PWS_Spawned)
        writemission(_spawnedStr, PWS.spawnedUnitsSaveFile)
    end



    --%%% SAVE FUNCTION FOR MARKS %%%
    function PWS.SaveMarks(timeloop, time)
            
        PWS_updateMarksTable()
        
        _marksStr = IntegratedserializeWithCycles("PWS_Marks", PWS_Marks)
        writemission(_marksStr, PWS.marksSaveFile)
        env.info("Persistent World | Marks Saved")
        return time + PWS.SaveSchedule
    end

    function PWS.SaveMarksTableNoArgs()
        _marksStr = IntegratedserializeWithCycles("PWS_Marks", PWS_Marks)
        writemission(_marksStr, PWS.marksSaveFile)	
    end



--%%%%% MAIN () %%%%%
    --> Counters
    PWSDeletedUnitCount = 0
    PWSDeletedStaticCount = 0

    --> Loading message
    trigger.action.outText("Persistent World | Loading...  -  Credits : JGi | Quéton 1-1", 5)
    env.info("Persistent World | Loading...  -  Credits : JGi | Quéton 1-1")

    if os ~= nil then

        --%%% LOAD DEAD STATICS %%%
        if file_exists(PWS.deadStaticsSaveFile) then
            
            dofile(PWS.deadStaticsSaveFile)
            
            for i = 1, #PWS_Statics do
                
                if ( StaticObject.getByName(PWS_Statics[i]) ~= nil ) then		
                    StaticObject.getByName(PWS_Statics[i]):destroy()		
                    PWSDeletedStaticCount = PWSDeletedStaticCount + 1
                elseif ( Unit.getByName(PWS_Statics[i]) ~= nil ) then
                    Unit.getByName(PWS_Statics[i]):destroy()
                    PWSDeletedUnitCount = PWSDeletedUnitCount + 1
                else
                    trigger.action.outText("Static "..i.." Is "..PWS_Statics[i].." And Was Not Found", 2)
                    env.info("Persistent World | Static "..i.." Is "..PWS_Statics[i].." And Was Not Found", 2)
                end	
            end
            trigger.action.outText("Persistent World | Removed "..PWSDeletedStaticCount.." Static(s)", 5)
            env.info("Persistent World | Removed "..PWSDeletedStaticCount.." Static(s)", 5)
        else
            PWS_Statics = {}
            StaticIntermentTableLength = 0	
        end

        --%%% LOAD DEAD UNITS %%%
        if file_exists(PWS.deadUnitsSaveFile) then	
            dofile(PWS.deadUnitsSaveFile)
            for i = 1, #PWS_Units do	
                
                if ( Unit.getByName(PWS_Units[i]) ~= nil ) then
                    Unit.getByName(PWS_Units[i]):destroy()
                    PWSDeletedUnitCount = PWSDeletedUnitCount + 1
                else
                    trigger.action.outText("Unit "..i.." Is "..PWS_Units[i].." And Was Not Found", 2)
                    env.info("Unit "..i.." Is "..PWS_Units[i].." And Was Not Found")
                end	
            end
            trigger.action.outText("Persistent World | Removed "..PWSDeletedUnitCount.." Unit(s)", 5)
            env.info("Persistent World | Removed "..PWSDeletedUnitCount.." Unit(s)")
        else			
            PWS_Units = {}	
            trigger.action.outText("Persistent World | No save found, creating new files...", 5)
            env.info("Persistent World | No save found, creating new files...")
        end

        --%%% LOAD SPAWNED UNITS %%%
        if PWS.saveBirthBlue == true or PWS.saveBirthRed == true then
            if file_exists(PWS.spawnedUnitsSaveFile) then	
                --trigger.action.outText("Persistent World | Loads units spawned in the past...",5)
                
                dofile(PWS.spawnedUnitsSaveFile)
                
                restoredUnit = 0
                if PWS_Spawned then   
                    for i = 1, #PWS_Spawned do
                        
                        if PWS_Spawned[i]
                        and PWS_Spawned[i].unitObjectCategory
                        and PWS_Spawned[i].unitCategory
                        and PWS_Spawned[i].unitCoalition
                        and PWS_Spawned[i].unitGroupName
                        and PWS_Spawned[i].units
                        then
                            if PWS_Spawned[i].unitCoalition == 2 then _flag = country.id.CJTF_BLUE else _flag = country.id.CJTF_RED end

                            _name = PWS_Spawned[i].unitGroupName
                            _units = PWS_Spawned[i].units
                            _points = {
                                [1] = {
                                    ["posY"] = PWS_Spawned[i].units[1].posY,
                                    ["posX"] = PWS_Spawned[i].units[1].posX,
                                },
                            }
                            _freq = 122000000

                            PWS.GroundGroupSpawn(_flag, _name, _points, _units, _freq)
                            restoredUnit = restoredUnit + 1
                        else
                            trigger.action.outText("Persistent World | Restoring unit : One loop skip, a nil value",5)
                            env.info("Persistent World | Restoring unit : One loop skip, a nil value")
                        end	
                    end
                    trigger.action.outText("Persistent World | Restored "..restoredUnit.." Unit(s)",5)
                    env.info("Persistent World | Restored "..restoredUnit.." Unit(s)")

                end
            else
                trigger.action.outText("Persistent World | No Spawned save file",5)
                env.info("Persistent World | No Spawned save file")			
            end
        end

        --%%% LOAD MARKS %%%
        if PWS.saveMarksBlue == true or PWS.saveMarksRed == true then
            if file_exists(PWS.marksSaveFile) then	
                --trigger.action.outText("Persistent World | Loads units spawned in the past...",5)
                
                dofile(PWS.marksSaveFile)
                
                _restoredMarks = 0

                if PWS_Marks then            
                    for i = 1, #PWS_Marks do
                        
                        if PWS_Marks[i]
                        and PWS_Marks[i].coalition
                        and PWS_Marks[i].idx
                        and PWS_Marks[i].text
                        and PWS_Marks[i].pos
                        then
                            trigger.action.markToCoalition(PWS_Marks[i].idx , PWS_Marks[i].text , PWS_Marks[i].pos, PWS_Marks[i].coalition , false) --optionnal ,string message)

                            _restoredMarks = _restoredMarks + 1
                        else
                            trigger.action.outText("Persistent World | Restoring Marks : One loop skip, a nil value",5)
                            env.info("Persistent World | Restoring Marks : One loop skip, a nil value")
                        end	
                        i = i+1
                    end
                    trigger.action.outText("Persistent World | Restored ".._restoredMarks.." Mark(s)",5)
                    env.info("Persistent World | Restored ".._restoredMarks.." Mark(s)")
                end
            else		
                trigger.action.outText("Persistent World | No Marks save file",5)
                env.info("Persistent World | No Marks save file")
                PWS_Marks = {}
            end
        end

        --%%% SCHEDULE %%%
        timer.scheduleFunction(PWS.SaveDeadUnits, 53, timer.getTime() + PWS.SaveSchedule)
        timer.scheduleFunction(PWS.SaveDeadStatics, 53, timer.getTime() + (PWS.SaveSchedule))
        timer.scheduleFunction(PWS.SaveSpawned, nil, timer.getTime() + PWS.SaveSchedule)
        timer.scheduleFunction(PWS.SaveMarks, nil, timer.getTime() + PWS.SaveSchedule)

        --%%% EVENT LOOP - ON DEAD, LOST, KILL %%%
            PWS_ONDEADEVENTHANDLER = {}
            function PWS_ONDEADEVENTHANDLER:onEvent(Event)
                if Event.id == world.event.S_EVENT_DEAD or Event.id == world.event.S_EVENT_UNIT_LOST then --or Event.id == world.event.S_EVENT_KILL then
                    if Event.initiator then --and Event.initiator:getCoalition() ~= nil then
                        if ( Event.initiator:getCategory() == 1 or Event.initiator:getCategory() == 3 ) then -- UNIT or STATIC
                            
                            if Event.id == world.event.S_EVENT_DEAD or Event.id == world.event.S_EVENT_UNIT_LOST then
                                DeadUnit 				 = Event.initiator
                                DeadUnitObjectCategory = Event.initiator:getCategory() 
                                -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
                                DeadUnitCategory 		 = Event.initiator:getDesc().category 
                                -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
                                DeadUnitCoalition 	   = Event.initiator:getCoalition()
                                --DeadGroupName		     = Event.initiator:getGroup():getName()
                                DeadUnitName			 = Event.initiator:getName()
                                DeadUnitType			 = Event.initiator:getTypeName()

                            elseif Event.id == world.event.S_EVENT_KILL then
                                DeadUnit 				 = Event.target
                                DeadUnitObjectCategory = Event.target:getCategory()
                                -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
                                DeadUnitCategory 		 = Event.target:getDesc().category
                                -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
                                DeadUnitCoalition 	 = Event.target:getCoalition()
                                --DeadGroupName		     = Event.initiator:getGroup():getName()
                                DeadUnitName			 = Event.target:getName()
                                DeadUnitType			 = Event.target:getTypeName()
                            else
                            end
                            
                            if ( DeadUnitCoalition == 1 or DeadUnitCoalition == 2 and PWS.saveDeadBlue == true) then	
                                if DeadUnitObjectCategory == 1 then -- UNIT
                                    if ( DeadUnitCategory == 2 or DeadUnitCategory == 3 ) then -- GROUND_UNIT or SHIP
                                        --trigger.action.outText("Persistent World | "..DeadUnitType, 60)

                                        match = 0
                                        for i=1, #PWS.escapeTypeFromDeadList do
                                            if string.match(DeadUnitType, PWS.escapeTypeFromDeadList[i]) then match = match + 1 end
                                        end
                                        for i=1, #PWS.escapeNameFromDeadList do
                                            if string.match(DeadUnitName, PWS.escapeNameFromDeadList[i]) then match = match + 1 end
                                        end
                                        if match ~= 0 then  
                                            --trigger.action.outText("Persistent World | Unit ignored", 5)
                                        else
                                            match = 0
                                            for i=1, #PWS_Units do
                                                if PWS_Units[i] == DeadUnitName then match = match + 1 end
                                            end
                                            if match == 0 then
                                                PWS_Units[#PWS_Units+1] = DeadUnitName
                                            end
                                            --trigger.action.outText("Persistent World | Unit added (Dead)", 10)
                                        end	
                                    else
                                    end
                                elseif DeadUnitObjectCategory == 3 then	-- STATIC
                                    match = 0
                                    for i=1, #PWS_Statics do
                                        if PWS_Statics[i] == DeadUnitName then match = match + 1 end
                                    end
                                    if match == 0 then
                                        PWS_Statics[#PWS_Statics+1] = DeadUnitName
                                    end
                                    --trigger.action.outText("Persistent World | Static "..DeadUnitName.." destroyed ", 10)			
                                else
                                end
                            else
                            end
                            
                        end	
                    end
                end
            end
            world.addEventHandler(PWS_ONDEADEVENTHANDLER)

        --%%% EVENT LOOP - ON BIRTH %%%
            PWS_ONBIRTHEVENTHANDLER = {}
            function PWS_ONBIRTHEVENTHANDLER:onEvent(Event)
                
                if Event.id == world.event.S_EVENT_BIRTH then
                    if Event.initiator then
                        if ( Event.initiator:getCategory() == 1 or Event.initiator:getCategory() == 3 ) then -- UNIT or STATIC
                            if ( Event.initiator:getCoalition() ~= nil ) then
                            
                                local birthUnit 				 = Event.initiator
                                local birthUnitObjectCategory = Event.initiator:getCategory()
                                -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
                                local birthUnitCategory 		 = Event.initiator:getDesc().category
                                -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
                                birthUnitCoalition 	        = Event.initiator:getCoalition()
                                BirthGroupName		        = Event.initiator:getGroup():getName()
                                birthUnitName			    = Event.initiator:getName()
                                birthUnitType			    = Event.initiator:getTypeName()
                                currentPos                  = Unit.getByName(birthUnitName):getPoint()
                                birthUnitPosY 		        = currentPos.z
                                birthUnitPosX 		        = currentPos.x

                                if ( birthUnitCoalition == 1 and PWS.saveBirthRed == true or birthUnitCoalition == 2 and PWS.saveBirthBlue == true) then
                                    if birthUnitObjectCategory == 1 and birthUnitCategory == 2 then -- UNIT
                                        _match = 0
                                        for i=1, #PWS.escapeNameFromBirthList do
                                            if string.match(birthUnitName, PWS.escapeNameFromBirthList[i]) then _match = _match + 1 end
                                        end
                                        if _match ~= 0 then  
                                            --trigger.action.outText("Persistent World | Birth Unit ignored", 5)
                                            env.info("Persistent World | Birth Unit ignored")
                                        else
                                            _groupMatch = 0
                                            for i = 1, #PWS_Spawned do
                                                if PWS_Spawned[i].unitGroupName == BirthGroupName then
                                                    _groupMatch = _groupMatch+1
                                                    PWS_Spawned[i].units[#PWS_Spawned[i].units+1] = {
                                                        unitType = birthUnitType,
                                                        unitName = birthUnitName,
                                                        posY = birthUnitPosY,
                                                        posX = birthUnitPosX,
                                                    }
                                                end
                                            end
                                            if _groupMatch == 0 then
                                                PWS_Spawned[#PWS_Spawned+1] = {
                                                    unitCoalition = birthUnitCoalition,
                                                    unitObjectCategory = birthUnitObjectCategory,
                                                    unitCategory = birthUnitCategory,
                                                    unitGroupName = BirthGroupName,
                                                    units = {
                                                        [1] = {
                                                            unitType = birthUnitType,
                                                            unitName = birthUnitName,
                                                            posY = birthUnitPosY,
                                                            posX = birthUnitPosX,
                                                        },
                                                    }
                                                }
                                            end
                                            PWS.escapeTypeFromDeadList[#PWS.escapeTypeFromDeadList+1] = birthUnitName
                                        end
                                    -- elseif ( birthUnitObjectCategory == 3 ) then 									-- STATIC
                                    -- 	SpawnedTableLength = SpawnedTableLength + 1			
                                    -- 	PWS_Spawned[SpawnedTableLength] = birthUnitName												
                                    else
                                    end
                                else
                                end
                            else
                            end
                        end	
                    end
                end
            end
            world.addEventHandler(PWS_ONBIRTHEVENTHANDLER)
    else
        trigger.action.outText("Persistent World | Error, MissionScripting.lua 'sanitize'.", 10)
        env.info("Persistent World | Error, MissionScripting.lua 'sanitize'.")
    end