local user = {}
local aapi = require("aapi_core")
local aapi_user = user
local USERTEMP = "zxzxzxxz"
user.client = {}
user.data = {}
function user.data.Init(list)
    DataPattern = ""
    DataTemplate = "0"
    DataNum = 0
    DataTypes = list
    for key, value in pairs(list) do
        DataNum = DataNum + 1
        DataPattern = DataPattern .. "zx"
        DataTemplate = "0" .. "0"
    end
end
function user.data.encoder(dataTable)
    local result = ""
    for key, value in pairs(dataTable) do
        result = result .. value
    end
    return(result)
end
function user.data.userDB()
    Serverkey = nil
    UserDB = {}
    if fs.exists("/user_database") then
        aapi.cprint(nil, "user", "Database Folder Created..")
        local fs_ = fs.open("/user_database/key.txt", "r")
        Serverkey = fs_.readLine()
        fs_.close()
        Lastid = 0
        local fs_ = fs.open("/user_database/users.txt", "r")
        while true do
            local line = fs_.readLine()
            if line == nil then
                return
            else
                Lastid = Lastid + 1
                local id, un, pw, data_ = string.unpack(USERTEMP, line)
                --local PR = line[4]
                UserDB[id] = {}
                UserDB[id]["IDN"] = id
                UserDB[id]["UN"] = un
                UserDB[id]["PW"] = pw / Serverkey
                UserDB[id]["DATA"] = {}
                local count = 1
                for key, value in pairs(DataTypes) do
                    local c = string.sub(data_, count, count)
                    if c == "" then
                        c = "0"
                    end
                    UserDB[id]["DATA"][value] = c
                    count = count + 1
                end
            end
            -- If line is nil then we've reached the end of the file and should stop
        end
    else
        Lastid = 0
        fs.makeDir("/user_database")
        local fs_ = fs.open("/user_database/users.txt", "w")
        fs_.close()
        Serverkey = math.random(5000000, 7800000000000)
        local fs_ = fs.open("/user_database/key.txt", "w")
        fs_.writeLine(Serverkey)
        fs_.close()
    end
end
--[[
    UserDB[id] = {}
    UserDB[id]["UN"] = un
    UserDB[id]["PW"] = pw / Serverkey
    UserDB[id]["DATA"] = {} 
    UserDB[id]["DATA"]["1"] = 0
]]
function user.data.save()
    local fs_ = fs.open("/user_database/users.txt", "w")
    for key, value in pairs(UserDB) do
        local save = user.data.encoder(value["DATA"])
        local encode = string.pack(USERTEMP, value["IDN"], value["UN"], value["PW"] * Serverkey, save)
        --left off here ahhh, add in encoder, and save to file plz!
        fs_.writeLine(encode)
        aapi.dbg(value["UN"] .. " with data: " .. save .. " Saved")
    end
    fs_.close()
end
function user.data.manage(data_)
    local type = data_[3]
    local key = data_[8]
    local un = data_[4]
    local pw = data_[5]
    local val1 = data_[6]
    local val2 = data_[7]
    local result = nil
    local types = {
        lookup = function()
            local found = false
            for key, value in pairs(UserDB) do
                if value["UN"] == un then
                    aapi.dbg("User Match found.. Updating Data")
                    result = string.pack(USERTEMP, value["IDN"], value["UN"], value["PW"], user.data.encoder(value["DATA"]))
                    print(result)
                    found = true
                else
                    aapi.dbg(value["UN"] .. " does not match " .. un)
                end
            end
            if found == false then
                result = "false"
            end
        end,
        userlist = function()
            result = {}
            for key, value in pairs(UserDB) do
                local entry = string.pack(USERTEMP, value["IDN"], value["UN"], value["PW"], user.data.encoder(value["DATA"]))
                aapi.dbg(entry)
                table.insert(result,entry)        
            end
        end,
        useradd = function()
            local function unchecklite()
                for key, value in pairs(UserDB) do
                    if value["UN"] == un then
                        aapi.dbg("User Match found.. Updating Data")
                        return (true)
                    else
                        aapi.dbg(value["UN"] .. " does not match " .. un)
                    end
                end
                return(false)
            end
            if unchecklite() == false then
                user.adduser(un, pw)
                result = "added"
            else
                result = "taken"
            end
        end,
        usermodify = function()
            local found = false
            for key, value in pairs(UserDB) do
                if value["UN"] == un then
                    value["DATA"][val1] = val2
                    found = true
                    user.data.save()     
                else
                    aapi.dbg(value["UN"] .. " does not match " .. un)
                end
            end
        end,
        getdatatype = function()
            result = DataTypes
        end,
    }
    types[type]()

    return(result)
end
function user.login(uname,pass)
    local badun = true
    local badpw = true
    for key, value in pairs(UserDB) do
        aapi.dbg("Input: " .. value["UN"] .. " Checked against: " .. uname)
        aapi.dbg("Input: "..value["PW"].." Checked against: "..string.byte(pass))
        local cpass = nil
        if type(value["PW"]) == "number" then
            cpass = textutils.serialize(value["PW"])
        else
            cpass = value["PW"]
        end
        if value["UN"] == uname then
            badun = false
            aapi.dbg("Good UN")
            if cpass == string.byte(pass) then
                badpw = false
                aapi.dbg("Good PW")
            else
                aapi.dbg("Failed PW Check")
            end
            break
        end
    end
    if badun == true then
        aapi.cprint(nil, "user", "Bad UN")

        return (false)
    elseif badpw == true then
        aapi.cprint(nil, "user", "Bad PW")
        return (false)
    else
        aapi.cprint(nil, "user", "Login Successful for user: "..uname)
        return(true)
    end
end
function user.adduser(un, pw)
    local id = Lastid + 1
    local savedata = ""
    UserDB[id] = {}
    UserDB[id]["IDN"] = id
    UserDB[id]["UN"] = un
    UserDB[id]["PW"] = string.byte(pw)
    UserDB[id]["DATA"] = {}
    local count = 1
    for key, value in pairs(DataTypes) do
        UserDB[id]["DATA"][value] = 0
        savedata = savedata.."0"
    end
    local fs_ = fs.open("/user_database/users.txt", "a")

    local encode = string.pack(USERTEMP,id,un,UserDB[id]["PW"]* Serverkey,savedata)
    fs_.writeLine(encode)
    fs_.close()
    Lastid = Lastid + 1

end

return aapi_user