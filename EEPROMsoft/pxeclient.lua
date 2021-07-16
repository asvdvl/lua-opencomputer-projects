local port = 6
local modem
local title = "PXEClient"
local serverAddr
local content

local exist = pairs(component.list("tunnel"))

if exist then
    modem = component.proxy(component.list("tunnel")())
    function modem.getServer()
        modem.send(title, "whoIsPXEServer")
    end
    function modem.getProgramm()
        modem.send(title, "getProgramm")
    end
else
    modem = component.proxy(component.list("modem")())
    modem.open(port)
    function modem.getServer()
        modem.broadcast(port, title, "whoIsPXEServer")
    end
    function modem.getProgramm()
        modem.send(serverAddr, port, title, "getProgramm")
    end
end

for i = 1, 20 do
    modem.getServer()
    local mess={computer.pullSignal(2)}
    if mess[1] == "modem_message" and mess[6] == "PXEServer" then
        serverAddr = mess[3]
        break
    end
end

if not serverAddr then
    error("get server timeout")
end

for i = 1, 10 do
    modem.getProgramm()
    local mess={computer.pullSignal(2)}
    if mess[1] == "modem_message" and mess[6] == "PXEServer" then
        content = mess[7]
        break
    end
end

if not content then
    error("get content timeout")
end