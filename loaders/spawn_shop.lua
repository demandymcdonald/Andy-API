
function Boot()
    shell.run("delete aapi_loader.lua")
    shell.run("pastebin get gWaWXz2q aapi_loader.lua")
    local loader = require("aapi_loader")
    loader.setVersion("d")
    loader.update()
    loader.core()
    loader.display()
    loader.custom("products/adminshop.lua", "adminshop.lua")
    sleep(1)
    term.clear()
    term.setCursorPos(1,1)
end
Boot()
shell.run("adminshop")
