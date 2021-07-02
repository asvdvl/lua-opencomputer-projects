--сделать отправку данных, прием данных, сохранение данных в локальную базу(??)
--в днс сервере сделать проверку типа принимаемой переменной 
-----------------
----настройки----
-----------------
local DNSPort = 53
local DNSAddress
local TimeOut = 3 --in second
local sendDataAboutYourself = false
local DNSName = ""
local DNSData = ""

------------------------
--Системные переменные--
------------------------
local DNSClient = {}
local localDB = {}
local cmp = require("component")
local event = require("event")
local modem, send

local function init() --сделать отправку данных о себе
  if not modem then
    if not cmp.isAvailable("modem") then
      return false
    end
    modem =  require("component").modem
  end
  if not modem.isOpen(DNSPort) then
    modem.open(DNSPort)
  end
  if not DNSAddress then
    if DNSClient.ping() then
      return false
    end
  end
  if sendDataAboutYourself then
    --todo
  end

  send = function(...) modem.send("dns", ...) end
  return true
end

local function chechOnInit()
  if not DNSAddress or not modem then
    if init() then
	  return true
	end
  end
  return false
end

function DNSClient.ping()
  if not chechOnInit() then
    return false
  end
  if not DNSAddress then
	for i=1,3 do
	  modem.broadcast(DNSPort, "dns", "ping")                    
      local ansver = {event.pull("modem_message", TimeOut)}            
      if ansver[6] == "dnsAnswer" and ansver[7] == "pong" then
	    DNSAddress = ansver[3]
	    return true
	  end
	end
	
  elseif type(DNSAddress) == "string" then
	for i=1,3 do
	  send("ping")
      local ansver = {event.pull("modem_message", TimeOut)}            
      if ansver[6] == "dnsAnswer" and ansver[8] == "pong" then
	    return true
	  end
	end
	
  else
    DNSAddress = nil
	return false
  end
end


function DNSClient.get(name)
  if not chechOnInit() then
    return false
  end
  send("get", name)
  local ansver = {event.pull("modem_message", TimeOut)}            
  if ansver[6] == "dnsAnswer" and ansver[7] == "ok" then
    --продолжать здесть
  end
end

return DNSClient
