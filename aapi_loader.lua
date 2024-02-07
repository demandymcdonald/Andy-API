
F = {}

function F.setVersion(version)
    BeenRun = false
    print("[LOADER]  Version set to: " .. version)
    if version == "m" then
        Version = "m"
    elseif version == "d" then
        Version = "d"
    end
end
function F.git()
    if BeenRun == false then
        if fs.exists("/gitapi.lua") then
            Git = require("gitapi")
            if Version == "m" then
                Git.get("demandymcdonald", "Andy-API", "main", "git.lua", "gitapi_tmp.lua")
            elseif Version == "d" then
                Git.get("demandymcdonald", "Andy-API", "InDev", "git.lua", "gitapi_tmp.lua")
            end
            shell.run("delete gitapi.lua")
            shell.run("rename /gitapi_tmp.lua /gitapi.lua")
            shell.run("delete gitapi_tmp.lua")
            Git = require("gitapi")
            sleep(1)
        else
            print("[LOADER]   Downloading GitHub Integration...")
            shell.run("pastebin get Zv4fpxuj gitapi.lua")
            sleep(1)
            print("[LOADER]   Download Successful..")
            Git = require("gitapi")
            F.git()
        end
        BeenRun = true
    end
end
function F.update()
    if Version == "m" then
        Git.get("demandymcdonald", "Andy-API", "main", "git.lua", "aapi_loader_tmp.lua")
    elseif Version == "d" then
        Git.get("demandymcdonald", "Andy-API", "InDev", "git.lua", "aapi_loader_tmp.lua")
    end
    shell.run("delete aapi_loader.lua")
    shell.run("rename /aapi_loader_tmp.lua /aapi_loader.lua")
    shell.run("delete aapi_loader_tmp.lua")
    print("[LOADER] AAPI_Loader is Up-To-Date")
end
function F.core()
    F.git()
    print("[LOADER]  Initializing AAPI_Core...")
    shell.run("delete aapi_core.lua")
    if Version == "m" then
        Git.get("demandymcdonald", "Andy-API", "main", "aapi_core.lua", "aapi_core.lua")
    elseif Version == "d" then
        Git.get("demandymcdonald", "Andy-API", "InDev", "aapi_core.lua", "aapi_core.lua")
    end
    Aapi = require("aapi_core")
end
function F.display()
    F.git()
    print("[LOADER]  Initializing AAPI_Display...")
    shell.run("delete aapi_display.lua")
    if Version == "m" then
        Git.get("demandymcdonald", "Andy-API", "main", "aapi_core.lua", "aapi_display.lua")
    elseif Version == "d" then
        Git.get("demandymcdonald", "Andy-API", "InDev", "aapi_core.lua", "aapi_display.lua")
    end
    Disp = require("aapi_display")
end
function F.net()
    F.git()
    print("[LOADER]  Initializing AAPI_Network...")
    shell.run("delete aapi_net.lua")
    if Version == "m" then
        Git.get("demandymcdonald", "Andy-API", "main", "aapi_net.lua", "aapi_net.lua")
    elseif Version == "d" then
        Git.get("demandymcdonald", "Andy-API", "InDev", "aapi_net.lua", "aapi_net.lua")
    end
    Net = require("aapi_net")
end
function F.sound()
    F.git()
    print("[LOADER]  Initializing AAPI_Sound...")
    shell.run("delete aapi_sound.lua")
    if Version == "m" then
        Git.get("demandymcdonald", "Andy-API", "main", "aapi_net.lua", "aapi_sound.lua")
    elseif Version == "d" then
        Git.get("demandymcdonald", "Andy-API", "InDev", "aapi_net.lua", "aapi_sound.lua")
    end
    Sound = require("aapi_sound")
end
function F.user()
    F.git()
    print("[LOADER]  Initializing AAPI_User...")
    shell.run("delete aapi_user.lua")
    if Version == "m" then
        Git.get("demandymcdonald", "Andy-API", "main", "aapi_user.lua", "aapi_user.lua")
    elseif Version == "d" then
        Git.get("demandymcdonald", "Andy-API", "InDev", "aapi_net.lua", "aapi_user.lua")
    end
    Sound = require("aapi_user")
end
local aapi_loader = F
return aapi_loader
