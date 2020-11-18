local cmp = require("component")
local event = require("event")
local greetingsFromFile = false
local multilineGreetengs = true
local sayDistance = 3 --Max(default): 32

cmp.modem.open(20)

local chatAvailable = cmp.isAvailable("chat")

local function receive(...)
	local param = {...}
	print(os.date()..tostring(param[6]))
	if chatAvailable then
		cmp.chat.say(os.date().." "..tostring(param[6]))
	end
	require("computer").beep(1400, 0.2)
end

local function initComplete()
	cmp.chat.setName("System alert")
	cmp.chat.setDistance(sayDistance)
	if greetingsFromFile then
		local file = io.open("/usr/misc/receiverGreetings.txt")
		if file and multilineGreetengs then
			for val in file:lines() do
				cmp.chat.say("§r"..val)
			end
		end
	else
		cmp.chat.say("Init complete")
	end
end

event.listen("modem_message", receive)
if chatAvailable then
	initComplete()
end
