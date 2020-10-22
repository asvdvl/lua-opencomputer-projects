local cmp = require("component")
local bb = cmp.gt_batterybuffer

local size, maxSize, iterations = 0, 0, 0;
while true do
	size, maxSize, iterations = 0, 0, 0;
	for _, tb in pairs(cmp.transposer.getAllStacks(1).getAll()) do 
		if tb["size"] then
			size = size + tb["size"]
		end
		if tb["maxSize"] then
			maxSize = tb["maxSize"]
		end
		iterations = iterations + 1
	end
	maxSize = maxSize * iterations
	
	if size == 0 then
	
	elseif size/maxSize >= 0.95 then
		cmp.modem.broadcast(20, "over 95% buffer chest full")
	elseif size/maxSize >= 0.70 then
		cmp.modem.broadcast(20, "over 70% buffer chest full")
	elseif size/maxSize >= 0.50 then
		cmp.modem.broadcast(20, "over 50% buffer chest full")
	end
	
	local currentEU = string.gsub(bb.getSensorInformation()[3], "([^0-9]+)", "")
	local maxEU = string.gsub(bb.getSensorInformation()[4], "([^0-9]+)", "")
	
	if currentEU/maxEU <= 0.1 then
		cmp.modem.broadcast(20, "level voltage buffer is low")
	end
	
	print(currentEU/maxEU)
	print(size, maxSize)
	os.sleep(10)
end
