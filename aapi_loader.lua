
F = {}
function F.setVersion(version)
    if version == "m" then
        Version = "m"
    elseif version == "d" then
        Version = "d"
    end
end
function F.git()
    if fs.exists("/git.lua") then
        git = require("git")
        sleep(1)
    else
        print("[SETUP]   Downloading GitHub Integration...")
        shell.run("pastebin get Zv4fpxuj git.lua")
        sleep(1)
        print("[SETUP]   Download Successful..")
        sleep(.5)
    end
end
function F.core()
    
    F.git()
    if Version == "m" then
        git.get("demandymcdonald","Andy-API","main","aapi_core.lua","aapi_core.lua")
    elseif Version == "d" then
        git.get("demandymcdonald","Andy-API","InDev","aapi_core.lua","aapi_core.lua")
    end
    Aapi = require("aapi_core")
end

return F
