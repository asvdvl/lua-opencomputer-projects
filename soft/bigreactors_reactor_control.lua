local cmp = require("component")
local reactor = cmp.br_reactor
local RS = cmp.redstone
local itemOnTurnOn = "minecraft:redstone_torch"
local itemOnTurnOff = "minecraft:lever"
local messageOnTurnOn = "реактор включен"
local messageOnTurnOff = "реактор выключен"
local notifI = cmp.notification_interface
local percentCharge
local rodLevel
local valueMinimum = 20
local valueMaximum = 80
local retentionMode = false

local function turnOn()
  reactor.setActive(true)
  reactor.setAllControlRodLevels(0)
  notifI.notify(messageOnTurnOn, "", itemOnTurnOn, 0)
  retentionMode = false
end

local function turnOff()
  reactor.setActive(false)
  reactor.setAllControlRodLevels(0)
  notifI.notify(messageOnTurnOff, "", itemOnTurnOff, 0)
  retentionMode = false
end


while true do
  percentCharge = ((reactor.getEnergyStored()/reactor.getEnergyCapacity())*100)
  if percentCharge > valueMaximum and reactor.getActive() then
    turnOff()
  elseif percentCharge < valueMinimum and reactor.getActive() ~= true then
    turnOn()
  elseif percentCharge < (valueMaximum - 5) and percentCharge > (valueMinimum + 5) then
  --powen regulation
    if reactor.getActive() ~= true then
      turnOn()
    end
    rodLevel = (((percentCharge - (valueMinimum+5))/((valueMaximum-5) - (valueMinimum+5)))*100)
    RS.setOutput(3, 150/rodLevel)
    reactor.setAllControlRodLevels(rodLevel)
    if retentionMode ~= true then
      retentionMode = true
      notifI.notify("режим стабилизации", "", "minecraft:obsidian", 0)
    end
  end
  os.sleep(0.1)
end
