--libs and service settings
local cmp = require("component")
local PIDEnergy =
{
    pk = 2, --4
    ik = 0.5, --0.4
    dk = 5,
    integral = 0,
    differential = 0,   --for debug
    lastError = 0
}
local PIDShield =
{
    pk = 2, --4
    ik = 0.5, --0.4
    dk = 5,
    integral = 0,
    differential = 0,   --for debug
    lastError = 0
}

--user settings
local arrdINRegulator = "20a"
local arrdOUTRegulator = "d47"
local temperatureLevel = 7900
local shieldLevel = 20    --in persent
local delay = 1 --in seconds

--init components
local reactor = cmp.draconic_reactor
local INRegulator = cmp.proxy(cmp.get(arrdINRegulator))
local OUTRegulator = cmp.proxy(cmp.get(arrdOUTRegulator))

--functions
local function calculatePID(currentTemperature, PIDArray)
    local error = currentTemperature - temperatureLevel
    PIDArray.integral = PIDArray.integral + error * delay
    PIDArray.differential = (error - PIDArray.lastError)/delay
    PIDArray.lastError = error
    return error * PIDArray.pk + PIDArray.integral * PIDArray.ik + PIDArray.differential * PIDArray.dk
end

local lastpid = 0
local function main()
    local info = reactor.getReactorInfo()
    local pid = -calculatePID(info.temperature)
    OUTRegulator.setSignalLowFlow(pid)


    --out data
    require("term").clear()
    print("pidout", pid, pid - lastpid, "RF/"..delay.."sec")
    print("tempr", info.temperature, "shield", info)
    print("error", PIDEnergy.lastError)
    print("integral", PIDEnergy.integral, "differential", PIDEnergy.differential)
    print("PIDEnergy", "p", PIDEnergy.pk, "i", PIDEnergy.ik, "d", PIDEnergy.dk, "settemp", temperatureLevel)
    print("PIDShield", "p", PIDShield.pk, "i", PIDShield.ik, "d", PIDShield.dk, "setShield", shieldLevel)

    lastpid = pid
end


--main cycle
while true do
    main()
    os.sleep(delay)
end