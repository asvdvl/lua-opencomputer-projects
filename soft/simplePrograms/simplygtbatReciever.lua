local time = require("asv").time
local cmp = require("component")
local event = require("event")
local gpu = cmp.gpu

local screenW = 15
local screenH = 7
local calculateTicks = 20    --5 ticks - closest to real value and low latency. 20 ticks - 1 second
local colorOutput = true
local fullsreen = true
local interruptListen
local exitF

---

local chat = cmp.chat
local prewPerc = 0
local currPerc = 0

cmp.chat.setName("dial-up notice")
cmp.chat.setDistance(3)

---

local asv = require("asv")
local link = asv.net.Layers.Link
local utils = asv.utils
local time = asv.time
local protoName = "gt_batteryAdv"
local lastTake = 0

local packetStruc = {
        type = "none",
        stored = {
            current = 0,
            max = 1,
            percent = 0
        },
        flow = {
            input = 0,
            output = 0
        }
    }

local row1 = ""
local row2 = ""

--register proto
local i = 0
link.protocols[protoName] = {
    onMessageReceived = function(dstAddr, frame, srcAddr)
        local data, bagRequest = utils.correctTableStructure(frame.data, packetStruc)

        if bagRequest then
            return
        end

        if data.type == "response" then     --do something with this data
            i = i - 1
            currPerc = data.stored.percent
            row1 = "buff: "..tostring(currPerc).."%"
            row2 = "flow:\nin "..tostring(data.flow.input).."\nout "..tostring(data.flow.output)
            lastTake = time.getRaw()

            if i < 0 then
                chat.say("§r§2"..row1.."§f(§3"
                  ..tostring(currPerc - prewPerc).."§f)§c "
                  ..tostring(data.flow.input).."§f/§a"
                  ..tostring(data.flow.output).." §f(§3"
                  ..tostring(data.flow.input-data.flow.output).."§f)")
                i = 6
                prewPerc = currPerc
            end
        end
    end
}

---

local function getTicks()
    return os.time()/3.6
end

if fullsreen then
    require("term").clear()
    gpu.setResolution(screenW, screenH)
end

local function stopAll()
    print("closing")
    event.cancel(interruptListen)
    exitF = true

    if fullsreen then
        gpu.setResolution(gpu.maxResolution())
    end
end

interruptListen = event.listen("interrupted", stopAll)
local ti = false

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
    gpu.setForeground(0xFFFFFF)
    print(row1)
    print(row2)
    print("upd: "..tostring(math.ceil((time.getRaw()-lastTake)/1000)).." ago")
end

print("bye!")
link.protocols[protoName] = nil