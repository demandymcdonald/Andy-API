Aapi = require("aapi_core")
local DebugLogFiles = "SpawnManager/debuglogs/"
Aapi.initDebug(DebugLogFiles)
Aapi.dbg("hello world")
Debugmode = true
Aapi.PeripheralSetup()
PD = AAPI.Pertype("playerDetector")
Playersinspawn = {}
function PlayerFinder()
    local players = PD.getPlayersInRange(100)           
    if players then
        for i = 1, #players do
            --if players[i] ~= "Wolf_Obsidio" then
            commands.exec("gamemode adventure " .. players[i])
            table.insert(Playersinspawnm, players[i])
            --end
        end
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
            commands.exec("gamemode adventure " .. Playersinspawn[i])
            table.remove(Playersinspawn, i)
        end
    end
    sleep(5)
end
while true do
    PlayerFinder()
end