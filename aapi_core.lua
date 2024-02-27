
local aapi = {}
local aapi_core = aapi
local dbgwindow = nil
local gitbeenrun = false
--DebugLogFiles = "/"
--DebugInstance = "nullnullnull"
-- Used to initialize the Debug mode. Path: Path to create a debug log file | Win: window to display debug messages, defaults to the terminal 
function aapi.initDebug(path, win)
    local DebugInstance = math.random(10000, 99999)
    local test = nil
    local filename = "debug-" .. os.date("%F") .. "-" .. DebugInstance .. ".txt"
    DebugLogFiles = textutils.serialize(path .. filename)
    local free = aapi.FM("freespace", path)[1]
    if free < .9 then
        fs.makeDir(path)
    end
    Debugmode = true
    aapi.dbg("Debug file at: " .. DebugLogFiles)
    if win == nil then
        dbgwindow = win
    else
        dbgwindow = nil
    end
    sleep(1)
end
-- Used to create a directory for logging specific messages. Path: Path to create a  log file
function aapi.initLogs(path)
    local CmdInstance = math.random(10000, 99999)
    local filename = "cmd-" .. os.date("%F") .. "-" .. CmdInstance .. ".txt"
    fs.makeDir(path)
    sleep(1)
    return (textutils.serialize(path .. filename))
end
-- Used to send a debug message, use initDebug prior to ensure it works. You also need to have DebugMode = true somewhere at the top of your program to make the message visible
function aapi.dbg(msg)
    if Debugmode == true then
        local window = dbgwindow or term.native()
        aapi.cprint(window, "Dbg", msg, DebugLogFiles)
    end
end
-- Use to add messages to a log. Win: window to display debug messages, defaults to the terminal | Path: Path to save the log in | msg: What you want to be logged
function aapi.log(window, path, msg)
    aapi.cprint(window, "Log", msg, path)
