Aapi = require("aapi_core")
print("Hello World")
local DebugLogFiles = "SpawnManager/debuglogs/"
Aapi.initDebug(DebugLogFiles)
Aapi.dbg("hello world")
Debugmode = true
Aapi.PeripheralSetup()
print("test2")