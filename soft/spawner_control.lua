local cmp = require("component")
local AirRS = cmp.proxy(cmp.get("3ff"))
local SpawnerRS = cmp.proxy(cmp.get("4f2"))
local term = require("term")

local object = {
    ifrits  	= {side = 5, state = 0},
    enderman 	= {side = 4, state = 0},
	witherSkel 	= {side = 3, state = 0},
	light    	= {state = true},
	fun			= {side = 0, state = 0}

    }

function RScontrolSet(obj) 
	
	if obj.state then 
		obj.state = 0 
	else 
		obj.state = 1 
	end 
	
	SpawnerRS.setOutput(obj.side, obj.state)
end

function TurnLightControl()
	local obj = object.light
	local Brightness = 0
	if obj.state then
		obj.state = false
		Brightness = 0
	else
		obj.state = true
		Brightness = 15
	end
	for addr in pairs(cmp.list("openlight")) do
			cmp.proxy(addr).setBrightness(Brightness)
	end
end

local function printMenu()
	for name in pairs(object) do
		print(name.." состояние:"..name.state)
	end

end

local function inputProcessing()


end


while true do
	
	
	
	
end

term.clear()