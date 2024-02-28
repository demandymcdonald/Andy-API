term.clear()
local aapi = require("aapi_core")
--local DebugLogFiles = "asreactor/debuglogs/"
--aapi.initDebug(DebugLogFiles)
local disp = require("aapi_display")
local audio = require("aapi_audio")
aapi.dbg("hello world")
local speakerenabled = false
local firsttime = true
local AReactorsOLD = {}
Version = "d"
function Startup()
    aapi.PeripheralSetup()
    Reactors = aapi.Pertype("fissionReactorLogicAdapter")
    Boilers = aapi.Pertype("boilerValve")
    Condensers = aapi.Pertype("rotaryCondensentrator")
    Batteries = aapi.Pertype("inductionPort")
    Monitors = aapi.Pertype("monitor")
    Turbines = aapi.Pertype("turbineValve")
    Speakers = aapi.Pertype("speaker")
    AReactors = {}
    --if #Speakers > 0 then
        --aapi.dbg("Speakers Enabled...")
        --sleep(1)
        --speakerenabled = true
    --end
    LastRS = 0
    SelectedReactor = 1
    local PeripheralList = peripheral.getNames()
    for i = 1, #PeripheralList do
        if peripheral.getType(PeripheralList[i]) == "redstoneIntegrator" then
            RS = peripheral.wrap(PeripheralList[i])
        end
    end
    Commandlog = aapi.initLogs("asreactor/commandlogs/")
    Displaytypes = { "Reactor", "Battery", "Rstatus", "Coolant", "Log" }
    Warnings = {}
    Batdata = {}
    Powertable = {}
    Displays = {}
    Pstatcount = 1
    Alarm = false
    Cycle = 0
    Energyunit = "FE"
    AutoStatus = 0
    ASTable = {}
    SodTable = {}
    BoiTable = {}
    ReactorList = {}

    -- SodTable = {R1 = {RC1, RC2, RC3, etc}}
    -- BoiTable = {R1 = {B1,B2,B3,etc.}}
    if fs.exists("/asreactor/settings.txt") then
        local fs_ = fs.open("/asreactor/settings.txt", "r")
        if fs_ ~= nil then
            Tier = textutils.unserialize(fs_.readLine())
            Surmargin = fs_.readLine()
            AOTP = fs_.readLine()
            Battery = fs_.readLine()
            --Batnames = textutils.unserialize(fs_.readLine())
            BRproduce = fs_.readLine()
            Gcycle = fs_.readLine()
            BRLimit = fs_.readLine()
            Energynit = fs_.readLine()
            aapi.dbg("Energy set to: " .. Energynit)
            Tempunit = fs_.readLine()
            aapi.dbg("Temp set to: " .. Tempunit)
            AutoStatus = fs_.readLine()
            fs_.close()
            SodTable = aapi.FM("load", "/asreactor/SodMAN1.txt")
            BoiTable = aapi.FM("load", "/asreactor/SodMAN2.txt")
            Batnames = aapi.FM("load", "/asreactor/batdata.txt")
            ASTable = aapi.FM("load", "/asreactor/APset.txt")
            disp.initDisplay(false, Displays, Monitors, Displaytypes, "/asreactor/monitorconfig.txt")
        else
            error("Error in settings file... Please delete the file and re-run launcher..")
        end
    else
        error("Settings file not found.. Please run launcher..")
    end
    -- avg output
    for i = 1, #Monitors do
        Monitors[i].clear()
        Monitors[i].setBackgroundColour(colors.black)
    end
end
function SaveSettings()
    if fs.exists("/asreactor/settings.txt") then
        local fs_ = fs.open("/asreactor/settings.txt", "w")
        -- local towrite = {Tier,Surmargin,AOTP,Battery,Batnames,BRproduce,Gcycle,BRLimit,Energyunit,Tempunit,AutoStatus,ASTable}
        -- for i=1,#towrite do
        --     fs_.writeLine(towrite[i])    
        -- end
        -- fs_.close()
        fs_.writeLine(Tier)
        fs_.writeLine(Surmargin)
        fs_.writeLine(AOTP)
        fs_.writeLine(Battery)
        --fs_.writeLine(textutils.serialize(Batnames))
        fs_.writeLine(BRproduce)
        fs_.writeLine(Gcycle)
        fs_.writeLine(BRLimit)
        fs_.writeLine(Energyunit)
        fs_.writeLine(Tempunit)
        fs_.writeLine(AutoStatus)
        --fs_.writeLine(textutils.serialize({}))   
        --fs_.writeLine(textutils.serialize(SodTable)) 
        --fs_.writeLine(textutils.serialize(BoiTable))
        fs_.close()
        aapi.FM("save", "/asreactor/batdata.txt", Batnames)
        aapi.FM("save", "/asreactor/SodMAN1.txt", SodTable)
        aapi.FM("save", "/asreactor/SodMAN2.txt", BoiTable)
        aapi.FM("save","/asreactor/APset.txt",ASTable)
    end
