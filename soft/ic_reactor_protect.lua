local defaultSettings = {
	sideOut = 0,
	sideIn = 1,
	alarm = false,
	sideAlarm = 2,
	connectToReactorType = 0,
	--0 - connect to reactor chamber
	--1 - connect to core
	--2 - connect by id
	reactorId = "0", --fill this if connectToReactorType = 2 (you can fill unique start of address e.g. "6afd")
	reactorRedstone = "111", --you can fill unique start of address e.g. "6afd"
	inputRedstone = "222", --you can fill unique start of address e.g. "6afd"
	--energy stogares
	useEnergyStorage = false,
	energyStorageType = 0,
	--0 - use gregtech energy buffer
	--1 - use ic2 energy storage
	--2 - use gregtech energy buffer with asielib(nuclear output)
	connectToEnergyStorageType = 0, 
	--0 - connect by component name
	--1 - connect by address
	energyStorageAddress = "0", --fill this if connectToEnergyStorageType = 1 (you can fill unique start of address e.g. "6afd")
	updatePer = 3, -- 0 = never
}

local settLib = require("settings")
local settings = {}

--load settings
require("term").clear()
io.stdout:write("loading settings\n")
local status
status, settings = settLib.getSettings("reactor", defaultSettings)
if status then
	io.stdout:write("loading complete\n")
else
	io.stderr:write("error loading settings: "..settings.."\n")
	settings = defaultSettings
	os.sleep(3)
end

local cmp = require("component")
local term = require("term")
local rs = cmp.proxy(cmp.get(settings.reactorRedstone))
local rs1 = cmp.proxy(cmp.get(settings.inputRedstone))
local counter = 0
local objects = {}
local delay = 0.1
local programState = 0
local programStateString = {
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

local function printInfo(data)
	term.clear()
	print("Reactor heat: "..tostring(data.heat/data.maxHeat*100).."%")
	print("Reactor output: "..math.floor(data.reactorEUOutput).." EU")
	local reactorStateString = "";
	if data.reactorState then
		reactorStateString = "Enable"
	else
		reactorStateString = "Disable"
	end
	print("Reactor state: "..reactorStateString)
	print("Program state: "..tostring(programState))
	if settings.useEnergyStorage then
		print("Energy storage: "..tostring(math.floor(data.batBuf/data.batBufMax*100)).."%")
	end
end

local function getInfo()
	local data = {
	heat = 0,
	maxHeat = 0,
	reactorEUOutput = 0,
	reactorState = false,
	batBuf = 0,
	batBufMax = 0
	}	

	if objects.reactor == nil then
		if settings.connectToReactorType == 0 then
			--0 - connect to reactor chamber
			objects.reactor = cmp.reactor_chamber
		elseif settings.connectToReactorType == 1 then
			--1 - connect to core
			objects.reactor = cmp.reactor
		elseif settings.connectToReactorType == 2 then
			--2 - connect by id
			objects.reactor = cmp.proxy(cmp.get(settings.reactorId))
		else
			io.stderr:write("error connectToReactorType")
			os.sleep(5);
			os.exit();
		end
	end

	if settings.useEnergyStorage and not objects.batterybuffer then
		local function getStorage(byAddress, name, address)
			if byAddress == 1 then
				return cmp.proxy(cmp.get(address))
			else
				return cmp.proxy(cmp.list(name)())
			end
		end
		
		if settings.energyStorageType == 0 then
			--0 - use gregtech energy buffer
			objects.batterybuffer = getStorage(settings.connectToEnergyStorageType, "batterybuffer", settings.energyStorageAddress)
			objects.getBatBuf = objects.batterybuffer.getStoredEU
			objects.getBatBufMax = objects.batterybuffer.getEUCapacity
			
		elseif settings.energyStorageType == 1 then
			--1 - use ic2 energy storage
			local function zeroReturnFunction()
				return 0
			end
			objects.getBatBuf = zeroReturnFunction
			objects.getBatBufMax = zeroReturnFunction
			
		elseif settings.energyStorageType == 2 then
			--2 - use gregtech energy buffer with asielib(nuclear output)
			objects.batterybuffer = getStorage(settings.connectToEnergyStorageType, "batterybuffer", settings.energyStorageAddress)
			local function getStoredEU()
				return string.gsub(objects.batterybuffer.getSensorInformation()[3], "([^0-9]+)", "")
			end
			local function getEUCapacity()
				return string.gsub(objects.batterybuffer.getSensorInformation()[4], "([^0-9]+)", "")
			end
			objects.getBatBuf = getStoredEU
			objects.getBatBufMax = getEUCapacity
			
		else
			io.stderr:write("error useEnergyStorage")
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

term.clear()
--load settings
print("loading settings")
local status
status, settings = settLib.getSettings("reactor", defaultSettings)
if status then
	io.stdout:write("loading complete\n")
else
	io.stderr:write("error loading settings: "..settings.."\n")
	settings = defaultSettings
	os.sleep(3)
end

cmp.gpu.setResolution(24, 6)
while true do
	local succes, data = pcall(getInfo)
	if not succes then
		programState = 2
		io.stderr:write("Error", data)
		rs.setOutput(settings.sideOut, 0)
		if settings.alarm then
			rs1.setOutput(settings.sideAlarm, 15)
		end
		os.exit();
	end

	if rs1.getInput(settings.sideIn) == 0 then
		--no redstone
		programState = 4
	elseif (data.heat/data.maxHeat*100 >= 80.0) then
		--overheat
		programState = 3
		if settings.alarm then
			rs1.setOutput(settings.sideAlarm, 15)
		end
	elseif settings.useEnergyStorage == true and data.batBuf/data.batBufMax*100 >=90 then
		--full batbuffer
		programState = 1
	else
		programState = 0
	end
	
	if programState == 0 then
		rs.setOutput(settings.sideOut, rs1.getInput(settings.sideIn))
	else
		rs.setOutput(settings.sideOut, 0)
	end
	
	if counter == settings.updatePer then
		printInfo(data)
		counter = 0
	end
	counter = counter + 1
	os.sleep(delay)
end