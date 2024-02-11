local aapi = require("aapi_core")
local disp = require("aapi_display")
local checksum = 0
local cchecksum = 0
local rtm = true
local function timer(timer_id)
    timer_id = os.startTimer(120)
    local event, id
    repeat
        event, id = os.pullEvent("timer")
    until id == timer_id
    rtm = true
end
sleep(2)
local DebugLogFiles = "AS/debuglogs"
aapi.initDebug(DebugLogFiles)
Debugmode = false
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
        elseif peripheral.getType(PeripheralList[i]) == "minecraft:chest" then
            Coindep = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Coin Dep Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "create:creative_crate" then
            Coinsrc = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Coin Window Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "monitor" then
            Mon = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Monitor Wrapped")
        elseif peripheral.getType(PeripheralList[i]) == "command" then
            Cmd = peripheral.wrap(PeripheralList[i])
            aapi.dbg("Command Block Wrapped")
        end
    end
    PriceList = aapi.FM("load", "/AS/MarketPrice.txt")
	if PriceList == nil then
        PriceList = {}
        aapi.dbg("Nil Price List, recreating...")
    end
    --disp.initDisplay()
    disp.addWindow(Mon,"Main","The Company Store",0,0,1,1,colors.black,true)
	w_Main.clear()
	w_Main.setCursorPos(1,1)
end
Startup()
sleep(1)
function Savelist()
    if aapi.FM("save", "/AS/MarketPrice.txt", PriceList) == 1 then
        return
    end
end
local function listPrices()
    local function rewrite()
        local cx, cy = w_Main.getCursorPos()
        local mx, my = w_Main.getSize()
        w_Main.setCursorPos(1, 1)
        w_Main.write("Price List:")
        w_Main.setCursorPos(1, cy + 1)
        for i = 1, mx do
            w_Main.write("-")
        end
		--for i=1,#PriceList do
		--		aapi.dbg(PriceList[i]["DName"])
		--		sleep(1)
		--end
        for key, value in pairs(PriceList) do
            local cx, cy = w_Main.getCursorPos()
            cy = cy + 1
            if cy > my then
                w_Main.scroll(1)
                cy = my
            end
            w_Main.setCursorPos(1, cy + 1)
            w_Main.write(value["Dname"] .. ": " .. value["Price"]*value["Inf"])
			aapi.dbg(value["Dname"] .. ": " .. value["Price"]*value["Inf"])
        end
    end
    rewrite()
end
local function bulkaddObject()
    aapi.cprint(nil, "eve", "Please insert items to sell and then press the button")
    os.pullEvent("redstone")
    if Inv.list() then
        for slot, item in pairs(Inv.list()) do
            local name = nil
            local price = nil
            local dupe = false
            local dupelist = {}
            local slotitem = Inv.getItemDetail(slot)
            if slotitem then
                for key, value in pairs(PriceList) do
                    if value["Name"] == slotitem.name then
                        dupe = true
                        aapi.cprint(nil, "eve",
                            "Duplicate item detected, would you like to remove the current price for: " ..
                            slotitem.name .. "?")
                        local replace = aapi.uinput(nil, "Eve", nil, "yn")
                        if replace == "true" then
                            table.remove(PriceList, key)
                            aapi.dbg("replace = true")
                            dupe = false
                        elseif replace == "false" then
                            table.insert(dupelist, value["Name"])
                            aapi.dbg("replace = false")
                        end
                    end
                end
                if dupe == false then
                    local iname = slotitem.name
                    name = slotitem.displayName
                    aapi.cprint(nil, "Eve", slotitem.displayName .. " Set base price: ")
                    price = aapi.uinput(nil, "Eve", nil, "num")
                    iname = {}
                    iname["Name"] = slotitem.name
                    iname["Dname"] = name
                    iname["Price"] = price
                    iname["Inf"] = 1
                    iname["Num"] = 1
                    table.insert(PriceList, iname)
                    aapi.dbg(iname["Dname"] .. " added at the price of " .. iname["Price"])
                    sleep(1)
                end
            end
        end
    end

    Savelist()
