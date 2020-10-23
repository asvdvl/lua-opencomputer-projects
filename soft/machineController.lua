local asvutils = require("asvutils")
local cmp = require("component")
local settLib = require("settings")
local settings = {}

local defaultSettings = {
    actionMode = "file",
    --actionMode - set view of action(file or function mode)
    --function mode - action write as function
    --file mode - action write as path to program
    machineGroups = {
        defaultGroupName = {checkFunction = "/usr/chk1", actionOnTRUE = "/usr/ac1", actionOnFALSE = "/usr/ac2", options = {returned = {}}}
    },
    --current machineGroup object are passed as first argument
    --table of machines and passed as second argument
    --checkFunction should return true or false.
    --also stores the second return parameter in options.returned.(can be either a table or another arbitrary type)

    machines = {
        defaultMachineName = {machineGroup = "defaultGroupName", options = {address = "1meh"}}
    },

    machineGroupsItem = {
        --user parameters
        checkFunction = "", actionOnTRUE = "", actionOnFALSE = "", options = {returned = {}},
        --service parameters
        machinesObjects = {}
    },
    machinesItem = {
        --user parameters
        machineGroup = "defaultGroupName", options = {},
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



--init
io.stdout:write("loading settings\n")
loadSettings()

io.stdout:write("correct items\n")
correctItems()