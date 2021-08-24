local this = {}
local cmp = require("component")
local gisteresises = {}

function this.checkFunction(_, machines, opt)
    for address, table in pairs(opt.transposers) do
        local addr = cmp.get(address)
        if addr then
            local transposer = cmp.proxy(addr)
            for side, params in pairs(table) do
                local value = transposer.getTankLevel(tonumber(side))
                if value > params.max or gisteresises[addr..side] then
                    for key in pairs(machines) do
                        if type(machines[key].options.problemsCount) == "nil" then
                            machines[key].options.problemsCount = 0
                            machines[key].options.allowDisable = true
                        end
                        gisteresises[addr..side] = true
                        machines[key].options.problemsCount = machines[key].options.problemsCount + 1
                    end
                    if value < params.min then
                        gisteresises[addr..side] = false
                    end
                end
            end
        else
            io.stderr:write("Could not resolve address "..address.."\n")
        end
    end
end

function this.action()

end

return this