end    
-----------------------------------------------------------------
function Warning(type,value2,value)
    local bcolor = colors.lightGray
    local tcolor = colors.black
    local types = {
        norm = function()
            bcolor = value
            tcolor = value2
        end,
        grad = function()
            local dir = value2
            tcolor = colors.black
            if dir == "+" then
                
                if value >= .90 then
                    bcolor = colors.lime
                elseif value >= .65 then
                    bcolor = colors.green
                elseif value >= .50 then
                    bcolor = colors.yellow
                elseif value >= .35 then
                    bcolor = colors.orange
                else
                    tcolor = colors.white
                    bcolor = colors.red
                end
            else
                if value >= .90 then
                    tcolor = colors.white
                    bcolor = colors.red
                elseif value >= .65 then
                    bcolor = colors.orange
                elseif value >= .50 then
                    bcolor = colors.yellow
                elseif value >= .35 then
                    bcolor = colors.green
                else
                    bcolor = colors.lime
                end
            end
        end,
        bool = function()
            local dir = value2
            tcolor = colors.black
            if dir == "+" then
                if value == true then
                    tcolor = colors.white
                    bcolor = colors.green
                else
                    tcolor = colors.white
                    bcolor = colors.red
                end
            else
                if value == false then
                    tcolor = colors.white
                    bcolor = colors.green
                else
                    tcolor = colors.white
                    bcolor = colors.red
                end
            end
        end
    }
    types[string.lower(type)]()
    local result = { bcolor, tcolor }
    aapi.dbg("Colors: "..bcolor..","..tcolor)
    return(result)
    --table.insert(Warnings,code,tcolor,bcolor)
end
----------------------------------------------------------------
function FacilityAlarm()
    os.pullEvent("Alarm")
    if Alarm == false then
        Alarm = true
        audio.smcmd("medialoop", "alarm.dfpwm", "products/asreactor_sounds/", Speakers)
    elseif Alarm == true then
        Alarm = false
        audio.smcmd("stoploop")        
    end
