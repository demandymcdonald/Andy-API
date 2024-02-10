local aapi = require("aapi_core")
local disp = require("aapi_display")
sleep(2)
local DebugLogFiles = "SpawnManager/debuglogs/"
aapi.initDebug(DebugLogFiles)
Debugmode = true
PriceList = {}
Inv = {}
Dispose = {}
sleep(1)
term.clear()
term.setCursorPos(1,1)
--Price format item {Price = price, Inf = inflation, Num = numsold}
function Startup()
    local PeripheralList = peripheral.getNames()
    for i = 1, #PeripheralList do
        if peripheral.getType(PeripheralList[i]) == "trashcans:ultimate_trash_can_tile" then
            Dispose = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Dispose Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "sophisticatedstorage:shulker_box" then
            Inv = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Inv Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "sophisticatedstorage:limited_barrel" then
            Coinbox = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Coin Box Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "create:creative_crate" then
            Coinsrc = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Coin Source Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "monitor" then
            Mon = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Monitor Wrapped")
        end
    end
    PriceList = aapi.FM("initialize", "/AS")
    if PriceList == nil then
        PriceList = {}
    end
    --disp.initDisplay()
    disp.addWindow(Mon,"Main","The Company Store",0,0,1,1,colors.black,true)
end
Startup()
sleep(1)
function Savelist()
    if aapi.FM("save", "/AS/MarketPrice.txt", PriceList) == 1 then
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
                    aapi.cprint(nil,"Eve",slotitem.displayName .. " Set base price: ")
                    price = aapi.uinput(nil,"Eve", nil, "num")
                    iname = {}
                    iname["Name"] = slotitem.name
                    iname["Dname"] = name
                    iname["Price"] = price
                    iname["Inf"] = 1
                    iname["Num"] = 0
                    table.insert(PriceList, iname)
                    aapi.dbg(iname["Dname"] .. " added at the price of " .. iname["Price"])
                    sleep(1)   
                    end
            end
        end
    end
    Savelist()
end
local function scanchest()
    w_Main.clear()
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
                    itemprice = item_["Price"]
                    iteminf = tonumber(item_["Inf"])
                    itemnum = tonumber(item_["Num"])
                    aapi.dbg("Name: " .. item_["Name"])
                    aapi.dbg("Price: " .. itemprice)
                    aapi.dbg("Inflation: " .. item_["Inf"])
                    aapi.dbg("Qty: " .. item_["Num"])
                    sleep(1)
                end
            end
            if slotitem then
                local lineitem = {}
                lineitem["Name"] = slotitem.displayName
                lineitem["Qty"] = slotitem.count
                lineitem["Price"] = (itemprice / iteminf)
                lineitem["Futureinf"] = (iteminf + ((slotitem.count + itemnum) * .08))
                lineitem["NewQty"] = slotitem.count + itemnum
                lineitem["Subtot"] = itemprice * slotitem.count
                table.insert(upforoffer, lineitem)
                local cx, cy = w_Main.getCursorPos()
                w_Main.setCursorPos(1,cy+1)
                w_Main.write(lineitem["Qty"] .."x" .. lineitem["Name"] .. " @ " .. lineitem["Price"] .. " | " .. lineitem["Subtot"])
                
            end
        end
    end
    
    for key, value in pairs(upforoffer) do
        total = value["Subtot"] + total
    end
    --disp.arrayTabulate(w_Main, upforoffer, 1)
    local cx, cy = w_Main.getCursorPos()
    w_Main.setCursorPos(1,cy+1)
    w_Main.write("Total Payout: "..total)
    aapi.dbg("Total: " .. total)
    return({upforoffer,total})
end
local function sell()
    local msg = read()
    local offer, total = nil,nil
    local accepted = false
    local function redstone()
        while accepted == false do
            os.pullEvent("redstone")
            --print("A redstone input has changed!")
            accepted = true
        end
    end
    local function scaninv()
        while accepted == false do
            w_Main.clear()
            w_Main.setCursorPos(1,1)
            offer, total = scanchest()
            sleep(15)
        end
    end
    parallel.waitForAll(redstone, scaninv)
    for slot, item in pairs(Inv.list()) do
        if item then
            Inv.pushItems(peripheral.getName(Dispose), slot)
        end
    end
---@diagnostic disable-next-line: param-type-mismatch
    Coinsrc.pushItems(peripheral.getName(Coinbox), 1,total)
end
-- local function buy()
--     local itemsforsale = {}
--     local function additem(name, title, physical, price, cmd)
--         itemsforsale[name] = {}
--         itemsforsale[name]["title"] = title
--         itemsforsale[name]["type"] = physical
--         itemsforsale[name]["price"] = price
--         itemsforsale[name]["cmd"] = cmd
--     end
--     aapi.cprint(nil, "Shop", "Please type in the number of the item you wish to purchase: ")
--     local msg aapi.uinput(nil, "Shop", nil, "num")

-- end
bulkaddObject()
sell()
