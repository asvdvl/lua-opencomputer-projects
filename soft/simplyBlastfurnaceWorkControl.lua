local turninigOnWithOrMore = 90
local cmp = require("component")
local current = 0
local total = 0

while true do
	current = 0
	total = 0
	for bbaddr in pairs(cmp.list("gt_batterybuffer")) do
		local bb = cmp.proxy(bbaddr)
		current = current + string.gsub(bb.getSensorInformation()[3], "([^0-9]+)", "")
		total = total + string.gsub(bb.getSensorInformation()[4], "([^0-9]+)", "")
	end

	cmp.gt_machine.setWorkAllowed(current/total*100 >=turninigOnWithOrMore)
	print(current.."/"..total.."("..(current/total*100).."%)")
	print("setState: "..tostring(current/total*100 >=turninigOnWithOrMore))
	os.sleep(1)
end
