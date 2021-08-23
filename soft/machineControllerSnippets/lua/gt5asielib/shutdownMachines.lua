local this = {}
local cmp = require("component")
local lastExecutions = {}
local groups = machineControllerENV.objectsAndSets.machineGroups

function this.checkFunction(_, machines, opt)
    local notAllWasUpdated = false
    for _, key in pairs(opt.groups) do
        local current = groups[key]

        if current.enable and current.lastExecution == lastExecutions[key] then
            notAllWasUpdated = true
        end
    end
    if not notAllWasUpdated then
        for _, key in pairs(opt.groups) do
            local current = groups[key]
            lastExecutions[key] = current.lastExecution
        end
    end
    for key, value in pairs(machines) do
        if value.enable then
            local addr = cmp.get(value.options.addr)
            if addr then
                local machine = cmp.proxy(addr)
                if type(value.options.problemsCount) == "nil" then
                    machines[key].options.problemsCount = 0
                    machines[key].options.allowDisable = true
                end
                if value.options.problemsCount > 0 and value.options.allowDisable then
                    if machine.isWorkAllowed() then
                        io.write("Machine "..value.options.addr.." was detect "..value.options.problemsCount.." problems, disabling...\n")
                        machine.setWorkAllowed(false)
                    end
                elseif value.options.problemsCount == 0 and value.options.allowDisable then
                    if not notAllWasUpdated and not machine.isWorkAllowed() then
                        io.write("Machine "..value.options.addr.." was detect "..value.options.problemsCount.." problems, enabling...\n")
                        machine.setWorkAllowed(true)
                    end
                end
                value.options.problemsCount = 0
            else
                io.stderr:write("Could not resolve address "..value.options.addr.." in "..value.title.."\n")
            end
        end
    end
end

function this.action()

end

return this