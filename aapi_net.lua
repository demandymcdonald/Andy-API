local aapi = require("aapi_core")
local user = require("aapi_user")
local aapi_net = {}
aapi_net.server = {}
aapi_net.client = {}
ServerFunctions = {
    redst = function()
        
    end,
    login = function(data)
        local un = data[3]
        local pw = data[4]
        local status = user.login(un, pw)
        aapi_net.server.send(data[1],"login",{status})
    end,
    userman =function(data)
        local msg = user.data.manage(data)
        if type(msg) =="table" then
            aapi_net.server.send(data[1],"userman",msg)
        else
            aapi_net.server.send(data[1],"userman",{msg})        
        end
    end,
    message = function(data)
        Data = data
        coroutine.yield()
    end,
}
function aapi_net.server.addFunction(data,name)
    if name == nil then
        name = "unnamed"
    end
    table.insert(ServerFunctions, data)
    aapi.dbg(name.." has been added to ServerFunctions")
end
function aapi_net.server.host(hosttype,subjecttype,mode)
    --Modem = peripheral.find("modem") or error("Modem not Found")
    rednet.open("left")
    rednet.host("AANET", hosttype)
    aapi.cprint(nil,"NET","Server "..hosttype.." Online")
    local function listener()
        Clients = {}
        --fs_ = fs.open("aanet_host/clients.txt")
        local msg = {}
        --local event, sender, message, protocol = 
        local event, id, msg, protocol = os.pullEvent("rednet_message")
        if protocol == "AANET" then
            if msg == "handshake" then
                rednet.send(id, "connected", "AANET")
                table.insert(Clients, id)
                aapi.cprint(nil,"NET","Handshake with client "..id)
                listener()
            elseif msg == nil then
                listener()
            elseif type == "pass" then
                aapi.cprint(nil,"NET","Incoming Packets from "..id.." with subject "..msg[1])
            else
                aapi.cprint(nil,"NET","Incoming Packets from "..id.." with subject "..msg[1])
                aapi_net.server.recieve(subjecttype,id,msg)
                listener()
            end        
        end
    end
    listener()
end
function aapi_net.server.recieve(allowlist,id,msg)
        local msggood = false
        local f1 = msg[1]
        local f2 = msg[2]
        local f3 = msg[3]
        local f4 = msg[4]
        local f5 = msg[5]
        local f6 = msg[6]
        local f7 = msg[7]
        local f8 = msg[8]
        local f9 = msg[9]
    for i=1,#allowlist do
        if f1 == allowlist[i] then
            msggood = true
            --print("msggood")
        end    
    end
    if msggood == true then
        ServerFunctions[f1]({id,f1,f2,f3,f4,f5,f6,f7,f8,f9}) 
        --aapi_net.server.send(id, subject, data_)
        --elseif type(subject) == "table" then
        --    for i = 1, #subject do
        --        if subject[i] == f1 then
        --            local data_ = { f2, f3, f4, f5, f6, f7, f8, f9 }
        --            aapi_net.server.msgFunctions(id, subject[i], data_)
        --        end
        --    end
    end
end
function aapi_net.server.send(id, subject, data)
    table.insert(data,1,subject)
    rednet.send(id, data, "AANET")
end
function aapi_net.client.turtleconnect()
    Modem = peripheral.find("modem") or error("Modem not Found")
    Hostname = 00000
    rednet.open("right")
    local netname = nil
    if fs.exists("/networkinfo.txt") then
        local fs_ = fs.open("/networkinfo.txt", "r") or 0
        netname = fs_.readLine()
        Host = rednet.lookup("AANET", netname)
        fs_.close()
        if aapi_net.handshake(Host) == true then
            aapi.cprint(nil, "net", "Connected to " .. Host)
        else
            aapi.cprint(nil, "net", "Network timeout.. trying again in 30 seconds")
            sleep(30)
            aapi_net.turtleconnect()
        end
    else
        aapi.cprint(nil, "net", "Please type in the name of the network you'd like to join:")
        netname = read()
        Host = rednet.lookup("AANET", netname)
        if Host == nil then
            aapi.cprint(nil, "net", "Incorrect Input please try again..")
        else
            local fs_ = fs.open("/networkinfo.txt", "w")
            fs_.writeLine(netname)
            fs_.close()
        end
        --textutils.tabulate(colors.orange,Host)
        --for key, value in pairs(Host) do
        --    if key == select then
        if aapi_net.handshake(Host) == true then
            aapi.cprint(nil, "net", "Connected to " .. Host)
        else
            aapi.cprint(nil, "net", "Network timeout.. trying again in 30 seconds")
            sleep(30)
            aapi_net.turtleconnect()
        end
    end
