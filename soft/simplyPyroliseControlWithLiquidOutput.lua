local cmp = require("component")

while true do
    if cmp.tank_controller.getFluidInTank(3)[1].amount/cmp.tank_controller.getFluidInTank(3)[1].capacity*100 < 50 then
        cmp.redstone.setOutput(1, 15)
    else
        cmp.redstone.setOutput(1, 0)
    end
    os.sleep(5)
end