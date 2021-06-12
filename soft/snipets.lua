--This file is parts of different codes for different tasks
local cmp = require("component")

--get information from gt_batterybuffer
local current, total = 0, 0
local bb = cmp.proxy(--[[bbaddr]])
local current = current + string.gsub(bb.getSensorInformation()[3], "([^0-9]+)", "")
local total = total + string.gsub(bb.getSensorInformation()[4], "([^0-9]+)", "")

--get information from multiple gt_batterybuffer
--init
local current, total = 0, 0
--main
current, total = 0, 0
for bbaddr in pairs(cmp.list("gt_batterybuffer")) do
	local bb = cmp.proxy(bbaddr)
	current = current + string.gsub(bb.getSensorInformation()[3], "([^0-9]+)", "")
	total = total + string.gsub(bb.getSensorInformation()[4], "([^0-9]+)", "")
end

--get a percentage of the computer's remaining energy
local persent = computer.energy() / computer.maxEnergy() * 100