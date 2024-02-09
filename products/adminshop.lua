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
        end
    end
    PriceList = Aapi.FM("initialize", "/AS")
    if PriceList == nil then
        PriceList = {}
    end
end
Startup()
function Savelist()
    if Aapi.FM("save", "/AS/MarketPrice.txt", PriceList) == 1 then
        return
    end
end
local function addObject(name, price)
    local nobj = {}
    nobj["Dname"] = name
    nobj["Price"] = price
    nobj["Inf"] = 1
    nobj["Num"] = 0
    table.insert(PriceList, nobj)
    Aapi.dbg(name["Dname"] .. " added at the price of " .. name["Price"])
    Savelist()
end
local function bulkaddObject()
    if Inv.list() then
        for slot, item in pairs(Inv.list()) do
            local name = nil
            local price = nil
            if item then
                local slotitem = Inv.getItemDetail(slot)
                if slotitem then 
                    Aapi.cprint(nil,"Eve",slotitem.displayName .. " Set base price: ")
                    price = Aapi.uinput(nil, "Eve", nil, "num")
                    local nobj = {}
                    nobj["Dname"] = name
                    nobj["Price"] = price
                    nobj["Inf"] = 1
                    nobj["Num"] = 0
                    table.insert(PriceList, nobj)
                    Aapi.dbg(name["Dname"] .. " added at the price of " .. name["Price"])
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
            local itemprice = 0
            local iteminf = 1
            local itemnum = 1
            local slotitem = Inv.getItemDetail(slot)
            for key, item_ in pairs(PriceList) do
                if item == item_.Dname then
                    itemprice = item_.Price
                    iteminf = item_.Inf
                    itemnum = item_.Num
                end
            end
            if slotitem then
                local lineitem = {
                    Name = slotitem.displayName,
                    Qty = slotitem.count,
                    Price = (itemprice / iteminf),
                    Futureinf = (iteminf + ((slotitem.count + itemnum) * .08)),
                    NewQty = slotitem.count + itemnum
                }
                table.insert(upforoffer, lineitem)
                textutils.tabulate(lineitem)
            end
        end
    end
    for key, value in pairs(upforoffer) do
        local lqty = value[2]
        local lpri = value[3]
        local stot = lqty * lpri
        total = stot + total
    end

    return({upforoffer,total})
end
local function sell()
    local offer,total = scanchest()[1],scanchest()[2]
    local function redstone()
        while true do
            os.pullEvent("redstone")
            print("A redstone input has changed!")
        end
    end
    local function scaninv()
        offer,total = scanchest()[1],scanchest()[2]
        sleep(5)  
    end
end

addObject("minecraft:cobblestone", 0.001)
addObject("minecraft:dirt", 0.001)
bulkaddObject()
sell()
