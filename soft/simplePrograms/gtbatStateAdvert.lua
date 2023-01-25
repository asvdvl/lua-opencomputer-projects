local cmp = require("component")
local bb = cmp.gt_batterybuffer
local net = require("asv").net
local link = net.Layers.Link
local event = require("event")
local protoName = "gt_batteryAdv"
local sendDataTimer, interruptListen, watchDog
local watchDogTestF = false
local bbInfo
local exitF

local packetStruc = {
    stored = {
        current = 0,
        max = 0
    },
    flow = {
        input = 0,
        output = 0
    }
}

local function sendData(srcAddr)
    for i = 1, 10 do
        bbInfo = bb.getSensorInformation()
    end

    if bbInfo[2] ~= "Stored Items:" or bbInfo[5] ~= "Average input:" or bbInfo[7] ~= "Average output:" then
        print("detect string that not exepted(API changes?)")
        os.exit()
    end

    packetStruc.stored.current = string.gsub(bbInfo[3], "([^0-9]+)", "")+0
    packetStruc.stored.max = string.gsub(bbInfo[4], "([^0-9]+)", "")+0
    packetStruc.flow.input = string.gsub(string.gsub(bbInfo[6], "([^0-9]+)", ""), "^(6)", "")+0
    packetStruc.flow.output = string.gsub(bbInfo[8], "([^0-9]+)", "")+0

    print("report:")
    print("buff: "..tostring(packetStruc.stored.current).."/"..tostring(packetStruc.stored.max))
    print("flow: in "..tostring(packetStruc.flow.input).."; out "..tostring(packetStruc.flow.output))

    if srcAddr then
        link.send(nil, srcAddr, protoName, packetStruc)
    else
        link.broadcast(nil, protoName, packetStruc)
    end
end

local function stopAll()
    print("shutdown")
    event.cancel(sendDataTimer)
    event.cancel(watchDog)
    event.cancel(interruptListen)
    link.protocols[protoName] = nil
    exitF = true
end

local function watchDogTest()
    if watchDogTestF then
        print("programm was stop incoreectly")
        stopAll()
    end
    watchDogTestF = true
end

--register proto
link.protocols[protoName] = {
    onMessageReceived = function(dstAddr, frame, srcAddr)
        if frame == "get" then
            sendData(srcAddr)
        end
    end
}

sendDataTimer = event.timer(10, sendData, math.maxinteger)
interruptListen = event.listen("interrupted", stopAll)
watchDog = event.timer(10, watchDogTest, math.maxinteger)

sendData()
while not exitF do
    event.pull(5)
    watchDogTestF = false
end