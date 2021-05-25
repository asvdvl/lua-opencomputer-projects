local this = {}
local event = require("event")
local cmp = require("component")
local groups = machineControllerENV.objectsAndSets.machineGroups
local machines = machineControllerENV.objectsAndSets.machines
local asvutils = require("asvutils")

function this.checkFunction(_, _, opt)
    --check existing items
    for _, group in pairs(opt.groups) do
        for machineIndex, machine in pairs(groups[group].machines) do
            if machine.enable then
                local addr = cmp.get(machine.options.addr)
                if not addr then
                    io.stderr:write("Could not resolve address "..machine.options.addr.." in `"..machine.title.."`\n")
                    cmp.modem.broadcast(20, "Could not resolve address `"..machine.options.addr.."` in "..machine.title)
                    groups[group].machines[machineIndex].enable = false
                else
                    --try detect gt multiblock
                    local mach = cmp.proxy(addr)
                    if mach.type ~= opt.machineType then
                        io.stderr:write(machine.title.." is not a `"..opt.machineType.."`\n")
                        cmp.modem.broadcast(20, machine.title.." is not a "..opt.machineType)
                        groups[group].machines[machineIndex].enable = false
                    elseif mach.getSensorInformation()[6] ~= "Problems:" then
                        io.stderr:write(machine.title.." required field `Problems:` in `getSensorInformation` is missing\n")
                        cmp.modem.broadcast(20, machine.title.." is not a "..opt.machineType)
                        groups[group].machines[machineIndex].enable = false
                    end
                end
            end
        end
    end
end

function this.action(_, _, opt)
    --add listeners for detect removed or added components
    local function eventHandler(eventType, addr, type)
        if type == opt.machineType then
            if eventType == "component_added" then
                --try find exiting item
                for key, value in pairs(machines) do
                    if cmp.get(value.options.addr) == addr then
                        io.stderr:write("activate `"..opt.machineType.."` with address `"..addr.."`\n")
                        cmp.modem.broadcast(20, "activate `"..opt.machineType.."` with address `"..addr.."`")
                        machines[key].enable = true
                        return
                    end
                end

                --check on gt multiblock
                local mach = cmp.proxy(addr)
                local info = mach.getSensorInformation()
                if info[6] == "Problems:" then
                    io.stderr:write("found new `"..opt.machineType.."` with address `"..addr.."`\n")
                    cmp.modem.broadcast(20, "found new `"..opt.machineType.."` with address `"..addr.."`")

                    --create item
                    local itemTab = {
                        title = addr,
                        enable = true,
                        options = {
                            addr = addr
                        }
                    }
                    local item = asvutils.correctTableStructure(itemTab, machineControllerENV.items.machinesItem)

                    for _, group in pairs(opt.groups) do
                        groups[group].machines[addr] = item
                    end
                end
            else
                for key, value in pairs(machines) do
                    if value.options.addr == string.sub(addr, 1, #value.options.addr) then
                        io.stderr:write("found removed `"..opt.machineType.."` with address `"..addr.."`\n")
                        cmp.modem.broadcast(20, "found removed `"..opt.machineType.."` with address `"..addr.."`")
                        machines[key].enable = false
                    end
                end
            end
        end
    end
    event.listen("component_added", eventHandler)
    event.listen("component_removed", eventHandler)
end

return this