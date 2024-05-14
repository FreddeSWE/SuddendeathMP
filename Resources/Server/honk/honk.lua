
local suddenDeath = false --is sudden death active

local isHonking = {} --table to hold who is honking

local defaultInterval = 10 --default interval that suddendeathinterval can return to
local suddenDeathTimer = 0 --let's start at 0
local suddenDeathInterval = 10 --how long after starting will honks begin
local suddenDeathMax = 60 --how long after honks start will sudden death end
local suddenDeathWarn = 5 --how many seconds before the end of max time will players be warned about honking

local initID = nil
local honkNotified = false --have we told everyone that it is honking time

function onInit()
    --server provided events
    MP.RegisterEvent("onPlayerJoin","onPlayerJoinHandler") --when a player joins
    MP.RegisterEvent("onPlayerDisconnect","onPlayerDisconnectHandler") --when a player disconnects
    MP.RegisterEvent("onChatMessage", "onChatMessageHandler") --when a player sends a chat message
    --our custom events(s)
    MP.RegisterEvent("onTick", "onTickHandler") --basic event to tick
    MP.CreateEventTimer("onTick", 1000) --tick rate, onTick will be called every 1000ms
    print("Sudden Death Loaded!") --tell server console we have loaded
end

function onTickHandler() --every second
    if suddenDeath then --check if it is sudden death
        suddenDeathTimer = suddenDeathTimer + 1 --increment our timer by 1 second
        if suddenDeathTimer >= suddenDeathMax + suddenDeathInterval then --if sudden death has gone on longer than 5 minutes
            suddenDeathTimer = 0 --reset the timer
            suddenDeath = false --turn off suddenDeath
            honkNotified = false --reset the notification
            suddenDeathInterval = defaultinterval --reset to default interval
            initID = nil --reset initializing ID so that a new ID can be stored when a new sudden death is started
            MP.SendChatMessage(-1, "Sudden Death has been stopped") --tell everyone sudden death has stopped
            return
        end
            if suddenDeathTimer >= suddenDeathInterval then --if it has been more than 10 seconds
                if not honkNotified then --if we have not notified everyopne that it is honking time
                    MP.SendChatMessage(-1, "Its honking time!") --tell everyone that it is honking time
                    honkNotified = true
                end
                if suddenDeathTimer % 2 == 0 then --if the timer's value divided by 2 leaves no remainder
                    for player_id in pairs(MP.GetPlayers()) do --for each player on the server
                        if player_id ~= initID then -- if player_id doesn't match the ID of the person initializing the command then send honk
                            randomHonk(player_id) --send their player_id to randomHonk() down there --v  
                        end

                    end
                end
            elseif suddenDeathTimer >= suddenDeathInterval - suddenDeathWarn then --otherwise, if there are 5 or fewer seconds remaining in sudden death
                MP.SendChatMessage(-1, "Sudden Death starts in " .. tostring(suddenDeathInterval - suddenDeathTimer) .. " seconds") --tell everyone how much time before honking commences
            end
    end
end

function randomHonk(player_id) --it's time to honk
    if suddenDeath then --if sudden death is active
        if not isHonking[player_id] then --if the player is not honking
            local chance = math.random(1,10) --get us a random number
            if chance >= 6 then --if high value
                MP.TriggerClientEvent( player_id, "honk", "true" ) --this player will honk true
            else --must be low value
                MP.TriggerClientEvent( player_id, "honk", "false" ) --this player will not honk false
            end
            isHonking[player_id] = true --mark player as honking
        else
            isHonking[player_id] = false --mark player as not honking
        end
    else
        isHonking[player_id] = false --mark player as no longer honking
    end
end

function onPlayerJoinHandler(player_id)
    isHonking[player_id] = false --player starts out not honking
end

function onPlayerDisconnectHandler(player_id)
    isHonking[player_id] = nil --player has left server, remove entry so we can use it for another player later
end

function onChatMessageHandler(player_id, player_name, message)
    if message == "/suddendeath" or message == "/sd" then --check for command, or short alias
        if not suddenDeath then --if sudden death is not already running
            MP.SendChatMessage(-1, player_name .. " has started a Sudden Death timer!") --tell everyone who started the timer
            initID = player_id
            suddenDeathInterval = defaultInterval
            suddenDeath = true --turn on sudden death
        else
            MP.SendChatMessage(player_id, "Sudden Death is already in progress.") --if sudden death is already on, tell the player that tried to start it that it is already active
        end
        return 1 --suppress chat message
    elseif string.match(message, "^/suddendeath %d+") or string.match(message, "^/sd %d+") then
        interval = tonumber(string.match(message, "%d+")) * 60 --convert interval to minutes
        if interval > 1800 then -- if interval is more than 30 minutes, default to 30 minutes
            interval = 1800
            MP.SendChatMessage(player_id, "Sudden Death can only be 30 minutes at most, defaulting to 30 minutes.")
        end
        if not suddenDeath then --if sudden death is not already running
            suddenDeathInterval = interval --set interval to input interval, set in minutes
            MP.SendChatMessage(-1, player_name .. " has started a Sudden Death timer!") --tell everyone who started the timer
            MP.SendChatMessage(-1, "Sudden Death will start in: " .. interval/60 .. " minutes") --tell everyone who started the timer
            initID = player_id
            suddenDeath = true --turn on sudden death
        else
            MP.SendChatMessage(player_id, "Sudden Death is already in progress.") --if sudden death is already on, tell the player that tried to start it that it is already active
        end
        return 1 --suppress chat message
    end
    if message == "/stop" then
        suddenDeathTimer = 0 --reset the timer
        suddenDeath = false --turn off sudden death
        honkNotified = false --reset the notification
        suddenDeathInterval = defaultInterval --reset to default interval
        MP.SendChatMessage(-1, "Sudden Death has been stopped") --tell everyone sudden death has stopped
        initID = nil
        return 1 --suppress chat message
    end
end