end
function aapi_net.client.fconnect(hostname)
    if type(hostname) == "string" then
        --print(hostname)
        --Modem = peripheral.find("modem")
        Hostname = 00000
        rednet.open("left")
        Hostname = rednet.lookup("AANET", hostname)
        if Hostname ~= 00000 then
            --print("yay")
            --print(Hostname)
            return(Hostname)
        else
            return(false)
        end      
    else
        return(false)
    end
end
function aapi_net.client.connect()
    Modem = peripheral.find("modem")
    Hostname = 00000
    rednet.open(peripheral.getName(Modem))
    local netname = nil
    if fs.exists("/networkinfo.txt") then
        local fs_ = fs.open("/networkinfo.txt","r") or 0
        netname = fs_.readLine()
        Host = rednet.lookup("AANET", netname)
        fs_.close()
        if aapi_net.client.handshake(Host) == true then
            aapi.cprint(nil,"net","Connected to " .. Host)
        else
            aapi.cprint(nil,"net","Network timeout.. trying again in 30 seconds")
            sleep(30)
            aapi_net.client.connect()
        end 
    else
        aapi.cprint(nil,"net","Please type in the name of the network you'd like to join:")
        netname = read()
        Host = rednet.lookup("AANET", netname)
        if Host == nil then
            aapi.cprint(nil,"net","Incorrect Input please try again..")
        else
            local fs_ = fs.open("/networkinfo.txt","w")
            fs_.writeLine(netname)
            fs_.close()     
        end
        --textutils.tabulate(colors.orange,Host)
        --for key, value in pairs(Host) do
        --    if key == select then
        if aapi_net.handshake(Host) == true then
            aapi.cprint(nil,"net","Connected to " .. Host)
        else
            aapi.cprint(nil,"net","Network timeout.. trying again in 30 seconds")
            sleep(30)
            aapi_net.turtleconnect()
        end
    end
end
function aapi_net.client.handshake(server)
    if type(server) == nil then
       --print("AAAHHH")
        return (false)
    else
        --print(server)
    end
    local mess = "handshake"
    rednet.send(server, mess, "AANET")
    local id,msg = rednet.receive("AANET", 60)
    if msg == "connected" then
        return (true)
    else
        return (false)    
    end
end
function aapi_net.client.send(id, subject, data)
    local transmit = {}
    table.insert(transmit,subject)
    if type(data) == "table" then
        for key,value in pairs(data) do
            table.insert(transmit,value)
        end
    end
    rednet.send(id, transmit, "AANET")
    local ide,msg = rednet.receive("AANET",30)
    if ide then
        if msg[1] == subject then
            return({ide,msg[2],msg[3],msg[4],msg[5],msg[6],msg[7],msg[8]})
        end
    else
        aapi.dbg("No Response from recipient, resending package...")
        aapi_net.client.send(id, subject, data)
    end
end
function aapi_net.client.recieve(id_,msg_)
    local id, msg = rednet.receive("AANET", 30)
    if id == id_ then
        if msg_ ~= nil and msg_ == msg[1] then
            return(msg)
        elseif msg == nil then
            return({id,msg})
        else
            aapi_net.client.recieve(id_,msg_)
        end
    elseif id == nil and msg == nil then
        return(false)
    else
        aapi_net.client.recieve(id_,msg_)
    end

end
function aapi_net.client.turtleRS()
    while true do
        os.pullEvent("redstone")
        local sides = { "top", "bottom", "left", "right", "front", "back" }
        for i=1,#sides do
            local input = redstone.getAnalogInput(sides[i])
            if input > 0 then
                local data = {"redstone",sides[i], input}
                
            end
        end
    end
end
function aapi_net.AANETEvent(event, id, msg, datatype)
    if event == "AANET" then
        local type_ = msg[1]
        local val1 = msg[2] or nil
        local val2 = msg[3] or nil
        local val3 = msg[4] or nil
        local val4 = msg[5] or nil
        if type_ == datatype then
            return ({ val1, val2, val3, val4 })
        end
    end
end
function aapi_net.client.ACHostConnect()
    Modem = peripheral.find("modem")
    rednet.open(peripheral.getName(Modem))
    local host = rednet.lookup("AANET","AndyCorp")
    --print(host)
    --print("------")
    if aapi_net.client.handshake(host) == true then
        return(host)
    end
end   
return aapi_net