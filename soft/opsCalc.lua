--simple program for calculate cpu performs.
--[[my test result:
opencomputers, lua 5.3: 0.056s, 17857142 ops(1.8879% from host)
native c++ program: 0.0010572s, 945894816 ops
]]
local time = require("time")

local x = 0
local op = 1000000
print(op.." cycles")
local startTime = time.getRaw()
for i = 0, op do
    x = (x + 2)*3
end
local finishTime = time.getRaw()
local elapsed = (finishTime - startTime)/1000
print(elapsed.." seconds")
print(op/elapsed.." op/time")
print(x.." 'x' var")