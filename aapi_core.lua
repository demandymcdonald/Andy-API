
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
    local msg = "nullnullnull"
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
            for i = 1, #allow do
                if msg == allow[i] then
                    pass = true
                end
            end
            if pass == false then
                aapi.cprint(window, sender, "Invalid entry.. Please try again...", nil, speed)
                aapi.uinput(window, sender, speed, allow, confirm, autocomplete, password)
            end
        end,
        yn = function()
            local cleaned = string.lower(msg)
            if cleaned == "yes" or "y" or "no" or "n" then
                if cleaned == "yes" or "y" then
                    confo(true)
                else
                    confo(false)
                end
                confo(msg)
            else
                aapi.cprint(window, sender, "Invalid entry.. Please respond with either: y, yes, n, or no", nil, speed)
                aapi.uinput(window, sender, speed, allow, confirm, autocomplete, password)
            end               
        end,
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
    --aapi.dbg("Cursor Y: "..y)
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
    elseif type(msg) ~= "string" then
        aapi.cprint("Invalid entry detected, please try again..")
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
    local color = colors.gray
    if sender == nil then
        sender = "MSG"
    end
    local sname = os.date("%R") .. "[" .. sender .. "]   "
    local slen = 0
    local mlen = 0
    if msg == nil then
        mlen = 0
    else
        mlen = string.len(textutils.serialize(msg))
    end

    local tlen = 0
        local types = {
        api = {
                colors.red,
                os.date("%R") .. " [AAPI]   ",
                "api"
            },
            con = {
                colors.green,
                os.date("%R") .. " [CONSOLE]   ",
                "con"
            },
            net = {
                colors.blue,
                os.date("%R").." [NETWORK]   ",
                "net"
            },
            dis = {
                colors.yellow,
                os.date("%R") .. " [DISPLAY]   ",
                "dis"
            },
            set = {
                colors.orange,
                os.date("%R") .. " [SETUP]   ",
                "set"
            },
            log = {
                colors.pink,
                os.date("%R").." [LOG]   ",
                "log"
            },
            dbg = {
                colors.lightBlue,
                os.date("%R").." [DEBUG]   ",            
                "dbg"
            },
            eve = {
                colors.blue,
                os.date("%R").." [EVE]   ",
                "eve"
            },
            user = {
                colors.orange,
                os.date("%R").." [USER]   ",
                "user"
            },
        }
    for key, type in pairs(types) do
        if type[3] == string.lower(sender) then
            color = type[1]
            sname = type[2]
        end
    end
    slen = string.len(sname)
    tlen = slen + mlen
    -- Begin Writing
    if window == nil then
        window = term.native()
    end
    local tmsg = {}
    local x, y = window.getCursorPos()
    local mx, my = window.getSize()

    local function linebreak()
        local numlines = 1
        local lstart = 1
        local lend = 0
        if tlen > mx then
            numlines = math.max(tlen / mx)
            lend = (mx - slen - 1)
            for i = 1, numlines do
                local lline = nil
                if i ~= 1 then
                    lstart = lend
                    lend = lstart+mx-1
                end
                lline = string.sub(msg, lstart, lend) .. "-"
                table.insert(tmsg,lline)  
            end
        else
            table.insert(tmsg,msg)  
        end
    end
    window.setCursorPos(1, y + 1)
    if y + 1 >= my then
        window.scroll(1)
    end
    window.setTextColor(color)
    --if speed == 0 or nil then
    if msg then
        linebreak()
        window.write(sname)
        if #tmsg > 1 then
            window.setTextColor(colors.white)
            for i = 1, #tmsg do
                window.write(tmsg[i])
                window.setCursorPos(1, y + i)
            end
        else   
            window.setTextColor(colors.white)
            window.write(msg)
        end
    else
        return
    end
    -- else
    --     if msg then
    --         window.write(sname)
    --         window.setTextColor(colors.white)
    --         window.slowWrite(msg,speed)
    --     else
    --         return
    --     end
    -- end
    if log ~= nil then
        local f_ = fs.open(log, "a")
        f_.writeLine(textutils.formatTime(os.time("local"),true) .. ": " .. msg)
        f_.close()
    end
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
        save = function()
            aapi.dbg("Saving "..file.."...")
            local f = fs.open(file, "w")
            for i = 1, #data do
                local tosave = textutils.serialize(data[i])
                f.writeLine(tosave)
                aapi.dbg(string.sub(tosave,1,15).." saved")
            end
            f.close()
            value = 1
        end,
        load = function()
            aapi.dbg("Loading "..file.."...")
            local f = fs.open(file, "r")
            if f == nil then
                aapi.dbg("Error: " .. file .. " is nil")
                return
            end
            
            local prevalue = f.readAll() or '"null"'
            aapi.dbg(prevalue)
            value = textutils.unserialize(prevalue)
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