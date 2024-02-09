
local aapi = {}
local aapi_core = aapi
local dbgwindow = nil
--DebugLogFiles = "/"
--DebugInstance = "nullnullnull"
function aapi.initDebug(path,win)
    local DebugInstance = math.random(10000, 99999)
    local filename = "debug-" .. os.date("%F") .. "-" .. DebugInstance .. ".txt"
    DebugLogFiles = textutils.serialize(path .. filename)
    fs.makeDir(path)
    Debugmode = true
    aapi.dbg("Debug file at: " .. DebugLogFiles)
    if win == nil then
        dbgwindow = win
    else
        dbgwindow = nil
    end
    sleep(1)
end
function aapi.initLogs(path)
    local CmdInstance = math.random(10000, 99999)
    local filename = "cmd-" .. os.date("%F") .. "-" .. CmdInstance .. ".txt"
    fs.makeDir(path)
    sleep(1)
    return(textutils.serialize(path .. filename))  
end 
function aapi.dbg(msg)
    if Debugmode == true then
        local window = dbgwindow or term.native()
        aapi.cprint(window,"Dbg",msg,DebugLogFiles)
    end
end
function aapi.log(window, path, msg)
    aapi.cprint(window, "Log", msg, path)
end
function aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
    local msg = nil
    local complete = require("cc.completion")
    local function confo(msg)
        if confirm == true then
            aapi.cprint(window, sender, "Please retype your entry to confirm..", nil, speed)
            print()
            local confi = read()
            if confi == msg then
                return (msg)
            else
                aapi.cprint(window, sender, "Entries do not match.. Try again", nil, speed)
                sleep(1)
                aapi.uinput(window, sender, speed, allow, confirm, autocomplete, password)
            end
        else
            return (msg)
        end
    end

    local allowlist = {
        num = function()
            if tonumber(msg) ~= nil then
                confo(msg)
            else
                aapi.cprint(window,sender,"Invalid entry.. Please only use numbers",nil,speed)
                sleep(1)
                aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
            end
        end,
        abc = function()
            if tonumber(msg) == nil then
                confo(msg)
            else
                aapi.cprint(window, sender, "Invalid entry.. Please only use Letters and Symbols", nil, speed)
                sleep(1)
                aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
            end
        end,
        none = function()
            confo(msg)
        end,
        sallow = function()
            if msg == allow then
                confo(msg)
            else
                aapi.cprint(window, sender, "Invalid entry.. Please try again...", nil, speed)
                aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
            end
        end,
        tallow = function()
            local pass = false
            for i = 1,#allow do
                if msg == allow[i] then
                    pass = true

                end
            end
            if pass == false then
                aapi.cprint(window, sender, "Invalid entry.. Please try again...", nil, speed)
                aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
            end
        end
    }
    --if allow == nil then
    --     atype = "none"
    -- elseif type(allow) == "table" then
    --     atype = "tallow"
    -- elseif type(allow) == "string" then
    --     for key, value in pairs(allowlist) do
    --         if allow == value then
    --             atype = allow 
    --         end
    --     end
    --     if atype == nil then
    --         atype = "sallow"
        --     end
    --end
    --if window == nil then
    --    window = term.native()
    --end
    --term.redirect(window)
    local x, y = term.getCursorPos()
    aapi.dbg("Cursor Y: "..y)
    term.setCursorPos(1,y+1)   
    if autocomplete == true then
        if type(allow) == "table" then
            aapi.cprint()
            msg = read(nil, nil, function(text) return complete.choice(text, allow) end)
        else
            return
        end
    else
        aapi.cprint()
        msg = read()
    end
    if password == true then
        
    end
    if msg == nil then
        aapi.cprint(window,sender,"No input detected.. Please try again",nil,speed)
        sleep(1)
        aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
    else
        if allow then
            allowlist[allow]()
        end
        return(msg)
    end
