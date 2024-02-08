Aapi = require("aapi_core")
local DebugLogFiles = "SpawnManager/debuglogs/"
Aapi.initDebug(DebugLogFiles)
Aapi.dbg("hello world")
Debugmode = true
Aapi.PeripheralSetup()
PD = Aapi.Pertype("playerDetector")
Playersinspawn = {}
function PlayerFinder()
    local players = {}
    for a = 1,#PD do
        local tplayers = PD[a].getPlayersInRange(100)
        for i=1,#tplayers do
            table.insert(players,tplayers[i])
        end 
    end    
    if players then
        Aapi.dbg("Players in Spawn Area:")
        for i = 1, #players do
            Aapi.dbg(players[i])
            --if players[i] ~= "Wolf_Obsidio" then
                commands.exec("gamemode adventure " .. players[i])
                table.insert(Playersinspawn, players[i])
            --end
            commands.exec("effect give " .. players[i] .. " minecraft:regeneration 10")
            commands.exec("effect give ".. players[i].." minecraft:saturation 10")
        end

        for i = 1, #Playersinspawn do
            local here = false
            for e = 1, #players do
                if Playersinspawn[i] == players[e] then
                    here = true
                    break
                end
            end
            if here == false then
                commands.exec("gamemode survival " .. Playersinspawn[i])
                table.remove(Playersinspawn, i)
            end
        end
    end
    sleep(5)
end
while true do
    PlayerFinder()
end