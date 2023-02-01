local time = require("asv").time
local cmp = require("component")
local event = require("event")
local gpu = cmp.gpu

local screenW = 9
local screenH = 2
local calculateTicks = 20    --5 ticks - closest to real value and low latency. 20 ticks - 1 second
local colorOutput = true
local fullsreen = true
local interruptListen
local exitF

local function getTicks()
    return os.time()/3.6
end

if fullsreen then
    require("term").clear()
    gpu.setResolution(screenW, screenH)
end

local function stopAll()
    print("bye!")
    event.cancel(interruptListen)
    exitF = true

    if fullsreen then
        gpu.setResolution(gpu.maxResolution())
    end
end

interruptListen = event.listen("interrupted", stopAll)

while not exitF do
    local realTime = time.getRaw()
    local gameTime = getTicks()

    --sleep on in-game ticks
    while (getTicks() - gameTime) < calculateTicks do
        os.sleep(0)
    end
    local tps = math.ceil(10000/((time.getRaw() - realTime)/(getTicks() - gameTime)))/10

    --set collor
    if colorOutput then
        if tps <= 12 then
            gpu.setForeground(0xFF0000)
        elseif tps <= 15 then
            gpu.setForeground(0xFFFF55)
        else
            gpu.setForeground(0x55FF55)
        end
    end

    print("tps: "..tps)
end