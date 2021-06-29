local turninigOnWithOrMore = 90
local turninigOnWithOrLessBarrel = 90
local cmp = require("component")
local computer = require("computer")
local bb_current, bb_total = 0, 0
local bar_current, bar_total = 0, 0

----Optional
--cmp.gpu.setResolution(15, 5)

while true do
	bb_current, bb_total = 0, 0
	for bbaddr in pairs(cmp.list("gt_batterybuffer")) do
		local bb = cmp.proxy(bbaddr)
		bb_current = bb_current + string.gsub(bb.getSensorInformation()[3], "([^0-9]+)", "")
		bb_total = bb_total + string.gsub(bb.getSensorInformation()[4], "([^0-9]+)", "")
	end

	local bar = cmp.mcp_mobius_betterbarrel
	bar_current = bar.getStoredCount()
	bar_total = bar.getMaxStoredCount()

	local workAllowed =
		bb_current / bb_total * 100 >= turninigOnWithOrMore and
		computer.energy() / computer.maxEnergy() * 100 >= 10 and
		bar_current / bar_total * 100 <= turninigOnWithOrLessBarrel
	cmp.gt_machine.setWorkAllowed(workAllowed)

	print("bb: "..string.sub(bb_current/bb_total*100, 1, 5).."%")
	print("storage: "..string.sub(bar_current/bar_total*100, 1, 5).."%")
	print("comp: "..string.sub(computer.energy() / computer.maxEnergy() * 100, 1, 5).."%")
	print("allow: "..tostring(workAllowed))

	if computer.energy() / computer.maxEnergy() * 100 <= 30 then
		computer.beep(1000, 0.5)
		os.sleep(0.5)
	else
		os.sleep(1)
	end
end
