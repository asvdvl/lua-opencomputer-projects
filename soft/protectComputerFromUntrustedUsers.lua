local event = require("event")
local mode = 0
--0 - black list
--1 - white list
local users = {
	"notch",
	"Herobrine"
}

--{"event", the index of the username in the table row}
local onEvents = {
	key_down = 5,
	key_up = 5,
	motion = 6,
	touch = 6,
	drop = 6
}

local function check(...)
	local args = {...}
	local foundUser = false

	local foundPointer = onEvents[args[1]]
	if not foundPointer then
		return
	end

	for _, name in pairs(users) do
		if name == args[foundPointer] then
			foundUser = true
			break
		end
	end

	if (foundUser and mode == 0) or (not foundUser and mode == 1) then
		require("computer").shutdown()
	end
end

for eventName in pairs(onEvents) do
	event.listen(eventName, check)
end
