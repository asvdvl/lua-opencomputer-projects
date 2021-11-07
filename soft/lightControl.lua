--Control colourful_lamp 's from computronics
local cmp = require("component")
local shell = require("shell")
local bit32 = require("bit32")

local args, opts = shell.parse(...)
local newColor = 0

if not args[1] or opts.h or opts.help then
    print("Usage:")
    print("lightControl <r 0-31> <g 0-31> <b 0-31>")
    print("lightControl <colour 0-32767>")
    os.exit()
end

if args[1] and args[2] and args[3] then
    local r, g, b = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])

    assert(r <= 31 and r >= 0, "Channel R not in range")
    assert(g <= 31 and g >= 0, "Channel G not in range")
    assert(b <= 31 and b >= 0, "Channel B not in range")

    newColor = bit32.lshift(tonumber(args[1]), 10) + bit32.lshift(tonumber(args[2]), 5) + tonumber(args[3])
elseif args[1] then
    newColor = tonumber(args[1])
    assert(newColor <= 32767 and newColor >= 0, "Color not in range")
end

local currentLamp
for key in pairs(cmp.list("colorful_lamp")) do
    currentLamp = cmp.proxy(key)

    currentLamp.setLampColor(newColor)
end