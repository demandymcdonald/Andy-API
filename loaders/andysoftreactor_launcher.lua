term.clear()
term.setCursorPos(1, 1)
local activationcodes = {}
activationcodes["Basic"] = "Rxr8BzslZRTHEB"
activationcodes["Gold"] = "OKhUcx0wFKDzuj"
activationcodes["Platnum"] = "FgIkhbvGKinpjd"
activationcodes["PlatnumPLUS"] = "2p59HcUjmf2kMe"
local tiers = {"Basic","Gold","Platnum","PlatnumPLUS"}
local tier = 0

function Apistartup()
    shell.run("delete aapi_loader.lua")
    shell.run("pastebin get gWaWXz2q aapi_loader.lua")
    local loader = require("aapi_loader")
    loader.setVersion("d")
    loader.update()
    loader.core()
    loader.display()
    loader.audio()
    loader.custom("products/andysoftreactor.lua", "andysoftreactor.lua")
end
Apistartup()
local aapi = require("aapi_core")
local disp = require("aapi_display")
local sound = require("aapi_audio")
local channelmap = {"15 = Scram","14 = Power Off","13 = Power On","12 = Reset Alarm","11 = Burn Rate Up (.5)","10 = Burn Rate Up (.1)","9 = Reset Burn Rate","8 = Burn Rate Down (.1)","7 = Burn Rate Down (.5)","6 = Change Selected Reactor (+)","5 = Change Selected Reactor (-)","4 = Facility Shutdown"}
function Startup()
    if fs.exists("/asreactor/settings.txt") then
        while true do
            Reactors = aapi.Pertype("fissionReactorLogicAdapter")
            shell.run("andysoftreactor")
            for i = 1,#Reactors do
                local reactor = Reactors[i]
                reactor.scram()
            end
        end
    else
        aapi.PeripheralSetup()
        Reactors = aapi.Pertype("fissionReactorLogicAdapter")
        Boilers = aapi.Pertype("boilerValve")
        PressureValve = aapi.Pertype("ultimateChemicalTank")
        Batteries = aapi.Pertype("inductionPort")
        Monitors = aapi.Pertype("monitor")
        Turbines = aapi.Pertype("turbineValve")
        Commandlog = aapi.initLogs("asreactor/commandlogs/")
        Speakers = aapi.Pertype("speaker")
        Displaytypes = { "Reactor", "Battery", "Rstatus", "Coolant", "Log" }
        Warnings = {}
        Batdata = {}
        Powertable = {}
        Displays = {}
        Pstatcount = 1
        Cycle = 0
        FSSetup()
        AOTP = {}
    end
    Surmargin = 1000000
 -- avg output
    Batnames = { "Bob the Bat", "Joe the Bat" }
    Gcycle = 0
 -- setup option later
    --EnergyStats = {} -- work on function l8r
    BRLimit = 50   -- set this dynamically or statically later
end

