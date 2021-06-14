--for eeprom
local modem = component.proxy(component.list("modem")())

while true do
    modem.broadcast(1, "wakeup", computer.uptime())
    computer.pullSignal(5)
end