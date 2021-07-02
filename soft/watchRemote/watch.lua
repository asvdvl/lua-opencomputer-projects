local event = require("event")
local cmp = require("component")
local Wmodem = cmp.modem
local witelist = " "


while true do

--print(event.pull())

local eventType, address, x, y, z, player = event.pull()

if eventType == "motion" then
  if player ~= witelist then
    Wmodem.broadcast(1, "противник обнаружен в ...")
    if address == cmp.get("d80e") then
       Wmodem.broadcast(1, "серверной")
    end
    if address == cmp.get("9c49") then
       Wmodem.broadcast(1, "конец коридора 3й этаж")
    end
    if address == cmp.get("e513") then
      Wmodem.broadcast(1, "на леснице на 3й этаж (верх)")
    end
    if address == cmp.get("7212") then
      Wmodem.broadcast(1, "подьем на лестницу 3й этаж")
    end
    if address == cmp.get("d71b") then
      Wmodem.broadcast(1, "северовосточная часть коридора")
    end    
    if address == cmp.get("8e0e") then
      Wmodem.broadcast(1, "на входе")
    end
    if address == cmp.get("f4e6") then
      Wmodem.broadcast(1, "на лестнице на 2й этаж")
    end
    if address == cmp.get("3510") then
      Wmodem.broadcast(1, "западноюжный коридор 2й этаж")
    end
    if address == cmp.get("1bce") then
      Wmodem.broadcast(1, "северозападном коридоре 2й этаж")
    end
    if address == cmp.get("1d75") then
      Wmodem.broadcast(1, "восточноюжное крыло 2й этаж")
    end
  end
end













end
