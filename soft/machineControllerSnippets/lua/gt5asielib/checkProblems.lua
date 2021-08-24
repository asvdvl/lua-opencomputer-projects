local this = {}
local cmp = require("component")

function this.checkFunction(_, machines)
    local toreturn = {}
    for _, value in pairs(machines) do
        if value.enable then
            local addr = cmp.get(value.options.addr)
            if not addr then
                io.stderr:write("Could not resolve address "..value.options.addr.." in "..value.title.."\n")
                break;
            end

            local mach = cmp.proxy(addr)
            local problems = tonumber(mach.getSensorInformation()[7])
            if problems > 0 then
                if type(value.options.problemsCount) == "nil" then
                    value.options.problemsCount = 0
                    value.options.allowDisable = true
                end
                value.options.problemsCount = value.options.problemsCount + problems
                table.insert(toreturn, "`"..value.title.."` detect problems: "..problems)
            end
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