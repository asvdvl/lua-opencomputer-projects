local asvutils = require("asvutils")
local settLib = require("settings")
local comp = require("computer")
local fs = require("filesystem")
local objectsAndSets = {}
local groupEnv = {}

local hardSett = {
    loadDefaultIfParseFromFileError = false,
    useScreenOutput = true,
    debug = false
}

local defaultSettings = {
    --Warning! Don't edit this table. You can edit your solution in /etc/settings/machineController.cfg(serialized table).
    --If the path to the file does not exist(or table is damaged) then run the program, the path and the file with the default settings will be created automatically.

    actionMode = 1,
    --actionMode - set action type(file, function or single mode)
    ---1: function mode - action write as function
    ---2: file mode - action write as path to program
    ---3: single file - actions write as library
    ---(A table with functions checkFunction, action, actionOnPrint should be returned).
    ---The file path should be in checkFunction

    machineGroups = {
        defaultGroupName = {
            title = "Default Group",
            enable = true,
            checkFunction = "local a={...}for _,mh in pairs(a[2])do opt=mh.options;return{math.ceil(require(\"computer\").uptime()%a[3].num1)==opt.num2,require(\"computer\").uptime()}end",
            action = "local a={...}local opt=a[1].options.returned.checkFunction;print(opt[1], opt[2])",
            actionOnPrint = "",
            machines = {"defaultMachineName"},
            options = {num1=5, returned = {}},
            executeEvery = 7,
            printSettings = {}
        },
        defaultOnStartMessage = {
            title = "On Start Message",
            enable = true,
            checkFunction = "local a={...}for b,c in pairs(a[2])do for b,d in pairs(c.options.rows)do print(d)end end",
            action = "",
            actionOnPrint = "",
            machines = {"defaultOnStartMessageText"},
            options = {returned = {}},
            executeEvery = "start"
        }
    },
    --Arguments for checkFunction action and actionOnPrint.
    --Current machineGroup object are passed as first argument
    --The machines and options are also passed as the second and third arguments, respectively.

    --Also stores the second return parameter in options.returned.(can be either a table or another arbitrary type)
    --title - Custom parameter. Not used(Except in error messages and user scripts).
    --enable - If false this item will be ignored during init and execute.
    --machines - Table of text indexes in the machine table.
    --checkFunction - A function(or file. see actionMode) where the code for getting some data from sensors or other input devices.
    --action - A function(or file. see actionMode), where the code for processing the output value from checkFunction is located and/or some action is perfomed(e.g. enable reactors).
    --p.s. Of course, you don't need to split into 2 different functions. Just write "return nil" for actionMode 1 and 2 or empty function for mode 3.
    --options - Custom parameter. You can add your own fields. By default contains a table with returned values from checkFunction and action.
    --executeEvery - Delay between executions groups(in number). The "start" value is also available. in which the group is executed once i.e. at startup.

    machines = {
        defaultMachineName = {
            title = "Default machine title",
            enable = true,
            options = {num2=2}
        },
        defaultOnStartMessageText = {
            title = "On Start Message text",
            enable = true,
            options = {
                rows = {
                    "It is default configuration.",
                    "See /etc/settings/machineController.cfg to change the configuration.",
                    "Also see machineControllerSnippets folder on repository for examples and work solutions.",
                    "In this configuration, there is also an item that receives the computer's uptime and gets the remainder of the division of number1 and compares it with number2.",
                    "The example is minified for string packaging but uses most of the features of this program."
                }
            }
        }
    },
    --title - Custom parameter. Not used.
    --enable - If false this item will be ignored during create links and execute.
    --options - Custom parameter. Not used. You can add your own fields.

    printSettings = {
        enable = false,
    }
    --enable - Enables the print function.
}

