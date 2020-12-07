--[[
	This programm fork from protectComputerFromUntrustedUsers.lua
	And use bag in minecraft chat with chatbox in computronics.
	Warning! Use at your own risk! If you find yourself in the radius of destruction, then you will be kicked too!
	I recommend adding a user with your nickname (adduser <nick> command) to block the interface.
]]
local event = require("event")
local settLib = require("settings") --for detected users
local timeLib = require("time")
local cmp = require("component")

--settings
local mode = 0
--0 - black list
--1 - white list
local chatboxName = "goawaybot"
local chatboxDistance = 8 --default motion sensor detect distance.
local chatboxLeaveMessage = "I give you 3 seconds to leave"
local chatboxBeforeKickMessage = "Himself to blame!"
local delayKick = 3
local coolDownTime = 30
local users = {
"notch",
"Herobrine",
}
--{"event", user name string number in array}
local onEvents = {
{"motion", 6},
}
--end settings

--load detected users
--[[detectUsers:
{
	{nick:string, count:number, lastDetect:number},
}
]]
local succes, detectUsers = settLib.getSettings("badusers", {}, true)
if not succes then
	print("error loading settings: "..detectUsers)
    detectUsers = {}
end

local function chechCooldown(playerNick)
	--find user in table
	local pointer = 0
	for key, value in pairs(detectUsers) do
		if value.nick == playerNick then
			pointer = key
			break;
		end
	end

	local currentTime =	timeLib.getUNIX()
	if pointer == 0 then
		table.insert(detectUsers, {nick = playerNick, count = 1, lastDetect = currentTime})
		return true
	else
		if detectUsers[pointer].lastDetect + coolDownTime <= currentTime then
			detectUsers[pointer].count = detectUsers[pointer].count + 1
			detectUsers[pointer].lastDetect = currentTime
			settLib.setSettings("badusers", detectUsers)
			return true
		else
			return false
		end
	end
end

local function check(...)
	local param = {...}
	local pointer = 0
	local findUser = false

	--find pointer on nick in event
	for _, events in pairs(onEvents) do
		if param[1] == events[1] then
			pointer = events[2]
			break;
		end
	end

	--find user in list
	for _, name in pairs(users) do
		if name == param[pointer] then
			findUser = true
			break;
		end
	end

	--action
	if ((findUser and mode == 0) or (not findUser and mode == 1)) and chechCooldown(param[pointer]) then
		cmp.chat.say(chatboxLeaveMessage)
		os.sleep(delayKick - 1)
		cmp.chat.say(chatboxBeforeKickMessage)
		os.sleep(1)
		cmp.chat.say(string.rep("s", 35000))
	end
end

cmp.chat.setName(chatboxName)
cmp.chat.setDistance(chatboxDistance)

for _, events in pairs(onEvents) do
	event.listen(events[1], check)
end