end
function Powermeter()
    GlobalBR = 0
    Battery = true
    if Battery == true then
        OTP = 0
        INP = 0
        EnergyBalance = 0
        Gcycle = Gcycle + 1
        Cycle = Cycle + 1
        FillMode = false
        for i = 1, #Batteries do
            local bat = Batteries[i]
            local batname = Batnames[i]
            local output = bat.getLastOutput() or 1
            local input = bat.getLastInput() or 0
            local fill = bat.getEnergy() / bat.getMaxEnergy()
            if fill == 0 then
                output = 1000
            end
            if fill <= .75 then
                FillMode = true
                aapi.dbg("Fill mode enabled for battery #" .. #Batteries[i])
            end
            aapi.dbg(batname .. " output is: " .. output)
            aapi.dbg(batname .. " input is: " .. input)
            OTP = output + OTP
            INP = input + INP
            if Batdata[batname] == nil then
                Batdata[batname] = {}
            end
            if Batdata[batname][Cycle] ~= nil then
                Batdata[batname]["AvgIn"] = (input + (batname["AvgIn"] - batname[Cycle]["Input"])) /
                    (50 * math.min((Gcycle / 50), 1))
                Batdata[batname]["AvgOut"] = (output + (batname["AvgOut"] - batname[Cycle]["Output"])) /
                    (50 * math.min((Gcycle / 50), 1))
                Batdata[batname][Cycle] = {}
                Batdata[batname][Cycle]["Input"] = input
                Batdata[batname][Cycle]["Output"] = output
                Batdata[batname][Cycle]["Fill"] = fill
            else
                Batdata[batname][Cycle] = {}
                Batdata[batname][Cycle]["Input"] = input
                Batdata[batname][Cycle]["Output"] = output
                Batdata[batname][Cycle]["Fill"] = fill
            end
            --table.insert(Batdata,batdata_)
            -- eventually do average calculations over past x period of time and create graph by being a smart boi
            EnergyBalance = INP - OTP
        end
        if Cycle == 50 then
            --f_ = fs.open((textutils.serialize("reactorsoft/meter-" .. os.day() .. "-" .. os.time()) .. ".txt"), "a")
            --f_.writeLine(textutils.serialize(Batdata))
            --f_.close()
            --f_ = fs.open("reactorsoft/meterinfo.txt", "w")
            --f_.writeLine(textutils.serialize(AOTP))
            --f_.writeLine(textutils.serialize(Gcycle))
            --f_.writeLine(textutils.serialize(Batdata))
            --f_.close()
            Cycle = 0
        end
        aapi.dbg("Overall Input: " .. INP)
        aapi.dbg("Overall Output: " .. OTP)
        aapi.dbg("EnergyBalance: " .. EnergyBalance)
    else
        EnergyBalance = 0
        aapi.dbg("EnergyBalance: " .. EnergyBalance)
        --local turout = (turbine.getProductionRate() / 2.5)
        -- local metflow = meter.getNeeded()
        -- local metcap = meter.getCapacity()
        --  EnergyBalance = turout - metflow
    end
    local numreactors
    if #AReactors == 0 or #AReactors == nil then
        if #AReactorsOLD == 0 or #AReactorsOLD == nil then
            numreactors = 1
        else
            numreactors = #AReactorsOLD
        end
    else
        numreactors = #AReactors
    end
    local function powerstatistics()
        local cyclevel = { INP, OTP, EnergyBalance, Gcycle }
        table.insert(Powertable, cyclevel)
        if Pstatcount == 9 then
            table.remove(Powertable, 1)
        else
            Pstatcount = Pstatcount + 1
        end
    end
    local oldbr = nil
    local function powercalculate()
        for i = 1, #Reactors do
            local reactor = Reactors[i]
            if reactor.getStatus() == true then
                GlobalBR = GlobalBR + reactor.getBurnRate()
            end
        end
        oldbr = GlobalBR
        local realmargin = OTP * Surmargin
        -- Reactor produces 200k sodium per mb fuel/tick
        local ucGlobalBR = nil
        if FillMode == true then
            ucGlobalBR = realmargin*4/ BRproduce
        else
            ucGlobalBR = realmargin / BRproduce
        end
        local roundfactor = string.len(math.floor(ucGlobalBR))
        local pgr = tonumber(string.sub(ucGlobalBR, 1, (3 + roundfactor))) or 0
        GlobalBR = math.min(pgr,tonumber(BRLimit) or 1)
        aapi.log(w_rlog, Commandlog, "GlobalBR for Cycle: "..Gcycle.." is "..GlobalBR..".. Old GBR: "..oldbr)
    end
    powerstatistics()
    if AutoStatus ~= 1 then
        powercalculate()
        if oldbr ~= GlobalBR then
            local delta = GlobalBR / numreactors
            for i = 1, #Reactors do
                local reactor = Reactors[i]
                if reactor.getStatus() == true then
                    aapi.dbg("Delta Burn Rate for " .. #AReactors .. " Reactors is " .. delta .. " Each")
                    local reason = "AUTO-ADJUST-BR Reactor " .. i .. " | 'Adjusted BR to:" .. delta .. "'"
                    Commands(Reactors[i], "Burnrate", reason, math.min(delta,175))
                elseif reactor.getBurnRate() ~= 0.1 then
                    local reason = "AUTO-ADJUST-BR Shutdown Reactor to 0.1"
                    Commands(Reactors[i], "Burnrate", reason, .1)
                end
            end
        end
    end
    SaveSettings()
end
function SodiumManagement(cmd,Reactor)
    local u = ""
    local entct = 0
    for key,value in ipairs(BoiTable) do
        entct = entct + 1
    end
    if #Reactors == entct then
        u = "R" .. Reactor
    else
        u = "R1"
    end
    aapi.dbg("SodMAN u = "..u)
    local function togglefill()
        for i = 1, #SodTable[u] do
            local machine = Condensers[SodTable[u][i]]
            local isworking = not machine.isCondensentrating()
            if isworking == false and filloff == false then
                machine.setCondensentrating(false)
            else
                machine.setCondensentrating(true)
            end
        end
    end
    local function fillon()
        for i=1,#SodTable[u] do
            local machine = Condensers[SodTable[u][i]]
            local isworking = not machine.isCondensentrating()
            if isworking == false then
                machine.setCondensentrating(false)
            else
                return
            end
        end    
    end   
    local function filloff()
        for i=1,#SodTable[u] do
            local machine = Condensers[SodTable[u][i]]
            local isworking = not machine.isCondensentrating()
            if isworking == true then
                machine.setCondensentrating(true)
            else
                return
            end     
        end    
    end  
    local cmds = {
        togfill = togglefill(),
        fon = fillon(),
        foff = filloff(),
        levelman = function()
            local reactor = Reactors[Reactor]
            local pass = true
            if reactor.getCoolantFilledPercentage() <.9 then
                pass = false
            end
            local boiler = BoiTable[u]
            for i = 1, #boiler do
                local boiler_ = Boilers[BoiTable[u][i]]
                if boiler_.getCooledCoolantFilledPercentage() < .65 then
                    pass = false
                end
            end
            if pass == true then
                filloff()
            else
                fillon()
            end
        end
    }
    cmds[cmd]()
end
function Commands(object, input, reason, value1)
    local command = {
        scram = function()
            object.scram()
            local msg = "!!!SCRAM INITATED!!! - " .. reason
            aapi.log(w_rlog, Commandlog, msg)
            if Alarm == false then
                Commands(nil, "alarmtoggle", "SCRAM")
            end
        end,
        shutdown = function()
            object.scram()
            local msg = "Reactor " .. SelectedReactor .. " Shutdown- " .. reason
            aapi.log(w_rlog, Commandlog, msg)
        end,
        startup = function()
            object.activate()
            local msg = "Reactor " .. SelectedReactor .. " Startup- " .. reason
            aapi.log(w_rlog, Commandlog, msg)
        end,
        burnrate = function()
            object.setBurnRate(value1)
            local msg = reason
            if AutoStatus == 1 then
                table.remove(ASTable, SelectedReactor)
                table.insert(ASTable, SelectedReactor, value1)
                SaveSettings()
            end
            aapi.log(w_rlog, Commandlog, msg)
        end,
        rselectplus = function()
            local num = #Reactors
            if SelectedReactor == num then
                SelectedReactor = 1
            else
                SelectedReactor = SelectedReactor + 1
            end
            aapi.log(w_rlog, Commandlog, "Selected Reactor Changed to" .. SelectedReactor)
        end,
        rselectminus = function()
            local num = #Reactors
            if SelectedReactor == 1 then
                SelectedReactor = num
            else
                SelectedReactor = SelectedReactor - 1
            end
            aapi.log(w_rlog, Commandlog, "Selected Reactor Changed to" .. SelectedReactor)
        end,
        actoggle = function()
            if AutoStatus == 0 then
                aapi.log(w_rlog, Commandlog, "Eve Autocommand DISABLED")
                AutoStatus = 1
                for i = 1, #Reactors do
                    ASTable = {}
                    local reactor = Reactors[i]
                    local br = reactor.getBurnRate()
                    table.insert(ASTable, br)
                end
                SaveSettings()
            elseif AutoStatus == 1 then
                ASTable = {}
                AutoStatus = 0
                SaveSettings()
                aapi.log(w_rlog, Commandlog, "Eve Autocommand ENABLED")
            end
        end,
        alarmtoggle = function()
            if Alarm == true then
                aapi.log(w_rlog, Commandlog, "!!!Facility Alarm Deactivated!!! -" .. reason)
            elseif Alarm == false then
                aapi.log(w_rlog, Commandlog, "!!!Facility Alarm Activated!!! -" .. reason)
            end
        end,
        togglefill = function()
        end,
    }
    command[string.lower(input)]()
end
function Input()
    local input = RS.getAnalogInput("right")
    local channelmap = {
        one = function()
        end,
        two = function()
        end,
        three = function()
            Commands(nil,"ACtoggle")
        end,
        four = function()
            for i=1,#Reactors do
                Commands(Reactors[i], "scram", "Facility Shutdown Initiated")
            end
        end,
        five = function()
            Commands(nil,"rselectminus")
        end,
        six = function()
            Commands(nil,"rselectplus")
        end,
        seven = function()
            local curburn = Reactors[SelectedReactor].getBurnRate()
            Commands(Reactors[SelectedReactor],"burnrate","Manual: -.5",curburn-.5)
        end,
        eight = function()
            local curburn = Reactors[SelectedReactor].getBurnRate()
            Commands(Reactors[SelectedReactor],"burnrate","Manual: -.1",curburn-.1)
        end,
        nine = function()
            Commands(Reactors[SelectedReactor],"burnrate","Manual Burn Rate Reset",1)
        end,
        ten = function()
            local curburn = Reactors[SelectedReactor].getBurnRate()
            Commands(Reactors[SelectedReactor], "burnrate", "Manual: +.1", curburn + .1)
        end,
        eleven = function()
            local curburn = Reactors[SelectedReactor].getBurnRate()
            Commands(Reactors[SelectedReactor],"burnrate","Manual: +.5",curburn+.5)
        end,
        twelve = function()
            if Alarm == true then
                Commands(nil,"Alarmtoggle","Manual Alarm Shutoff")
            end
        end,
        thirteen = function()
            Commands(Reactors[SelectedReactor],"shutdown","Manual Shutdown")
        end,
        fourteen = function()
            Commands(Reactors[SelectedReactor],"startup","Manual Startup")
        end,
        fifteen = function()
            Commands(Reactors[SelectedReactor],"scram","Manual Activation")
            
        end
    }
    local cdecode = {
        "one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"
    }

    if input ~= 0 or (LastRS ~= 0 and input == 0) then
        if input == LastRS then
            return
        elseif input == 0 then
            LastRS = 0
        else
            if speakerenabled == true then
                audio.smcmd("playgamesound", "mekanism:digital_beep", 1, Speakers)
            end
            aapi.dbg(input)
            local cd = cdecode[input]
            channelmap[cd]()
            LastRS = input
        end
    end
    sleep(1.5)
end
function SYSstatus()
    local function reactorstatus()
        aapi.dbg("Checking Rstatus...")
        AReactorsOLD = AReactors
        AReactors = {}
        local rcoolfull = false
        local bcoolfull = false
        local bwaterfull = false
        local bwaterempty = false
        for i = 1, #Reactors do
            local reactor = Reactors[i]
            if reactor == nil then
                aapi.dbg("Reactor = nil")
                break
            end
            local rstatus = nil
            local rsbool = false
            local rtemp = reactor.getTemperature()
            local rdama = reactor.getDamagePercent()
            local rcool = reactor.getCoolantFilledPercentage()
            local rburn = reactor.getBurnRate()
            local rwast = reactor.getWasteFilledPercentage()
            local rfuel = reactor.getFuelFilledPercentage()
            if reactor.getStatus() == true then
                if rdama >= .1 then
                    local reason = "Reactor " .. i .. "AUTO-SCRAM 'DAM'"
                    Commands(reactor, "scram", reason)
                    aapi.dbg("SCRAM REACTOR DAMAGE")
                elseif rtemp >= 1000 then
                    local reason = "Reactor " .. i .. "AUTO-SCRAM 'TEMP @" .. disp.textf("temp", rtemp, Tempunit) .. "'"
                    Commands(reactor, "scram", reason)
                    aapi.dbg("SCRAM HIGH REACTOR TEMP")
                elseif rcool <= .40 then
                    local reason = "Reactor " .. i .. "AUTO-SCRAM 'COOL @" .. disp.textf("per", rcool) .. "'"
                    Commands(reactor, "scram", reason)
                    aapi.dbg("SCRAM LOW REACTOR COOLANT")
                elseif rfuel < 0.10 then
                    local reason = "Reactor " .. i .. "AUTO-SD 'FUEL @" .. disp.textf("per", rfuel) .. "'"
                    Commands(reactor, "shutdown", reason)
                    aapi.dbg("SHUTDOWN LOW REACTOR FUEL")
                elseif rwast >= 0.80 then
                    local reason = "Reactor " .. i .. "AUTO-SD 'Waste @" .. disp.textf("per", rwast) .. "'"
                    Commands(reactor, "shutdown", reason)
                    aapi.dbg("SHUTDOWN HIGH REACTOR WASTE")
                elseif rcool == 100 then
                    rcoolfull = true
                else
                    rstatus = "Active"
                    rsbool = true
                    table.insert(AReactors,i)
                end
            else
                rstatus = "Inactive"
                rsbool = false
            end
            SodiumManagement("levelman",i)
            ReactorList["reactor" .. i] = {}
            ReactorList["reactor" .. i]["Status"] = rstatus
            ReactorList["reactor" .. i]["StatBool"] = Warning("bool", "+", rsbool)
            ReactorList["reactor" .. i]["Temp"] = rtemp
            ReactorList["reactor" .. i]["TempC"] = Warning("GRAD", "-", (rtemp / 1200))
            ReactorList["reactor" .. i]["Dama"] = rdama/100
            ReactorList["reactor" .. i]["DamaC"] = Warning("GRAD", "-", rdama)
            ReactorList["reactor" .. i]["Cool"] = rcool
            ReactorList["reactor" .. i]["CoolC"] = Warning("GRAD", "+", rcool)
            ReactorList["reactor" .. i]["Burn"] = rburn
            ReactorList["reactor" .. i]["Wast"] = rwast
            ReactorList["reactor" .. i]["Fuel"] = rfuel
            Reactorwinwigtable = {}
            
            
            aapi.dbg("Rtemp:" .. rtemp)
            aapi.dbg("Rdama:" .. rdama)
            aapi.dbg("Rcool:" .. rcool)
            aapi.dbg("Rburn:" .. rburn)
            aapi.dbg("Rwast:" .. rwast)
            aapi.dbg("Rfuel:" .. rfuel)
        end
    end
    local function boilerstatus()
        local bwaterlow = false
        local bcoolfull = false
        for i = 1, #Boilers do
            local boiler = Boilers[i]
            local bwater = boiler.getWaterFilledPercentage()
            local bcoola = boiler.getHeatedCoolantFilledPercentage()
            local bsteam = boiler.getSteamFilledPercentage()

            Warning("grad", "+", bwater)
            Warning("grad", "-", bsteam)
            Warning("grad", "-", bcoola)
            if bwater < .25 then
                bwaterlow = true
            else
                bwaterlow = false
            end
            if bcoola == 1 then
                bcoolfull = true
            else
                bcoolfull = false
            end
        end
        if bwaterlow == true then
            for i = 1, #Reactors do

                local reason = "Reactor "..i.."AUTO-SCRAM 'BWATER @"..disp.textf("per",bwater).."'"
                Commands(reactor, "SCRAM", reason)
                aapi.dbg("SCRAM LOW BOILER WATER")
            end
        end
    end
    reactorstatus()
    boilerstatus()

end
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
function BuildDisplays()
    local function CustomReactorInterface()
        local function pre()
            --[[
                    data_[1] = length
                    data_[2] = width
                ]]
            parent.setCursorPos(xstart, ystart)
        end
        local function dodraw()
            paintutils.drawFilledBox(xstart, ystart, xend, yend, bcolor)
            parent.setTextColor(ncolor)
            local lct = 1
            local wct = 1
        end
    end
    for key, display in pairs(Displays) do
        if display[1] == "Reactor" then
            display[2].clear()
            display[2].setTextScale(.5)
            local displayname = "Reactordisplay"
            disp.addWindow(display[2], displayname, "ARS Reactor Status", 0, 0, 1, 1, colors.black, true)
            disp.addWindow(w_Reactordisplay, "RStatusWidgets", "Status & Warnings", 0, 0, 1, .3 * #Reactors, colors
                .black,
                false)
            disp.addWindow(w_Reactordisplay, "rlog", "Reactor Log", 0, .3 * #Reactors, 1, .8, colors.black, false)
            SYSstatusWidgets()
            disp.buildWidgets("Rwidgets", w_RStatusWidgets, Rwidget, true)
        elseif display[1] == "Battery" then
            display[2].clear()
            display[2].setTextScale(.5)
            local displayname = "Batterydisplay"
            disp.addWindow(display[2], displayname, "ARS Battery Status", 0, 0, 1, 1, colors.black, true)
            disp.addWindow(w_Batterydisplay, "BStatusWidgets", "Status & Warnings", 0, 0, 1, .6 * #Reactors, colors
                .black, false)
            POWmainstatWidgets()
            disp.buildWidgets("Pwidgets", w_BStatusWidgets, Pwidget, true)
            disp.addWindow(w_Batterydisplay, "ADisplay", "Batteries", 0, .6, 1, 1 * #Reactors, colors
                .black, false)
            disp.windowArray(w_ADisplay, #Batteries, "Awidget", Batnames, colors.lightGray, true, 0, 0, 1, 1)
            for i = 1, #Batteries do
                disp.buildWidgets("Awidgets" .. i, _G["w_Awidget" .. i], _G["Awidgetlist" .. i], false)
            end
        end
    end
end
local function convertenergy(data)
        return(aapi.contostand("energy",data,"j"))
end
function SYSstatusWidgets()
    Rwidget = {}
    disp.createWidget(Rwidget, "display", "SelectReact",
        ("SELR"), SelectedReactor, colors.yellow,
        colors.black, colors.white)
    --for key, data in pairs(Reactors) do
    for i = 1, #Reactors do
        local name = ReactorList["reactor" .. i]
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "status"),
            ("R" .. i .. "STAT"), name["Status"], name["StatBool"][1],
            name["StatBool"][2], colors.white)
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "dama"),
            ("R" .. i .. "DAMA"), disp.textf("per", name["Dama"]), name["DamaC"][1],
            name["DamaC"][2], colors.white)
        aapi.dbg(Tempunit)
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "temp"),

            ("R" .. i .. "TEMP"), disp.textf("temp", name["Temp"], Tempunit), name["TempC"][1],
            name["TempC"][2], colors.white)
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "cool"),
            ("R" .. i .. "COOL"), disp.textf("per", name["Cool"]), name["CoolC"][1],
            name["CoolC"][2], colors.white)
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "br"),
            ("R" .. i .. "BURN"), name["Burn"], colors.gray,
            colors.white, colors.white)
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "fuel"),
            ("R" .. i .. "FUEL"), disp.textf("per", name["Fuel"]), colors.gray,
            colors.white, colors.white)
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "waste"),
            ("R" .. i .. "WAST"), disp.textf("per", name["Wast"]), colors.gray,
            colors.white, colors.white)
    end
