local turninigOnWithOrMore = 90
local cmp = require("component")
local computer = require("computer")
local current, total = 0, 0

----Optional
--cmp.gpu.setResolution(15, 4)

while true do
	current, total = 0, 0
	for bbaddr in pairs(cmp.list("gt_batterybuffer")) do
		local bb = cmp.proxy(bbaddr)
		current = current + string.gsub(bb.getSensorInformation()[3], "([^0-9]+)", "")
		total = total + string.gsub(bb.getSensorInformation()[4], "([^0-9]+)", "")
	end

	local workAllowed = current/total*100 >= turninigOnWithOrMore and computer.energy() / computer.maxEnergy() * 100 >= 10
	cmp.gt_machine.setWorkAllowed(workAllowed)

	print("bb: "..string.sub(current/total*100, 1, 5).."%")
	print("comp: "..string.sub(computer.energy() / computer.maxEnergy() * 100, 1, 5).."%")
	print("allow: "..tostring(workAllowed))

	if computer.energy() / computer.maxEnergy() * 100 <= 30 then
		computer.beep(1000, 0.5)
		os.sleep(0.5)
	else
		os.sleep(1)
	end
end
