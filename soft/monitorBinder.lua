local cmp = require("component")
--gpu, screen
local binds = {
{"b078", "6d14"},
{"f93", "5c6"},
}

for id, _ in cmp.list("gpu") do 
	for _, addr in pairs(binds) do 
		if not cmp.get(addr[1]) and not cmp.get(addr[2]) then
			local gpu = cmp.proxy(cmp.get(addr[1]))
			gpu.bind(cmp.get(addr[2]))
			gpu.setResolution(gpu.maxResolution())
		end
	end
end
require("term").clear()
