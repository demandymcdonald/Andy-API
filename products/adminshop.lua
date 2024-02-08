Aapi = require("aapi_core")
local DebugLogFiles = "SpawnManager/debuglogs/"
Aapi.initDebug(DebugLogFiles)
Debugmode = true
PriceList = {}
--Price format item {Price = price, Inf = inflation, Num = numsold}
function Startup()
    local PeripheralList = peripheral.getNames()
    for i = 1, #PeripheralList, 1 do
        if PeripheralList[i] == "trashcans:ultimate_trash_can_tile" then
            Dispose = peripheral.wrap(PeripheralList[i])
        elseif PeripheralList[i] == "sophisticatedstorage:limited_barrel" then
            Inv = peripheral.wrap(PeripheralList[i])
        end
    end
    PriceList = Aapi.FM("initialize","/AS/MarketPrice")
end
function Savelist()
    Aapi.FM("save", "/AS/MarketPrice", PriceList)
end
local function addObject(name, price)
        local nombre = name
        name = {}
        name["Dname"] = nombre    
        name["Price"] = price
        name["Inf"] = 1
        name["Num"] = 0
    table.insert(PriceList, name)
    Aapi.dbg(name["Dname"].." added at the price of "..name["Price"])
end
local function buy()
    local upforoffer = {}
    for slot, item in pairs(Inv.list()) do
        if item then
            local itemprice = 0
            local iteminf = 1
            local itemnum = 1
            local slotitem = inv.getItemDetail(slot)
            for key, item_ in pairs(PriceList) do
                if item == item_.Dname then
                    itemprice = item_.Price
                    iteminf = item_.Inf
                    itemnum = item_.Num
                end
            end
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
Startup()
addObject("minecraft:cobblestone", 0.001)
addObject("minecraft:dirt",0.001)
buy()
