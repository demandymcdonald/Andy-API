term.clear()
require("andysoftreactor_launcher")
AAPI = require("aapi_core")
local DebugLogFiles = "asreactor/debuglogs/"
AAPI.initDebug(DebugLogFiles)
local disp = require("aapi_display")
AAPI.dbg("hello world")

function Startup()
    aapi.PeripheralSetup()
    Reactors = aapi.Pertype("fissionReactorLogicAdapter")
    Boilers = aapi.Pertype("boilerValve")
    PressureValve = aapi.Pertype("ultimateChemicalTank")
    Batteries = aapi.Pertype("inductionPort")
    Monitors = aapi.Pertype("monitor")
    Turbines = aapi.Pertype("turbineValve")
    LastRS = 0
    SelectedReactor = 1
    local PeripheralList = peripheral.getNames()
    for i = 1, #PeripheralList do
        if peripheral.getType(peripheralList[i]) == "redstoneIntegrator" then
            RS = peripheral.wrap(peripheralList[i])
        end
    end
    Commandlog = aapi.initLogs("asreactor/commandlogs/")
    Displaytypes = { "Reactor", "Battery", "Rstatus", "Coolant", "Log" }
    Warnings = {}
    Batdata = {}
    Powertable = {}
    Displays = {}
    Pstatcount = 1
    Cycle = 0
    EnergyUnit = "FE"
    if fs.exists("/asreactor/settings.txt") then
        local fs_ = fs.open("/asreactor/settings.txt", "r")
        if fs_ ~= nil then
            Tier = textutils.unserialize(fs_.readLine())
            Surmargin = fs_.readLine()
            AOTP = fs_.readLine()
            Battery = fs_.readLine()
            Batnames = fs_.readLine()
            BRproduce = fs_.readLine()
            Gcycle = fs_.readLine()
            BRLimit = fs_.readLine()
            EnergyUnit = fs_.readLine()
            fs_.close()
            disp.initDisplay(false, Displays, Monitors, Displaytypes, "/asreactor/monitorconfig.txt")
        else
            error("Error in settings file... Please delete the file and re-run launcher..")
        end
    else
        error("Settings file not found.. Please run launcher..")
    end
 -- avg output
end
-----------------------------------------------------------------
function Warning(type,value_,value2_)
    local bcolor = colors.lightGray
    local tcolor = colors.black
    local types = {
        norm = function(value, value2,value2_)
            bcolor = value
            tcolor = value2
            return({bcolor,tcolor})
        end,    
        grad = function(dir, value,value2_)
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
            return({bcolor,tcolor})
        end,
        bool = function(dir,value,value2_)
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
            return({bcolor,tcolor})
        end
    }
    local result = types[string.lower(type)](value_,value2_)
    return(result)
    --table.insert(Warnings,code,tcolor,bcolor)
