local asvutils = require("asvutils")
local settLib = require("settings")
local settings = {}

local defaultSettings = {
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
            checkFunction = "local a={...}local opt=a.machinesObjects[1].options;return math.ceil(computer.uptime()%opt.num1)==opt.num2,computer.uptime()",
            action = "local a={...}local opt=a.machinesObjects[1].options;print(opt.returned[1], opt.returned[2])",
            actionOnPrint = "",
            options = {returned = {}}
        }
    },
    --current machineGroup object are passed as first argument
    --also stores the second return parameter in options.returned.(can be either a table or another arbitrary type)

    machines = {
        defaultMachineName = {
            title = "Default machine title",
            machineGroup = "defaultGroupName",
            options = {address = "1meh", num1=5, num2=2}
        }
    },
    --title - Custom parameter. Not used.
    --machineGroup - The text value of the index in the machineGroups table.

    machineGroupsItem = {
        --user parameters
        title = "Default group title", checkFunction = "", action = "",actionOnPrint = "", options = {returned = {}},
        --service parameters
        machinesObjects = {}
    },
    machinesItem = {
        --user parameters
        title = "Default machine title", machineGroup = "defaultGroupName", options = {},
        --service parameters
        groupObject = {}
    },
}

local function loadSettings()
    local status
    status, settings = settLib.getSettings("machineController", defaultSettings)
    if status then
    	io.stdout:write("loading complete\n")
    else
        io.stderr:write("error loading settings: "..settings.."\n")
        io.stderr:write("loading default settings")
    	settings = defaultSettings
    end
end

local function correctItems()
    for key, value in pairs(settings.machineGroups) do
        settings.machineGroups[key] = asvutils.checkTableStructure(value, settings.machineGroupsItem)
    end

    for key, value in pairs(settings.machines) do
        settings.machines[key] = asvutils.checkTableStructure(value, settings.machinesItem)
    end
end

local function createLinks()
    for key, value in pairs(settings.machines) do
        if settings.machineGroups[value.machineGroup] then
            --set link in groupObject
            settings.machines[key].groupObject = settings.machineGroups[value.machineGroup]

            --add link to machineGroups
            table.insert(settings.machineGroups[value.machineGroup].machinesObjects, value)
            return true
        else
            io.stderr:write("group "..value.machineGroup.." not found")
            return false
        end
    end
end

local function loadFunctions()
    if settings.actionMode >= 1 and settings.actionMode <= 3 then
        local functionKeys = {
            "checkFunction", "action", "actionOnPrint"
        }

        for keyGroup in pairs(settings.machineGroups) do
            if settings.actionMode == 1 or settings.actionMode == 2 then
                for _, value in pairs(functionKeys) do
                    if settings.actionMode == 1 then
                        local func, reason = load(settings.machineGroups[keyGroup][value])
                        settings.machineGroups[keyGroup][value] = func
                        if reason then
                            io.stderr:write("Function loading error: "..reason);
                            return false
                        end
                    else
                        local func, reason = loadfile(settings.machineGroups[keyGroup][value])
                        settings.machineGroups[keyGroup][value] = func
                        if reason then
                            io.stderr:write("File loading error: "..reason);
                            return false
                        end
                    end
                end
            else
                local table, reason = loadfile(settings.machineGroups[keyGroup].checkFunction)()
                if reason then
                    io.stderr:write("Functions loading error: "..reason);
                    return false
                end
                for _, value in pairs(functionKeys) do
                    settings.machineGroups[keyGroup][value] = table[value]
                end
            end
        end
    else
        io.stderr:write("parameter actionMode is not correct")
        return false
    end
    return true
end

--init
io.stdout:write("loading settings\n")
loadSettings()

io.stdout:write("correct items\n")
correctItems()

io.stdout:write("create links\n")
if not createLinks() then
    os.exit()
end

io.stdout:write("loading functions\n")
if not loadFunctions() then
    os.exit()
end