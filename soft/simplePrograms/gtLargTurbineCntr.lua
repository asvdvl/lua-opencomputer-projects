local maxProblems = 1
local maxDamageLevel = 90
local bbOnLevel = 5
local bbOffLevel = 85
local advTimeout = 60

local cmp = require("component")
local event = require("event")
local term = require("term")
local keys = require("keyboard").keys
local asv = require("asv")
local utils = asv.utils
local time = asv.time
local link, protoName, bbAdvPacket, exitF, interruptListen, keyListen
local statuses = {}
local sensrInfoMapping = {outFlow = 4, damage = 14, problems = 16}
local initX, initY, lastAnswer, totalGen, connectionLostFixState, globalWorkAllowed = 1, 1, 0, 0, 0, false

local function initProto()
    link = asv.net.Layers.Link

    protoName = "gt_batteryAdv"

    bbAdvPacket = {
        type = "none",
        stored = {
            current = 1,
            max = 1,
            percent = 100   --if getting status failed, set buffer as fully charged
        },
        flow = {
            input = 0,
            output = 0
        }
    }

    --register proto
    link.protocols[protoName] = {
        onMessageReceived = function(dstAddr, frame, srcAddr)
            local data, bagRequest = utils.correctTableStructure(frame.data, bbAdvPacket)

            if bagRequest then
                return
            end

            if data.type == "response" then     --do something with this data
                bbAdvPacket = data
                lastAnswer = os.time()/3.6/20
            end
        end
    }
end
initProto()

local function log(...)
    print("["..time.getDateTime(3).."]", ...)
end

local function firstReqest(nolog)
    link.broadcast(nil, protoName, {type = "request"})
    for i = 1, 4 do
        os.sleep(1)
        if lastAnswer > 0 then
            if not nolog then log("succes!") end
            break
        elseif i == 4 then
            if not nolog then log("bb dont answer(network issue?)") end
            os.exit()
        end
        if not nolog then log("attempt: "..i) end
        link.broadcast(nil, protoName, {type = "request"})
    end
end
log("try to get bb status")
firstReqest()

local function shortName(name)
    return string.sub(name, 1, 4)
end

local function report()
    local function prClr(...)
        term.clearLine()
        print(...)
    end
    local x, y = term.getCursor()
    term.setCursor(initX, initY)
    prClr("work allowed: "..tostring(globalWorkAllowed))
    for machine, table in pairs(statuses) do
        prClr(machine, "problems: "..table.problems, "damage: "..table.damage, "gen: "..table.outFlow, "isWork: "..tostring(table.isWork))
    end
    prClr("buffPerc: "..bbAdvPacket.stored.percent, "lastAnswer(mtime, seconds): "..(math.ceil(((os.time()/3.6/20)-lastAnswer)*100)/100).."ago")
    prClr("gen(buff input): "..bbAdvPacket.flow.input,"this control gen: "..totalGen , (math.ceil((totalGen/bbAdvPacket.flow.input)*10000)/100).."% of total")
    prClr("on/off: i", "exit: q or ctrl+c", "exit witout stop: shift(hold until exit)+q")
    term.clearLine()
    term.setCursor(x, y)
end

local function switchMode(machine, tuntTo, probl, damage)
    if machine.isWorkAllowed() ~= tuntTo then
        machine.setWorkAllowed(tuntTo)
        log(shortName(machine.address), "turn to: "..tostring(tuntTo))
    end
end

local function processing()
    statuses = {}
    totalGen = 0
    if bbAdvPacket.stored.percent <= bbOnLevel then
        globalWorkAllowed = true
    elseif bbAdvPacket.stored.percent >= bbOffLevel then
        globalWorkAllowed = false
    end
    for turbine in cmp.list("gt_machine") do
        turbine = cmp.proxy(turbine)
        if turbine.getInventoryName() == "multimachine.largegasturbine" then
            local sensr = turbine.getSensorInformation()

            local probl = string.gsub(sensr[sensrInfoMapping.problems], "([^0-9]+)", "")+0
            local damage = string.gsub(sensr[sensrInfoMapping.damage], "([^0-9]+)", "")+0
            local outFlow = string.gsub(sensr[sensrInfoMapping.outFlow], "([^0-9]+)", "")+0

            if probl < maxProblems and damage < maxDamageLevel and globalWorkAllowed then
                switchMode(turbine, true, probl, damage)
            end

            if probl >= maxProblems or damage >= maxDamageLevel or not globalWorkAllowed then
                switchMode(turbine, false, probl, damage)
            end
            statuses[shortName(turbine.address)] = {problems = probl, damage = damage, isWork = turbine.isWorkAllowed(), outFlow = outFlow}
            totalGen = totalGen + outFlow
        end
    end
end

local function stopProcessigs()
    if not require("keyboard").isShiftDown() then
        bbOffLevel = 0 --force make off level
        processing()
    else
        log("exiting witout stoping")
    end

    event.cancel(keyListen)
    event.cancel(interruptListen)

    --unregister proto on close programm(this step is required)
    link.protocols[protoName] = nil
end

os.sleep(1) --stop for viewing logs
term.clear()
globalWorkAllowed = cmp.gt_machine.isWorkAllowed()
processing()
local x, y = term.getCursor()
local i = 0
for _ in pairs(statuses) do
    i = i + 1
end
term.setCursor(x, y+i+5)    --yea, "magical" numbers

keyListen = event.listen("key_down", function (...)
    local _, _, _, k = ...

    if k == keys["q"] then --exit
        log("exiting")
        if exitF then
            stopProcessigs()
        end
        exitF = true
        return
    elseif k == keys["i"] then
        if globalWorkAllowed then
            log("disable")
            globalWorkAllowed = false
            processing()
        else
            log("enable")
            globalWorkAllowed = true
            processing()
        end
    end
end)
interruptListen = event.listen("interrupted", function ()
    log("exiting")
    if exitF then
        stopProcessigs()
    end
    exitF = true
end)

while not exitF do
    processing()
    report()

    local timediff = (math.ceil(((os.time()/3.6/20)-lastAnswer)*100)/100)
    if timediff > advTimeout and globalWorkAllowed and connectionLostFixState == 0 then
        log("detect lost connection with battery buffer")
        log("try to request directly")

        firstReqest()

        if timediff > advTimeout then
            connectionLostFixState = 1
        else
            connectionLostFixState = 0
        end
    elseif connectionLostFixState == 1 then
        log("try to rebuild protocol objects and request directly")

        initProto()
        firstReqest()
        if timediff > advTimeout then
            connectionLostFixState = 2
            globalWorkAllowed = false
            log("stop turbines, wait while bb will be answer")
        else
            connectionLostFixState = 0
        end
    elseif connectionLostFixState == 2 then
        firstReqest(true)

        if timediff < advTimeout then
            connectionLostFixState = 0
        end
    else
        connectionLostFixState = 0
    end

    os.sleep(1)
end

stopProcessigs()