end
----------------------------------------------------------------

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
            local output = bat.getLastOutput(), 1
            local input = bat.getLastInput()
            local fill = bat.getEnergy() / bat.getMaxEnergy()
            if fill == 0 then
                output = 1000
            end
            if fill <= .75 then
                FillMode = true
                AAPI.dbg("Fill mode enabled for battery #" .. #Batteries[i])
            end
            AAPI.dbg(batname .. " output is: " .. output)
            AAPI.dbg(batname .. " input is: " .. input)
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
        AAPI.dbg("Overall Input: " .. INP)
        AAPI.dbg("Overall Output: " .. OTP)
        AAPI.dbg("EnergyBalance: " .. EnergyBalance)
    else
        EnergyBalance = 0
        AAPI.dbg("EnergyBalance: " .. EnergyBalance)
        --local turout = (turbine.getProductionRate() / 2.5)
        -- local metflow = meter.getNeeded()
        -- local metcap = meter.getCapacity()
        --  EnergyBalance = turout - metflow
    end
    local function powerstatistics()
        local cyclevel = {INP,OTP,EnergyBalance,Gcycle}
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
            GlobalBR = GlobalBR + Reactors[i].getBurnRate()
        end
        oldbr = GlobalBR
        local realmargin = OTP + Surmargin
        -- Reactor produces 200k sodium per mb fuel/tick
        local ucGlobalBR = nil
        if FillMode == true then
            ucGlobalBR = (realmargin * 2.5) / BRproduce
        else
            ucGlobalBR = realmargin / BRproduce
        end
        local roundfactor = string.len(math.floor(ucGlobalBR))
        GlobalBR = string.sub(ucGlobalBR,1,(3+roundfactor))
    end
    powerstatistics()
    powercalculate()
    if oldbr ~= GlobalBR then
        for i = 1,#Reactors do 
            local delta = GlobalBR / #Reactors
            AAPI.dbg("Delta Burn Rate for "..#Reactors.." Reactors is " .. delta.." Each")
            local reason = "AUTO-ADJUST-BR Reactor "..i.." | 'Adjusted BR to:"..delta.."'"
            Commands(Reactors[i],"Burnrate",reason,delta)
        end
    end
end 
function Commands(object, input, reason, value1)
    local command = {
        scram = function()
            object.scram()
            local msg = "!!!SCRAM INITATED!!! - "..reason
            AAPI.log(w_rlog,Commandlog,msg)
        end,
        resetalarm = function()

        end,
        shutdown = function()
            object.scram()
            local msg = "Reactor Shutdown- "..reason
            AAPI.log(w_rlog,Commandlog,msg)
        end,
        startup = function()
            object.activate()
            local msg = "Reactor Startup- "..reason
            AAPI.log(w_rlog,Commandlog,msg)            
        end,
        burnrate = function()
            object.setBurnRate(value1)
            local msg = reason
            AAPI.log(w_rlog, Commandlog, msg)
        end,
        rselectplus = function ()
            local num = #Reactors
            if SelectedReactor == num then
                SelectedReactor = 1
            else
                SelectedReactor = SelectedReactor + 1
            end
            AAPI.log("Selected Reactor Changed to"..SelectedReactor)
        end,
        rselectminus = function ()
            local num = #Reactors
            if SelectedReactor == 1 then
                SelectedReactor = num
            else
                SelectedReactor = SelectedReactor - 1
            end
            AAPI.log("Selected Reactor Changed to"..SelectedReactor)
        end
    }
    command[string.lower(input)]()
end
function SYSstatus()
    local function reactorstatus()
        AAPI.dbg("Checking Rstatus...")
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
            local rtemp = reactor.getTemperature()
            local rdama = reactor.getDamagePercent()
            local rcool = reactor.getCoolantFilledPercentage()
            local rburn = reactor.getBurnRate()
            local rwast = reactor.getWasteFilledPercentage()
            local rfuel = reactor.getFuelFilledPercentage()
            if reactor.getStatus() == true then
                if rdama >= .1 then
                    local reason = "Reactor "..i.."AUTO-SCRAM 'DAM'"
                    Commands(reactor, "scram", reason)
                    AAPI.dbg("SCRAM REACTOR DAMAGE")
                elseif rtemp >= 1000 then
                    local reason = "Reactor "..i.."AUTO-SCRAM 'TEMP @"..disp.textf("temp",rtemp,"f").."'"
                    Commands(reactor, "scram", reason)
                    AAPI.dbg("SCRAM HIGH REACTOR TEMP")
                elseif rcool <= .40 then
                    local reason = "Reactor "..i.."AUTO-SCRAM 'COOL @"..disp.textf("per",rcool).."'"
                    Commands(reactor, "scram", reason)
                    AAPI.dbg("SCRAM LOW REACTOR COOLANT")
                elseif rfuel < 0.10 then
                    local reason = "Reactor "..i.."AUTO-SD 'FUEL @"..disp.textf("per",rfuel).."'"                    
                    Commands(reactor, "shutdown", reason)
                    AAPI.dbg("SHUTDOWN LOW REACTOR FUEL")
                elseif rwast >= 0.80 then
                    local reason = "Reactor "..i.."AUTO-SD 'Waste @"..disp.textf("per",rwast).."'"        
                    Commands(reactor, "shutdown", reason)
                    AAPI.dbg("SHUTDOWN HIGH REACTOR WASTE")
                elseif rcool == 100 then
                    rcoolfull = true
                end
                rstatus = "Active"
            else
                rstatus = "Inactive"
            end
            ReactorList["reactor" .. i] = {}
            ReactorList["reactor" .. i]["Status"] = rstatus
            ReactorList["reactor"..i]["StatBool"] = Warning("bool", "+", name["StatBool"])
            ReactorList["reactor" .. i]["Temp"] = rtemp
            ReactorList["reactor" .. i]["TempC"] = Warning("GRAD", "-", (rtemp / 1200))
            ReactorList["reactor" .. i]["Dama"] = rdama
            ReactorList["reactor"..i]["DamaC"] = Warning("GRAD", "-", rdama)
            ReactorList["reactor" .. i]["Cool"] = rcool
            ReactorList["reactor" .. i]["CoolC"] = Warning("GRAD", "+", rcool)
            ReactorList["reactor" .. i]["Burn"] = rburn
            ReactorList["reactor"..i]["Wast"] = rwast
            ReactorList["reactor"..i]["Fuel"] = rfuel
            Reactorwinwigtable = {}
            
            
            AAPI.dbg("Rtemp:" .. rtemp)
            AAPI.dbg("Rdama:" .. rdama)
            AAPI.dbg("Rcool:" .. rcool)
            AAPI.dbg("Rburn:" .. rburn)
            AAPI.dbg("Rwast:" .. rwast)
            AAPI.dbg("Rfuel:" .. rfuel)
        end
    end
    local function boilerstatus()

        for i = 1, #Boilers do
            local boiler = Boilers[i]
            local bwater = boiler.getWaterFilledPercentage()
            local bcoola = boiler.getHeatedCoolantFilledPercentage()
            local bsteam = boiler.getSteamFilledPercentage()
            local bwaterlow = false
            local bcoolfull = false
            Warning("grad", "+", bwater)
            Warning("grad", "-", bsteam)
            Warning("grad", "-", bcoola)
            if bwater < .25 then
                local bwaterlow = true
            else
                local bwaterlow = false
            end
            if bcoola == 1 then
                local bcoolfull = true
            else
                local bcoolfull = false
            end
        end
        if bwaterlow == true then
            for i = 1, #Reactors do
                local reactor = Reactors[i]
                local reason = "Reactor "..i.."AUTO-SCRAM 'BWATER @"..disp.textf("per",bwater).."'"
                Commands(reactor, "SCRAM", reason)
                AAPI.dbg("SCRAM LOW BOILER WATER")
            end
        end
        if bcoolfull == true then
            for i = 1, #Valves do
                local valve = Valves[i]
                valve.setDumpingMode("DUMPING")
                AAPI.dbg("Valve "..Valves[i].." Dumping")
            end
            --Warning("Valves", 1)
        elseif bcoolfull == false then
            for i = 1, #Valves do
                local valve = Valves[i]
                valve.setDumpingMode("IDLE")
                AAPI.dbg("Valve "..Valves[i].." Idle")
            end
            --Warning("Valves", 0)       
        end
    end
    reactorstatus()
    boilerstatus()
end
--------------------------------------------------------------------------------------------------
function Input(side)
    local input = RS.getAnalogInput("left")
    local channelmap = {
        one = function()
        end,
        two = function()
        end,
        three = function()
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

        end,
        thirteen = function()
        end,
        fourteen = function()

        end
    }
    if input ~= 0 then
        if input == LastRS then
            return
        else
            channelmap[input]()
            LastRS = input
        end            
    end
end
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
            disp.addWindow(w_Reactordisplay, "RStatusWidgets", "Status & Warnings", 0, 0, 1, .3 * #Reactors, colors.black,
                false)
            disp.addWindow(w_Reactordisplay, "rlog", "Reactor Log", 0, .3 * #Reactors, 1, .8, colors.black, false)
            SYSstatusWidgets()
            disp.buildWidgets("Rwidgets",w_RStatusWidgets, Rwidget,true)

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
function SYSstatusWidgets()
    Rwidget = {}
    local i = 1
    for key, data in pairs(ReactorList) do
        local name = ReactorList["reactor" .. i]
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "status"),
            ("R" .. i .. "STAT"), name["Status"], name["StatBool"][1],
            name["StatBool"][2], colors.white)
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "dama"),
            ("R" .. i .. "DAMA"), disp.textf("per", name["Dama"]), name["DamaC"][1],
            name["DamaC"][2], colors.white)
        disp.createWidget(Rwidget, "display", ("reactor" .. i .. "temp"),
            ("R" .. i .. "TEMP"), disp.textf("temp", name["Temp"], "f"), name["TempC"][1],
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
        i = i + 1
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
        table.insert(aiopd, disp.textf("energy", value[1], EnergyUnit))
        table.insert(aotpd, disp.textf("energy", value[2], EnergyUnit))
        table.insert(aenbd, disp.textf("energy", value[3], EnergyUnit))
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
    disp.createWidget(Pwidget, "display", "EnergyBalanceD", "Energy Balance", disp.textf("energy", EnergyBalance, EnergyUnit),
        colors
        .gray, colors.white, colors.white)
    disp.createWidget(Pwidget, "display", "AIOPD", "Generating:", disp.textf("energy", INP, EnergyUnit), colors
        .green, colors.white, colors.white)
    disp.createWidget(Pwidget, "display", "AOTPD", "Using:", disp.textf("energy", OTP, EnergyUnit), colors
        .red, colors.white, colors.white)
    local function POWstatusWidgets(i)
        local name = Batdata[Batnames[i]][Cycle]
        _G["Awidgetlist" .. i] = {}
        local wtname = _G["Awidgetlist" .. i]
        disp.createWidget(wtname, "smallbarmeter", ("Bat" .. i .. "Fill"), ("B" .. i .. "FIL"), { name["Fill"], 1 },
            colors.gray, colors.white, colors.black, colors.green, colors.white)
        disp.createWidget(wtname, "display", ("Bat" .. i .. "Input"), ("B" .. i .. "IN"),
            disp.textf("energy", name["Input"], EnergyUnit), colors.gray, colors.white, colors.green)
        disp.createWidget(wtname, "display", ("Bat" .. i .. "Output"), ("B" .. i .. "OUT"),
            disp.textf("energy", name["Output"], EnergyUnit), colors.gray, colors.white, colors.red)
    end
    for i = 1, #Batteries do
        POWstatusWidgets(i)
    end
end
if Tier == 1 then
    while true do
        SYSstatus()
    end
elseif Tier == 2 then
    BuildDisplays()
    while true do
        SYSstatus()
        Powermeter()
        SYSstatusWidgets()
        POWmainstatWidgets()
    end
elseif Tier == 3 then
    BuildDisplays()
    local function thread1()
        while true do
            SYSstatus()
            SYSstatusWidgets()
            sleep(2)
        end
    end
    local function thread2()
        while true do
            Powermeter()
            POWmainstatWidgets()
            sleep(10)
        end
    end
    local function thread3()
        while true do
            input()
        end
    end
    parallel.waitForAll(thread1, thread2, thread3)
elseif Tier == 4 then
    BuildDisplays()
    local function thread1()
        while true do
            SYSstatus()
            SYSstatusWidgets()
            sleep(2)
        end
    end
    local function thread2()
        while true do
            Powermeter()
            POWmainstatWidgets()
            sleep(10)
        end
    end
    local function thread3()
        while true do
            input()
        end
    end
    parallel.waitForAll(thread1,thread2,thread3)
end