end
-- Allows for custom user input with validation. Win: window to display, defaults to the terminal | sender: who you want confirmation messages to come from (see cprint) | speed: speed at which you want confirmation messages to be sent | Allow: (see below) | confirm: true or false allows for confirmation of input prior to returning it | autocomplete: see cc:complete | password: true or false, allows for hiding of inputs
-- Allow accepts the following: A table with alllowed inputs, num (numeric inputs only), abc (string only, no number only entries), yn (allows yes, y, n, or no. Returns true or false based on yes or no)
-- NOTE: as a protective measure, uinput returns everything (including numbers and ints) as a string, use textutils.unserialise() to revert any output to its variable,int, or number form
function aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
    if window == nil then
        window = term.native()
        term.redirect(window)
    else
        term.redirect(window)
    end
    if allow == nil then
        allow = "none"
    end
	local msg = "nullnullnull"
    local complete = require("cc.completion")
	local mx,my = term.getSize()
    local x, y = term.getCursorPos()
    --aapi.dbg("Cursor Y: "..y)
    if y + 1 >= my then
        term.scroll(1)
        term.setCursorPos(1, my)
    else
        term.setCursorPos(1, y + 1)
    end
    local cpass = false
    local function confo(msg_)
        if confirm == true then
            aapi.cprint(window, sender, "Please retype your entry to confirm..", nil, speed)
            local confi = read()
            if confi == msg_ then
                cpass = true
            else
                aapi.cprint(window, sender, "Entries do not match.. Try again", nil, speed)
                sleep(1)
            end
        else
			aapi.dbg("Confo OPT: "..msg_)
            cpass = true
        end
    end
    local pass = false
    local passval = "nil"    
    local allowlist = {
        num = function()
            if tonumber(msg) ~= nil then
                pass = true
                passval = textutils.serialise(msg)
            else
                aapi.cprint(window,sender,"Invalid entry.. Please only use numbers",nil,speed)
                sleep(1)
                pass = false
            end
        end,
        abc = function()
            if tonumber(msg) == nil then
                pass = true
                passval = msg
            else
                aapi.cprint(window,sender,"Invalid entry.. Please only use letters",nil,speed)
                sleep(1)
                pass = false
            end
        end,
        none = function()
            confo(msg)
        end,
        tallow = function()
            local t = allow
            for i = 1, #t do
                if string.lower(msg) == string.lower(t[i]) then
                    pass = true
                    passval = t[i]
                end
            end
            if pass == false then
                aapi.cprint(window,sender,"Invalid entry.. Please try again",nil,speed)
                sleep(1)
            end
        end,
        yn = function()
			local alist = {"yes","y","n","no"}
			for i = 1,#alist do 
                if string.lower(msg) == string.lower(alist[i]) then
                    pass = true
                    if string.lower(alist[i]) == "yes" or string.lower(alist[i]) == "y" or string.lower(alist[i]) == "true" then
                        passval = "true"
                    else
                        passval = "false"
                    end
                end
            end
            if pass == false then
                aapi.cprint(window, sender, "Invalid entry.. Please respond with either: y, yes, n, or no", nil, speed)
                sleep(1)
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
	local mx,my = term.getSize()
    local x, y = term.getCursorPos()
    --aapi.dbg("Cursor Y: "..y)
    if y + 1 >= my then
        term.scroll(1)
        term.setCursorPos(1, my)
        --else
        --    term.setCursorPos(1, y + 1)
    end
    if allow == "none" then
        msg = read() or "nil"
        return
    end
    if autocomplete == true then
        if type(allow) == "table" then
            while pass == false do
                msg = read(nil, nil, function(text) return complete.choice(text, allow) end) or "null"
                allowlist["tallow"]()
            end
            while cpass == false do
                confo(passval)
            end
        else
            return
        end
    else
        while pass == false do
            if type(allow) == "table" then
                msg = read() or " "
                allowlist["tallow"]()
            else
                msg = read() or " "
                allowlist[allow]()
            end
        end
        while cpass == false do
            confo(passval)
        end        
    end
    if password == true then
        
    end
    -- if msg == " " then
    --     aapi.cprint(window,sender,"No input detected.. Please try again",nil,speed)
    --     sleep(1)
    --     aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
    -- elseif type(msg) ~= "string" then
    --     aapi.cprint("Invalid entry detected, please try again..")
    --     sleep(1)
    --     aapi.uinput(window, sender, speed, allow, confirm,autocomplete,password)
    -- else
    --     if allow then
    --         if type(allow) == "table" then
                
    --         else
    --             allowlist[allow]()
    --         end

    --     end
	-- 	if output == nil then
	-- 		aapi.dbg("Uinput Output: nil")
	-- 	else
	-- 		aapi.dbg("Uinput Output:"..output)
	-- 	end
        return(passval)
    -- end
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
	local numlines = 1
    local function linebreak()
        
        local lstart = 1
        local lend = 0
        if tlen + 1 > mx then
            numlines = math.ceil(tlen / mx)
            lend = (mx - slen - 1)
            for i = 1, numlines do
                local lline = nil
                if i ~= 1 then
                    lstart = lend+1
                    lend = lstart+mx-2
                end
                if i < numlines then
                    lline = string.sub(msg, lstart, lend)
                    local lastlet = string.sub(msg, lend, lend)
                    local nextlet = string.sub(msg, lend+1, lend+1)
                    if lastlet == " " or nextlet == " " then
                        table.insert(tmsg,lline)
                    else
                        lline = lline .. "-"
                        table.insert(tmsg,lline)  
                    end
				else
					lline = string.sub(msg, lstart, lend)
					table.insert(tmsg,lline)  
				end
            end
        else
            table.insert(tmsg,msg)  
        end
    end

    window.setTextColor(color)
    --if speed == 0 or nil then
    if msg then
        linebreak()
        window.write(sname)
        if numlines > 1 then
            for p = 1,numlines do
				window.setTextColor(colors.white)
                window.write(tmsg[p])
				local x, y = window.getCursorPos()
				if y + 1 >= my then
					window.scroll(1)
						window.setCursorPos(1, my)
				else
					window.setCursorPos(1, y + 1)
				end
            end
        elseif numlines == 1 then   
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
        if f_ == nil then
            
        else
            f_.writeLine(textutils.formatTime(os.time("local"),true) .. ": " .. msg)
            f_.close()            
        end
    end
    local x, y = window.getCursorPos()
    if y + 1 >= my then
        window.scroll(1)
			window.setCursorPos(1, my)
    else
		window.setCursorPos(1, y + 1)
	end
	sleep(.1)
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
        --sleep(.1)
        local name = peripheral.getName(wrap)
        --local gvarname = _G['fname .. "ct"']
        --print(textutils.serialize(wrap))
        AttachedPer[type][count] = {}
        AttachedPer[type][count]["name"] = name
        AttachedPer[type][count]["wrap"] = wrap
        Persave[type][count] = {}
        Persave[type][count]["name"] = name
        _G[name] = wrap
        aapi.dbg(name .. " of type " .. type .. " Initialized.. This is number: " .. count)
        --sleep(0.1)
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
    --print(table_)
    return (table_)
end
function aapi.FM(operation, file, data)
    local value = {}
    local ops = {
        initialize = function()
            if fs.exists(file) then
                local f = fs.open(file, "r")
                if f == nil then
                    aapi.dbg("Error: " .. file .. " is nil")
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
            aapi.dbg("Saving " .. file .. "...")
            local f = fs.open(file, "w")
            --for i = 1, #data do
            --    local tosave = textutils.serialize(data[i])
            --    f.writeLine(tosave)
            --    aapi.dbg(string.sub(tosave,1,15).." saved")
            --end
            f.write(textutils.serialize(data))
            f.close()
            value = 1
        end,
        load = function()
            aapi.dbg("Loading " .. file .. "...")
            local f = fs.open(file, "r")
            if f == nil then
                aapi.dbg("Error: " .. file .. " is nil")
                sleep(2)
                return
            else
                value = textutils.unserialize(f.readAll())
                aapi.dbg(f.readAll())
            end
            f.close()
        end,
        freespace = function()
            local free = fs.getFreeSpace(file)
            local cap = fs.getCapacity(file)
            local perfree = free / cap
            table.insert(value, perfree)
            table.insert(value, free)
            table.insert(value, cap)
        end,
        deleteolddebug = function()

            local files = fs.list(path)
            if data == nil then
                data = #files * .75
            end
            local function mysplit(inputstr, sep)
                if sep == nil then
                    sep = "%s"
                end
                local t = {}
                for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
                    table.insert(t, str)
                end
                return t
            end
            local datess = {}
            local oldest = {}
            local current = {}
            current["y"] = os.date("%Y")
            current["m"] = os.date("%m")
            current["d"] = os.date("%e")
            table.insert(oldest, current)
            local function tablesort()
                for i = 1, #files do
                    datess[files[i] .. "_"] = {}
                    local splittab = mysplit(files[i], "-")
                    datess[files[i] .. "_"]["n"] = files[i]
                    datess[files[i] .. "_"]["y"] = splittab[2]
                    datess[files[i] .. "_"]["m"] = splittab[3]
                    datess[files[i] .. "_"]["d"] = splittab[4]
                    datess[files[i] .. "_"]["h"] = splittab[5]
                    for i = 1, #oldest do
                        if datess[files[i] .. "_"]["y"] < oldest[i]["y"] then
                            table.insert(oldest, datess[files[i] .. "_"])
                        elseif datess[files[i] .. "_"]["m"] < oldest[i]["m"] then
                            table.insert(oldest, datess[files[i] .. "_"])
                            if #oldest >= data then
                                table.remove(oldest, i)
                            end
                        elseif datess[files[i] .. "_"]["d"] < oldest[i]["d"] then
                            table.insert(oldest, datess[files[i] .. "_"])
                            if #oldest >= data then
                                table.remove(oldest, i)
                            end
                        elseif #oldest >= data then
                            table.insert(oldest, datess[files[i] .. "_"])
                        end
                    end
                end
            end
            tablesort()
            tablesort()
            for i=1,#oldest do
                fs.delete(path..oldest[i]["n"])
            end
        end    

    }
    ops[operation]()
    return (value)
end
function aapi.contostand(type, data, unit)
    --convert all types of energy into FE and all types of temp into kelvin
    local result = 0
    local types = {
        temp = {
            k = function()
                result = data    
            end,
            c = function()
                result = data + 273.15
            end,
            f = function()
                result = ((data - 32) * 5 / 9 + 273.15)
            end,
        },
        energy = {
            fe = function()
                result = data
            end,
            rf = function()
                result = data
            end,
            j = function()
                result = data * 0.4
            end,
            eu = function()
                result = data * 4
            end,
        }
    }
    types[type][string.lower(unit)]()
    return(result)
end
-- The MIT License (MIT)
-- Copyright (c) 2018,2020 Thomas Mohaupt <thomas.mohaupt@gmail.com>

-- year: 2-digit (means 20xx) or 4-digit (>= 2000)
function aapi.datetime2epoch(second, minute, hour, day, month, year)
    local mi2sec = 60
    local h2sec = 60 * mi2sec
    local d2sec = 24 * h2sec
    -- month to second, without leap year 
    local m2sec = {
          0, 
          31 * d2sec, 
          59 * d2sec, 
          90 * d2sec, 
          120 * d2sec, 
          151 * d2sec, 
          181 * d2sec, 
          212 * d2sec, 
          243 * d2sec, 
          273 * d2sec, 
          304 * d2sec, 
          334 * d2sec }  
          
    local y2sec = 365 * d2sec
    local offsetSince1970 = 946684800
  
    local yy = year < 100 and year or year - 2000
  
    local leapCorrection = math.floor(yy/4) + 1  
    if (yy % 4) == 0 and month < 3 then
      leapCorrection = leapCorrection - 1
    end
    
    return offsetSince1970 + 
          second + 
          minute * mi2sec + 
          hour * h2sec + 
          (day - 1) * d2sec + 
          m2sec[month] + 
          yy * y2sec +
          leapCorrection * d2sec 
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
function aapi.timeout(name, time)
    aapi.dbg("Timer Started | ID:" .. name .. " | Time:" .. time)
    _G[name] = os.startTimer(time)
    while true do
        local event, timerID = os.pullEvent("timer")
        if timerID == _G[name] then break end
    end
end
function aapi.inactivitytimer(name, time)
    aapi.dbg("Timer Started | ID:" .. name .. " | Time:" .. time)
    _G[name] = os.startTimer(time)
    while true do
        local event, timerID = os.pullEvent()
        if event == "key" then
            --aapi.dbg("kp_timer reset")
            sleep(10)
            aapi.inactivitytimer(name, time)
        elseif event == "timer" then

            if timerID == _G[name] then aapi.dbg("Timer up") break end
        end
    end
end
function aapi.deccutoff(numb, length)
    local cval = "0"
    local final = "0"
    if type(numb) == "number" then
        cval = textutils.serialize(numb)
    else
        error("Value to Round is not a number")
    end
    local decimalloc, decloc = string.find(cval, ".")
    local shortened = nil
    if decimalloc then
        local shortened = string.sub(cval, decimalloc + 1, decimalloc + length)
        final = string.sub(cval, 1, decimalloc) .. shortened
    else
        final = cval
    end
    return (textutils.unserialize(final))
end
function aapi.gitget(cmd, gitfile, localfile, istemp)
    if Version == nil then
        Version = "m"
    end
    if gitbeenrun == false then
        if fs.exists("/gitapi.lua") then
            Git = require("gitapi")
            if Version == "m" then
                Git.get("demandymcdonald", "Andy-API", "main", "git.lua", "gitapi_tmp.lua")
            elseif Version == "d" then
                Git.get("demandymcdonald", "Andy-API", "InDev", "git.lua", "gitapi_tmp.lua")
            end
            shell.run("delete gitapi.lua")
            shell.run("rename /gitapi_tmp.lua /gitapi.lua")
            Git = require("gitapi")
            gitbeenrun = true
        else
            ---print("[LOADER]   Downloading GitHub Integration...")
            shell.run("pastebin get Zv4fpxuj gitapi.lua")
            ---print("[LOADER]   Download Successful..")
            Git = require("gitapi")
            gitbeenrun = true
        end
    else
        Git = require("gitapi")    
    end
    local cmds = {
        get = function()
            local localfile_ = nil
            if fs.exists(localfile) then
                shell.run("delete " .. localfile)
            end
            if istemp == false then
                localfile_ = localfile
            else
                if not fs.exists("/tmp/") then
                    fs.makeDir("/tmp/")
                end
                localfile_ = "/tmp/"..localfile
            end
            if Version == "m" then
                Git.get("demandymcdonald", "Andy-API", "main", gitfile, localfile_)
            elseif Version == "d" then
                Git.get("demandymcdonald", "Andy-API", "InDev", gitfile, localfile_)
            end
        end
    }
    cmds[string.lower(cmd)]()
end
function aapi.printdocument(printer, ftype, title, document)
    local result = "Printed"
    local function printdoc(tit, text)
        local lines = {}
        for i = 1, #text do
            local line = require "cc.strings".wrap(text[i], 25)
            if type(line) == "table" then
                for u = 1, #line do
                    table.insert(lines, line[u])
                end
            else
                table.insert(lines.line)
            end
        end
        local pn = 1
        if #lines > 21 then
            pn = math.ceil(#lines / 21)
        end
        if pn == 1 then
            if not printer.newPage() then
                local newpage = false
                if printer.getPaperLevel() == 0 or printer.getInkLevel() == 0 then
                    result = "Out of Paper or Ink"
                    return
                else
                    while newpage == false do
                        aapi.dbg("Buffer full, waiting...")
                        if printer.newPage() then
                            newpage = true
                        end
                        sleep(5)
                    end
                end
            end
            printer.setPageTitle(tit)
            printer.setCursorPos(1, 1)
            for i = 1, #lines do
                printer.setCursorPos(1, i)
                printer.write(lines[i])
            end
            printer.endPage()
        else
            local lineno = 1
            for i = 1, pn do
                if not printer.newPage() then
                    local newpage = false
                    if printer.getPaperLevel() == 0 or printer.getInkLevel() == 0 then
                        result = "Out of Paper or Ink"
                        return
                    else
                        while newpage == false do
                            aapi.dbg("Buffer full, waiting...")
                            if printer.newPage() then
                                newpage = true
                            end
                            sleep(5)
                        end
                    end
                end
                printer.setPageTitle(tit .. "Pg: " .. i .. "/" .. pn)
                for n = 1, 21 do
                    printer.setCursorPos(1, n)
                    local wline = lines[lineno]
                    if wline == nil then
                        return
                    else
                        printer.write(wline)
                    end
                    lineno = lineno + 1
                end
                printer.endPage()
            end
        end
    end

    local function fsdocument(path)
        local file = fs.open(path, "r")
        local lines = {}
        aapi.dbg("Reading Lines...")
        while true do
            local line = file.readLine()
            -- If line is nil then we've reached the end of the file and should stop
            if not line then break end
            table.insert(lines, line)
        end
        aapi.dbg("Completeed reading lines")
        file.close()
        return (lines)
    end
    if ftype == "string" or ftype == "table" then
        printdoc(title, document)
    elseif ftype == "github" then
        aapi.gitget("get", document[1], document[2], true)
        printdoc(title, fsdocument("/tmp/" .. document[2]))
        shell.run("delete " .. document[2])
    elseif ftype == "local" then
        local doc = fsdocument(document)
        printdoc(title, doc)
    end
    return (result)
end
return aapi_core