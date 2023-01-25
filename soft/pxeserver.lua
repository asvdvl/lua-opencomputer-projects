local time = require("asv").time
local cmp = require("component")
local event = require("event")
local srl = require("serialization")
local prefix = "PXEServer"
local sendFile = "/home/pxeload.lua"
local port = 6
local messagesListen
local interruptListen
local wakeupTimer
local exitF

local logFileHandler = io.open("/home/pxe.log", "a")
local function log(message)
    message = time.getDateTime().." "..message
    print(message)
    logFileHandler:write(message.."\n")
end

for addr in pairs(cmp.list("modem")) do
    cmp.proxy(addr).open(port)
end

local function getModem(addr)
    local modem = cmp.proxy(addr)
    if modem.type == "tunnel" then
        function modem.clientAnsver(_, ...)
            modem.send(prefix, ...)
        end
        function modem.wakeupMessage()
            modem.send("wakeup")
        end
    elseif modem.type == "modem" then
        function modem.clientAnsver(clientAddr, ...)
            modem.send(clientAddr, port, prefix, ...)
        end
        function modem.wakeupMessage()
            modem.broadcast(65535, "wakeup")
        end
    end
    return modem
end

local function sendWakeupMessage()
    log("send ping")
    for addr in pairs(cmp.list("modem")) do
        getModem(addr).wakeupMessage()
    end
    for addr in pairs(cmp.list("tunnel")) do
        getModem(addr).wakeupMessage()
    end
end

wakeupTimer = event.timer(10, sendWakeupMessage, math.maxinteger)

local function onModemMessage(...)
    local args = {...}
    log("onModemMessage from client: "..args[3])
    if args[6] == "PXEClient" then
        if args[7] == "whoIsPXEServer" then
            log("request whoIsPXEServer")
            getModem(args[2]).clientAnsver(args[3], "iAmPXEServer")
            log("[dbg] ansver on whoIsPXEServer")
        elseif args[7] == "getProgramm" then
            log("request programm")
            getModem(args[2]).clientAnsver(args[3], "content", io.open(sendFile, "r"):read("*a"))
            log("[dbg] sended programm")
        elseif args[7] == "message" then
            log("message")
            for i = 1, 7 do
                args[i] = nil
            end
            log(srl.serialize(args, math.maxinteger))
        end
    end
end

local function stopAll()
    print("shutdown")
    event.cancel(messagesListen)
    event.cancel(interruptListen)
    event.cancel(wakeupTimer)
    logFileHandler:close()
    exitF = true
end

messagesListen = event.listen("modem_message", onModemMessage)
interruptListen = event.listen("interrupted", stopAll)

sendWakeupMessage()
while not exitF do
    event.pull(30)
end