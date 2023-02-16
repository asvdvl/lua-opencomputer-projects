--if you check the user offline, it will be deleted! because the OC has no way to add it back!

local comp = require("computer")
local cmp = require("component")
local rs = cmp.redstone
local testtype = 0 --0 - one of all, 1 - all should be online
local redstoneSide = 0

rs.setOutput(redstoneSide, 0)

local players = {
    "dial-up",
    "darkwolfqww"
}

for _, nick in pairs(players) do
    comp.removeUser(nick)
end

local function probePlayer(nick)
    local result = comp.addUser(nick)
    comp.removeUser(nick)
    return result
end

local probsuccess = 0
for _, nick in pairs(players) do
    local probe = probePlayer(nick)
    if probe then
        probsuccess = probsuccess + 1
        if testtype == 0 then
            rs.setOutput(redstoneSide, 15)
        end
    end
end

if probsuccess == #players then
    rs.setOutput(redstoneSide, 15)
end