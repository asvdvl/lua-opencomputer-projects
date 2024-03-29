local cmp = require("component")
local term = require("term")
local time = require("asv").time
local td = cmp.tape_drive
local dictinary = {}
local maxval = 255
cmp.redstone.setOutput(4, 0)

local function prClr(...)
    term.clearLine()
    print(...)
end
local x, y = term.getCursor()
for i = 0, maxval do
    dictinary[i] = string.char(i)
end

while true do
    while not td.isReady() or td.getLabel() == "done" do
        if td.getLabel() == "done" then
            cmp.redstone.setOutput(4, 15)
        else
            cmp.redstone.setOutput(4, 0)
        end
        os.sleep(0)
    end

    if td.getState() ~= "STOPPED" then
        td.stop()
    end
    td.seek(math.mininteger)

    local data = ""

    local prevTime = time.getRaw()
    while not td.isEnd() do
        data = ""
        for i = 0, 255^2 do
            data = data..dictinary[i%255]..dictinary[math.random(0, maxval)]
        end
        td.write(data)
        term.setCursor(x, y)

        prClr("pos: "..td.getPosition().."/"..td.getSize())
        prClr("wps: "..(1000/(time.getRaw()-prevTime)))
        prClr("flow: "..(1000/(time.getRaw()-prevTime))*#data)
        prevTime = time.getRaw()

        os.sleep(0)
    end
    print()
    td.seek(math.mininteger)
    td.setLabel("done")
end