end
function POWmainstatWidgets()
    -- Powertable{INP OTP ENBAL}
    local dname = {}
    local aiop = {}
    local aotp = {}
    local aenb = {}
    local aiopd = {}
    local aotpd = {}
    local aenbd = {}
    Pwidget = {}
    for key, value in pairs(Powertable) do
        table.insert(dname, value[4])
        table.insert(aiop, value[1])
        table.insert(aotp, value[2])
        table.insert(aenb, value[3])
        table.insert(aiopd, disp.textf("energy", value[1], Energyunit))
        table.insert(aotpd, disp.textf("energy", value[2], Energyunit))
        table.insert(aenbd, disp.textf("energy", value[3], Energyunit))
    end
    local aenb_ = disp.createDataTable(dname, aenb, aenbd)
    local aiop_ = disp.createDataTable(dname, aiop, aiopd)
    local aotp_ = disp.createDataTable(dname, aotp, aotpd)
    disp.createWidget(Pwidget, "smallbargraph", "EnergyBalanceG", "Energy Balance", aenb_, colors
        .gray, colors.white, colors.black, colors.black, { colors.blue, colors.lightBlue })
    disp.createWidget(Pwidget, "smallbargraph", "AIOPG", "Generating:", aiop_, colors
        .gray, colors.white, colors.black, colors.black, { colors.blue, colors.lightBlue })
    disp.createWidget(Pwidget, "smallbargraph", "AOTPG", "Using:", aotp_, colors
        .gray, colors.white, colors.black, colors.black, { colors.blue, colors.lightBlue })
    disp.createWidget(Pwidget, "display", "EnergyBalanceD", "Energy Balance",
        disp.textf("energy", convertenergy(EnergyBalance), Energyunit),
        colors
        .gray, colors.white, colors.white)
    disp.createWidget(Pwidget, "display", "AIOPD", "Generating:", disp.textf("energy", convertenergy(INP), Energyunit),
        colors
        .green, colors.white, colors.white)
    disp.createWidget(Pwidget, "display", "AOTPD", "Using:", disp.textf("energy", convertenergy(OTP), Energyunit), colors
        .red, colors.white, colors.white)
    local function POWstatusWidgets(i)
        local name = Batdata[Batnames[i]][Cycle]
        _G["Awidgetlist" .. i] = {}
        local wtname = _G["Awidgetlist" .. i]
        disp.createWidget(wtname, "smallbarmeter", ("Bat" .. i .. "Fill"), ("B" .. i .. "FIL"), { name["Fill"], 1 },
            colors.gray, colors.white, colors.black, colors.green, colors.white)
        disp.createWidget(wtname, "display", ("Bat" .. i .. "Input"), ("B" .. i .. "IN"),
            disp.textf("energy", convertenergy(name["Input"]), Energyunit), colors.gray, colors.white, colors.green)
        disp.createWidget(wtname, "display", ("Bat" .. i .. "Output"), ("B" .. i .. "OUT"),
            disp.textf("energy", convertenergy(name["Output"]), Energyunit), colors.gray, colors.white, colors.red)
    end
    for i = 1, #Batteries do
        POWstatusWidgets(i)
    end
