--this program is created with the aim of protecting de storage from discharging to zero
--this is useful if this storage is used by a reactor

local minLevel = 100000

local cmp = require("component")
local fluxGate = cmp.flux_gate
local storage = cmp.draconic_rf_storage
fluxGate.setSignalLowFlow(0)
fluxGate.setSignalHighFlow(0)
local difference = 0

while true do
    difference = storage.getEnergyStored() - minLevel
    if difference <= 0 then
        fluxGate.setSignalLowFlow(0)
    else
        print(difference)
        fluxGate.setSignalLowFlow(difference)
    end
    os.sleep(1)
end