local items = {
    machineGroupsItem = {
        --user parameters
        title = "Default group title", checkFunction = "", action = "", options = {returned = {}}, executeEvery = 60, enable = false, machines = {},
        printSettings = {
            enable = false,
            action = "",
            rows = 1,
        },
        --service parameters
        lastExecution = 0
    },
    machinesItem = {
        --user parameters
        title = "Default machine title", options = {}, enable = false,
        --service parameters
        groupObjects = {}
    }
}

if hardSett.useScreenOutput then
    require("term").clear()
end

local function debugPrint(text)
    if hardSett.debug then
        io.stdout:write("[DEBUG]["..comp.uptime().."] "..text.."\n")
    end
end


local function print(text, err)
    if hardSett.useScreenOutput then
        if err then
            io.stderr:write(text.."\n")
        else
            io.stdout:write(text.."\n")
        end
    end
end

local function printErr(text)
    print(text, true)
end

local function loadSettings()
    local status
    status, objectsAndSets = settLib.getSettings("machineController", defaultSettings)
    if not status then
        printErr("error loading settings: "..objectsAndSets)
        if not hardSett.loadDefaultIfParseFromFileError then
            return false
        end
        printErr("loading default settings")
        objectsAndSets = defaultSettings
    end
    return true
end

local function correctItems()
    for index, object in pairs(objectsAndSets.machineGroups) do
        objectsAndSets.machineGroups[index] = asvutils.correctTableStructure(object, items.machineGroupsItem)
    end

    for index, object in pairs(objectsAndSets.machines) do
        objectsAndSets.machines[index] = asvutils.correctTableStructure(object, items.machinesItem)
    end
end

local function createLinks()
    for machGroupIndex, item in pairs(objectsAndSets.machineGroups) do
        local machinesObj = {}
        for _, machineItemName in pairs(item.machines) do
            if not objectsAndSets.machines[machineItemName] then
                printErr("group `"..machineItemName.."` not found")
                return false
            end

            if item.enable and objectsAndSets.machines[machineItemName].enable then
                --add link to machinesObjects
                machinesObj[machineItemName] = objectsAndSets.machines[machineItemName]

                --add link to machineGroups
                objectsAndSets.machines[machineItemName].groupObjects[machGroupIndex] = item

                debugPrint("Successfully create link between `"..machGroupIndex.."` and `"..machineItemName.."`")
            else
                debugPrint("Machine `"..machineItemName.."` was skip create links because machine group "..
                "`"..machGroupIndex.."` is "..tostring(item.enable).." and `"..machineItemName..
                "` is "..tostring(objectsAndSets.machines[machineItemName].enable))
            end
        end
        item.machines = machinesObj
    end
    return true
end

local function buildEnviroment()
    groupEnv = setmetatable(groupEnv, {__index = _G})
    groupEnv["machineControllerENV"] = {}

    groupEnv.machineControllerENV["items"] = items
    groupEnv.machineControllerENV["objectsAndSets"] = objectsAndSets
end

