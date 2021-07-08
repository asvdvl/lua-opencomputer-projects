local robot = require("robot")
local event = require("event")
local term = require ("term")
local keyb = require("keyboard")
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

local function updateScreen(keyvalue)
    term.clear()
    print(keyvalue)
    print("wasd - move")
    print("e - use")
    print("q - exit")
    print("space/shift - up/down")
    print(justAStrangeActivityIndicator())
end

updateScreen("")

local function eventHandler(...)
	local _, _, _, k = ...
    updateScreen(keyb.keys[k])
	if k == keyb.keys["q"] then --exit
        exitF = true
        event.cancel(eventNumb)
		return
    elseif k == keyb.keys["w"] then
        robot.forward()
        return
    elseif k == keyb.keys["a"] then
        robot.turnLeft()
        return
    elseif k == keyb.keys["s"] then
        robot.back()
        return
    elseif k == keyb.keys["d"] then
        robot.turnRight()
        return
    elseif k == keyb.keys["e"] then
        robot.use()
		return
    elseif k == keyb.keys["space"] then
        robot.up()
		return
    elseif k == keyb.keys["lshift"] then
        robot.down()
		return
    end
end

eventNumb = event.listen("key_down", eventHandler)

while not exitF do
	event.pull(10)
end