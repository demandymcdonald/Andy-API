local aapi_display = {}
local aapi = require("aapi_core")
function aapi_display.initDisplay(setup,result,pers,displaynames,savepath)
    DataTableSize = {}
    Gval = 0
    local function monitorSetup()
        local count = 0
        if fs.exists(savepath) and setup == false then
            local fs_ = fs.open(savepath, "r")
            local rawoutcome = {}
            local count = 0
            while true do
                count = count + 1
                local line = fs_.readLine()
                if not line then break end
                aapi.dbg(line .. " added to line " .. count)
                table.insert(rawoutcome, line)
            end
            for id, moni in pairs(pers) do
                for key, value in pairs(rawoutcome) do
                    if id == key then
                        local res = { value, moni }
                        table.insert(result, res)
                        aapi.dbg("Monitor " .. id .. " is now startcount: " .. value)
                    end
                end
            end
        else
            for key, moni in pairs(pers) do
                local w, h = moni.getSize()
                count = count + 1
                moni.clear()
                moni.setBackgroundColor(colors.gray)
                moni.setTextScale(2)
                moni.setCursorPos((w / 2) - 5, h / 2)
                moni.write("Monitor Setup")
                moni.setCursorPos((w / 2), (h / 2) + 1)
                moni.write(count)
            end
            term.clear()
            term.redirect(term.native())
            term.setCursorPos(1, 1)
            aapi.cprint(nil,"Display","Welcome to Monitor Setup..")
            aapi.cprint(nil,"Display","We are going to go through every monitor now, for each of your connected monitors please specify the startcount from the list below: ")
            textutils.tabulate(displaynames)
            print()
            print()
            sleep(1)
            local dcount = 1
            local completion = require "cc.completion"
            local expect = require "cc.expect"
            local expect, field = expect.expect, expect.field
            local fs_ = fs.open(savepath, "a")
            for id, monit in pairs(pers) do
                local function monselect()
                    aapi.cprint(nil,"Display","Monitor " .. dcount .. "/" .. count)
                    aapi.cprint(nil,"Display","Please choose what startcount monitor " .. id .. " is...")
                    local msg = read(nil, displaynames, function(text) return completion.choice(text, displaynames) end)
                    local res = { msg, monit }
                    local sres = msg
                    local correct = false
                    for i = 1, #displaynames do
                        if msg == displaynames[i] then
                            correct = true
                        end
                    end
                    if correct == true then
                        aapi.cprint(nil,"Display","Monitor " .. id .. " saved as startcount " .. msg)
                        table.insert(result, res)
                        fs_.writeLine(sres)
                        sleep(3)
                        local px, py = term.getCursorPos()
                        term.setCursorPos(1, py - 1)
                        term.clearLine()
                        term.setCursorPos(1, py - 2)
                        term.clearLine()
                        term.setCursorPos(1, py - 3)
                        term.clearLine()
                        term.setCursorPos(1, py - 4)
                        term.clearLine()
                        dcount = dcount + 1
                    else
                        aapi.cprint(nil,"Display","Invalid Choice.." .. msg .. " Please try again..")
                        sleep(3)
                        local px, py = term.getCursorPos()
                        term.setCursorPos(1, py - 1)
                        term.clearLine()
                        term.setCursorPos(1, py - 2)
                        term.clearLine()
                        term.setCursorPos(1, py - 3)
                        term.clearLine()
                        term.setCursorPos(1, py - 4)
                        term.clearLine()
                        monselect()
                    end
                end
                monselect()
            end
            aapi.cprint(nil,"Display","Monitor Configuration Complete.. Thank you!")
            fs_.close()
        end
        for key, moni in pairs(pers) do
            moni.setTextScale(3)
            local w, h = moni.getSize()
            count = count + 1
            moni.clear()
            moni.setBackgroundColor(colors.gray)
            moni.setCursorPos(w - 12, h)
            moni.write("AAPI DISPLAY")
        end
        return (result)
    end
    if type(pers) == "table" then
        monitorSetup(pers)
    end
