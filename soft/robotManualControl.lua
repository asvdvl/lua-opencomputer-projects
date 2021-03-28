local robot = require("robot")
local event = require("event")
local term = require ("term")
local exitF
local eventNumb = 0

local chars = {"-", "\\", "|", "/"}
local currentChar = 0 --range 1-4
local keycodes = { --4 parameter of key_down and key_up events
    {16, "q"},  --{keycode, "real key"}
	{17, "w"},
	{18, "e"},
	{30, "a"},
	{31, "s"},
	{32, "d"}
}

local function justAStrangeActivityIndicator()
	currentChar = currentChar + 1
	if currentChar >= #chars+1 then
		currentChar = 1
	end
	return chars[currentChar]
end

local function eventHandler(...)
	local evt = {...}
	for _, keyvalue in pairs(keycodes) do
        if evt[4] == keyvalue[1] then
            term.clear()
            print(keyvalue[2])
            print(justAStrangeActivityIndicator())
			if keyvalue[2] == "q" then --exit
                exitF = true
                event.cancel(eventNumb)
				return
            elseif keyvalue[2] == "w" then
                robot.forward()
                return
            elseif keyvalue[2] == "a" then
                robot.turnLeft()
                return
            elseif keyvalue[2] == "s" then
                robot.back()
                return
            elseif keyvalue[2] == "d" then
                robot.turnRight()
                return
            elseif keyvalue[2] == "e" then
                robot.use()
				return
            end
		end
	end
end

eventNumb = event.listen("key_down", eventHandler)

while not exitF do
	event.pull(10)
end