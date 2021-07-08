local r = require("robot")
local period = 5

local function forward()
    local succes = r.forward()
    while not succes do
        succes = r.detect()
    end
end

local function cycle()
    print(r.placeDown())
    for i = 1, period do
        forward()
    end
end

while true do
    cycle()
    os.sleep(1)
end