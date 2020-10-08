local cmp = require("component")
local modem = cmp.modem
local event = require("event")
local comblock = cmp.command_block
local math = require("math")

local start = false
local pause = false
local newvoln = true

local volna = 1
local from = 1
local spawned = 1
local timeout = 1

local summon1 = "/summon mw:bandit1 72270 76 -2411"
local summon2 = "/summon mw:bandit1 72263 76 -2411"

modem.open(5)


local function executeComm (text) 
  comblock.setCommand(text)
  comblock.executeCommand()
end

local function notify (text, subtext, icon)
  cmp.notification_interface.notify(text, subtext, icon, 0)
end

while true do
  local e = {event.pull(1)}
  if e[1] == "control" then
    if e[2] == "start" and start == false then
      print(e[6])
      executeComm("/say ХАХАХА!!! ГЛУПЦЫ!!! Думаете, сможете сбежать от НАС?")
      os.sleep(3)
      executeComm("/say НЕТ! НЕТ! НЕТ! и еще раз НЕТ! Вы в тупике! А стороны перекрыли МОИ солдаты! Сдавайтесь! У вас есть, 5, секунд! 1...2...")
      os.sleep(5)
      executeComm("/say ...5 Ну что ж... Ваша жизнь съест кит-кат СДЕСЬ! Парни в АТАКУ!")
      start = true
    elseif e[2] == "pause" then
      notify("пауза", " ", "minecraft:record_11")
      while true do
        local e = {event.pull()}
        if e[1] == "control" and e[2] == "pause/resume" then 
          notify("продолжаем", " ", "minecraft:record_13")
          break
        end
      end  
    end
  end

  if start == true and newvoln == true then
    spawned = math.random(volna, from);
    notify("волна "..volna, "солдатов: "..spawned, "minecraft:shield")

    volna = volna + 1
    from = from + math.random(1, 2)

    for i = 1, math.ceil(spawned/'2') do
      executeComm(summon1)
      executeComm(summon2)
      os.sleep(0.2)
    end
  end
end