function FSSetup()

    local sped = 100
    local this = term.native()
    term.clear()
    disp.addWindow(this, "setup", "AS Reactor Setup", 0, 0, 1, 1, colors.red, true)
    this = w_setup
    local function pktc()
        aapi.cprint(this, "eve", "Press any key to continue..")
        local msg = aapi.uinput(this, "eve", sped)
    end
    aapi.cprint(this,"eve","Hello, my name is EVE.",nil,sped)
    aapi.cprint(this, "eve", "I'm your AI Reactor Controller. I'm here to guide you through the setup process!", nil, sped)
    aapi.cprint(this, "eve", "Let's start setting up your reactor", nil, sped)
    aapi.cprint(this, "eve",
        "Before we go any further, please craft a printer and ensure that said printer is connected to the network and supplied with paper and ink",
        nil, sped)
    pktc()
    local PeripheralList = peripheral.getNames()
    local printerinst = false
    for i = 1, #PeripheralList do
        if peripheral.getType(peripheralList[i]) == "printer" then
            print = peripheral.wrap(peripheralList[i])
            printerinst = true
        end
    end
    if printerinst == false then
        aapi.cprint(this, "eve", "Printer not detected, restarting setup..", nil, sped)
        sleep(2)
        FSSetup()
    end
    local pass = false
    while pass == false do
        local success = aapi.printdocument("github", "ASReactor TOS", "docs/asreactortos.txt")
        if success == "Printed" then
            pass = trueW
        else
            aapi.cprint(this, "eve",
                "Failed to print the terms of service, please ensure there is enough paper and ink in the printer..", nil,
                sped)W
            pktc()
        end
    end
    aapi.cprint(this, "eve", "Do you agree to the terms of service?", nil, sped)
    local msg = aapi.uinput(this, "eve", sped, "yn")
    if msg == false then
        shell.run("delete andysoftreactor_launcher.lua")
        shell.run("delete andysoftreactor.lua")
        shell.run("delete startup.lua")         
        aapi.cprint(this, "eve", "TOS Rejected, uninstalling Andysoft Reactor", nil, sped)
        aapi.cprint(this, "eve", "Have a nice life :)", nil, sped)
        sleep(5)
        os.shutdown()
    end
    local function activation()
        local pass =W false

        aapi.cprint(this, "eve", "Please Insert your Product Activation Code now:", nil, sped)
        local msg = aapi.uinput(this, "eve", nil)
        for i = 1, #activationcodes do
            if msg == activationcodes[i] then
                pass = true
                tier = i
            end
        end
        if pass == true then
            aapi.cprint(this, "eve", "Activation code accepted.. Welcome "..tiers[tier].." customer!", nil, sped)
        else
            aapi.cprint(this, "eve", "Invalid code, Please try again..", nil, sped)
            sleep(3)
            activation()
        end
    end
    activation()
    function RedstoneSetup()
        local rs = nil

        local function ChannelMap()
            for i = 1, #channelmap do
                aapi.cprint(this, "eve", channelmap[i], nil, sped)
            end
        end
        aapi.cprint(this, "eve",
            "We will now enter the control surface setup.. Would you like a tutorial on how to properly set up the redstone for this system?",
            nil, sped)
        local msg = aapi.uinput(this, "eve", sped, "yn")
        if msg == "true" then
            aapi.cprint(this, "eve", "Redstone Tutorial:", nil, sped)
            aapi.cprint(this, "eve", "You will need the following materials:", nil, sped)

            aapi.cprint(this, "eve", "- 1 Redstone Integrator", nil, sped)
            aapi.cprint(this, "eve", "- 1 Computercraft Modem (plus cable to connect it to your network)", nil, sped)
            if tier > 3 then
                aapi.cprint(this, "eve", "- 28 pieces of redstone", nil, sped)
                aapi.cprint(this, "eve", "- One of the following:", nil, sped)
                aapi.cprint(this, "eve",
                    "    1) 56 Create Redstone Links (plus 56 unique blocks or items)", nil, sped)
                aapi.cprint(this, "eve",
                    "    2) 28 RFTools Redstone Recievers and Transmitters", nil, sped)
            else
                aapi.cprint(this, "eve", "- 14 pieces of redstone", nil, sped)
                aapi.cprint(this, "eve", "- One of the following:", nil, sped)
                aapi.cprint(this, "eve",
                    "    1) 28 Create Redstone Links (plus 28 unique blocks or items)", nil, sped)
                aapi.cprint(this, "eve",
                    "    2) 14 RFTools Redstone Recievers and Transmitters", nil, sped)
            end
            pktc()
            aapi.cprint(this, "eve", "Step 1: Clear out a 31x31x4 area near your control room", nil, sped)
            pktc()
            local function s1()
                aapi.cprint(this, "eve",
                    "Step 2: In the center of the room, place your Redstone Integrator while facing North", nil, sped)
                aapi.cprint(this, "eve",
                    "Step 3: Place the Modem on the south face of the Integrator, and connect the modem to the rest of the network",
                    nil, sped)
                aapi.cprint(this, "eve",
                    "Step 4: Right click on the modem, a message should appear in chat to indicate that the integrator has been connected",
                    nil, sped)
                pktc()
                aapi.cprint(this, "eve", "We will now check to ensure that it is connected...", nil, sped)
                local PeripheralList = peripheral.getNames()

                for i = 1, #PeripheralList do
                    if peripheral.getType(peripheralList[i]) == "redstoneIntegrator" then
                        rs = peripheral.wrap(peripheralList[i])
                    end
                end
                if rs == nil then
                    aapi.cprint(this, "eve", "Error, please re-read the directions and try again..", nil, sped)
                    s1()
                end
            end
            s1()
            local function s2()
                rs.setAnalogOutput("right", 14)
                if tier > 3 then
                    rs.setAnalogOutput("left", 14)
                    aapi.cprint(this, "eve",
                        "Step 4: From the East and West sides of the integrator, place 14 pieces of redstone", nil, sped)
                else
                    aapi.cprint(this, "eve",
                        "Step 4: From the East side of the integrator, place 14 pieces of redstone", nil, sped)
                end

                aapi.cprint(this, "eve", "If you have done this correctly, all of the redstone will be activated ",
                    nil, sped)
                pktc()
            end
            s2()
            local function s3()
                rs.setAnalogOutput("right", 0)
                aapi.cprint(this, "eve",
                    "Step 5: Along the EAST side of the redstone dust, place your Redstone Links or RECIEVERS according to the following diagram:",
                    nil, sped)
                aapi.cprint(this, "eve", " WWWWWWWWWWWWWW")
                aapi.cprint(this, "eve", "XRRRRRRRRRRRRRR")
                aapi.cprint(this, "eve", "X = Integrator | R = Redstone | W = Link or Recievers")
                pktc()
                if tier > 3 then
                    rs.setAnalogOutput("left", 0)
                    aapi.cprint(this, "eve",
                        "Step 5.5: Along the WEST side of the redstone dust, place your Redstone Links or TRANSMITTERS according to the following diagram:",
                        nil, sped)
                    aapi.cprint(this, "eve", "WWWWWWWWWWWWWW ")
                    aapi.cprint(this, "eve", "RRRRRRRRRRRRRRX")
                    aapi.cprint(this, "eve", "X = Integrator | R = Redstone | W = Link or Recievers")
                    pktc()
                    aapi.cprint(this, "eve",
                        "NOTE: Support for warning lights is currently in development, and will be provided in a free update",
                        nil, sped)
                end

                aapi.cprint(this, "eve",
                    "Step 6: For each reciever, place a transmitter (ensure they are linked) in the control room. Would you like to see a chart for channel mapping?",
                    nil, sped)
                local msg = aapi.uinput(this, "eve", sped, "yn")
                if msg == "true" then
                    ChannelMap()
                    pktc()
                end
                aapi.cprint(this, "eve", "We will now test the inputs..", nil, sped)
                local function rstest()
                    for i = 1, #channelmap do
                        local pass = false
                        aapi.cprint(this, "eve", "Please press the following button: " .. channelmap[i], nil, sped)
                        while pass == false do
                            local value = rs.getAnalogInput("right")
                            if value > 0 then
                                if value == 15 - i then
                                    aapi.cprint(this, "eve", "Correct input detected.. Moving on", nil, sped)
                                    pass = true
                                else
                                    aapi.cprint(this, "eve",
                                        "Incorrect input detected.. Recieved: " ..
                                        value .. " Expected: " .. i .. ".. Please Resolve", nil, sped)
                                end
                            end
                        end
                    end
                end
                rstest()
            end
            s3()
            local function s4()

            end
            s4()
        end
    end
    function ReactorCert()
        local maxburn = {}
        local bwaterbneck = false
        aapi.cprint(this,"eve","Starting the: 'Nuclear Regulatory Commission 'Approved' Reactor Certification Test.. This may take some time to complete.. Please ensure all chunks remain loaded while test is underway..",nil,sped)
        for i = 1, #Reactors do
            aapi.cprint(this,"eve","Starting test on Reactor #"..i.."..",nil,sped)
            local reactor = Reactors[i]
            local complete = false
            reactor.setBurnRate(1)
            reactor.activate()
            while complete == false do
                if reactor.isForceDisabled() == true then
                    error("Reactor is busted bro")
                end
                local rcool = reactor.getCoolantFilledPercentage()
                local rburn = reactor.getBurnRate()
                local function completed()
                    complete = true
                    reactor.setBurnRate(1)
                    reactor.scram()
                    table.insert(maxburn, (rburn - 1))
                    aapi.cprint(this,"eve","Test on Reactor #"..i.." Complete..",nil,sped)
                end
                if rcool < .95 then
                    completed()
                    aapi.cprint(this, "eve", "Coolent Bottleneck at " .. rburn, nil, sped)
                end
                for u = 1, #Boilers do
                    local boiler = Boilers[u]
                    local bwater = boiler.getWaterFilledPercentage()
                    if bwater < .90 then
                        bwaterbneck = true
                        completed()
                        aapi.cprint(this, "eve", "Boiler Water Level Bottleneck at " .. rburn, nil, sped)
                    end
                end
                if complete == false then
                    reactor.setBurnRate(rburn + .5)
                    aapi.cprint(this, "eve", "Increasing Burn Rate by .5")
                    sleep(10)
                end
            end
        end
        return (maxburn)
    end
    BR = ReactorCert()
    Battery = false
    Batnames = {}
    SM = 0
    if tier < 1 then
        disp.initDisplay(false, Displays, Monitors, Displaytypes, "/asreactor/monitorconfig.txt")
        local function Rcheck()
            if Reactors == nil then
                aapi.cprint(this, "eve",
                    "No Fission Reactors Detected.. Please ensure the reactor logic port is connected to the network and try again..",
                    nil, sped)
                pktc()
                Reactors = aapi.Pertype("fissionReactorLogicAdapter")
                Rcheck()
            else
                aapi.cprint(this, "eve",
                    "There are currently " .. #Reactors .. " Fission Reactors connected to the network, is that correct?",
                    nil, sped)
                local msg
                aapi.uinput(this, "eve", sped, "yn")
                if msg == "false" then
                    aapi.cprint(this, "eve",
                        "Connect the disconnected reactors then continue..",
                        nil, sped)
                    pktc()
                    Reactors = aapi.Pertype("fissionReactorLogicAdapter")
                    Rcheck()
                end
            end
        end
        local function Bcheck()
            if Boilers == nil then
                aapi.cprint(this, "eve",
                    "No Boilers Detected.. Please ensure the Boilers valve is connected to the network and try again..",
                    nil, sped)
                pktc()
                Boilers = aapi.Pertype("boilerValve")
                Bcheck()
            else
                aapi.cprint(this, "eve",
                    "There are currently " .. #Boilers .. " Boilers connected to the network, is that correct?",
                    nil, sped)
                local msg
                aapi.uinput(this, "eve", sped, "yn")
                if msg == "false" then
                    aapi.cprint(this, "eve",
                        "Connect the disconnected peripherals then continue..",
                        nil, sped)
                    pktc()
                    Boilers = aapi.Pertype("boilerValve")
                    Bcheck()
                end
            end
        end
        local function Tcheck()
            if Turbines == nil then
                aapi.cprint(this, "eve",
                    "No Turbines Detected.. Please ensure the turbine valve is connected to the network and try again..",
                    nil, sped)
                pktc()
                Turbines = aapi.Pertype("turbineValve")
                Tcheck()
            else
                aapi.cprint(this, "eve",
                    "There are currently " .. #Turbines .. " Turbines connected to the network, is that correct?",
                    nil, sped)
                local msg
                aapi.uinput(this, "eve", sped, "yn")
                if msg == "false" then
                    aapi.cprint(this, "eve",
                        "Connect the disconnected peripherals then continue..",
                        nil, sped)
                    pktc()
                    Turbines = aapi.Pertype("turbineValve")
                    Tcheck()
                end
            end
        end
        local function Vcheck()
            if PressureValve == nil then
                aapi.cprint(this, "eve",
                    "No Pressure Valve Detected.. Please ensure an ultimateChemicalTank is connected to the network and try again..",
                    nil, sped)
                pktc()
                PressureValve = aapi.Pertype("ultimateChemicalTank")
                Vcheck()
            else
                aapi.cprint(this, "eve",
                    "There are currently " ..
                    #PressureValve .. " PressureValves connected to the network, is that correct (number should be 1)?",
                    nil, sped)
                local msg
                aapi.uinput(this, "eve", sped, "yn")
                if msg == "false" then
                    aapi.cprint(this, "eve",
                        "Connect the disconnected peripherals then continue..",
                        nil, sped)
                    pktc()
                    PressureValve = aapi.Pertype("ultimateChemicalTank")
                    Vcheck()
                end
            end
        end
        Rcheck()
        Bcheck()
        Vcheck()
        if tier < 2 then
            Tcheck()
            local function Turbinetest()
                local tr = 0
                for i = 1, #Turbines do
                    local turbine = Turbines[1]
                    tr = tr + turbine.getMaxProduction()
                end
                return (tr)
            end
            TR = Turbinetest()
            RedstoneSetup()
            if tier < 3 then
                if Batteries ~= nil then
                    local function Bacheck()

                        if Batteries == nil then
                            aapi.cprint(this, "eve",
                                "No Batteries Detected.. Please ensure an inductionPort is connected to the network and try again..",
                                nil, sped)
                            pktc()
                            Batteries = aapi.Pertype("inductionPort")  
                            Bacheck()
                        else
                            aapi.cprint(this, "eve",
                            "There are currently "..#Batteries.." Batteries connected to the network, is that correct?",
                                nil, sped)
                            local msg
                            aapi.uinput(this, "eve", sped, "yn")
                            if msg == "false" then
                                aapi.cprint(this, "eve",
                                "Connect the disconnected peripherals then continue..",
                                    nil, sped)
                                pktc()
                                Batteries = aapi.Pertype("inductionPort")     
                                Bacheck()                                         
                            end
                        end
                    end
                    local function BatterySetup()
                        local bname = {}
                        aapi.cprint(this, "eve", "Initializing Battery Setup..", nil, sped)
                        aapi.cprint(this, "eve",
                            "Note: Battery number is determined by the order they were connected to the network.", nil,
                            sped)
                        for i = 1, #Batteries do
                            aapi.cprint(this, "eve", "Please name Battery " .. i, nil, sped)
                            local msg = aapi.uinput(this, "eve", sped)
                            table.insert(bname, msg)
                        end
                    end
                    Battery = true
                    Bacheck()
                    Batnames = BatterySetup()
                end
                aapi.cprint(this, "eve", "What would you like the margin (amount of energy over what is being consumed) for your reactor system to be (in FE)?", nil, sped)
                SM = aapi.uinput(this,"eve",sped,"num")  
            end
        end
    end
    local fs_ = fs.open("/asreactor/settings.txt", "r")
    fs_.writeLine(tier)
    fs_.writeLine(SM)
    fs_.writeLine(0)   
    fs_.writeLine(Battery)
    fs_.writeLine(Batnames)
    fs_.writeLine(TR)
    fs_.writeLine(1)
    fs_.writeLine(BR)
    fs_.close()

    -- local msg = aapi.uinput(this,"eve",sped,{"Yes","No"},false,true,false)
    -- if string.lower(msg) == "yes" then
    --     --aapi.cprint(this,"eve","",nil,sped)
    --     aapi.cprint(this, "eve", "Great! Please type your username in...", nil, sped)
    --     local msg1 = aapi.uinput(this,"eve",sped)
    --     aapi.cprint(this, "eve", "Great! Please type your password in...", nil, sped)
    --     local msg2 = aapi.uinput(this, "eve", sped, nil, nil, nil, true)

    --     local authres = net.client.send(auth,"login",{msg1,msg2})
    --     if authres == true then
    --         aapi.cprint(this,"eve","YAY IT WORKED",nil,sped)
    --     else
    --         aapi.cprint(this,"eve","SAd sad",nil,sped)       
    --     end  
    -- end

    aapi.cprint(this,"eve","Setup Complete... Please restart computer to begin reactor monitoring",nil,sped)
end    


Startup()