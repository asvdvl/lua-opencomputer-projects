local cmp = require("component")
local bb = cmp.gt_batterybuffer
local barrel = cmp.mcp_mobius_betterbarrel
local side = 2 --redstone output

local oPrint = print
local function print(...)
	cmp.modem.broadcast(20, ...)
	oPrint(...)
end

local size, maxSize, iterations, haveProblem = 0, 0, 0, false;
while true do
	haveProblem = false;
	size, maxSize = barrel.getStoredCount(), barrel.getMaxStoredCount()

	if size/maxSize >= 0.95 then
		print("over 95% buffer chest full")
		haveProblem = true
	elseif size/maxSize >= 0.70 then
		print("over 70% buffer chest full")
		haveProblem = true
	elseif size/maxSize >= 0.50 then
		print("over 50% buffer chest full")
		haveProblem = true
	end

	local currentEU = string.gsub(bb.getSensorInformation()[3], "([^0-9]+)", "")
	local maxEU = string.gsub(bb.getSensorInformation()[4], "([^0-9]+)", "")

	if currentEU/maxEU <= 0.1 then
		print("level voltage buffer is low")
		haveProblem = true
	end

	if haveProblem then
		cmp.redstone.setOutput(side, 15)
	else
		cmp.redstone.setOutput(side, 0)
	end

	oPrint(currentEU/maxEU)
	oPrint(size, maxSize)
	oPrint("Have problems: "..tostring(haveProblem))
	os.sleep(10)
end
