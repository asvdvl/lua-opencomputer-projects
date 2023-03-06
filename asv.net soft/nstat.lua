local net = require("asv").net
--local shell = require("shell")

--local args, options = shell.parse(...)

local fileName = os.tmpname()
local statsFileWriter = io.open(fileName, "w")

local function printRow(text)
    statsFileWriter:write(text.."\n")
end

local function collectData()
    printRow("phys level")
    for key, value in pairs(net.phys.service.stats) do
        printRow(key..":    "..value)
    end
    printRow("")

    printRow("LinkLayer level")
    for key, value in pairs(net.Layers.Link.service.stats) do
        printRow(key..":    "..value)
    end
    printRow("")
end

collectData()

statsFileWriter:close()
loadfile("/bin/edit.lua")("-r",fileName)
require("filesystem").remove(fileName)