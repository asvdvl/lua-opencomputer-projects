local cmp = require("component")
local term = require("term")
local debug = cmp.debug
local world = debug.getWorld()
local killedRain = 0
local killedNight = 0
local skipedTime = 0

function KillRain()
  if (world.isRaining(true)) then
    world.setRaining(false)
    killedRain = killedRain + 1
  end
end

function KillNight()
  local time = world.getTime()
  if(time%24000 > 12000 and time%24000 < 24000) then
    killedNight = killedNight + 1
    world.setTime(time+(25000-time))  
    skipedTime = skipedTime + (time+(2500-time))  
  end
end

local function printInfo()
  term.clear()
  local time = world.getTime()
  print("kill rain: "..killedRain)
  print("kill night: "..killedNight)
  print("Skip time: "..skipedTime)
  print("Full time: "..time)
  print("Day time: "..time%24000)
  local secInGame = time/20
  
  print(
        "In game: "
        ..math.floor(secInGame/3600)
        ..":"..math.floor(secInGame/60%60)
        ..":"..math.floor(secInGame%60)
       )

end

while(true) do
  KillRain()
  KillNight()
  printInfo()  
  os.sleep(1)
end