end
function aapi_display.addWindow(par, name, title, x, y, wid, hei, color, fs)
    local last = term.current()
    local w, h = par.getSize()
    aapi.dbg(w)
    aapi.dbg(h)
    local startX = 0
    if fs == true then 
        Factor = 0
        Factor2 = 0
        startX = math.max((w*x),1)
    else
        Factor = 2
        Factor2 = 1
        startX = (w * x) + Factor 
        --startX = (x -1)*w + Factor
    end
    --math.max(math.floor(h*.05),1)

    local startY = math.max(y*h,1) + Factor2
    local wid_ = (wid*w) - (Factor)
    local hei_ = math.max((hei*h),1) - (Factor2)
    aapi.dbg(Factor)
    aapi.dbg(Factor2)
    aapi.dbg("-------")
    aapi.dbg(startX)
    aapi.dbg(startY)
    aapi.dbg(wid_)
    aapi.dbg(hei_)
    _G["bb" .. name] = window.create(par, startX, startY, wid_, hei_)
    aapi.dbg("Window BoundingBox: bb"..name.." created")
    term.redirect(_G["bb"..name])
    local w, h = _G["bb" .. name].getSize()

    aapi.dbg("O-------")
    aapi.dbg(w)
    aapi.dbg(h)
    term.setCursorPos(1,1)
    paintutils.drawFilledBox(1, 1, w, h, colors.gray)
    term.setCursorPos(2, 1)
    _G["bb"..name].setTextColor(colors.black)
    print("| "..title)
    _G["w_" .. name] = window.create(_G["bb" .. name], 2, 2, w - 2, h - 2)
    aapi.dbg("Window: w_"..name.." created")
    term.redirect(_G["w_" .. name])
    local w, h = _G["w_"..name].getSize()
    aapi.dbg("I-------")
    aapi.dbg(w)
    aapi.dbg(h)
    term.setCursorPos(1, 1)
    paintutils.drawFilledBox(1, 1, w, h, color)
    term.setCursorPos(1, 1)
    _G["w_" .. name].setTextColor(colors.white)
    --print("test test test")
    term.redirect(last)
end
function aapi_display.windowArray(parent,number,namet,titlet,bcolor,fs,startx,starty,endx,endy)
    local rows = 0
    local count = 0
    local xsize = 0
    local ysize = 0
    local xst = startx
    local yst = starty
    local xen = 0
    local yen = 0
    local dcount = 0
    local rows = 0
    local xint = (endx - startx)
    local yint = (endy - starty)
    local startcount = nil
    if (number % 2 == 0) and number >=4 then
        rows = number / 4
        count = 4
        ysize = yint/rows
        startcount = 4
    elseif (number % 2 ~= 0) and number >= 3 then
        startcount = 3
        rows = number / 3
        count = 3
        ysize = yint/rows
    else
        rows = 1
        count = number
        ysize = yint
    end
    xsize = xint / count
    for i = 1, number do
        local title = "ERRORERRORERROR"
        if type(titlet) == "table" then
            title = titlet[i]
        else
            title = titlet .. i
        end
        local name = namet .. i
        if count > 0 then
            xen = xst + xsize
            yen = yst + ysize
            disp.addWindow(parent, name, title, xst, yst, xen, yen, bcolor, fs)
            xst = xen
            count = count - 1
            dcount = dcount + 1
        elseif count == 0 and dcount ~= number then
            yst = yst + ysize
            xsize = xint / math.min(startcount, number - dcount)
            xst = 1 / count
            xen = xst + xsize
            yen = yst + ysize
            disp.addWindow(parent, name, title, xst, yst, xen, yen, bcolor, fs)
            count = startcount - 1
            dcount = dcount + 1
        end
    end
    term.redirect(term.native())
end
function aapi_display.createWidget(tablee, type_, name, title, data, bgcolor, ncolor, dcolor, ecolor, fcolor)
    aapi.dbg("Widget '" .. name .. "' created")
    local sname = name
    local function colorcheck(color)
        local colour = nil
        if color == nil then
            colour = colors.lime
            aapi.dbg("ERROR: Color error in "..sname.." Replaced with Lime")
        else
            colour = color
        end
        return(colour)
    end
    name = {}
    name["name"] = sname
    name["title"] = title
    name["type_"] = type_
    name["data"] = data
    name["bgcolor"] = colorcheck(bgcolor)
    name["ncolor"] = colorcheck(ncolor)
    name["dcolor"] = colorcheck(dcolor)
    name["ecolor"] = colorcheck(ecolor)
    name["fcolor"] = colorcheck(fcolor)
    --textutils.tabulate(name)
    return (table.insert(tablee, name))