end
local function wformat(type, name, title, data, bgcolor, ncolor, dcolor, ecolor, fcolor)
    local tab = {}
    tab["name"] = name
    tab["type_"] = type
    tab["title"] = title
    tab["data"] = data
    tab["bgcolor"] = bgcolor or colors.black
    tab["ncolor"] = ncolor or colors.black
    tab["dcolor"] = dcolor or colors.black
    tab["ecolor"] = ecolor or colors.black
    tab["fcolor"] = fcolor or colors.black
    return (tab)
end
function RefreshSW()
    local rs_sel = wformat("display","SelectReact", "SELR", SelectedReactor, colors.yellow,colors.black, colors.white)
    disp.refreshWidget("Rwidgets", rs_sel)
    for i = 1, #Reactors do
        local name = ReactorList["reactor" .. i]
        local rs_stat = wformat("display", ("reactor" .. i .. "status"),("R" .. i .. "STAT"), name["Status"],
            name["StatBool"][1],
            name["StatBool"][2], colors.white)
        local rs_dama = wformat("display",("reactor" .. i .. "dama"),
            ("R" .. i .. "DAMA"), disp.textf("per", name["Dama"]), name["DamaC"][1],
            name["DamaC"][2], colors.white)
        local rs_temp = wformat("display",("reactor" .. i .. "temp"),
            ("R" .. i .. "TEMP"), disp.textf("temp", name["Temp"], Tempunit), name["TempC"][1],
            name["TempC"][2], colors.white)
        local rs_cool = wformat( "display",("reactor" .. i .. "cool"), ("R" .. i .. "COOL"),
            disp.textf("per", name["Cool"]), name["CoolC"][1],
            name["CoolC"][2], colors.white)
        local rs_burn = wformat("display",("reactor" .. i .. "br"),  ("R" .. i .. "BURN"), name["Burn"], colors.gray,
            colors.white, colors.white)
        local rs_fuel = wformat( "display", ("reactor" .. i .. "fuel"),("R" .. i .. "FUEL"),
            disp.textf("per", name["Fuel"]), colors.gray,
            colors.white, colors.white)
        local rs_waste = wformat("display", ("reactor" .. i .. "waste"), ("R" .. i .. "WAST"),
            disp.textf("per", name["Wast"]), colors.gray,
            colors.white, colors.white)


        disp.refreshWidget("Rwidgets", rs_stat)
        disp.refreshWidget("Rwidgets", rs_dama)
        disp.refreshWidget("Rwidgets", rs_temp)
        disp.refreshWidget("Rwidgets", rs_cool)
        disp.refreshWidget("Rwidgets", rs_burn)
        disp.refreshWidget("Rwidgets", rs_fuel)
        disp.refreshWidget("Rwidgets", rs_waste)
    end
