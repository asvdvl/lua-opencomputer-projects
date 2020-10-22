-------------------------------------------
----------------настройки------------------
-------я знаю что есть конфиг RC но-------- 
------------мне так удобней----------------
-------------------------------------------
local DNSDB = "/mnt/75c/DNSData.dt"
local DNSPort = 53

-------------------------------------------
----------технические переменные-----------
--Не изменять, если не знаете что делаете--
-------------------------------------------
local cmp =    require("component")
local fs =     require("filesystem")
--local io =     require("io")
local event =  require("event")
local serialization = require("serialization")
local computer = require("computer")
local modem
local DNSTable = {}
local DNSDBFileStream
local started = false
local requests = 0

--------запись таблицы в файл--------

local function saveDBToFile()
  local path = fs.path(DNSDB)
  local name = fs.name(DNSDB)

  fs.copy(DNSDB, DNSDB..".old")

  --инициализация
  local DBWriter = io.open(DNSDB, "w")
  DBWriter:write(serialization.serialize(DNSTable))
  DBWriter:flush()
  DBWriter:close()
end

---------обработка сообщений---------

local function modemMessageHandler(...)
  local args = {...}
  if not args[6] == "dns" then
    return
  end
  requests = requests + 1
  local sender = args[3]
  local send = function(...) modem.send(sender, DNSPort, "dnsAnswer", ...) end
  if args[7] == "ping" then
    send("ok", "pong")
  elseif args[7] == "get" then
    if args[8] then
      for i=1,#DNSTable do 
        if DNSTable[i][1] == args[8] then 
          send("ok", DNSTable[i][1], DNSTable[i][2])
          return
        end
      end
    end
    send("error")
    return
  elseif args[7] == "add" then
    if args[8] and args[9] then
      for i=1,#DNSTable do 
        if DNSTable[i][1] == args[8] then
          send("error")
          return
        end
      end
      table.insert(DNSTable, {args[8], args[9]})
      send("ok")
      saveDBToFile()
      return
    end
    send("error")
    return    
  elseif args[7] == "remove" then
    if args[8] then
      for i=1,#DNSTable do 
        if DNSTable[i][1] == args[8] then
          table.remove(DNSTable, i)
          send("ok")
          saveDBToFile()
          return
        end
      end
    end
    send("error")      
    return
  end
end

--------------вывод инфо-------------

function Status()
  --io.stdout:write()
  print("DNS Server by asvdeveloper")
  print("Записей в таблице:", #DNSTable)
  print("запросов:", requests)
  print("статус:", started)
  print("uptime", computer.uptime())
  print("CPU time", os.clock())
end

----------работа с таблицей----------

function TableHandler(request, ...)
  local args = {...}
  --add---------------------
  if request == "add" then
    if args[1] and args[2] then
      for i=1,#DNSTable do 
        if DNSTable[i][1] == args[1] then
          io.stderr:write("Запись уже существует!")
          return
        end
      end
      table.insert(DNSTable, {args[1], args[2]})
      return
    else
      io.stderr:write("Use: add <name> <address>")
    end
  --remove------------------
  elseif request == "remove" then
    if args[1] then
      for i=1,#DNSTable do 
        if DNSTable[i][1] == args[1] then
          table.remove(DNSTable, i)
          saveDBToFile()
          return
        end
      end
      return
    else
      io.stderr:write("Use: remove <name>")
    end
  --get---------------------
  elseif request == "get" then
    if args[1] then
      for i=1,#DNSTable do 
        if DNSTable[i][1] == args[1] then
          io.stderr:write(DNSTable[i][1], " ",DNSTable[i][2])
          return
        end
      end
      return
    else
      io.stderr:write("Use: get <name>")
    end
  --print-------------------
  elseif request == "print" then
    for name, tabl in pairs(DNSTable) do
      print("["..name.."]", tabl[1], tabl[2])
    end
  else
    io.stderr:write("Use: <mode(add|remove|get|print)> [options]")
    return
  end
end

----------запуск---------

function Start()
  --проверка на васю
  if started then
    io.stderr:write("Сервер уже запущен!")
    return
  end
  
  --инициализация
  if not fs.exists(DNSDB) then 
    print("БД ДНС отсутствует!") 
    return
  end
  started = true
    
  --считывание базы
  local reader = io.open(DNSDB, "r")
  local rData = reader:read("*a")
  reader:close()
  if type(serialization.unserialize(rData)) ~="table" then
    io.stderr:write("БД ДНС повреждена и будет заменена на новую")
    saveDBToFile()
  end
  local reader = io.open(DNSDB, "r")
  local rData = reader:read("*a")
  DNSTable = serialization.unserialize(rData)
  
  if not cmp.isAvailable("modem") then
    io.stderr:write("Сетевая карта не найдена!")
    return
  end
  modem =  require("component").modem

  if not modem.isOpen(DNSPort) then
    modem.open(DNSPort)
  end

  event.listen("modem_message", modemMessageHandler) 
  
end

----------остановка----------

function Stop()
  if not started then  
    io.stderr:write("Сервер уже выключен!")
    return
  end
  started = false
  saveDBToFile()
  DNSTable = {}
  event.ignore("modem_message", modemMessageHandler)   
end