end
local function movemoney(dir, qty)
	-- Coindep
    if dir == "i" then
		aapi.dbg("Total to Deposit:"..qty)
        if qty < 65 then
            Coinsrc.pushItems(peripheral.getName(Coinbox), 1,qty)
        else
            local xbigger = qty / 64
            local rxbigger = math.floor(xbigger)
            for i = 1, rxbigger do
				aapi.dbg("Depositing: "..i.."/"..rxbigger)
                Coinsrc.pushItems(peripheral.getName(Coinbox), 1, 64)
                sleep(.5)
            end
            Coinsrc.pushItems(peripheral.getName(Coinbox), 1,64*(xbigger-rxbigger))
        end
    elseif dir == "o" then
    aapi.dbg("Total to Withdraw:"..qty)
        if qty < 65 then
            Coinbox.pushItems(peripheral.getName(Dispose), 1,qty)
        else
            local xbigger = qty / 64
            local rxbigger = math.floor(xbigger)
            for i = 1, rxbigger do
                aapi.dbg("Withdrawing: "..i.."/"..rxbigger)
                Coinbox.pushItems(peripheral.getName(Dispose), 1, 64)
                sleep(.5)
            end
            Coinbox.pushItems(peripheral.getName(Dispose), 1,64*(xbigger-rxbigger))
        end
    end    

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
                end
            end
            if slotitem then
                local lineitem = {}
                lineitem["Name"] = slotitem.displayName
                lineitem["Qty"] = slotitem.count
                lineitem["Price"] = (itemprice / iteminf)
                lineitem["NewQty"] = slotitem.count + itemnum
                lineitem["Subtot"] = itemprice * slotitem.count
                table.insert(upforoffer, lineitem)
            end
        end
    end
    for key, value in pairs(upforoffer) do
        total = value["Subtot"] + total
    end
    local function rewrite()
		local mx,my = w_Main.getSize()
        w_Main.setCursorPos(1, 1)
        w_Main.write("Sell List:")
		w_Main.setCursorPos(1, 2)
		for i = 1, mx do
            w_Main.write("-")
        end
        for key, value in pairs(upforoffer) do
            local cx, cy = w_Main.getCursorPos()
            w_Main.setCursorPos(1, cy + 1)
            w_Main.write(value["Qty"] .. "x" .. value["Name"] .. " @ " .. value["Price"] .. "sc/ea. | " .. value["Subtot"].."sc")

        end
        local cx, cy = w_Main.getCursorPos()
        w_Main.setCursorPos(1, cy + 1)
        for i = 1,mx do
            w_Main.write("-")
        end
        w_Main.setCursorPos(1, cy + 2)
        w_Main.write("Total Payout: "..total.."sc")
    end
    --disp.arrayTabulate(w_Main, upforoffer, 1)
    aapi.dbg("Total: " .. total)
    rewrite()
	
    return ({total,upforoffer})
end
local function sell()
    while rtm == false do
        aapi.cprint(nil,"Store","Please insert any items you wish to sell into the Offering Box and press the button when you are ready to complete the transaction")
        local accepted = false
        local total = 0
        local ufo = {}
        local function redstone()
            while accepted == false do
                local function rs()
                    os.pullEvent("redstone")
                    accepted = true
                end
                local function timer()
                    local timer_id = os.startTimer(120)
                    local event, id
                    repeat 
                        event, id = os.pullEvent("timer")
                    until id == timer_id
                    accepted = true
                    rtm = true
                end
                --print("A redstone input has changed!")
                parallel.waitForAny(rs,timer)
            end
        end
        local function scaninv()
            while accepted == false do
                w_Main.clear()
                w_Main.setCursorPos(1,1)
                local scanres = scanchest()
                total = scanres[1]
                ufo = scanres[2]
                sleep(8)
            end
        end
        parallel.waitForAll(redstone, scaninv)

    ---@diagnostic disable-next-line: param-type-mismatch
        if rtm == false then
            movemoney("i", total)
            for slot, item in pairs(Inv.list()) do
                if item then
                    Inv.pushItems(peripheral.getName(Dispose), slot)
                end
            end
            for key, value in pairs(ufo) do
                for name, data in pairs(PriceList) do
                    aapi.dbg("Checking " .. data["Dname"] .. "/" .. value["Name"])
                    if data["Dname"] == value["Name"] then
                        local adder = {}
                        adder["Name"] = data["Name"]
                        adder["Dname"] = data["Dname"]
                        adder["Price"] = data["Price"]
                        adder["Inf"] = (value["Qty"] / data["Num"]) * 0.00008 + data["Inf"]
                        adder["Num"] = value["Qty"] + data["Num"]
                        aapi.dbg("Removed " .. data["Name"] .. " from slot " .. name)
                        table.remove(PriceList, name)
                        aapi.dbg("Added " .. adder["Name"] .. " to slot " .. name)
                        table.insert(PriceList, name, adder)
                        aapi.dbg("Inflation for item: " ..
                        adder["Name"] .. " is at " .. adder["Inf"] .. " or " .. adder["Price"] * adder["Inf"] .. " sc")
                    end
                end
            end
            Savelist()
            rtm = true
            return
        else
            rtm = true
            return
        end  
    end
