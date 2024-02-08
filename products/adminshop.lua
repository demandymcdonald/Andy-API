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
    for i = 1, #PeripheralList, 1 do
        if PeripheralList[i] == "trashcans:ultimate_trash_can_tile" then
            Dispose = peripheral.wrap(PeripheralList[i])
            Aapi.dbg("Dispose Wrapped")
        elseif PeripheralList[i] == "sophisticatedstorage:shulker_box" then
            Inv = peripheral.wrap(PeripheralList[i])
            Aapi.dbg("Inv Wrapped")
        end
    end
    PriceList = Aapi.FM("initialize", "/AS/MarketPrice.txt")
    if PriceList == nil then
        PriceList = {}
    end
end
function Savelist()
    Aapi.FM("save", "/AS/MarketPrice.txt", PriceList)
end
local function addObject(name, price)
    local nombre = name
    name = {}
    name["Dname"] = nombre
    name["Price"] = price
    name["Inf"] = 1
    name["Num"] = 0
    table.insert(PriceList, name)
    Aapi.dbg(name["Dname"] .. " added at the price of " .. name["Price"])
    Savelist()
end
local function bulkaddObject()
    for slot, item in pairs(Inv.list()) do
        local name = nil
        local price = nil
        if item then
            local slotitem = Inv.getItemDetail(slot)
            if slotitem then 
                print(slotitem.displayName .. " Set base price: ")
                price = Aapi.uinput(nil, "EVE", nil, "num")
                local nombre = name
                name = {}
                name["Dname"] = nombre
                name["Price"] = price
                name["Inf"] = 1
                name["Num"] = 0
                table.insert(PriceList, name)
                Aapi.dbg(name["Dname"] .. " added at the price of " .. name["Price"])
            end
        end
    end
    Savelist()
end
local function buy()
    local upforoffer = {}
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
end
Startup()
addObject("minecraft:cobblestone", 0.001)
addObject("minecraft:dirt", 0.001)
bulkaddObject()
buy()
