local cmp = require("component")
local level = 60

----Optional
--cmp.gpu.setResolution(11, 5)

while true do
    local workAllowed = cmp.transposer.getFluidInTank(1)[1].amount / cmp.transposer.getFluidInTank(1)[1].capacity * 100 < level
    cmp.gt_machine.setWorkAllowed(workAllowed)
    print("set: "..tostring(workAllowed))
    os.sleep(5)
    if not workAllowed then
        os.sleep(120)
    end
end