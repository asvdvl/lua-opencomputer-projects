local asv = require("asv")
local link = asv.net.Layers.Link
local utils = asv.utils
local protoName = "gt_batteryAdv"

local packetStruc = {
    type = "none",
    stored = {
        current = 0,
        max = 0
    },
    flow = {
        input = 0,
        output = 0
    }
}

--register proto
link.protocols[protoName] = {
    onMessageReceived = function(dstAddr, frame, srcAddr)
        local data, bagRequest = utils.correctTableStructure(frame.data, packetStruc)

        if bagRequest then
            return
        end

        if data.type == "response" then     --do something with this data
            print("report:")
            print("buff: "..tostring(data.stored.current).."/"..tostring(data.stored.max))
            print("flow: in "..tostring(data.flow.input).."; out "..tostring(data.flow.output))
        end
    end
}

for i = 1, 3 do --"main loop"
    link.broadcast(nil, protoName, {type = "request"})
    os.sleep(1)
end

--unregister proto on close programm(this step is required)
link.protocols[protoName] = nil