end
local function buy()
    local function bf()
        local itemsforsale = {}
        local total = 0
        local un = "notch"
        aapi.cprint(nil, "Shop", "Please type in your username to continue: ")
        un = aapi.uinput(nil, "Shop", nil, "none", true)
        local qty = 0
        local function additem(name, title, price, cmd)
            itemsforsale[name] = {}
            itemsforsale[name]["title"] = title
            itemsforsale[name]["price"] = price
            itemsforsale[name]["cmd"] = cmd
            aapi.dbg("Item: " .. itemsforsale[name]["title"] .. " added with a price of: " .. itemsforsale[name]
                ["price"])
        end
        sleep(1)
        additem(1, "Additional Claimed Chunk", 50, "ftbchunks admin extra_claim_chunks " .. un .. " add ")
        additem(2, "Additional Force Load Chunk", 100, "ftbchunks admin extra_force_load_chunks " .. un .. " add ")
        additem(3, "ATM Nugget", 150, "give " .. un .. " allthemodium:allthemodium_nugget ")
        additem(4, "Vibranium Nugget", 150, "give " .. un .. " allthemodium:vibranium_nugget ")
        w_Main.clear()
        local mx, my = w_Main.getSize()
        w_Main.setCursorPos(1, 1)
        w_Main.write("Items for Sale:")
        w_Main.setCursorPos(1, 2)
        for i = 1, mx do
            w_Main.write("-")
        end
        local smallmenu = {}
        for key, value in pairs(itemsforsale) do
            local x, y = w_Main.getCursorPos()
            w_Main.setCursorPos(1, y + 1)
            aapi.dbg("Item: " .. value["title"])
            w_Main.write(key .. " | " .. value["title"] .. ": " .. value["price"] .. "sc")
            local sm = key .. " | " .. value["title"]
            table.insert(smallmenu, sm)
        end
        aapi.cprint(nil, "Shop", "Welcome to the Buy Menu:")
        aapi.cprint(nil, "Shop", "------------------------")
        for i = 1, #smallmenu do
            aapi.cprint(nil, "Shop", smallmenu[i])
        end
        aapi.cprint(nil, "Shop", "Please type in the list number of the item you wish to purchase: ")
        local msg = aapi.uinput(nil, "Shop", nil, "num")
        local pass = false
        for key, value in pairs(itemsforsale) do
            if key == textutils.unserialize(msg) then
                aapi.cprint(nil, "Shop", "How many would you like to purchase? ")
                qty = aapi.uinput(nil, "Shop", nil, "num")

                total = qty * value["price"]
                aapi.cprint(nil, "Shop",
                    "Your total is: " ..
                    total .. "sc.. Please ensure you have enough funds in the coin slot to cover the transaction")
                aapi.cprint(nil, "Shop", "Press the button when you are ready to continue")
                local function cashout()
                    os.pullEvent("redstone")
                    local CB = Coinbox.list()
                    local covered = false
                    local totalins = 0
                    for n = 1, #CB do
                        totalins = CB[n].count + totalins
                    end
                    if totalins >= total then
                        aapi.cprint(nil, "Shop", "Processing transaction. Please wait...")
                        movemoney("o", total)
                        Cmd.setCommand(value["cmd"] .. qty)
                        Cmd.runCommand()
                    else
                        aapi.cprint(nil, "Shop", "Insufficient Funds.. Would you like to try again?")
                        local inp = aapi.uinput(nil, "Shop", "yn")
                        if inp == "true" then
                            cashout()
                        else
                            rtm = true
                            return
                        end
                    end
                end
                cashout()
            end
        end
    end
    parallel.waitForAny(timer(_G["buy"]), bf)
    rtm = true
end
local dispref = true 
local function mainmenu()
    local function pricescroll()
        while dispref == true do
            listPrices()
            sleep(5)
        end
    end
    local function menufunction()
        aapi.cprint(nil, "Shop", "Welcome to The Company Store! Please select a function from the list below:")
        aapi.cprint(nil, "Shop", "1 | Buy things using Star Coins")
        aapi.cprint(nil, "Shop", "2 | Sell items to earn Star Coins")
        aapi.cprint(nil, "Shop", "3 | Enter Admin Mode")
        local choice = aapi.uinput(nil,"Shop",nil,"num")     
        local opt = {
            o0 = function()
                rtm = true
                return    
            end,
            o1 = function()
                aapi.cprint(nil, "Shop", "Entering Buy Mode...")
                dispref = false 
                buy()
            end,
            o2 = function()
                aapi.cprint(nil, "Shop", "Entering Sell Mode...")
                dispref = false 
                sell()    
            end,
            o3 = function()
                local function timeout()
                    timer(_G["ADM"])
                end
                local function ADM()
                    aapi.cprint(nil, "Shop", "Please type in the Admin Password:")
                    aapi.uinput(nil, "Shop", nil, { "bikinibottomday" }, nil, nil, true)
                    dispref = false
                    bulkaddObject()
                end
                parallel.waitForAny(ADM,timeout)
                return
            end
        }
        if choice == nil then
            choice = "0"
        end
        if opt["o"..textutils.unserialize(choice)]() == nil then
            aapi.cprint(nil, "Shop", "Invalid choice.. Please try again")
            menufunction() 
        end
    end
    while true do 
        if rtm == true then
            local nat = term.native()
            w_Main.clear()
            nat.clear()
            w_Main.setCursorPos(1, 1)
            nat.setCursorPos(1, 1)
            rtm = false
            dispref = true 
        end
        parallel.waitForAll(menufunction, pricescroll)
        
    end
end
mainmenu()
--bulkaddObject()
