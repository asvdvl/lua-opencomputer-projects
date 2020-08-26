local event = require("event")
local mode = 0
--0 - black list
--1 - white list
local users = {
"notch",
"Herobrine",
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
	local detect = false
	
	for _, events in pairs(onEvents) do
		if param[1] == events[1] then
			pointer = events[2]
			break;
		end
	end
	
	for _, name in pairs(users) do
		if name == param[pointer] then
			detect = true
		end
	end
	
	if (detect and mode == 0) or (not detect and mode == 1) then
		require("computer").shutdown()
	end
	 
end

for _, events in pairs(onEvents) do
	event.listen(events[1], check)
end
