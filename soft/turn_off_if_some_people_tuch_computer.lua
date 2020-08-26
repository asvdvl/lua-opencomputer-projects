local event = require("event")
local blockUsers = {
"y.varenkov",
"darkwolfqww",

}
--{"event", user name string number in array}
local onEvents = {
{"key_down", 5},
{"key_up", 5},
{"motion", 6},
{"touch", 6},
{"drop", 6},

}

function check(...) 
	local param = {...} 
	local pointer = 0
	
	for _, events in pairs(onEvents) do
		if param[1] == events[1] then
			pointer = events[2]
			break;
		end
	end
	
	for _, name in pairs(blockUsers) do
		if name == param[pointer] then
			require("computer").shutdown() 
		end
	end
end

for _, events in pairs(onEvents) do
	event.listen(events[1], check)
end
