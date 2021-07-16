local time = require("asv").time
local cmp = require("component")
local event = require("event")
local sendFile = "/home/pxeload.lua"
local port = 6
local messagesListen
local interruptListen
local exitF

cmp.modem.open(6)

local function onModemMessage(...)
    local args = {...}
    if args[6] == "PXEClient" then
        
    end
end

local function stopAll()
    print("shutdown")
    event.cancel(messagesListen)
    event.cancel(interruptListen)
    exitF = true
end

messagesListen = event.listen("modem_message", onModemMessage)
interruptListen = event.listen("interrupted", stopAll)

while not exitF do
    event.pull(5)
end