end
function aapi_display.createDataTable(array1, array2, array3, array4, array5, array6)
    local oarrays = {}
    local count = 0
    for i = 1, #array1 do
        count = count + 1
    end
    local function generatenil()
        local tabel = {}
        for i = 1, count do
            table.insert(tabel, 0)
        end
        return (tabel)
    end
    local array1_ = array1 or generatenil()
    local array2_ = array2 or generatenil()
    local array3_ = array3 or generatenil()
    local array4_ = array4 or generatenil()
    local array5_ = array5 or generatenil()
    local array6_ = array6 or generatenil()
    if type(array1) ~= "string" then
        --DataTableSize[textutils.serialize(oarrays.."_size")] = count
        --table.insert(DataTableSize,_G[oarrays.."_size"])
        --aapi.dbgTable(DataTableSize)

        for i = 1, count do
            oarrays["ent" .. i] = {}
            oarrays["ent" .. i]["value1"] = array1_[i]
            oarrays["ent" .. i]["value2"] = array2_[i]
            oarrays["ent" .. i]["value3"] = array3_[i]
            oarrays["ent" .. i]["value4"] = array4_[i]
            oarrays["ent" .. i]["value5"] = array5_[i]
            oarrays["ent" .. i]["value6"] = array6_[i]
            --aapi.dbg("Cycle: " .. i .. "/" .. count .. " Results: " .. array1_[i] ..
            --    " , " .. array2_[i] .. " , " .. array3_[i] .. " , " .. array4_[i] .. " , " .. array5_[i])
        end
        table.insert(oarrays, 1, count)
    else
        oarrays = { 1, array1, array2, array3, array4, array5, array6 }
    end
    return (oarrays)
end
function aapi_display.customWidget(name,xs,ys,predraw,todraw)
    name = function(parent, name_, data_, xstart, ystart, xen, yen, bcolor, ncolor, dcolor, ecolor, fcolor)
        local xsize = xs
        local ysize = ys
        predraw()
        if positioncheck(parent, name, xstart, ystart,xen,yen, xsize, ysize) == true then
            todraw()    
        end    
    end
    table.insert(Widgets,name)
