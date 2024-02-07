Aapi = require("aapi_core")
local DebugLogFiles = "SpawnManager/debuglogs/"
Aapi.initDebug(DebugLogFiles)
Aapi.dbg("hello world")
Debugmode = true
Aapi.PeripheralSetup()
PD = Aapi.Pertype("playerDetector")
Playersinspawn = {}
function PlayerFinder()
    local players = nil
    for a = 1,#PD do
        players = PD[a].getPlayersInRange(100) 
    end    
    if players then
        Aapi.dbg("Players in Spawn Area:")
        for i = 1, #players do
            Aapi.dbg(players[i])
            --if players[i] ~= "Wolf_Obsidio" then
            commands.exec("gamemode adventure " .. players[i])
            table.insert(Playersinspawn, players[i])
            --end
        end
    end
    for i = 1, #Playersinspawn do
        local here = false
        for e = 1, #players do
            if Playersinspawn[i] == players[e] then
                here = true
                Aapi.dbg(Playersinspawn[i].." is still in spawn")
                break
            end
        end
        if here == false then
            Aapi.dbg(Playersinspawn[i].." has left spawn")
            commands.exec("gamemode survival " .. Playersinspawn[i])
            table.remove(Playersinspawn, i)
        end
    end
    sleep(5)
end
while true do
    PlayerFinder()
end