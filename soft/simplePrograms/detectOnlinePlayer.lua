--if you check the user offline, it will be deleted! because the OC has no way to add it back!

local comp = require("computer")
local cmp = require("component")
--local rs = cmp.redstone

local players = {
    "test",
    "test1"
}

for _, nick in pairs(players) do
    comp.removeUser(nick)
end

local function probePlayer(nick)
    local result = comp.addUser(nick)
    comp.removeUser(nick)
    return result
end

for _, nick in pairs(players) do
    if probePlayer(nick) then
        print(nick)
    end
end