end
function aapi_display.buildWidgets(id,parent,datatable,centered)
    _G[id] = {}
    local nxpos = 1
    local nypos = 1
    local newline = false
    local collision = false
    local firstpass = true
    local xend = 1
    local yend = 1
    local widgetwidth = 0
    local moveover = 0
    local hitboxes = {}
    function positioncheck(parent, name, xst, yst, xen, yen, xsize, ysize)
        --aapi.dbg("PositionCheck")
        if xen == nil or yen == nil then
            local w, h = parent.getSize()
            widgetwidth = xsize + widgetwidth
            xend = xst + xsize
            yend = yst + ysize
            if xend > (w - 1) then
                aapi.dbg("Check FAILRD.. " .. xend .. " is greater than " .. w)
                newline = true
                return (false)
            else
                aapi.dbg("Check passed.. " .. xend .. " is less than " .. w)
            end
            for i = 1, #hitboxes do
                local x1_ = hitboxes[i][1]
                local x2_ = hitboxes[i][2]
                local y1_ = hitboxes[i][3]
                local y2_ = hitboxes[i][4]
                aapi.dbg("Iceberg coords: " .. x1_ .. " , " .. x2_ .. " , " .. y1_ .. " , " .. y2_)
                aapi.dbg("Titanic coords: " .. xst .. " , " .. xend .. " , " .. yst .. " , " .. yend)
                if xst >= x1_ and xst <= x2_ and yst <= y2_ and yst >= y1_ then
                    collision = true
                    moveover = x2_ + 2
                    aapi.dbg("Iceberg dead ahead! Moving over " .. moveover)
                    return (false)
                else
                    aapi.dbg("Check " .. i .. "/" .. #hitboxes .. " All is quiet..")
                end
            end

            --_G[name] = {}
            --name["1"] = xst
            --name["2"] = xend
            -- name["3"] = yst
            --name["4"] = yend
            if firstpass == true then
                return (false)
            else
                return (true)
            end
        else
            xend = xen
            yend = yen
            return (true)
        end
    
    end
    Widgets = {
        display = function(parent, name_, data_, xstart, ystart,xen,yen, bcolor, ncolor, dcolor, ecolor, fcolor)
            --ncolor = Title Color
            --dcolor = Data Color
            
            --parent.setCursorPos(xstart, ystart)
            local name = string.sub(name_, 1, 10)
            local data = string.sub(textutils.serialize(data_), 1, 10)
            local xsize = 12
            local ysize = 4
            if positioncheck(parent, name, xstart, ystart,xen,yen, xsize, ysize) == true then
                paintutils.drawFilledBox(xstart, ystart, xend, yend, bcolor)
                parent.setTextColor(ncolor)
                local nleng = string.len(name)
                local xctr = (xstart + 7) - (nleng / 2)
                parent.setCursorPos(xctr, (ystart + 2))
                parent.write(name)
                local dleng = string.len(data)
                local xctr = (xstart + 7) - (dleng / 2)
                --local cpx,cpy = parent.getCursorPos()
                --paintutils.drawLine(cpx, ystart, cpx, (ystart + 3), lcolor)
                --parent.setCursorPos(xstart,(ystart+2))
                parent.setCursorPos(xctr, (ystart + 3))
                parent.setTextColor(dcolor)
                parent.write(data)
                --aapi.dbg("----")
                --aapi.dbg(xend)
                --aapi.dbg(yend)
                --aapi.dbg("----")
                nxpos = xend
                nypos = yend
            end
        end,
        datalist = function(parent, name_, data_, xstart, ystart,xen,yen, bcolor, ncolor, dcolor, ecolor, fcolor)
            local count = data_[1]
            aapi.dbg("!!!!!" .. count)
            local name = string.sub(name_, 1, 20)
            --local data = string.sub(data_, 1, 10)
            local xsize = 25
            local ysize = (count + 4)
            if positioncheck(parent, name, xstart, ystart,xen,yen, xsize, ysize) == true then
                paintutils.drawFilledBox(xstart, ystart, xend, yend, bcolor)
                parent.setTextColor(ncolor)
                local nleng = string.len(name)
                local xctr = (xstart + 13) - (nleng / 2)
                parent.setCursorPos(xctr, (ystart + 2))
                parent.write(name)
                local cx, cy = parent.getCursorPos()
                parent.setCursorPos(xctr, cy + 1)
                for i=1,count do
                    local labelr = string.sub(data_["ent"..i]["value1"], 1, 10)
                    local datar = string.sub(data_["ent"..i]["value2"], 1, 10)
                    local lleng = string.len(labelr)
                    local xctr = (xstart + 12) - (lleng + 1)
                    local cx, cy = parent.getCursorPos()
                    local yposy = (cy + 1)
                    parent.setCursorPos(xctr, yposy)
                    parent.setTextColor(data_["ent"..i]["value3"])
                    parent.write(labelr)
                    parent.setTextColor(dcolor)
                    parent.write(" | ")
                    parent.setTextColor(data_["ent"..i]["value4"])
                    parent.write(datar)
                end
                nxpos = xend
                nypos = yend
            end
        end,
        smallbarmeter = function(parent, name_, data_, xstart, ystart,xen,yen, bcolor, ncolor, dcolor, ecolor, fcolor)
            --[[
                data_[1] = data
                data_[2] = maxvalue
                data_[3] = minvalue
                ncolor = Title Color
                dcolor = Bar Data Color
                fcolor = Bar Fill Color
                ecolor = Bar Empty Color
            ]]            
            parent.setCursorPos(xstart, ystart)
            local name = string.sub(name_, 1, 10)
            local xsize = 12
            local ysize = 4
            if positioncheck(parent, name, xstart, ystart,xen,yen, xsize, ysize) == true then
                paintutils.drawFilledBox(xstart, ystart, xend, yend, bcolor)
                parent.setTextColor(ncolor)
                local nleng = string.len(name)
                local xctr = (xstart + 7) - (nleng / 2)
                parent.setCursorPos(xctr, (ystart + 1))
                parent.write(name)
                local dat = data_[1]
                local datlab = disp.textf("per",dat)
                --local dmin = data_[2]
                local dmax = data_[2]
                local dend = (10*(dat/dmax)) + xstart +1
                local dleng = string.len(datlab)
                local xctr = (xstart + 6) - (dleng / 2)
                local cpx,cpy = parent.getCursorPos()
                paintutils.drawLine(xstart+1, cpy + 1, xend-1, cpy + 1, fcolor)  
                paintutils.drawLine(xstart + 1, cpy + 1, dend, cpy + 1, ecolor)         
                parent.setCursorPos(xctr, (ystart + 3))
                parent.setBackgroundColor(bcolor)
                parent.setTextColor(dcolor)
                parent.write(datlab)
                aapi.dbg("----")
                aapi.dbg(xend)
                aapi.dbg(yend)
                aapi.dbg("----")
                nxpos = xend
                nypos = yend
            end
        end,
        smallbargraph = function(parent, name_, data_, xstart, ystart,xen,yen, bcolor, ncolor, dcolor, ecolor, fcolor)
                                                            --[[
                ncolor = Name Color
                dcolor = line color
                ecolor = Data Text Color
                fcolor = Bar graph colors {1,2}
                value1 = datalabel
                value2 = data
                value3 = displaydata
                
            ]]
            local namelabel = string.sub(name_, 1, 21)
            --local datalabel = string.sub(data_[1], 1, 3)
            local xsize = 26
            local ysize = 18
            local count = data_[1]
            local maxval = 0
            local minval = 0
            local nmaxval = 0
            for i = 1,count do
                local numlen = textutils.serialize(math.floor(data_["ent"..i]["value2"]))
                if data_["ent"..i]["value2"] < minval then
                    nmaxval = data_["ent"..i]["value2"] - 8^#numlen
                    aapi.dbg("Nex NMax Value: "..nmaxval)                   
                elseif data_["ent"..i]["value2"] > maxval then
                    maxval = data_["ent"..i]["value2"] + 8^#numlen
                    aapi.dbg("Nex Max Value: "..maxval)
                end
            end
            -- Start of drawing instructions
            if positioncheck(parent, name, xstart, ystart,xen,yen, xsize, ysize) == true then
                term.redirect(parent)
                paintutils.drawFilledBox(xstart, ystart, xend, yend, bcolor)
                local labelx = (xstart + 13) - (string.len(namelabel) / 2)
                parent.setCursorPos(labelx, ystart + 1)
                parent.setTextColor(ncolor)
                parent.write(namelabel)
                local newx = xstart + 2
                local zero = 0
                local top = 0
                if nmaxval ~= 0 then
                    --local maxval_i = maxval
                    --local nmaxval_i = nmaxval
                    paintutils.drawLine(xstart + 1, yend - 5, xend - 1, yend - 5, dcolor)
                    paintutils.drawLine(xstart + 1, yend - 1, xstart + 7, ystart + 3, dcolor)
                    zero = yend - 6
                else
                    --local maxval_i = maxval / 3
                    --local nmaxval_i = 0
                    paintutils.drawLine(xstart + 1, yend - 1, xend - 1, yend - 1, ecolor)
                    paintutils.drawLine(xstart + 1, yend - 1, xstart + 1, ystart + 2, ecolor)
                    zero = yend - 2
                end
                for i = 1, count do
                    local color = data_["ent" .. i]["value3"]
                    if data_["ent" .. i]["value2"] >= 0 then
                        top = (data_["ent" .. i]["value2"] / maxval) * 15
                    else
                        top = ((data_["ent" .. i]["value2"] / nmaxval) * 7) * -1
                    end
                    local boxcolor = colors.white
                    if (i % 2 == 0) then
                        boxcolor = fcolor[2]
                    else
                        boxcolor = fcolor[1]
                    end
                    paintutils.drawFilledBox(newx, zero, newx + 2, zero - top, boxcolor)
                    local label = string.sub(data_["ent" .. i]["value1"], 1, 5)
                    local data = string.sub(data_["ent" .. i]["value3"], 1, 5)
                    local mid = (zero - top)
                    --parent.setBackgroundColor(boxcolor)
                    if mid >= 2 then
                        parent.setTextColor(ecolor)
                        parent.setCursorPos(newx, mid)
                        parent.write(string.sub(label, 1, 3))
                        parent.setCursorPos(newx, mid + 1)
                        parent.write(string.sub(data, 1, 3))
                        newx = newx + 3
                    elseif mid <= -2 then
                        parent.setTextColor(ecolor)
                        parent.setCursorPos(newx, zero + 1)
                        parent.write(string.sub(label, 1, 3))
                        parent.setCursorPos(newx, zero + 2)
                        parent.write(string.sub(data, 1, 3))
                        newx = newx + 3
                    end
                end
            end
            nxpos = xend
            nypos = yend
            -- end of small bar graph
        end,
        statusbar = function(parent, name_, data_, xstart, ystart,xen,yen, bcolor, ncolor, dcolor, ecolor, fcolor)
        end,
        freactor = function(parent, name_, data_, xstart, ystart,xen,yen, bcolor, ncolor, dcolor, ecolor, fcolor)
        
        end
    }
    term.redirect(parent)
    local xpos = 2
    local sxpos = 2
    local ypos = 2
    local w, h = parent.getSize()
    local function placewidget(a, b, c_, c, d, e, f, g, h_, i_, j, k)
        newline = false
        collision = false
        Widgets[a](b, c, d, xpos, ypos, nil, nil, g, h_, i_, j, k)
        if newline == true then
            ypos = nypos + 2
            xpos = sxpos
            placewidget(a, b, c_, c, d, xpos, ypos, g, h_, i_, j, k)
        elseif collision == true then
            xpos = moveover
            placewidget(a, b, c_, c, d, xpos, ypos, g, h_, i_, j, k)
        elseif firstpass == false then
            _G[id][c_] = {}
            _G[id][c_]["parent"] = parent 
            _G[id][c_]["xpos"] = xpos
            _G[id][c_]["ypos"] = ypos
            _G[id][c_]["xend"] = nxpos
            _G[id][c_]["yend"] = nypos

            if nypos - ypos > 4 then
                local array = { xpos, nxpos, ypos, nypos }
                table.insert(hitboxes, array)
                aapi.dbg(c_ .. " has been added as an iceberg")
            end
            xpos = nxpos + 2
            --ypos = nypos
        else
            if nypos - ypos > 4 then
                local array = { xpos, nxpos, ypos, nypos }
                table.insert(hitboxes, array)
                aapi.dbg(c_ .. " has been added as an iceberg")
            end
            xpos = nxpos + 2
            --ypos = nypos
        end
    end
    term.redirect(parent)
    if centered == true then
        firstpass = true
    else
        firstpass = false
    end 
    for key, value in pairs(datatable) do
        placewidget(value["type_"], parent, value["name"], value["title"], value["data"], xpos, ypos,
            value["bgcolor"],
            value["ncolor"], value["dcolor"], value["ecolor"], value["fcolor"])
    end
    if centered == true then
        local w, h = parent.getSize()
        parent.setCursorPos(1, 1)
        local centeredwidget = math.floor((w - widgetwidth) / 2) + 1
        if centeredwidget > 1 then
            sxpos = centeredwidget
            xpos = centeredwidget
        else
            xpos = 2
        end
        ypos = 2
        firstpass = false
        hitboxes = {}
        for key, value in pairs(datatable) do
            placewidget(value["type_"], parent, value["name"], value["title"], value["data"], xpos, ypos,
                value["bgcolor"],
                value["ncolor"], value["dcolor"], value["ecolor"], value["fcolor"])
        end
    end
    term.redirect(term.native())
end
function aapi_display.refreshWidget(id,data)
    for key, value in pairs(data) do
        local c = _G[id][value["name"]]
        term.redirect(c["parent"])
        Widgets[value["type_"]](c["parent"], value["title"], value["data"], c["xpos"], c["ypos"], c["xend"],
            c["yend"], value["bgcolor"],value["ncolor"], value["dcolor"], value["ecolor"], value["fcolor"])
        term.redirect(term.native())        
    end
    aapi.dbg("Widgets Refreshed")
end
function aapi_display.textf(type_,text,convert2)
    local result = nil
    local types = {
        per = function()
            result = math.floor(text * 100) .. "%"
            aapi.dbg("[textf]   "..text.." converted to "..result)
        end,
        temp = function()
            local units = {
                c = function()
                    local mat = math.floor((text - 273.15))
                    result = textutils.serialize(mat).."°C"
                    aapi.dbg("[textf]   "..text.." converted to "..result)
                end,
                f = function()
                    local mat = math.floor(((text - 273.15) * 9/5 + 32))
                    result = textutils.serialize(mat) .. "°F"
                    aapi.dbg("[textf]   "..text.." converted to "..result)
                end,
                k = function()
                    result = textutils.serialize(text) .. "°K"
                    aapi.dbg("[textf]   "..text.." converted to "..result)
                end,
            }
            units[convert2]()
        end,
        energy = function()
            local units = {
                FE = function()
                    local mathe = math.floor(text * 2.5)
                    local len = string.len(mathe)
                    local concat = {
                        { 1, 3,1, "FE/t" },
                        { 4, 6,3, "kFE/t"},
                        { 7, 9,6, "MFE/t" },
                        { 10, 12,9, "GFE/t" },
                        {13,15,12, "TFE/t"}
                    }
                    for key,value in pairs(concat) do
                        if len >= value[1] and len <= value[2] then
                            local presult = mathe / (10 ^ value[3])
                            result = string.sub(presult,1,4).. value[4]
                            aapi.dbg("[textf]   "..text.." converted to "..mathe.." then to "..result)
                        end
                    end
                end,
                RF = function()
                    local math = text * .4
                    local mathe = math.floor(text * 2.5)
                    local len = string.char(#mathe)
                    local concat = {
                        { 1,  3,  1,  "RF/t" },
                        { 4,  6,  3,  "kRF/t" },
                        { 7,  9,  6,  "MRF/t" },
                        { 10, 12, 9,  "GRF/t" },
                        { 13, 15, 12, "TRF/t" }
                    }
                    for key, value in pairs(concat) do
                        if len >= value[1] and len <= value[2] then
                            result = textutils.serialize(mathe / (10 ^ value[3])) .. value[4]
                            aapi.dbg("[textf]   " .. text .. " converted to " .. result)
                        end
                    end
                end
            }
            units[convert2]()
        end    
    }
    types[type_]()
    return (result)
end
function aapi_display.loading(disp, num, tasks)
    disp.clear()
    local w, h = disp.getSize()
    local loadscreen = window.create(disp, 1, 1, w, h)
    local cool = nil
    loadscreen.setBackgroundColor(colors.red)
    local lst = w * .25
    local lsty = h / 2 + 2
    local lend = w * .75
    if w < 40 then
        disp.setTextScale(1)
        cool = 5
    elseif w > 40 and w < 80 then
        disp.setTextScale(2)
        cool = 4
    elseif w > 80 then
        disp.setTextScale(3)
        cool = 3
    end
    local w, h = disp.getSize()
    local xctr, yctr = (w / 2) - cool, (h / 2)
    disp.setCursorPos(xctr, yctr)
    disp.write("Loading...")
end
function aapi_display.ctrtitle(disp, msg, rate)
    local cool = nil
    local w, h = disp.getSize()
    if disp == term.native() then
        cool = 1
    elseif w < 40 then
        disp.setTextScale(1)
        cool = 5
    elseif w > 40 and w < 80 then
        disp.setTextScale(2)
        cool = 4
    elseif w > 80 then
        disp.setTextScale(3)
        cool = 3
    end
    local xctr, yctr = ((w / 2) - cool) - (string.len(msg) / 2), (h / 2)
    disp.setCursorPos(xctr, yctr)
    textutils.slowWrite(msg, rate)
end
function aapi_display.arrayTabulate(disp,data,starty)
    local rowcount = 0
    local colcount = 0
    local column = {}
    local coleng = {}
    local ctleng = {}
    Aapi.dbg("Array Tabulating initiated...")
    --setmetatable(column, {_G = _G})            
    local dlen,dhei = disp.getSize()
    for key, value in pairs(data) do
        colcount = 0
        rowcount = rowcount + 1
        for i = 1, #value do
            colcount = colcount + 1
        end
    end
    for key, value in pairs(data) do
        for i = 1, colcount do
            if ctleng[i] == nil then
                ctleng[i] = 0
            end
            if ctleng[i] < string.len(value[i]) then
                ctleng[i] = math.max((string.len(value[i]) + ctleng[i]) / 2)
            end
            column[i] = {}
            table.insert(column[i], value[i])
        end
    end
    -- Start Printing Table
    local colpos = 1
    local ypos = starty
    for i = 1, colcount do
        coleng[i] = (ctleng[i] / dlen) - 2
        if i ~= 1 then
            colpos = colpos + coleng[i - 1] + 2
            ypos = starty
        end
        disp.setCursorPos(colpos, ypos)
        for key, value in pairs(column[i]) do
            disp.write(" " .. string.sub(value, 1, coleng[i]))
            ypos = ypos + 1
            disp.setCursorPos(colpos, ypos)
        end
        Aapi.dbg("Line "..i.." tabulated")
    end
end
return aapi_display