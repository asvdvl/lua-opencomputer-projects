local event = require("event")
local cmp = require("component")
local srl = require("serialization")
local messagesListen = 0
local interruptListen = 0
local exitF = false
local crops = {
    C5 = "0f45",
    M4 = "f42b",
    C4 = "2b6c",
    M3 = "367a",
    C3 = "0ddc",
    M2 = "04bd",
    C2 = "0c0d",
    M1 = "d02f",
    C1 = "76c8"
}
cmp.modem.open(234)

local function stopAll()
    print("shutdown")
    event.cancel(messagesListen)
    event.cancel(interruptListen)
    exitF = true
end

local function getCrop(cropName)
    local cropStats = {
        exist = false,
        name = "",
        gain = 0,
        grow = 0,
        resistance = 0,
        size = 0,
        maxSize = 0
    }
    local addr, why = cmp.get(crops[cropName])
    if not addr then
        print("warning: "..why.." by addr: "..crops[cropName])
        return cropStats
    end
    local crop = cmp.proxy(addr)
    cropStats.exist = true
    cropStats.name = crop.getID()
    cropStats.gain = crop.getGain()
    cropStats.grow = crop.getGrowth()
    cropStats.resistance = crop.getResistance()
    cropStats.size = crop.getSize()
    cropStats.maxSize = 4 --openperipheral donthave api for this
    return cropStats
end

local function scanCrop(...)
    local var = {...}
    print(var[6])
    if not var[6] then
        return
    end

    local tosend = getCrop(var[6])
    print(srl.serialize(tosend))
    cmp.modem.broadcast(234, "cropServer", srl.serialize(tosend))
end

messagesListen = event.listen("modem_message", scanCrop)
interruptListen = event.listen("interrupted", stopAll)

while not exitF do
    event.pull(5)
end