
f = {}
<<<<<<< Updated upstream
function f.setVersion(version)
=======
function f.selver(version)
>>>>>>> Stashed changes
    if version == "m" then
        Version = "m"
    elseif version == "d" then
        Version = "d"
    end
<<<<<<< Updated upstream
end 
function git()
=======
end
function f.git()
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    
=======
    if Version == "m" then
        
    elseif Version == "d" then

    end
>>>>>>> Stashed changes
end

Apistartup()

