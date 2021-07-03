local modem = component.proxy(component.list("modem")())
local sign = component.proxy(component.list("sign")())

modem.setWakeMessage("wakeup", true)

while true do
    modem.broadcast(65535, "wakeup", computer.uptime())
    sign.setValue("Uptime:\n"..tostring(computer.uptime()))
    computer.pullSignal(5)
end