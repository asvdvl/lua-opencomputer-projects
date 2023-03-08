local cmp = require("component")
local term = require("term")
local time = require("asv").time
local td = cmp.tape_drive
local dictinary = {}
local iA = {0, 0, 0, 0, 0, 0, 0, 0}
local maxval = 255

local function prClr(...)
    term.clearLine()
    print(...)
end

if not td.isReady() then
    print("not ready")
    os.exit()
end

if td.getState() ~= "STOPPED" then
    td.stop()
end
td.seek(math.mininteger)

for i = 0, maxval do
    dictinary[i] = string.char(i)
end

local x, y = term.getCursor()
local data = ""

local prevTime = time.getRaw()
while not td.isEnd() do
    data = ""
    for i = 0, 255 do
        data = data..dictinary[math.random(0, maxval)]
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