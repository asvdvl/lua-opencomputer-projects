local com = require("component")

while true do
	local current = string.gsub(com.gt_batterybuffer.getSensorInformation()[3], "([^0-9]+)", "")
	local total = string.gsub(com.gt_batterybuffer.getSensorInformation()[4], "([^0-9]+)", "")

	com.gt_machine.setWorkAllowed(current/total*100 >=50)
	print(current.."/"..total.."("..(current/total*100).."%)")
	print("setState: "..tostring(current/total*100 >=50))
	os.sleep(1)
end
