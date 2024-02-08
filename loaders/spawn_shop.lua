
function Boot()
    shell.run("delete aapi_loader.lua")
    shell.run("pastebin get gWaWXz2q aapi_loader.lua")
    local loader = require("aapi_loader")
    loader.setVersion("d")
    loader.update()
    loader.core()
    loader.custom("products/adminshop.lua","adminshop.lua")
end
Boot()
shell.run("adminshop")
