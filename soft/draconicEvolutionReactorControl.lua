--libs and service settings
local cmp = require("component")
local event = require("event")
local PIDEnergy =
{
    pk = 10,
    ik = 0.25,
    dk = 100,
    integral = 0,
    differential = 0,   --for debug
    lastError = 0,
    needLevel = 7900
}
local PIDShield =
{
    pk = 0.05,
    ik = 0.015,
    dk = 0.02,
    integral = 0,
    differential = 0,   --for debug
    lastError = 0,
    needLevel = 0
}
local printHelp = false
local exitF = false
local eventNumb = 0
local lastpidEnergy, lastpidShield, info = 0, 0, {}

--user settings
local arrdINRegulator = "20a"
local arrdOUTRegulator = "d47"
local delay = 1 --in seconds
local shieldLevel = 50    --in persent
local warmingUpEnergyFlow = math.maxinteger

--init components
local reactor = cmp.draconic_reactor
local INRegulator = cmp.proxy(cmp.get(arrdINRegulator))
local OUTRegulator = cmp.proxy(cmp.get(arrdOUTRegulator))

--calculate shield
info = reactor.getReactorInfo()
PIDShield.needLevel = info.maxFieldStrength * (shieldLevel/100)

--functions
local function calculatePID(currentTemperature, PIDArray, direction)
    --direction: normal- false, reverse - true
    local mdelay = delay
    local error = currentTemperature - PIDArray.needLevel

    if direction then
        error = -error
        mdelay = -delay
    end

    PIDArray.integral = PIDArray.integral + error * mdelay
    local differential = (error - PIDArray.lastError)/mdelay
    PIDArray.lastError = error

    PIDArray.differential = differential --for debug
    return error * PIDArray.pk + PIDArray.integral * PIDArray.ik + differential * PIDArray.dk
end

local function printInfo()
    local currentShieldLevel = info.fieldStrength/info.maxFieldStrength * 100

    require("term").clear()
    print("status "..info.status)
    print("tempr "..info.temperature)
    print("shield "..currentShieldLevel, info.fieldStrength.."/"..info.maxFieldStrength)
    print("energySaturation "..info.energySaturation/info.maxEnergySaturation, info.energySaturation.."/"..info.maxEnergySaturation)
    print("")
    print("settemp", PIDEnergy.needLevel)
    print("setShield", shieldLevel, "("..PIDShield.needLevel..")")
end

local function main()
    --get reactor state
    info = reactor.getReactorInfo()

    --print info
    printInfo()

    --processing reactor states
    if info.status == "invalid" then

    elseif info.status == "cold" then

    elseif info.status == "warming_up" then
        INRegulator.setSignalLowFlow(warmingUpEnergyFlow)
        OUTRegulator.setSignalLowFlow(0)
    elseif info.status == "running" then
        local pidoutEnergy = -calculatePID(info.temperature, PIDEnergy)
        local pidoutShield = -calculatePID(info.fieldStrength, PIDShield)
        OUTRegulator.setSignalLowFlow(pidoutEnergy)
        INRegulator.setSignalLowFlow(pidoutShield)

        --out data(debug)
        print("pidEnergy", pidoutEnergy, pidoutEnergy - lastpidEnergy, "RF/"..delay.."sec")
        print("error", PIDEnergy.lastError)
        print("integral", PIDEnergy.integral, "differential", PIDEnergy.differential)
        print("")
        print("pidShield", pidoutShield, pidoutShield - lastpidShield, "RF/"..delay.."sec")
        print("error", PIDShield.lastError)
        print("integral", PIDShield.integral, "differential", PIDShield.differential)

        lastpidEnergy = pidoutEnergy
        lastpidShield = pidoutShield

    elseif info.status == "stopping" then

    elseif info.status == "cooling" then

    elseif info.status == "beyond_hope" then
        print("oops...")
    end

    if printHelp then
        print("q - exit")
        print("h - show/hide this text")
        print("t/y - +/- temperature")
        print("j/k - +/- shield level")
    else
        print("press 'h' for keyhelp")
    end
end

local function eventHandler(...)
    local ev = {...}

    if ev[4] == 16 then --q
        exitF = true
    elseif ev[4] == 35 then --h
        printHelp = not printHelp

    elseif ev[4] == 20 then --t
        PIDEnergy.needLevel = PIDEnergy.needLevel + 1
    elseif ev[4] == 21 then --y
        PIDEnergy.needLevel = PIDEnergy.needLevel - 1
    elseif ev[4] == 36 then --j
        shieldLevel = shieldLevel + 1
    elseif ev[4] == 37 then --k
        shieldLevel = shieldLevel - 1
    end
    PIDShield.needLevel = info.maxFieldStrength * (shieldLevel/100)
end
eventNumb = event.listen("key_down", eventHandler)

--main cycle
while true do
    if exitF then
        event.cancel(eventNumb)
        os.exit()
    end

    main()
    os.sleep(delay)
end