end
function RefreshBW()
    local dname = {}
    local aiop = {}
    local aotp = {}
    local aenb = {}
    local aiopd = {}
    local aotpd = {}
    local aenbd = {}
    for key, value in pairs(Powertable) do
        table.insert(dname, value[4])
        table.insert(aiop, value[1])
        table.insert(aotp, value[2])
        table.insert(aenb, value[3])
        table.insert(aiopd, disp.textf("energy", value[1], Energyunit))
        table.insert(aotpd, disp.textf("energy", value[2], Energyunit))
        table.insert(aenbd, disp.textf("energy", value[3], Energyunit))
    end
    local aenb_ = disp.createDataTable(dname, aenb, aenbd)
    local aiop_ = disp.createDataTable(dname, aiop, aiopd)
    local aotp_ = disp.createDataTable(dname, aotp, aotpd)
    local w1 = wformat( "smallbargraph", "EnergyBalanceG", "Energy Balance", aenb_, colors
        .gray, colors.white, colors.black, colors.black, { colors.blue, colors.lightBlue })
    local w2 = wformat("smallbargraph", "AIOPG", "Generating:", aiop_, colors
        .gray, colors.white, colors.black, colors.black, { colors.blue, colors.lightBlue })
    local w3 = wformat("smallbargraph", "AOTPG", "Using:", aotp_, colors
        .gray, colors.white, colors.black, colors.black, { colors.blue, colors.lightBlue })
    local w4 = wformat("display", "EnergyBalanceD", "Energy Balance",
        disp.textf("energy", convertenergy(EnergyBalance), Energyunit), colors.gray, colors.white, colors.white)
    local w5 = wformat("display", "AIOPD", "Generating:", disp.textf("energy", convertenergy(INP), Energyunit),
        colors.green, colors.white, colors.white)
    local w6 = wformat("display", "AOTPD", "Using:", disp.textf("energy", convertenergy(OTP), Energyunit), colors
        .red, colors.white, colors.white)
    
    
    disp.refreshWidget("Pwidgets", w1)
    disp.refreshWidget("Pwidgets", w2)
    disp.refreshWidget("Pwidgets", w3)
    disp.refreshWidget("Pwidgets", w4)
    disp.refreshWidget("Pwidgets", w5)
    disp.refreshWidget("Pwidgets", w6)
    local function POWstatusWidgets(i)
        local name = Batdata[Batnames[i]][Cycle]
        
        local wtname = _G["Awidgetlist" .. i]
        local wt1 = wformat("smallbarmeter", ("Bat" .. i .. "Fill"), ("B" .. i .. "FIL"), { name["Fill"], 1 },
            colors.gray, colors.white, colors.black, colors.green, colors.white)
        local wt2 = wformat("display", ("Bat" .. i .. "Input"), ("B" .. i .. "IN"),
            disp.textf("energy", convertenergy(name["Input"]), Energyunit), colors.gray, colors.white, colors.green)
        local wt3 = wformat("display", ("Bat" .. i .. "Output"), ("B" .. i .. "OUT"),
            disp.textf("energy", convertenergy(name["Output"]), Energyunit), colors.gray, colors.white, colors.red)
        disp.refreshWidget("Awidgets" .. i, wt1)
        disp.refreshWidget("Awidgets" .. i, wt2)
        disp.refreshWidget("Awidgets" .. i, wt3)
    end
    for i = 1, #Batteries do
        POWstatusWidgets(i)
    end
