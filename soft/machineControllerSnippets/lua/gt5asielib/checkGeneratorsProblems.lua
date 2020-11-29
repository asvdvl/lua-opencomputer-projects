local this = {}
local cmp = require("component")

function this.checkFunction(_, machines)
    local toreturn = {}
    for _, value in pairs(machines) do
        local addr = cmp.get(value.options.addr)
        if not addr then
            io.stderr:write("Could not resolve address "..value.options.addr.."\n")
        end

        local mach = cmp.proxy(addr)
        local problemsRowText = mach.getSensorInformation()[8]
        if problemsRowText == "Needs Maintainance" then
            table.insert(toreturn, "`"..value.title.."` have problems")
        end
    end
    return toreturn
end

function this.action(_, _, options)
    if options.returned.checkFunction then
        for _, value in pairs(options.returned.checkFunction) do
            cmp.modem.broadcast(20, value)
        end
    end
end

return this