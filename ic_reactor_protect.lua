--user settings
local sideOut = 0
local sideIn = 0
local alarm = true
local sideAlarm = 0
--end user settings

local cmp = require("component")
local reactor = cmp.reactor_chamber
local rs = cmp.proxy(cmp.get("reactor"))
local rs1 = cmp.proxy(cmp.get("leverandalarm"))
local counter = 0

function printInfo()
	require("term").clear()
	print("Reactor heat: "..tostring(reactor.getHeat()/reactor.getMaxHeat()*100).."%")
	print("Reactor output: "..reactor.getReactorEUOutput().." EU")
end

while true do
	if (reactor.getHeat()/reactor.getMaxHeat()*100 >= 80.0) then
		rs.setOutput(sideOut, 0)
		if alarm then
			rs1.setOutput(sideAlarm, 15)
		end
	else
		if rs1.getInput(sideIn) > 0 then
			rs.setOutput(sideOut, rs1.getInput(sideIn))
		else
			rs.setOutput(sideOut, 0)
		end
		if alarm then
			rs1.setOutput(sideAlarm, 0)
		end
	end
	if counter == 3 then
		printInfo()
		counter = 0
	end
	counter = counter + 1
	os.sleep(0.1)
end
