--libs and service settings
local cmp = require("component")
local event = require("event")
local PIDEnergy =
{
    pk = 300,
    ik = 0.4,
    dk = 100,
    integral = 0,
    differential = 0,   --for debug
    lastError = 0,
    needLevel = 7900
}
local PIDShield =
{
    pk = 0.05,
    ik = 0.007,
    dk = 0.03,
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
local reactorAddress = ""   --optional
local delay = 1             --in seconds
local shieldLevel = 50      --in persent
local warmingUpEnergyFlow = math.maxinteger

--init components
local reactor = {}
if reactorAddress == "" then
    reactor = cmp.draconic_reactor
else
    reactor = cmp.proxy(cmp.get(reactorAddress))
end
local INRegulator = cmp.proxy(cmp.get(arrdINRegulator))
local OUTRegulator = cmp.proxy(cmp.get(arrdOUTRegulator))

--try get data
if not reactor.getReactorInfo() then
    print("Can not get data from reactor")
    exitF = true
end

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

    --shield PID
    if info.status == "running" or info.status == "stopping" then
        local pidoutShield = -calculatePID(info.fieldStrength, PIDShield)
        INRegulator.setSignalLowFlow(pidoutShield)

        print("pidShield", pidoutShield, pidoutShield - lastpidShield, "RF/"..delay.."sec")
        print("error", PIDShield.lastError)
        print("integral", PIDShield.integral, "differential", PIDShield.differential)

        lastpidShield = pidoutShield
    end


    --processing reactor states
    if info.status == "invalid" then
        print("check the reactor structure")
    elseif info.status == "warming_up" then
        if info.temperature < 2000 then
            --calculate shield
            info = reactor.getReactorInfo()
            PIDShield.needLevel = info.maxFieldStrength * (shieldLevel/100)

            INRegulator.setSignalLowFlow(warmingUpEnergyFlow)
            OUTRegulator.setSignalLowFlow(0)
        else
            INRegulator.setSignalLowFlow(0)
            OUTRegulator.setSignalLowFlow(0)
            print("press 's' to activate reactor")
        end
        print("press 'd' to shutdown reactor")
    elseif info.status == "running" then
        local pidoutEnergy = -calculatePID(info.temperature, PIDEnergy)
        OUTRegulator.setSignalLowFlow(pidoutEnergy)

        --out data(debug)
        print("pidEnergy", pidoutEnergy, pidoutEnergy - lastpidEnergy, "RF/"..delay.."sec")
        print("error", PIDEnergy.lastError)
        print("integral", PIDEnergy.integral, "differential", PIDEnergy.differential)

        lastpidEnergy = pidoutEnergy
        print("press 's' to shutdown reactor")
    elseif info.status == "stopping" then
        print("press 's' to activate reactor")
    elseif info.status == "cooling" or info.status == "cold" then
        print("press 's' to charge reactor")
    elseif info.status == "beyond_hope" then
        print("oops...")
    end

    if printHelp then
        print("q - exit")
        print("h - show/hide this text")
        print("s - start/stop reactor")
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
    elseif ev[4] == 31 then --s
        if info.status == "cold" or info.status == "cooling" then
            reactor.chargeReactor()
        elseif (info.status == "warming_up" and info.temperature >= 2000) or info.status == "stopping" then
            reactor.activateReactor()
        elseif info.status == "running" then
            reactor.stopReactor()
        end
    elseif ev[4] == 32 and info.status == "warming_up" then
        reactor.stopReactor()
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