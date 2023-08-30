local cmp = require("component")
local term = require("term")
local exitF
local eventNumb = 0
local chars = {"-", "\\", "|", "/"}
local currentChar = 0 --range 1-4
local keyb = require("keyboard")

--user settings
local list = {
	--name - visible name
	--redstone - address of redstone interface (OPTIONAL! if not, it will find primary and use it, but i recommend specifying it because "OC" can change it if you add 1 more interface)
	--key - real keyboard key (OPTIONAL! do not set in range 1-9, 0!(i'm just too lazy for check already bind keys), or set all on your own)
	--side - side of redstone interface, 0 - Down, 1 - Up, 2 - North, 3 - South, 4 - West, 5 - East
	--state - start redstone state (OPTIONAL! by default in false)
	
	--[[here is a line with all possible parameters
	{name = "SMTH ctrl", redstone = "123", key = "z", side = 0, state = true},
	]]
	{name = "Spw_N", side = 2},
	{name = "Spw_S", side = 3},
	{name = "Spw_W", side = 4},
	{name = "Spw_E", side = 5},
	{name = "light", redstone = "053", key = "l", side = 1, state = true},
}
--end user settings

assert(cmp.isAvailable("redstone"), "no redstone found")

local iList = keyb.keys["1"]
for _, lst in pairs(list) do
	if not lst.redstone then
		lst.redstone = cmp.redstone.address
	end
	if not lst.key then
		lst.key = keyb.keys[iList]	--such a double conversion will allow you to include the number "0" in the list without performing additional checks at the generation stage
		iList = iList + 1
		if iList > keyb.keys["0"] then	--I assume that in the future the order of the keys (1-9, 0) will not change.
			return
		end
	end
	if not lst.state then	--allows not to write "state = false" in the list
		lst.state = false
	end

	--I assume that name and side are always specified, this code serves as protection from the user
	if not lst.name then
		lst.name = "name not specifying!"
	end
	if not lst.side then
		lst.side = 0
		lst.name = lst.name + " / side not shown! taken by default for the bottom side"
	end
end
iList = nil

local function redstoneControl(objectRow, newState)
	local newLevel = 0
	if newState then
		newLevel = 15
	end
	objectRow.state = newState
	objectRow.redstone.setOutput(objectRow.side, newLevel)
end

local function justAStrangeActivityIndicator()
	currentChar = currentChar + 1
	if currentChar >= #chars+1 then
		currentChar = 1
	end
	return chars[currentChar]
end

local function printMenu()
	term.clear()
	for _, value in pairs(list) do
		io.stdout:write("[key:"..value.key.."] "..value.name..". state "..value.redstone.getOutput(value.side).."\n")
	end
	io.stdout:write("[key:q] quit programm\n")
	io.stdout:write(justAStrangeActivityIndicator())
end

local function init()
	for key, value in pairs(list) do
		list[key].redstone = cmp.proxy(cmp.get(value.redstone))
		redstoneControl(value, value.state)
	end
	for addr in pairs(cmp.list("openlight")) do
		cmp.proxy(addr).setColor(0xFFFFFF)
	end
end

local function eventHandler(...)
	local event = {...}
	if keyb.keys[event[4]] == "q" then --special for exit(may be used for other tasks)
		exitF = true
		require("event").cancel(eventNumb)
		printMenu()
		return
	end
	
	for _, obj in pairs(list) do
		if obj.key == keyb.keys[event[4]] then
			redstoneControl(obj, not obj.state)
			printMenu()
			return
		end
	end
end

init()
printMenu()
eventNumb = require("event").listen("key_down", eventHandler)

while not exitF do
	os.sleep(0.2)
end