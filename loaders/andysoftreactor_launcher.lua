term.clear()
term.setCursorPos(1, 1)
local activationcodes = {}
activationcodes["Basic"] = "Rxr8BzslZRTHEB"
activationcodes["Gold"] = "OKhUcx0wFKDzuj"
activationcodes["Platnum"] = "FgIkhbvGKinpjd"
activationcodes["PlatnumPLUS"] = "2p59HcUjmf2kMe"
local tiers = {"Basic","Gold","Platnum","PlatnumPLUS"}
local tier = 0
Version = "d"
Testing = true
local aapi = require("aapi_core")
local disp = require("aapi_display")
local audio = require("aapi_audio")
local channelmap = {"15 = Scram","14 = Power On","13 = Power Off","12 = Reset Alarm","11 = Burn Rate Up (.5)","10 = Burn Rate Up (.1)","9 = Reset Burn Rate","8 = Burn Rate Down (.1)","7 = Burn Rate Down (.5)","6 = Change Selected Reactor (+)","5 = Change Selected Reactor (-)","4 = Facility Shutdown","3 = Enable/Disable Automatic Ctrl"}
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
        Condensers = aapi.Pertype("rotaryCondensentrator")
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
    Surmargin = 10
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
    aapi.cprint(this, "eve",
    "Please select the language you wish to use. Your options are: English, Ingles, and Englisch", nil, sped)
    aapi.uinput(this, "eve", sped, { "English", "Ingles", "Englisch" }, nil, { "English", "Ingles", "Englisch" })
    aapi.cprint(this, "eve",
        "Note: Due to bugs in the GUI2 update, this reactor will be running the 'alpha' gui. GUI2 will be rolled out with the fusion update.",
        nil, sped)
    sleep(5)
    aapi.cprint(this,"eve","Hello, my name is EVE.",nil,sped)
    aapi.cprint(this, "eve", "I'm your AI Reactor Controller. I'm here to guide you through the setup process!", nil, sped)

    aapi.cprint(this, "eve",
        "Before we go any further, please craft a printer and ensure that said printer is connected to the network and supplied with paper and ink",
        nil, sped)
    pktc()

    local PeripheralList = peripheral.getNames()
    local printerinst = false
    for i = 1, #PeripheralList do
        if peripheral.getType(PeripheralList[i]) == "printer" then
            Main_printer = peripheral.wrap(PeripheralList[i])
            printerinst = true
        end
    end
    if printerinst == false then
        aapi.cprint(this, "eve", "Printer not detected, restarting setup..", nil, sped)
        sleep(2)
        FSSetup()
    end
    if Testing == false then
    aapi.cprint(this, "eve", "Printing TOS, Please look over documents to continue", nil, sped)    
    local pass = false
    while pass == false do
        local success = aapi.printdocument(Main_printer,"github", "ASReactor TOS", {"docs/asreactortos.txt","asreactortos.txt"})
        if success == "Printed" then
            pass = true
        else
            aapi.cprint(this, "eve",
                "Failed to print the terms of service, please ensure there is enough paper and ink in the printer..", nil,
                sped)
            pktc()
        end
    end
    aapi.cprint(this, "eve", "Do you agree to the terms of service?", nil, sped)
    local msg = aapi.uinput(this, "eve", sped, "yn")
    if msg == "false" then
        shell.run("delete andysoftreactor_launcher.lua")
        shell.run("delete andysoftreactor.lua")
        shell.run("delete startup.lua")
        aapi.cprint(this, "eve", "TOS Rejected, uninstalling Andysoft Reactor", nil, sped)
        aapi.cprint(this, "eve", "Have a nice life :)", nil, sped)
        sleep(5)
        os.shutdown()
    end

    local function activation()
        local pass = false

        aapi.cprint(this, "eve", "Please Insert your Product Activation Code now:", nil, sped)
        local msg = aapi.uinput(this, "eve", nil)
        local seltier = 0
        for key, value in pairs(activationcodes) do
            seltier = seltier + 1
            if msg == activationcodes[value] then
                pass = true
                tier = seltier
            end
        end
            if pass == true then
                aapi.cprint(this, "eve", "Activation code accepted.. Welcome " .. tiers[tier] .. " customer!", nil, sped)
            else
                aapi.cprint(this, "eve", "Invalid code, Please try again..", nil, sped)
                sleep(3)
                activation()
            end
        if tier == 4 then
            if Testing == false then
                aapi.cprint(this, "eve", "Printing PlatnumPLUS 48 Hour Support TOS, Please look over documents to continue", nil, sped)    
                local pass = false
                while pass == false do
                    local success = aapi.printdocument(Main_printer,"github", "ASR P+ Support TOS", {"docs/asreactorsupporttos.txt","asreactorsupporttos.txt"})
                    if success == "Printed" then
                        pass = true
                    end
                end
            end
        end
    end
    activation()
    else
        tier = 4
    end
    aapi.cprint(this, "eve", "Let's start setting up your reactor", nil, sped)
    local function SIUconfig()
        aapi.cprint(this, "eve",
            "What unit would you like your power to be measured in?",
            nil, sped)
        aapi.cprint(this, "eve",
            "Your options are: FE,EU,RF,J",
            nil, sped)
        Energyunit = aapi.uinput(this, "eve", sped, { "FE", "EU", "RF", "J" }, nil)
        aapi.cprint(this, "eve",
            "What unit would you like tempeture to be measured in?",
            nil, sped)
        aapi.cprint(this, "eve",
            "Your options are: F,C, and K",
            nil, sped)
        Tempunit = aapi.uinput(this, "eve", sped, { "C","F","K" }, nil)
    end
    SIUconfig()

    local SodTable = {}
    local BoiTable = {}
    function SodiumSetup()
        local systemtype = "null"
        local function SodiumInstall()
            aapi.cprint(this, "eve", "What kind of sodium coolent setup do you have?", nil, sped)
            aapi.cprint(this, "eve",
                "1. Universal: ALL Boilers are Connected to ALL reators and ALL Reactors are connected to the SAME source of Sodium",
                nil, sped)
            aapi.cprint(this, "eve",
                "2. Segregated: each reactor is connected to it's own boilers and sodium sources, which are not connected to any other reactors",
                nil, sped)
            local msg = aapi.uinput(this,"eve",sped,{"1","2"},true)
            if msg == "1" then 
                systemtype = "uni"
                aapi.cprint(this, "eve", "Universal system type selected..", nil, sped)  
            elseif msg == "2" then
                systemtype = "seg"
                aapi.cprint(this, "eve", "Segregated system type selected..", nil, sped)
            else
                error("Something has gone horribly wrong! Please fix!")
            end
            sleep(.5)
            aapi.cprint(this, "eve",
                "Due to changes in how AS Reactor manages sodium, all sodium entering the system is required to be in liquid form. The sodium will be converted into its gassious form using rotery condensentrators.",
                nil, sped)
                if systemtype == "uni" then
                    aapi.cprint(this, "eve", "Step 1: To begin, please ensure that you have a dynamic tank with liquid sodium being imputted into it.", nil, sped)    
                    pktc()
                    aapi.cprint(this, "eve", "Step 2: Using mechanical pipes, please connect the liquid sodium tank to a bank of rotery condensentrators")
                    pktc()
                    aapi.cprint(this, "eve", "Step 3: Using Pressurized tubes, please connect the rotery condensentrators to an import port in your reactor", nil, sped)  
                    pktc()                    
                    aapi.cprint(this, "eve", "Step 4: Connect each rotery condensentrators to your network by modem and modem cable", nil, sped)  
                    pktc()  
                    aapi.cprint(this, "eve", "Step 5: Ensure that the rotery condensentrators are properly configured to output gas and input fluid.", nil, sped)  
                    pktc()  
                end 
                if systemtype == "seg" then
                    aapi.cprint(this, "eve", "Note: for the following instructions, ensure that you do all of them for each individual reactor", nil, sped)
                    pktc() 
                    aapi.cprint(this, "eve", "Step 1: To begin, please ensure that you have a dynamic tank with liquid sodium being imputted into it.", nil, sped)    
                    pktc()
                    aapi.cprint(this, "eve", "Step 2: Using mechanical pipes, please connect the liquid sodium tank to a bank of rotery condensentrators")
                    pktc()
                    aapi.cprint(this, "eve", "Step 3: Using Pressurized tubes, please connect the rotery condensentrators to an import port in your reactor", nil, sped)  
                    pktc()                    
                    aapi.cprint(this, "eve", "Step 4: Connect each rotery condensentrators to your network by modem and modem cable, MAKE NOTE OF WHAT NUMBER (i.e. roteryCondensentrator_0) is provided in chat for each condensentrator you attach (separate by reactor).", nil, sped)  
                    pktc()  
                    aapi.cprint(this, "eve", "Step 5: Ensure that the rotery condensentrators are properly configured to output gas and input fluid.", nil, sped)  
                    pktc()  
                    aapi.cprint(this, "eve", "Step 6: if you have not done so already, please ensure that your boilers are connected to the network. Make sure you note the number associated with each one so you can bind it in the next phase of installation.", nil, sped)                      
                end            
        end
        local function SodiumConfig()
            if systemtype == "uni" then
                aapi.cprint(this, "eve", "Configuring SodiumMAN, Please wait...", nil, sped)
                SodTable["R1"] = {}
                BoiTable["R1"] = {}
                for i=1,#Boilers do
                    table.insert(BoiTable["R1"],Condensers[i])
                end
                for i=1,#Condensers do
                    table.insert(SodTable["R1"],Boilers[i])
                end
                sleep(5)
                aapi.cprint(this, "eve", "SodiumMAN Installation Complete!", nil, sped)
            elseif systemtype == "seg" then
                aapi.cprint(this, "eve", "Launching SodiumMAN Configuration Wizard..", nil, sped)
                local boilist = {"end"}
                local conlist = {"end"}
                for i=1,#Boilers do
                    local val = textutils.serialize(i-1)
                    table.insert(boilist,val)
                end
                for i=1,#Condensers do
                    local val = textutils.serialize(i-1)
                    table.insert(conlist,val)
                end
                for i=1,#Reactors do
                    aapi.cprint(this, "eve", "Starting setup for Reactor #"..i, nil, sped)
                    local nombre = "R"..i
                    SodTable[nombre] = {}
                    BoiTable[nombre] = {}
                    aapi.cprint(this, "eve", "Which boilers are connected to Reactor #"..i, nil, sped)
                    aapi.cprint(this, "eve", "Type one number at a time, and type end when complete", nil, sped)
                    aapi.cprint(this, "eve", "Boiler numbers are between 0 and "..#Boilers, nil, sped)
                    local looper = true
                    while looper == true do 
                        local msg = aapi.uinput(this,"eve",sped,boilist)
                        local dcm = textutils.unserialize(msg)
                        if msg == "end" then
                            looper = false
                        elseif type(dcm) == "number" then
                            table.insert(BoiTable[nombre],Boilers[dcm])
                        end
                    end
                    aapi.cprint(this, "eve", "Which condensentrators are connected to Reactor #"..i, nil, sped)
                    aapi.cprint(this, "eve", "Type one number at a time, and type end when complete", nil, sped)
                    aapi.cprint(this, "eve", "Condensentrators numbers are between 0 and "..#Condensers, nil, sped)
                    while looper == true do 
                        local msg = aapi.uinput(this,"eve",sped,conlist)
                        local dcm = textutils.unserialize(msg)
                        if msg == "end" then
                            looper = false
                        elseif type(dcm) == "number" then
                            table.insert(SodTable[nombre],Condensers[dcm])
                        end
                    end
                end
                sleep(1)
                aapi.cprint(this, "eve", "SodiumMAN Installation Complete!", nil, sped)
            end
        end
        aapi.cprint(this, "eve", "Would you like a tutorial on how to set up your Sodium Coolent", nil, sped)
        local msg = aapi.uinput(this, "eve", sped, "yn")
        if msg == "false" then
            aapi.cprint(this, "eve",
                "Note: Andysoft is not liable for any damages incured due to incompatibilities between the SodiumMAN software and your reactor setup and may charge an additional fee for any service calls involving incompatibilities (regardless of plan tier). Are you sure you want to skip the setup walkthrough?",
                nil, sped)
            local msg = aapi.uinput(this, "eve", sped, "yn")
            if msg == true then
                SodiumConfig()
            else
                SodiumInstall()
            end
        else
            SodiumInstall()
        end
    end
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
                    if peripheral.getType(PeripheralList[i]) == "redstoneIntegrator" then
                        rs = peripheral.wrap(PeripheralList[i])
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
                                if value == i then
                                    aapi.cprint(this, "eve", "Correct input detected.. Moving on", nil, sped)
                                    pass = true
                                    sleep(5)
                                else
                                    aapi.cprint(this, "eve",
                                        "Incorrect input detected.. Recieved: " ..
                                        value .. " Expected: " .. i .. ".. Please Resolve", nil, sped)
                                    sleep(5)
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
    function Rcheck()
        aapi.PeripheralSetup()
        if #Reactors == 0 then
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
    function Bcheck()
        aapi.PeripheralSetup()
        if #Boilers == 0 then
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
    function Tcheck()
        aapi.PeripheralSetup()
        if #Turbines == 0 then
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
    Battery = false
    Batnames = {}
    SM = 0
    if tier > 0 then
        disp.initDisplay(false, Displays, Monitors, Displaytypes, "/asreactor/monitorconfig.txt",this)

        -- local function Vcheck()
        --     aapi.PeripheralSetup()
        --     if #PressureValve == 0 then
        --         aapi.cprint(this, "eve",
        --             "No Pressure Valve Detected.. Please ensure an ultimateChemicalTank is connected to the network and try again..",
        --             nil, sped)
        --         pktc()
        --         PressureValve = aapi.Pertype("ultimateChemicalTank")
        --         Vcheck()
        --     else
        --         aapi.cprint(this, "eve",
        --             "There are currently " ..
        --             #PressureValve .. " PressureValves connected to the network, is that correct (number should be 1)?",
        --             nil, sped)
        --         local msg
        --         aapi.uinput(this, "eve", sped, "yn")
        --         if msg == "false" then
        --             aapi.cprint(this, "eve",
        --                 "Connect the disconnected peripherals then continue..",
        --                 nil, sped)
        --             pktc()
        --             PressureValve = aapi.Pertype("ultimateChemicalTank")
        --             Vcheck()
        --         end
        --     end
        -- end
        Rcheck()
        Bcheck()
        SodiumSetup()
        --Vcheck()
        BR = ReactorCert()
        if tier > 1 then

            Tcheck()
            local function Turbinetest()
                local blades = 0
                for i = 1, #Turbines do
                    blades = blades + Turbines[i].getBlades()
                end
                local result = blades * 7140
                return (result)
            end

            TR = Turbinetest()
            RedstoneSetup()
            if tier > 2 then
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
                        return(bname)
                    end
                    Battery = true
                    Bacheck()
                    Batnames = BatterySetup()
                end
                aapi.cprint(this, "eve", "What would you like the margin (percentage produced above what is being consumed)?", nil, sped)
                SM = aapi.uinput(this,"eve",sped,"num") /100 + 1  
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
    fs_.writeLine(Energyunit)
    fs_.writeLine(Tempunit)
    fs_.writeLine(0)
    fs_.writeLine({})   
    fs_.writeLine(SodTable) 
    fs_.writeLine(BoiTable)  
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