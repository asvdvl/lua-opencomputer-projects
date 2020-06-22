--user settings
local sideOut = 0
local sideIn = 1
--end user settings

local cmp = require("component")
local reactor = cmp.reactor_chamber
local rs = cmp.proxy(cmp.get("60fa"))
local rs1 = cmp.proxy(cmp.get("89c"))
local counter = 0

function printInfo()
	require("term").clear()
	print("Reactor heat: "..tostring(reactor.getHeat()/reactor.getMaxHeat()*100).."%")
	print("Reactor output: "..reactor.getReactorEUOutput().." EU")
	print()
	print()
end

while true do
	if (reactor.getHeat()/reactor.getMaxHeat()*100 >= 80.0) then
		rs.setOutput(sideOut, 0)
	else
		if rs1.getInput(sideIn) > 0 then
			rs.setOutput(sideOut, rs1.getInput(sideIn))
		else
			rs.setOutput(sideOut, 0)
		end
	end
	if counter == 5 then
		printInfo()
		counter = 0
	end
	counter = counter + 1
	os.sleep(0.1)
end