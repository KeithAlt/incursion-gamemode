hcWhitelist = hcWhitelist or {}
hcWhitelist.config = hcWhitelist.config or {}
hcWhitelist.motds = hcWhitelist.motds or {}
include("hcwhitelist_config.lua")

surface.CreateFont("hcWhitelist", {font = "Roboto", size = 18, weight = 400})
surface.CreateFont("hcWhitelistLarge", {font = "Arial", size = 82, weight = 400})
local deployableicon = Material("icons/72.png")
local waricon = Material("icons/50.png")
local motdicon = Material("icons/124.png")
hcWhitelist.config.font = "hcWhitelist"

-- Taken from https://wiki.facepunch.com/gmod/surface.DrawPoly
function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

net.Receive("hcSetFaction", function() --This isn't networked when changed by default?
    local uniqueID = net.ReadString()
    local ply = net.ReadEntity()
    ply:getChar().vars.faction = uniqueID
end)

function hcWhitelist.clearAvatarCache()
    for k, f in ipairs(file.Find("hcwhitelistavatarcache/*.png", "DATA")) do
        file.Delete("hcwhitelistavatarcache/" .. f)
    end
end

--Management menu
local function hcMenu()
    local startTime
    if hcWhitelist.config.debug then
        hcWhitelist.consoleLog("Receiving faction member data")
        startTime = SysTime()
    end

    local len   = net.ReadUInt(32) or false
    local data  = net.ReadData(len) or false
    local json  = util.Decompress(data) or false

	if !json then return end

    local chars = util.JSONToTable(json)

    local classes = {}
    for _, char in ipairs(chars) do
        local ply = player.GetBySteamID64(char.steamid)
        if IsValid(ply) then
            char.online = true
            char.ply = ply
        else
            char.online = false
        end

        local class = char.class
		local classID = hcWhitelist.uniqueIDToID(class)
        if nut.class.list[classID].NCO or nut.class.list[classID].Officer then
            class = "!" .. class
        end

        classes[class] = classes[class] or {}
        classes[class][#classes[class] + 1] = char
    end

    chars = {}
    for class, members in SortedPairs(classes) do
        table.sort(members, function(a, b) return a.online and !b.online end)
        for i = 1, #members do
            local member = members[i]

            chars[#chars + 1] = member
        end
    end

    if hcWhitelist.config.debug then
        hcWhitelist.consoleLog("Received data, runtime: " .. SysTime() - startTime .. "s")
    end

    if hcWhitelist.config.debug then
        hcWhitelist.consoleLog("Creating faction management menu")
        startTime = SysTime()
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle(nut.faction.indices[LocalPlayer():getChar():getFaction()].name)
    frame:SetSize(1280, 720)
    frame:Center()
    frame:MakePopup()
    frame:SetBackgroundBlur(hcWhitelist.theme.blur)
    frame.startTime = SysTime()
    frame.Paint = function(s, w, h)
        if s:GetBackgroundBlur() then
            Derma_DrawBackgroundBlur(s, s.startTime)
        end

		surface.SetDrawColor(hcWhitelist.theme.background)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(100, 100, 100, 25))
		surface.DrawOutlinedRect(0 + 1, 0 + 1, w - 2, h - 2)

        surface.SetDrawColor(hcWhitelist.theme.border)
		surface.DrawRect(0, 0, w, 24)
		surface.DrawOutlinedRect(0, 0, w, h)

        surface.SetDrawColor(hcWhitelist.theme.border)
		surface.DrawRect(0, 0, 72, h)
		surface.DrawOutlinedRect(0, 0, w, h)
    end
    frame.lblTitle:SetColor(hcWhitelist.theme.textColor)

    local name = vgui.Create("DLabel", frame)
    name:SetFont(hcWhitelist.config.font)
    name:SetText("Name")
    name:SizeToContents()
    name:SetPos(92, 65)
    name:SetTextColor(hcWhitelist.theme.textColor)

    local class = vgui.Create("DLabel", frame)
    class:SetFont(hcWhitelist.config.font)
    class:SetText("Class")
    class:SizeToContents()
    class:SetPos(483, 65)
    class:SetTextColor(hcWhitelist.theme.textColor)

    local steamid = vgui.Create("DLabel", frame)
    steamid:SetFont(hcWhitelist.config.font)
    steamid:SetText("SteamID")
    steamid:SizeToContents()
    steamid:SetPos(650, 65)
    steamid:SetTextColor(hcWhitelist.theme.textColor)

    local lastseen = vgui.Create("DLabel", frame)
    lastseen:SetFont(hcWhitelist.config.font)
    lastseen:SetText("Last Seen")
    lastseen:SizeToContents()
    lastseen:SetPos(809, 65)
    lastseen:SetTextColor(hcWhitelist.theme.textColor)

    local actions = vgui.Create("DLabel", frame)
    actions:SetFont(hcWhitelist.config.font)
    actions:SetText("Actions")
    actions:SizeToContents()
    actions:SetPos(1037, 65)
    actions:SetTextColor(hcWhitelist.theme.textColor)

    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:SetSize(frame:GetWide(), 590)
    scrollPanel:SetPos(0, 96)
    scrollPanel.FillMembers = function(s, members)
        s:Clear()

        for i = 1, math.min(#members, hcWhitelist.config.pageLen) do
            local member = members[i]

            local memberPanel = vgui.Create("hcMember", s)
            memberPanel:SetPos((frame:GetWide()/2) - (memberPanel:GetWide()/2), 79 * (i - 1))
            memberPanel:SetPlayer(member.ply, member)
            memberPanel.id = i
        end
    end
    scrollPanel:FillMembers(chars)

    local vbar = scrollPanel:GetVBar()
    vbar.Paint = function(s, w, h)
        surface.SetDrawColor(hcWhitelist.theme.primary)
        surface.DrawRect(0, 0, w, h)
    end

    vbar.btnGrip.Paint = function(s, w, h)
        if s.Depressed then
            surface.SetDrawColor(Color(0, 0, 0, 200))
        else
            surface.SetDrawColor(Color(0, 0, 0, 125))
        end
        surface.DrawRect(0, 0, w, h)
    end
    vbar.btnUp.Paint = function(s, w, h)
        surface.SetDrawColor(Color(0, 0, 0, 100))
        surface.DrawRect(0, 0, w, h)
    end
    vbar.btnDown.Paint = function(s, w, h)
        surface.SetDrawColor(Color(0, 0, 0, 100))
        surface.DrawRect(0, 0, w, h)
    end

    local pagesPanel = vgui.Create("DPanel", frame)
    pagesPanel:SetSize(frame:GetWide(), 30)
    pagesPanel:SetPaintBackground(false)
    pagesPanel:MoveBelow(scrollPanel, 2)
    pagesPanel.FillPages = function(s, members)
        local amtOfPages = math.ceil(#members / hcWhitelist.config.pageLen)

        pagesPanel:Clear()

        for i = 1, amtOfPages do
            local pageBtn = vgui.Create("DButton", pagesPanel)
            pageBtn:SetText(i)
            pageBtn:SetSize(24, 24)
            pageBtn:SetPos(i * 32, 0)
            pageBtn:CenterVertical()
            pageBtn.DoClick = function()
                local pagemembers = {}

                for j = ((i - 1) * hcWhitelist.config.pageLen) + 1, hcWhitelist.config.pageLen * i do
                    local member = members[j]
                    pagemembers[#pagemembers + 1] = member
                end

                scrollPanel:FillMembers(pagemembers)
            end
        end

        pagesPanel:SizeToChildren(true, false)
        pagesPanel:CenterHorizontal()
    end
    pagesPanel:FillPages(chars)

    local searchBox = vgui.Create("DTextEntry", frame)
    searchBox:SetSize(400, 30)
    searchBox:SetPos(100, 30)
    searchBox:SetFont(hcWhitelist.config.font)
    searchBox:SetPlaceholderText("Search")
    searchBox:SetHighlightColor(Color(3, 127, 252, 255))
    searchBox:SetCursorColor(Color(255, 255, 255, 255))
    searchBox:SetTextColor(hcWhitelist.theme.textColor)
    searchBox.Paint = function(panel, w, h)
        //draw.RoundedBox(15, 0, 0, w, h, hcWhitelist.theme.primary)

	    if panel:GetPlaceholderText() and !panel:HasFocus() and (!panel:GetText() or panel:GetText() == "")  then
            panel:SetText(panel:GetPlaceholderText())
            panel:DrawTextEntryText(panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor())
            panel:SetText("")

            return
        end

        panel:DrawTextEntryText(panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor())
    end
    searchBox.OnEnter = function(s)
        local search = s:GetText()

        if !search or search == "" then
            scrollPanel:FillMembers(chars)
            return
        end

        local results = {}
        for i = 1, #chars do
            local member = chars[i]

            if tostring(member.name):lower():find(search:lower()) or tostring(nut.class.list[hcWhitelist.uniqueIDToID(member.class)].name):lower():find(search:lower()) or tostring(member.steamid):lower():find(search:lower()) then
                results[#results + 1] = member
            end
        end
        scrollPanel:FillMembers(results)
        pagesPanel:FillPages(results)
    end

    local searchIcon = vgui.Create("DImage", frame)
    searchIcon:SetImageColor(Color(209, 209, 209, 255))
    searchIcon:SetImage("hcwhitelist/search_white_24x24.png")
    searchIcon:SizeToContents()
    searchIcon:SetPos(300, 33)
    searchIcon:MoveLeftOf(searchBox)


    if hcWhitelist.canOpenDeployable(LocalPlayer()) then
        local deployable = vgui.Create("DButton", frame)
        deployable:SetPos(10, 35)
        deployable:SetText("")
        deployable:SetSize(50, 50)
        deployable.iconcolor = Color(255, 255, 255, 255)

        local undertext = vgui.Create("DLabel", frame)
        undertext:SetPos(deployable:GetX() - 2, deployable:GetY() + 40)
        undertext:SetText("Deployables")

        deployable.OnCursorEntered = function()
            deployable.iconcolor = Color(255, 102, 0)
            undertext:SetTextColor(Color(255, 102, 0))
        end
        deployable.OnCursorExited = function()
            deployable.iconcolor = Color(255, 255, 255, 255)
            undertext:SetTextColor(Color(255, 255, 255, 255))
        end
        deployable.Paint = function(self, w, h)
            surface.SetDrawColor(hcWhitelist.theme.border)
            draw.NoTexture()
            draw.Circle(25, 25, 20, 25 )

            surface.SetDrawColor(deployable.iconcolor)
            surface.SetMaterial(deployableicon)
            surface.DrawTexturedRect(18, 15, 16, 16)
        end
        deployable.DoClick = function()
            local deploymenu = vgui.Create("FactionDeployableMenu")
            local fac = team.GetName(LocalPlayer():getChar():getFaction())

            deploymenu:SetTable(hcWhitelist.FactionDeployables[fac])
        end
    end

	if hcWhitelist.isHC(LocalPlayer()) then
    	local changeMOTD = vgui.Create("DButton", frame)
    	changeMOTD:SetPos(10, 110)
    	changeMOTD:SetText("")
    	changeMOTD:SizeToContents()
    	changeMOTD:SetSize(50, 50)
        changeMOTD.iconcolor = Color(255, 255, 255, 255)

        local undertext = vgui.Create("DLabel", frame)
        undertext:SetPos(changeMOTD:GetX() - 5, changeMOTD:GetY() + 45)
        undertext:SetText("MOTD")
        undertext:SetContentAlignment(8)

        changeMOTD.OnCursorEntered = function()
            undertext:SetTextColor(Color(255, 102, 0))
            changeMOTD.iconcolor = Color(255, 102, 0)
        end
        changeMOTD.OnCursorExited = function()
            undertext:SetTextColor(Color(255, 255, 255, 255))
            changeMOTD.iconcolor = Color(255, 255, 255, 255)
        end
        changeMOTD.Paint = function(self, w, h)
            surface.SetDrawColor(hcWhitelist.theme.border)
            draw.NoTexture()
            draw.Circle(25, 25, 20, 25 )

            surface.SetDrawColor(changeMOTD.iconcolor)
            surface.SetMaterial(motdicon)
            surface.DrawTexturedRect(18, 15, 16, 16)
        end
    	changeMOTD.DoClick = function(panel)
        	local motdFrame = vgui.Create("DFrame", frame)
        	motdFrame:SetTitle("Change MOTD")
        	motdFrame:SetSize(500, 600)
        	motdFrame:Center()
        	motdFrame.Paint = function(s, w, h)
    			surface.SetDrawColor(hcWhitelist.theme.background)
    			surface.DrawRect(0, 0, w, h)

    			surface.SetDrawColor(Color(100, 100, 100, 25))
    			surface.DrawOutlinedRect(0 + 1, 0 + 1, w - 2, h - 2)

            	surface.SetDrawColor(hcWhitelist.theme.border)
    			surface.DrawRect(0, 0, w, 24)
    			surface.DrawOutlinedRect(0, 0, w, h)
        	end

        	local motdBox = vgui.Create("DTextEntry", motdFrame)
        	motdBox:SetMultiline(true)
        	motdBox:Dock(FILL)
        	motdBox:SetHighlightColor(Color(3, 127, 252, 255))
        	motdBox:SetCursorColor(Color(255, 255, 255, 255))
        	motdBox:SetTextColor(hcWhitelist.theme.textColor)
        	motdBox:SetFont(hcWhitelist.config.font)
        	motdBox.Paint = function(s, w, h)
            	surface.SetDrawColor(hcWhitelist.theme.background)
    			surface.DrawRect(0, 0, w, h)

    			surface.SetDrawColor(Color(100, 100, 100, 25))
    			surface.DrawOutlinedRect(0 + 1, 0 + 1, w - 2, h - 2)

            	surface.SetDrawColor(hcWhitelist.theme.border)
    			surface.DrawOutlinedRect(0, 0, w, h)

            	s:DrawTextEntryText(s:GetTextColor(), s:GetHighlightColor(), s:GetCursorColor())
        	end

        	local motdConfirm = vgui.Create("DButton", motdFrame)
        	motdConfirm:Dock(BOTTOM)
        	motdConfirm:SetText("Confirm")
        	motdConfirm.DoClick = function(s)
            	local motd = motdBox:GetText()
            	if #motd > hcWhitelist.config.maxMOTDLen then
                	nut.util.notify("MOTD must be at most " .. hcWhitelist.config.maxMOTDLen .. " characters")
                	return
            	end

            	for k, str in pairs(motd:Split("\n")) do
                	if #str > 1000 then
                    	nut.util.notify("Each paragraph must be at most 1000 characters")
                    	return
                	end
            	end

            	motdFrame:Close()
            	net.Start("hcMOTD")
                	net.WriteString(motd)
            	net.SendToServer()
        	end
    	end

        local warreasons = vgui.Create("DButton", frame)
        warreasons:SetPos(10, 180)
        warreasons:SetText("")
        warreasons:SetSize(50, 50)
        warreasons.iconcolor = Color(255, 255, 255, 255)

        local undertext = vgui.Create("DLabel", frame)
        undertext:SetPos(warreasons:GetX() - 2, warreasons:GetY() + 40)
        undertext:SetText("War Reasons")

        warreasons.OnCursorEntered = function()
            warreasons.iconcolor = Color(255, 102, 0)
            undertext:SetTextColor(Color(255, 102, 0))
        end
        warreasons.OnCursorExited = function()
            warreasons.iconcolor = Color(255, 255, 255, 255)
            undertext:SetTextColor(Color(255, 255, 255, 255))
        end
        warreasons.Paint = function(self, w, h)
            surface.SetDrawColor(hcWhitelist.theme.border)
            draw.NoTexture()
            draw.Circle(25, 25, 20, 25 )

            surface.SetDrawColor(warreasons.iconcolor)
            surface.SetMaterial(waricon)
            surface.DrawTexturedRect(18, 15, 16, 16)
        end
        warreasons.DoClick = function()
            vgui.Create("WARReasonActivator")
        end
	end

    if hcWhitelist.config.debug then
        hcWhitelist.consoleLog("Menu created, runtime: " .. SysTime() - startTime .. "s")
    end
end
net.Receive("hcSendMembers", hcMenu)

--Logs menu
local function FillLogs(panel, logs)
    for i = 1, #logs do
        local log = logs[i]
        panel:AddLine(log.action, log.hcSteamID, log.targetSteamID, os.date("%d/%m/%Y - %H:%M:%S", log.time))
    end
end

local function LogSearch(panel, logs, search)
    panel:Clear()

    if !search or search == "" then
        FillLogs(panel, logs)
        return
    end

    local results = {}
    for _,log in pairs(logs) do
        for _,entry in pairs(log) do
            if tostring(entry):lower():find(search:lower()) then
                table.insert(results, log)
                break
            end
        end
    end

    FillLogs(panel, results)
end

local function hcLogs()
    local len  = net.ReadUInt(32)
    local data = net.ReadData(len)
    local json = util.Decompress(data)
    local logs = util.JSONToTable(json)

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Faction Management Logs")
    frame:SetSize(650, 950)
    frame:Center()
    frame:MakePopup()

    local listView = vgui.Create("DListView", frame)
    listView:Dock(FILL)
    listView:AddColumn("Action"):SetWidth(220)
    listView:AddColumn("HC SteamID"):SetWidth(70)
    listView:AddColumn("Target SteamID"):SetWidth(70)
    listView:AddColumn("Time"):SetWidth(75)
    FillLogs(listView, logs)

    local searchBox = vgui.Create("DTextEntry", frame)
    searchBox:Dock(BOTTOM)
    searchBox:SetPlaceholderText("Search...")
    searchBox.OnEnter = function(s)
        LogSearch(listView, logs, s:GetText())
    end
end
net.Receive("hcViewLogs", hcLogs)

--MOTD Display/notify
function hcWhitelist.showMOTD()
    local char = LocalPlayer():getChar()
    if !char then return end

    local factionID = char:getFaction()
    if !factionID then return end

    local faction = nut.faction.indices[factionID]

    local motd = hcWhitelist.getMOTD(faction.uniqueID)
    if !motd then
        nut.util.notify("No MOTD found!")
        return
    end

    local motdFrame = vgui.Create("DFrame")
    motdFrame:SetTitle(nut.faction.indices[LocalPlayer():getChar():getFaction()].name .. " MOTD")
    motdFrame:SetSize(500, 600)
    motdFrame:Center()
    motdFrame:MakePopup()
    motdFrame:SetBackgroundBlur(hcWhitelist.theme.blur)
    motdFrame.startTime = SysTime()
    motdFrame.Paint = function(s, w, h)
        if s:GetBackgroundBlur() then
            Derma_DrawBackgroundBlur(s, s.startTime)
        end

		surface.SetDrawColor(hcWhitelist.theme.background)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(100, 100, 100, 25))
		surface.DrawOutlinedRect(0 + 1, 0 + 1, w - 2, h - 2)

        surface.SetDrawColor(hcWhitelist.theme.popupColor)
		surface.DrawRect(0, 0, w, 24)
		surface.DrawOutlinedRect(0, 0, w, h)
    end

    local motdDisplay = motdFrame:Add("RichText")
    motdDisplay:Dock(FILL)

    motdDisplay.PerformLayout = function(s)
        s:SetFontInternal(hcWhitelist.config.font)
        s:SetFGColor(hcWhitelist.theme.textColor)
    end

    for k, str in pairs(motd:Split("\n")) do
        motdDisplay:AppendText(str .. "\n")
    end

    file.Write("hcwhitelistlastseenmotd.txt", motd)
end
net.Receive("hcShowMOTD", hcWhitelist.showMOTD)

net.Receive("hcMOTD", function()
    local len = net.ReadUInt(32)
    local data = net.ReadData(len)
    local json = util.Decompress(data)
    hcWhitelist.motds = util.JSONToTable(json)

    local faction = nut.faction.indices[LocalPlayer():getChar():getFaction()]

    if ispanel(hcWhitelist.notifPopup) then
        hcWhitelist.notifPopup:Remove()
        hcWhitelist.notifPopup = nil
    end

    local motd = hcWhitelist.getMOTD(faction.uniqueID)
    if !motd then
        return
    end

    local lastSeenMOTD = file.Read("hcwhitelistlastseenmotd.txt") or ""
    if lastSeenMOTD == motd then
        return
    end

    hcWhitelist.notifPopup = vgui.Create("hcNotification")

    chat.AddText("Received " .. faction.name .. " MOTD! Press F8 to toggle your cursor, then left click the notification alert in the top right to view or right click to dismiss.")
end)
