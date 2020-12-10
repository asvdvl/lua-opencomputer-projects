local time = require("time")

local function getTicks()
    return os.time()/3.6
end

while true do
    local realTime = time.getRaw()
    local gameTime = getTicks()

    --sleep on in-game ticks
    --5 ticks - closest to real value and low latency
    while (getTicks() - gameTime) < 5 do
        os.sleep(0)
    end

    print("tps", 1000/((time.getRaw() - realTime)/(getTicks() - gameTime)))
end