end
function aapi.cprint(window, sender, msg, log, speed)
    if window == nil then
        window = term.native()
    end
    local types = {
        api = {
            colors.red,
            os.date("%R").." [AAPI]   "
        },
        con = {
            colors.green,
            os.date("%R").." [CONSOLE]   "
        },
        net = {
            colors.blue,
            os.date("%R").." [NETWORK]   "
        },
        dis = {
            colors.yellow,
            os.date("%R").." [DISPLAY]   "
        },
        set = {
            colors.orange,
            os.date("%R").." [SETUP]   "
        },
        log = {
            colors.pink,
            os.date("%R").." [LOG]   "
        },
        dbg = {
            colors.lightBlue,
            os.date("%R").." [DEBUG]   "            
        },
        eve = {
            colors.blue,
            os.date("%R").." [EVE]   "
        },
        user = {
            colors.orange,
            os.date("%R").." [USER]   "
        }
    }
    local list = {
        "api",
        "con",
        "net",
        "dis",
        "set",
        "log",
        "dbg",
        "eve",
        "user"
    }
    local last = term.current()
    local color = nil
    local send = nil
    local onlist = false
    for i = 1, #list do
        if list[i] == sender then
            onlist = true
        end
    end
    if onlist == true then
        color = types[string.lower(sender)][1]
        send = types[string.lower(sender)][2]
    elseif sender == nil then
        color = colors.white
        send = "  "
    else
        color = colors.white
        send = os.date("%R").." ["..string.upper(sender).."]   "  
    end
    
    -- if sender ~= "null" then 
    --     color = types[string.lower(sender)][1]
    -- else
    --     color = colors.white
    -- end
    -- if types[string.lower(sender_)][2] then 
    --     send = types[string.lower(sender)][2]
    -- else
    --     send = os.date("%R").." [MSG]   "
    -- end
    term.redirect(window)
    local x,y = term.getCursorPos()
    term.setTextColor(color)
    write(send)
    term.setTextColor(colors.white)
    if speed == nil then
        if msg == nil then
            write("   ")
        else
            write(msg)
        end
    else
        if msg == nil then
            write("   ")
        else
            textutils.slowWrite(msg, speed)
        end
    end
    term.redirect(last)
    if log ~= nil then
        local f_ = fs.open(log, "a")
        f_.writeLine(textutils.formatTime(os.time("local"),true) .. ": " .. msg)
        f_.close()
    end
    term.setCursorPos(1,y+1)  
end
function aapi.PeripheralSetup()
    AttachedPer = {}
    Persave = {}
    Gvarnames = {}
    local PeripheralList = peripheral.getNames()
    for i = 1, #PeripheralList, 1 do
        local pname = peripheral.getType(PeripheralList[i])
        AttachedPer[pname] = {}
        Persave[pname] = {}
        local dbgname = pname .. "ct"

        aapi.dbg("Peripheral class " .. peripheral.getType(PeripheralList[i]) .. " Found..")
        aapi.dbg("Variable " .. dbgname .. " Created..")
        sleep(0.1)
    end
    --print("-----")
    PeripheralList = peripheral.getNames()
    sleep(2)
    for i = 1, #PeripheralList do
        local type = peripheral.getType(PeripheralList[i])
        local count = #AttachedPer[type] + 1
        local wrap = peripheral.wrap(PeripheralList[i])
        sleep(.1)
        local name = peripheral.getName(wrap)
        --local gvarname = _G['fname .. "ct"']
        --print(textutils.serialize(wrap))
        AttachedPer[type][count] = {}
        AttachedPer[type][count]["name"] = name
        AttachedPer[type][count]["wrap"] = wrap
        Persave[type][count] = {}
        Persave[type][count]["name"] = name
        _G['name'] = wrap
        aapi.dbg(name .. " of type " .. type .. " Initialized.. This is number: " .. count)
        sleep(0.1)
    end
    aapi.dbg("Peripheral Init Done..")
end

function aapi.Pertype(type)
    local table_ = {}
    local count_ = 0
    if AttachedPer ~= nil then
        for key, value in pairs(AttachedPer) do
            if type == key then
                aapi.dbg("Match FOUND: " .. key .. "/" .. type)
                --print(textutils.tabulate(value[1]))
                for count, data in pairs(value) do
                    aapi.dbg(data["name"] .. " added to Perlist " .. type)
                    local wrapp = data["wrap"]
                    local name = data["name"]
                    --print(wrapp)
                    _G[name] = wrapp
                    table.insert(table_, wrapp)
                    --table.insert(table_,wrapp,count_)
                end
            elseif Debugmode == true then
                --aapi.dbg("No Match: "..key.."/"..type)
                --aapi.dbg(value[1])
                --aapi.dbg(type)
            end
        end
    else
        table_ = { nil, nil }
    end
    print(table_)
    return (table_)
end
function aapi.FM(operation,file,data)
    local value = nil
    local ops = {
        initialize = function ()
            if fs.exists(file) then
                local f = fs.open(file, "r")
                if f == nil then
                    aapi.dbg("Error: ".. file.." is nil")
                    return
                end
                value = f.readAll()
                f.close()
            else
                fs.makeDir(file)
                value = {}      
            end
        end,
        save = function ()
            local f = fs.open(file, "w")
            for i = 1, #data do
                f.writeLine(data[i])
            end
            f.close()
            value = 1
        end,
        load = function()
            local f = fs.open(file, "r")
            if f == nil then
                aapi.dbg("Error: ".. file.." is nil")
                return
            end
            value = f.readAll()
            f.close()
        end,
    }
    ops[operation]()
    return(value)
end
--function aapi.Per(peripher)
--    for key, value in pairs(AttachedPer) do
--        if type == value then
--            local address = ("aapi." .. value[type .. "ct"]["name"])
--            count_ = count_ + 1
--            table.insert(table_, address, count_)
--        end
--   end
--end

return aapi_core