end
Startup()

local function thread1()
    if speakerenabled == true then
        audio.smcmd("playmedia", "startup.dfpwm", "products/asreactorsounds/", Speakers)    
    end
    while true do
        aapi.dbg("[THREAD] T1 Running...")
        SYSstatus()
        RefreshSW()
        sleep(5)
    end
end
local function thread2()
    while true do
        aapi.dbg("[THREAD] T2 Running...")
        Powermeter()
        RefreshBW()
        sleep(20)
    end
end
local function thread3()
    aapi.dbg("Input monitoring...")
    while true do
        aapi.dbg("[THREAD] T3 Running...")
        Input()
    end
end
if Tier == 1 then
    while true do
        SYSstatus()
    end
elseif Tier == 2 then

    while true do
        SYSstatus()
        Powermeter()
        if firsttime == true then
            firsttime = false
            BuildDisplays()
        end
        SYSstatusWidgets()
        POWmainstatWidgets()
        sleep(10)
    end
elseif Tier == 3 then
    if firsttime == true then
        firsttime = false
        SYSstatus()
        Powermeter()
        BuildDisplays()
    end
    aapi.cprint(nil,"eve","Startup Complete! Manual Inputs now accepted..")
    if speakerenabled == true then
        while true do
            parallel.waitForAll(thread1, thread2, thread3,audio.soundmanager,FacilityAlarm)
        end
    else
        while true do        
            parallel.waitForAll(thread1, thread2, thread3,FacilityAlarm)   
        end     
    end
elseif Tier == 4 then
    if firsttime == true then
        firsttime = false
        SYSstatus()
        Powermeter()
        BuildDisplays()
    end
    aapi.cprint(nil,"eve","Startup Complete! Manual Inputs now accepted..")
    if speakerenabled == true then
        while true do    
            parallel.waitForAll(thread1, thread2, thread3,audio.soundmanager,FacilityAlarm)
        end
    else
        while true do    
            parallel.waitForAll(thread1, thread2, thread3,FacilityAlarm)      
        end  
    end
end
