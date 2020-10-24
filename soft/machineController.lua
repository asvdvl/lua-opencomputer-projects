local asvutils = require("asvutils")
local settLib = require("settings")
local settings = {}

local defaultSettings = {
    actionMode = "file",
    --actionMode - set view of action(file or function mode)
    ---`function` mode - action write as function
    ---`file` mode - action write as path to program
    ---`single` file - actions write as library
    ---(A table with functions checkFunction, actionOnTRUE, actionOnFALSE, actionOnPrint should be returned).
    ---The file path should be in checkFunction
    machineGroups = {
        defaultGroupName = {title = "Default Group", checkFunction = "/usr/chk1", actionOnTRUE = "/usr/ac1", actionOnFALSE = "/usr/ac2", actionOnPrint = "/usr/acP", options = {returned = {}}}
    },
    --current machineGroup object are passed as first argument
    --table of machines and passed as second argument
    --checkFunction should return true or false.
    --also stores the second return parameter in options.returned.(can be either a table or another arbitrary type)

    machines = {
        defaultMachineName = {title = "Default group title", machineGroup = "defaultGroupName", options = {address = "1meh"}}
    },

    machineGroupsItem = {
        --user parameters
        title = "Default group title", checkFunction = "", actionOnTRUE = "", actionOnFALSE = "", actionOnPrint = "", options = {returned = {}},
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
    	os.sleep(3)
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
        else
            io.stderr:write("group "..value.machineGroup.." not found")
        end
    end
end

--init
io.stdout:write("loading settings\n")
loadSettings()

io.stdout:write("correct items\n")
correctItems()

io.stdout:write("create links\n")
createLinks()