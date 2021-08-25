local event = require("event")
local computer = require("computer")
local mode = 0
--0 - black list
--1 - white list
local protectMode = "soft"
-- "soft" - block events from ban player
-- "hard" - just shutdown computer
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
	drop = 6,
	clipboard = 4
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

if protectMode == "hard" then
	for eventName in pairs(onEvents) do
		event.listen(eventName, check)
	end
elseif protectMode == "soft" then
	local originalPullSignal = computer.pullSignal
	function computer.pullSignal(...)
		local args = {originalPullSignal(...)}
		local foundUser = false
		local foundPointer = onEvents[args[1]]
		if not foundPointer then
			return table.unpack(args)
		end

		for _, name in pairs(users) do
			if name == args[foundPointer] then
				foundUser = true
				if mode == 0 then
					return nil
				end
			end
		end

		if not foundUser and mode == 1 then
			return nil
		end
		return table.unpack(args)
	end
end

