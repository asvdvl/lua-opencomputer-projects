local modem = component.proxy(component.list("modem")())
local sign = component.proxy(component.list("sign")())
local redstone = component.proxy(component.list("redstone")())

modem.setWakeMessage("wakeup", true)
redstone.setWakeThreshold(1)

while true do
    modem.broadcast(65535, "wakeup", computer.uptime())
    sign.setValue("Uptime:\n"..tostring(computer.uptime()))
    computer.pullSignal(5)
end