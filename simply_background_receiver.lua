local cmp = require("component")
local event = require("event")

cmp.modem.open(20)

function receive(...)
	local param = {...}
	print(os.date()..tostring(param[6]))
	require("computer").beep(1400, 0.2)
end

event.listen("modem_message", receive)
