local cmp = require("component")
local term = require("term")
local exitF
local eventNumb = 0
local light = {state = false}
local keycodes = { --4 parameter of key_down and key_up events
	{2, "1"}, 	--{keycode, "real key"}
	{3, "2"},
	{4, "3"},
	{5, "4"},
	{6, "5"},
	{7, "6"},
	{8, "7"},
	{9, "8"},
	{10, "9"},
	{11, "0"},
	{38, "l"},
	{16, "q"}
}

--user settings
local objects = {
	--name - visible name
	--redstone - address of redstone interface
	--key - real keyboard key(see keycodes table)
	--side - side of redstone interface
	--state - start redstone state
    {name = "ifrits", redstone = "d31", key = "1", side = 5, state = false},
    {name = "endermans", redstone = "d31", key = "2", side = 4, state = false},
	{name = "wither skelets", redstone = "d31", key = "3", side = 3, state = false},
	{name = "funs", redstone = "d31", key = "4", side = 0, state = true}

}
--end user settings

local function turnLight()
	local brightness = 0
	if light.state then
		brightness = 0
	else
		brightness = 15
	end
	light.state = not light.state
	for addr in pairs(cmp.list("openlight")) do
			cmp.proxy(addr).setBrightness(brightness)
	end
end

local function redstoneControl(objectRow, newState)
	local newLevel = 0
	if newState then
		newLevel = 15
	end
	objectRow.redstone.setOutput(objectRow.side, newLevel)
end

local function printMenu()
	term.clear()
	for key, value in pairs(objects) do
		io.stdout:write("[key:"..value.key.."] "..value.name..". state "..value.redstone.getOutput(value.side).."\n")
	end
	--light row
	io.stdout:write("[key:l] ligth. state: "..tostring(light.state).."\n")
	io.stdout:write("[key:q] quit programm\n")
end

local function init()
	for key, value in pairs(objects) do
		objects[key].redstone = cmp.proxy(cmp.get(value.redstone))
		redstoneControl(value, value.state)
	end
	for addr in pairs(cmp.list("openlight")) do
		cmp.proxy(addr).setColor(0xFFFFFF)
	end
end

local function eventHandler(...)
	local event = {...}
	for key, value in pairs(keycodes) do
		if event[4] == value[1] then
			--special for exit and light
			if value[2] == "q" then
				exitF = true
				require("event").cancel(eventNumb)
				return
			elseif value[2] == "l" then
				turnLight()
				printMenu()
				return
			end
			--search in objects table
			for key, value in pairs(objects) do
				if value.key == value[2] then

					printMenu()
					return
				end
			end
		end
	end
end

init()
printMenu()
eventNumb = require("event").listen("key_down", eventHandler)

while not exitF do
	os.sleep(1)
end