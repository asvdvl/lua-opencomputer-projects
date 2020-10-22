local cmp = require("component")
local event = require("event")

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

event.listen("modem_message", receive)
if chatAvailable then
	cmp.chat.setName("system alert")
	cmp.chat.say("Init complete")
end
