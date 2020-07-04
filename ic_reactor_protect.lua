--user settings
local sideOut = 0
local sideIn = 1
local alarm = false
local sideAlarm = 2
local connectType = 0
--0 - connect to reactor chamber
--1 - connect to core
--2 - connect by id
local reactorId = "0" --fill this if connectType = 2 (you can fill unique start of address e.g. "6afd")
local reactorRedstone = "000" --you can fill unique start of address e.g. "6afd"
local inputRedstone = "111" --you can fill unique start of address e.g. "6afd"
--energy stogares
local useEnergyStorage = false
local energyStorageType = 0
--0 - use gregtech energy buffer
--1 - use ic2 energy storage
local updatePer = 3 -- 0 = never
--end user settings

local cmp = require("component")
local rs = cmp.proxy(cmp.get(reactorRedstone))
local rs1 = cmp.proxy(cmp.get(inputRedstone))
local counter = 0
local objects = {}
local delay = 0.1
local programmState = 0
local programmStateString = {
"enable",
"full batbuffer",
"incomplete structure",
"overheat reactor",
"no redstone input"
}
--0 - enable
--1 - full batbuffer
--2 - incomplete structure
--3 - overheat reactor
--4 - no redstone input

function printInfo(data)
	require("term").clear()
	print("Reactor heat: "..tostring(data.heat/data.maxHeat*100).."%")
	print("Reactor output: "..math.floor(data.reactorEUOutput).." EU")
	local reactorStateString = "";
	if data.reactorState then
		reactorStateString = "Enable"
	else
		reactorStateString = "Disable"
	end
	print("Reactor state: "..reactorStateString)
	print("Programm state: "..tostring(programmState))
end

function getInfo()
	local data = {
	heat = 0,
	maxHeat = 0,
	reactorEUOutput = 0,
	reactorState = false,
	batBuf = 0,
	batBufMax = 0
	}	

	if objects.reactor == nil then
		if connectType == 0 then
			--0 - connect to reactor chamber
			objects.reactor = cmp.reactor_chamber
		elseif connectType == 1 then
			--1 - connect to core
			objects.reactor = cmp.reactor
		elseif connectType == 2 then
			--2 - connect by id
			objects.reactor = cmp.proxy(cmp.get(reactorId))
		else
			print("error connectType")
			os.sleep(5);
			os.exit();
		end
	end

	if useEnergyStorage == true and objects.batterybuffer == nil then
		if energyStorageType == 0 then
			--0 - use gregtech energy buffer
			objects.batterybuffer = cmp.proxy(cmp.list("batterybuffer")())
			objects.getBatBuf = objects.batterybuffer.getStoredEU
			objects.getBatBufMax = objects.batterybuffer.getEUCapacity
		elseif energyStorageType == 1 then
			--1 - use ic2 energy storage
			function null()
				return 0
			end
			objects.getBatBuf = null
			objects.getBatBufMax = null
		else
			print("error useEnergyStorage")
			os.sleep(5);
			os.exit();
		end
	end
	
	data.heat = objects.reactor.getHeat()
	data.maxHeat = objects.reactor.getMaxHeat()
	data.reactorEUOutput = objects.reactor.getReactorEUOutput()
	data.reactorState = objects.reactor.producesEnergy()
	data.batBuf = objects.getBatBuf()
	data.batBufMax = objects.getBatBufMax()	
	return data
end

cmp.gpu.setResolution(24, 6)
while true do
	local succes, data = pcall(getInfo)
	if not succes then
		programmState = 2
		print("Error", data)
		rs.setOutput(sideOut, 0)
		if alarm then
			rs1.setOutput(sideAlarm, 15)
		end
		os.exit();
	end

	if rs1.getInput(sideIn) == 0 then
		--no redstone
		programmState = 4
	elseif (data.heat/data.maxHeat*100 >= 80.0) then
		--overheat
		programmState = 3
		if alarm then
			rs1.setOutput(sideAlarm, 15)
		end
	elseif useEnergyStorage == true and data.batBuf/data.batBufMax*100 >=90 then
		--full batbuffer
		programmState = 1
	else
		programmState = 0
	end
	
	if programmState == 0 then
		rs.setOutput(sideOut, rs1.getInput(sideIn))
	else
		rs.setOutput(sideOut, 0)
	end
	
	if counter == updatePer then
		printInfo(data)
		counter = 0
	end
	counter = counter + 1
	os.sleep(delay)
end
