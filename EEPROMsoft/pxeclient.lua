local port = 6
local modem
local prefix = "PXEClient"
local serverAddr
local content
local modemNotFound = true

local exist = component.list("tunnel")()
if exist then
    modem = component.proxy(exist)
    function modem.getServer()
        modem.send(prefix, "whoIsPXEServer")
    end
    function modem.getProgramm()
        modem.send(prefix, "getProgramm")
    end
    function modem.message(...)
        modem.send(prefix, "message", ...)
    end
    modemNotFound = false
end

exist = component.list("modem")()
if exist then
    modem = component.proxy(exist)
    modem.open(port)
    function modem.getServer()
        modem.broadcast(port, prefix, "whoIsPXEServer")
    end
    function modem.getProgramm()
        modem.send(serverAddr, port, prefix, "getProgramm")
    end
    function modem.message(...)
        modem.send(serverAddr, port, prefix, "message", ...)
    end
    modemNotFound = false
end

if modemNotFound then
    error("no modem or tunnel")
end

for i = 1, 20 do
    modem.getServer()
    local mess={computer.pullSignal(5)}
    if mess[1] == "modem_message" and mess[6] == "PXEServer" and mess[7] == "iAmPXEServer" then
        serverAddr = mess[3]
        break
    end
end

if not serverAddr then
    error("get server timeout")
end

for i = 1, 10 do
    modem.getProgramm()
    local mess={computer.pullSignal(5)}
    if mess[1] == "modem_message" and mess[6] == "PXEServer" and mess[7] == "content" then
        content = mess[8]
        break
    end
end

if not content then
    modem.message("error", "get content timeout")
    error("get content timeout")
end

modem.message("result", xpcall(load(content), debug.traceback))