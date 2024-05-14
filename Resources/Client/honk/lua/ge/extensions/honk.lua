
local M = {}

math.randomseed(os.time()) --let's get a random seed so that use of math.random() doesn't always start with the same value

local shouldHonk = false --has the server said we should honk
local hasHonked = false --have we honked

local honkTimer = 0 --initial vlaue
local honkLength = math.random(1,10) * 0.2 --initial value

local function honk(randomChance) --called from server
	if randomChance == "true" then
		shouldHonk = true --this player should honk
		hasHonked = false --let's make sure they're in  as tate where they haven't 
		honkTimer = 0 --reset the timer
		honkLength = math.random(1,10) * 0.2 --how long this honk should last
	elseif randomChance == "false" then
		shouldHonk = false --this player should not honk
		hasHonked = false --let's make sure they're in  as tate where they haven't 
	end
end

local function onUpdate(dt) --every update
	if shouldHonk then --if we should honk
		honkTimer = honkTimer + dt --increment the honk timer
		if honkTimer >= honkLength then --if longer than random honk length
			local veh = be:getPlayerVehicle(0) --get the currently focused vehicle
			if veh then --if there is a vehicle
				veh:queueLuaCommand('electrics.horn(false)') --tell that vehicle to stop honking
				shouldHonk = false --should no longer honk
				hasHonked = false --reset state
			end
		elseif not hasHonked then --otherwise if we have not honked yet
			local veh = be:getPlayerVehicle(0) --get the currently focused vehicle
			if veh then --if there is a vehicle
				veh:queueLuaCommand('electrics.horn(true)') --tell that vehicle to start honking
				hasHonked = true --set state
			end
		end
	end
end

local function onExtensionLoaded()
	AddEventHandler("honk", honk) --add the event so we can call it from the server
	log('W', 'honk', 'honk LOADED!')
end

local function onExtensionUnloaded()
	log('W', 'honk', 'honk UNLOADED!')
end

M.onUpdate = onUpdate

M.onInit = function() setExtensionUnloadMode(M, 'manual') end

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

return M
