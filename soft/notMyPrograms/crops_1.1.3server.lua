local event = require("event")
local cmp = require("component")
local srl = require("serialization")
local messagesListen = 0
local interruptListen = 0
local exitF = false
local crops = {
    {x = 0, z = -1, addr = "0f45"},
    {x = 0, z = -2, addr = "f42b"},
    {x = 0, z = -3, addr = "2b6c"},
    {x = 1, z = -1, addr = "367a"},
    {x = 1, z = -2, addr = "0ddc"},
    {x = 1, z = -3, addr = "04bd"},
    {x = 2, z = -1, addr = "0c0d"},
    {x = 2, z = -2, addr = "d02f"},
    {x = 2, z = -3, addr = "76c8"}
}
cmp.modem.open(234)

local function stopAll()
    print("shutdown")
    event.cancel(messagesListen)
    event.cancel(interruptListen)
    exitF = true
end

local function getCrop(x, z)
    for _, v in pairs(crops) do
        if v.x == x and v.z == z then
            local cropStats = {
                exist = false,
                name = "",
                gain = 0,
                grow = 0,
                resistance = 0,
                size = 0,
                maxSize = 0
            }
            local addr, why = cmp.get(v.addr)
            if not addr then
                print("warning: "..why.." by addr: "..v.addr.." x: "..v.x.." z: "..v.z)
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
    end
end

local function scanCrop(...)
    local var = {...}
    print(var[6])
    local result, reason = srl.unserialize(var[6])
    if not result then
        return
    end

    local tosend = getCrop(result.x, result.z)
    cmp.modem.broadcast(234, srl.serialize(tosend))
end



messagesListen = event.listen("modem_message", scanCrop)
interruptListen = event.listen("interrupted", stopAll)

while not exitF do
    event.pull(5)
end