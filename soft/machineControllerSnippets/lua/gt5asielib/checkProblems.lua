local this = {}
local cmp = require("component")

function this.checkFunction(group)
    local toreturn = {}
    for _, value in pairs(group.machines) do
        local addr = cmp.get(value.options.addr)
        if not addr then
            io.stderr:write("Could not resolve address "..value.options.addr.."\n")
        end

        local mach = cmp.proxy(addr)
        local problems = tonumber(mach.getSensorInformation()[7])
        if problems > 0 then
            table.insert(toreturn, "`"..value.title.."` detect problems: "..problems)
        end
    end
    return toreturn
end

function this.action(group)
    if group.options.returned.checkFunction then
        for _, value in pairs(group.options.returned.checkFunction) do
            cmp.modem.broadcast(20, value)
        end
    end
end

return this