local cmp = require("component")
local term = require("term")
local time = require("asv").time
local td = cmp.tape_drive
local dictinary = {}
local i1, i2, i3, i4, i5, i6, i7, i8 = 0, 0, 0, 0, 0, 0, 0, 0
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

local function getNext()
    local rt = dictinary[i1]..dictinary[i2]
    i2 = i2 + 1
    if i2>maxval then
        i1 = i1 + 1
        i2 = 0
    end
    if i1>maxval then
        i1 = 0
    end

    return rt
--    return dictinary[i1]..dictinary[i2]..dictinary[i3]..dictinary[i4]..dictinary[i5]..dictinary[i6]..dictinary[i7]..dictinary[i8]
end

getNext()
print(i1, i2)

local data = ""
for i = 0, 255*255-1 do
    data = data..getNext()
end

local x, y = term.getCursor()
local prevTime = time.getRaw()
while not td.isEnd() do

    td.write(data)

    prClr("pos: "..td.getPosition().."/"..td.getSize())
    prClr("wps: "..(1000/(time.getRaw()-prevTime)))
    prClr("flow: "..(1000/(time.getRaw()-prevTime))*#data)
    prevTime = time.getRaw()
    term.setCursor(x, y)

    os.sleep(0)
end