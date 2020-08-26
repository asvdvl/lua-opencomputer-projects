rm mine.lua
edit mine.lua
local r = require("robot")
local cmp = require("component")
local comp = require("computer")

local isGoToCharge = false
--user settings
local delay = 0
local location = {x = 0, y = 0, z = 0, side = 0}
--0 - north 1 - east 2 - south 3 - west
local mineSize = {x = 20, y = 20, z = 50}
--end user settings
local initVal = {x = location.x, y = location.y, z = location.z};

function changeSide(offset)
	if offset + location.side >= 4 then
		location.side = offset + location.side - 4
	elseif offset + location.side < 0 then
		location.side = offset + location.side + 4
	else
		location.side = offset + location.side
	end
end

function right()
	r.turnRight();
	changeSide(1);
end

function left()
	r.turnLeft();
	changeSide(-1);
end

function down()
	if r.detectDown() then
		r.swingDown()
	end
	
	r.down();
	location.z = location.z + 1;
end

function up()
	if r.detectUp() then
		r.swingUp()
	end
	r.up();
	location.z = location.z - 1;
end

function forward()
	if true then
		goToCharge()
	end
	--comp.energy()/comp.maxEnergy()*100 < 30
	mine()
	
	if location.side == 0 then
		location.x = location.x + 1
	elseif location.side == 1 then
		location.y = location.y + 1
	elseif location.side == 2 then
		location.x = location.x - 1
	elseif location.side == 3 then
		location.y = location.y - 1
	end
	while not r.forward() do 
		if r.detect(3) then
			r.swing(3)
		end
	end
end

function goToCharge()
	if isGoToCharge then
		return
	end
	isGoToCharge = true
	local locateBefore = {x = location.x, y = location.y, z = location.z}; 
	print(1)
	printInfo()
	up()
	while not (location.side == 2) do
		right()
	end
	print()
	while not (location.x == initVal.x) do
		forward()
		printInfo()
	end
	
	print(2)
	while not (location.side == 3) do
		right()
	end
	while not (location.y == initVal.y) do
		forward()
		printInfo()
	end
	print(3)
	while not (location.side == 0) do
		right()
	end
	while not (location.z == initVal.z) do
		up()
		printInfo()
	end
	print(4)
	while not (comp.energy()/comp.maxEnergy()*100 > 90) do 
		os.sleep(10)
		os.exit()
	end
	--isGoToCharge = false
end

function mine()
	if r.detectUp() then
		r.swingUp()
	end
	if r.detect(3) then
		r.swing(3)
	end
end

function printInfo()
	--require("term").clear()
	print("x: "..location.x);
	print("y: "..location.y);
	print("z: "..location.z);
	print("side: "..location.side);
end

function getTurnRight()
	if location.z%2 == 0 then
		if location.side == 0 then
			return true
		else 
			return false
		end
	else
		if location.side == 0 then
			return false
		else 
			return true
		end
	end
end


--main cycle
print("mineSize: x "..mineSize.x.." y "..mineSize.y.." z "..mineSize.z);
for z = initVal.z, mineSize.z do
	for y = initVal.y, mineSize.y do
		for x = initVal.x, mineSize.x do
			printInfo();
			os.sleep(delay);
			forward();
		end
		if getTurnRight() then
			right();
			forward();
			right();		
		else
			left();
			forward();
			left();
		end 
		printInfo();
		os.sleep(delay);
	end
	down();
	printInfo();
	os.sleep(delay);
end
printInfo();
