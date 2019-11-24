local cmp = require("component")
local modem = cmp.modem
local event = require("event")
local comp = require("computer")
local beep = true

modem.open(1)

while true do

local type, _, key, _, _, mes = event.pull()
if type == "modem_message" then
print(mes)
if beep == true then comp.beep() end
  if key == 109.0 then 
    beep = false
    print("бип офф")
  elseif key == 109.0 then
     beep = true 
     print("бип он")
  end
end
end