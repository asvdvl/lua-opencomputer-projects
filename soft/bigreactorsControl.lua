local cmp = require("component")
local reactor = cmp.br_reactor
local RS = cmp.redstone
local messageOnTurnOn = "реактор включен"
local messageOnTurnOff = "реактор выключен"
local percentCharge
local rodLevel
local valueMinimum = 20
local valueMaximum = 80
local retentionMode = false

local function turnOn()
  reactor.setActive(true)
  reactor.setAllControlRodLevels(0)
  print(messageOnTurnOn)
  retentionMode = false
end

local function turnOff()
  reactor.setActive(false)
  reactor.setAllControlRodLevels(0)
  print(messageOnTurnOff)
  retentionMode = false
end


print("start")
while true do
  --if draconic energy storage
  --percentCharge = ((cmp.draconic_rf_storage.getEnergyStored()/cmp.draconic_rf_storage.getMaxEnergyStored())*100)
  --if ender io energy storage
  --percentCharge = ((cmp.capacitor_bank.getEnergyStored()/cmp.capacitor_bank.getMaxEnergyStored())*100)
  --if internal buffer
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
    rodLevel = (((percentCharge - (valueMinimum))/((valueMaximum) - (valueMinimum)))*100)
    RS.setOutput(3, (1-rodLevel/100)*16)
    reactor.setAllControlRodLevels(rodLevel)
    if retentionMode ~= true then
      retentionMode = true
      print("режим стабилизации")
    end
  end
  os.sleep(0.1)
end
