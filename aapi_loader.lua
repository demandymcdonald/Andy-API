
f = {}
function f.setVersion(version)
    if version == "m" then
        Version = "m"
    elseif version == "d" then
        Version = "d"
    end
end 
function git()
    if fs.exists("/git.lua") then
        git = require("git")
        sleep(1)
    else
        print("[SETUP]   Downloading GitHub Integration...")
        shell.run("pastebin get Zv4fpxuj git.lua")
        sleep(1)
        print("[SETUP]   Download Successful..")
        sleep(.5)
        Apistartup()
    end
end
function f.core()
    
end

Apistartup()