local function loadFunctions()
    if objectsAndSets.actionMode >= 1 and objectsAndSets.actionMode <= 3 then
        local functionKeys = {
            "checkFunction", "action"
        }

        for machGroupIndex, item in pairs(objectsAndSets.machineGroups) do
            if item.enable then
                debugPrint("Loading `"..machGroupIndex.."` functions")
                if objectsAndSets.actionMode == 1 or objectsAndSets.actionMode == 2 then
                    for _, funcName in pairs(functionKeys) do
                        if objectsAndSets.actionMode == 1 then
                            local func, reason = load(objectsAndSets.machineGroups[machGroupIndex][funcName], nil, nil, groupEnv)
                            if reason then
                                printErr("Function "..funcName.." in "..machGroupIndex.." loading error: "..reason);
                                return false
                            end
                            objectsAndSets.machineGroups[machGroupIndex][funcName] = func
                        else
                            if not fs.exists(objectsAndSets.machineGroups[machGroupIndex].checkFunction) then
                                printErr("File "..objectsAndSets.machineGroups[machGroupIndex][funcName].." in group "..machGroupIndex.." not exists");
                                return false
                            end

                            local func, reason = loadfile(objectsAndSets.machineGroups[machGroupIndex][funcName], nil, groupEnv)
                            if reason then
                                printErr("File "..objectsAndSets.machineGroups[machGroupIndex][funcName].." in "..machGroupIndex.." loading error: "..reason);
                                return false
                            end
                            objectsAndSets.machineGroups[machGroupIndex][funcName] = func
                        end
                    end
                else
                    if not fs.exists(objectsAndSets.machineGroups[machGroupIndex].checkFunction) then
                        printErr("File "..objectsAndSets.machineGroups[machGroupIndex].checkFunction.." in group "..machGroupIndex.." not exists");
                        return false
                    end

                    local table, reason = loadfile(objectsAndSets.machineGroups[machGroupIndex].checkFunction, nil, groupEnv)()
                    if reason then
                        printErr("Functions in "..machGroupIndex.." loading error: "..reason);
                        return false
                    end
                    for _, funcName in pairs(functionKeys) do
                        objectsAndSets.machineGroups[machGroupIndex][funcName] = table[funcName]
                    end
                end
                debugPrint("Successful loading `"..machGroupIndex.."` functions")
            else
                debugPrint("Machine group `"..machGroupIndex.."` was skip load functions because machine group is disabled")
            end
        end
    else
        printErr("parameter actionMode is not correct")
        return false
    end
    return true
end

local function initScreen()
    
end

local function updateScreen()
    
end

local function main()
    local functionKeys = {
        "checkFunction", "action"
    }

    debugPrint("Start execute `onstart` groups.")
    --execute "start" operations
    for machGroupIndex in pairs(objectsAndSets.machineGroups) do
        local currentGroup = objectsAndSets.machineGroups[machGroupIndex]
        if currentGroup.enable and currentGroup.executeEvery == "start" then
            debugPrint("Start execute `"..machGroupIndex.."`")
            for _, funcName in pairs(functionKeys) do
                local succes, data = pcall(currentGroup[funcName], currentGroup, currentGroup.machines, currentGroup.options)
                if not succes then
                    printErr("Group: `"..currentGroup.title.."` Func: `"..funcName.."` Error: `"..data.."`")
                    break
                end
                currentGroup.options.returned[funcName] = data
            end

            currentGroup.lastExecution = comp.uptime()
            --disable group
            currentGroup.enable = false
        end
    end

    --searching minimum delay
    local delay = -1
    for _, value in pairs(objectsAndSets.machineGroups) do
        if value.enable then
            if value.executeEvery < delay or delay == -1 then
                delay = value.executeEvery
            end
        end
    end
    debugPrint("Minimum delay is: "..delay)
    debugPrint("Start execute normal groups.")

    while true do
        for machGroupIndex in pairs(objectsAndSets.machineGroups) do
            local currentGroup = objectsAndSets.machineGroups[machGroupIndex]
            if currentGroup.enable then
                debugPrint("Start execute `"..machGroupIndex.."`")
                local time = comp.uptime()
                if time - currentGroup.lastExecution >= currentGroup.executeEvery then
                    for _, funcName in pairs(functionKeys) do
                        local succes, data = pcall(currentGroup[funcName], currentGroup, currentGroup.machines, currentGroup.options)
                        if not succes then
                            printErr("Group: `"..currentGroup.title.."` Func: `"..funcName.."` Error: `"..data.."`")
                            break
                        end
                        currentGroup.options.returned[funcName] = data
                    end

                    currentGroup.lastExecution = comp.uptime()
                end
            end
        end
        updateScreen()
        os.sleep(delay)
    end
end

--init
print("loading settings")
if not loadSettings() then
    os.exit()
end

print("correct items")
correctItems()

print("create links")
if not createLinks() then
    os.exit()
end

print("build enviroment")
buildEnviroment()

print("loading functions")
if not loadFunctions() then
    os.exit()
end

print("init screen")
if hardSett.useScreenOutput then
    initScreen()
end

--main cycle
print("start working\n")
main()