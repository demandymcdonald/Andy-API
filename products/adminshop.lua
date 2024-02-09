Aapi = require("aapi_core")
local DebugLogFiles = "SpawnManager/debuglogs/"
Aapi.initDebug(DebugLogFiles)
Debugmode = true
PriceList = {}
Inv = {}
Dispose = {}
--Price format item {Price = price, Inf = inflation, Num = numsold}
function Startup()
    local PeripheralList = peripheral.getNames()
    for i = 1, #PeripheralList do
        if peripheral.getType(PeripheralList[i]) == "trashcans:ultimate_trash_can_tile" then
            Dispose = peripheral.wrap(PeripheralList[i])
            Aapi.dbg("Dispose Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "sophisticatedstorage:shulker_box" then
            Inv = peripheral.wrap(PeripheralList[i])
            Aapi.dbg("Inv Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "sophisticatedstorage:limited_barrel" then
            Coinbox = peripheral.wrap(PeripheralList[i])
            Aapi.dbg("Coin Box Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "create:creative_crate" then
            Coinsrc = peripheral.wrap(PeripheralList[i])
            Aapi.dbg("Coin Source")
        end
    end
    PriceList = Aapi.FM("initialize", "/AS")
    if PriceList == nil then
        PriceList = {}
    end
    sleep(1)
    term.clear()
    term.setCursorPos(1,1)
end
Startup()
function Savelist()
    if Aapi.FM("save", "/AS/MarketPrice.txt", PriceList) == 1 then
        return
    end
end
local function bulkaddObject()
    if Inv.list() then
        for slot, item in pairs(Inv.list()) do
            local name = nil
            local price = nil
            if item then
                local slotitem = Inv.getItemDetail(slot)
                if slotitem then
                    local iname = slotitem.name
                    name = slotitem.displayName
                    Aapi.cprint(nil,"Eve",slotitem.displayName .. " Set base price: ")
                    price = Aapi.uinput(nil,"Eve", nil, "num")
                    iname = {}
                    iname["Name"] = slotitem.name
                    iname["Dname"] = name
                    iname["Price"] = price
                    iname["Inf"] = 1
                    iname["Num"] = 0
                    table.insert(PriceList, iname)
                    Aapi.dbg(iname["Dname"] .. " added at the price of " .. iname["Price"])
                    sleep(1)   
                    end
            end
        end
    end
    Savelist()
end
local function scanchest()
    local upforoffer = {}
    local total = 0
    for slot, item in pairs(Inv.list()) do
        if item then
            local itemprice = tonumber(0)
            local iteminf = tonumber(1)
            local itemnum = tonumber(1)
            local slotitem = Inv.getItemDetail(slot)
            for key, item_ in pairs(PriceList) do
                if item.name == item_["Name"] then
                    itemprice = tonumber(item_["Price"])
                    iteminf = tonumber(item_["Inf"])
                    itemnum = tonumber(item_["Num"])
                    Aapi.dbg("Name: " .. item_["Name"])
                    Aapi.dbg("Price: " .. item_["Price"])
                    Aapi.dbg("Inflation: " .. item_["Inf"])
                    Aapi.dbg("Qty: " .. item_["Num"])                   
                end

            end
            if slotitem then
                local lineitem = {}
                lineitem["Name"] = slotitem.displayName
                lineitem["Qty"] = slotitem.count
                lineitem["Price"] = (itemprice / iteminf)
                lineitem["Futureinf"] = (iteminf + ((slotitem.count + itemnum) * .08))
                lineitem["NewQty"] = slotitem.count + itemnum
                table.insert(upforoffer, lineitem)
            end
        end
    end
    for key, value in pairs(upforoffer) do
        local stot = value["Qty"] * value["Price"]
        total = stot + total
        Aapi.dbg("Subtotal: " .. stot)
      
    end
        Aapi.dbg("Total: " .. total)  
    return({upforoffer,total})
end
local function sell()
    local msg = read()
    local offer, total = scanchest()[1], scanchest()[2]
    local accepted = false
    local function redstone()
        while accepted == false do
            os.pullEvent("redstone")
            print("A redstone input has changed!")
            accepted = true
        end
    end
    local function scaninv()
        while accepted == false do
            offer, total = scanchest()[1], scanchest()[2]
            sleep(1)
        end
    end
    parallel.waitForAll(redstone, scaninv)
    print("it worked!!!")
    Aapi.cprint(nil, "Store", "Please type in the username that you'd like to have the funds sent to: ")
    local username = Aapi.uinput(nil, "Store", nil, nil, true)
    for slot, item in pairs(Inv.list()) do
        if item then
            Inv.pushItems(peripheral.getName(Dispose), slot)
        end
    end
---@diagnostic disable-next-line: param-type-mismatch
    Coinsrc.pushItems(peripheral.getName(Coinbox), 1,total)
end

bulkaddObject()
sell()
