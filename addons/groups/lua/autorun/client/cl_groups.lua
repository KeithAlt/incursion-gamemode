local pingBind = KEY_P
local vcBind = KEY_O
local drawFriends = true

local left = true
local top = true


hook.Add("InitPostEntity", "GroupsSetupBinds", function()
    if file.Exists("groupsbinds.txt", "DATA") then
        local json  = file.Read("groupsbinds.txt")
        local table = util.JSONToTable(json)
        pingBind    = table.ping
        vcBind      = table.voice

        net.Start("GroupsBindChange")
            net.WriteString("ping")
            net.WriteInt(pingBind, 32)
        net.SendToServer()

        net.Start("GroupsBindChange")
            net.WriteString("voice")
            net.WriteInt(vcBind, 32)
        net.SendToServer()
    end
end)

surface.CreateFont("GroupsHUD", {font = "Calibri", size = 20, weight = 800})

local function initGroupPanel()
    if IsValid(GroupPanel) then
        GroupPanel:Remove()
    end

    GroupPanel = vgui.Create("DPanel")
    GroupPanel:ParentToHUD()
    GroupPanel:SetSize(310, (groupsConfig.MaxPlayers or 4 - 1) * 64)
    if !left and !top then
        GroupPanel:SetPos(ScrW() - 310 - 49, (ScrH() - 70) - GroupPanel:GetTall())
    elseif !left and top then
        GroupPanel:SetPos(ScrW() - GroupPanel:GetWide() - 16, 16)
    elseif left and top then
        GroupPanel:SetPos(16, 16)
    else
        GroupPanel:SetPos(32, (ScrH() - 70) - GroupPanel:GetTall())
    end
    GroupPanel:SetPaintBackground(false)
end
hook.Add("InitPostEntity", "CreateGroupVGUI", function()
    initGroupPanel()
end)

local micOn = Material("mic_white_192x192.png")
local micOff = Material("mic_off_white_192x192.png")
local pingMat = Material("group_ping.png")
local star = Material("star_white_18x18.png")

local function SaveBinds()
    local json = util.TableToJSON({ping = pingBind, voice = vcBind})
    file.Write("groupsbinds.txt", json)
end

local function ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
    draw.SimpleText(text, font, x + dist, y + dist, colorshadow, xalign, yalign)
    draw.SimpleText(text, font, x, y, colortext, xalign, yalign)
end

local function drawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 )
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local function SetupGroupVGUI()
    GROUPS = net.ReadTable()

    if !GroupPanel then return end
    for _,v in pairs(GroupPanel:GetChildren()) do
        v:Remove()
    end

    if !isfunction(LocalPlayer().GetGroup) then return end

    local group = LocalPlayer():GetGroup()

    if !group then return end

    local i
    if top then
        i = 0
    else
        i = 1
    end
    local colI = 1
    for ply, rank in pairs(group:GetPlayers()) do
        if !IsValid(ply) then continue end

        if ply == LocalPlayer() then
            colI = colI + 1
            continue
        end

        local col = Color(254, 201, 95)
        local circleCol = groupsConfig.Colors[colI]

        local avatar = vgui.Create("AvatarImage", GroupPanel)
        avatar:SetPlayer(ply)
        avatar:SetSize(48, 48)
        if !left and top then
            avatar:SetPos(GroupPanel:GetWide() - 51, 0 + 64 * i)
        elseif !left and !top then
            avatar:SetPos(GroupPanel:GetWide() - 51, (GroupPanel:GetTall() - (48 * i)) - 16 * i)
        elseif left and top then
            avatar:SetPos(0, 0 + 64 * i)
        else
            avatar:SetPos(0, (GroupPanel:GetTall() - (48 * i)) - 16 * i)
        end

        local circle = vgui.Create("DPanel", GroupPanel)
        circle:SetSize(12, 12)
        circle:MoveRightOf(avatar, -9)
        circle:MoveBelow(avatar, -9)
        circle.Paint = function(s, w, h)
            draw.NoTexture()
            surface.SetDrawColor(circleCol)
            drawCircle(w/2, w/2, w/2, 10)
        end

        if ply == group:GetOwner() then
            local starC = vgui.Create("DPanel", GroupPanel)
            starC:SetSize(20, 20)
            starC:MoveLeftOf(avatar, -10)
            starC:MoveBelow(avatar, -10)
            starC.Paint = function(s, w, h)
                DisableClipping(true)
                draw.NoTexture()
                surface.SetDrawColor(0, 0, 0, 200)
                drawCircle(w/2, w/2, w/2, 10)
                DisableClipping(false)
            end

            local starP = vgui.Create("DPanel", GroupPanel)
            starP:SetSize(18, 18)
            starP:MoveLeftOf(avatar, -10)
            starP:MoveBelow(avatar, -10)
            starP.Paint = function(s, w, h)
                DisableClipping(true)
                surface.SetDrawColor(col)
                surface.SetMaterial(star)
                surface.DrawTexturedRect(-1, 1, w, h)
                DisableClipping(false)
            end
        end

        local hpBar = vgui.Create("DPanel", GroupPanel)
        if !left then
            hpBar:MoveLeftOf(avatar, 14 + avatar:GetWide() + 115)
        else
            hpBar:MoveRightOf(avatar, 7)
        end
        hpBar:MoveBelow(avatar, -10)
        hpBar:SetSize(230, 10)
        hpBar.Paint = function(s, w, h)
            if !IsValid(ply) then return end
            DisableClipping(true)

            local pos = math.max((ply:Health() / ply:GetMaxHealth()) * w, 0)

            surface.SetDrawColor(0, 0, 0, 150)
        	surface.DrawRect(0, 0, w + 4, h)
        	surface.SetDrawColor(0, 0, 0, 200)
        	surface.DrawOutlinedRect(0, 0, w + 4, h)

        	surface.SetDrawColor(col.r, col.g, col.b)
        	surface.DrawRect(2, 2, pos, h - 4)

            DisableClipping(false)
        end

        local level = vgui.Create("DPanel", GroupPanel)
        level:SetSize(25, 20)
        if !left then
            level:MoveLeftOf(avatar, 9)
        else
            level:MoveRightOf(avatar, 9)
        end
        level:MoveAbove(hpBar, 3)
        level.Paint = function(s, w, h)
            if !IsValid(ply) then return end
            DisableClipping(true)

            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(2, 2, w, h)
            surface.SetDrawColor(col.r, col.g, col.b)
            surface.DrawRect(0, 0, w, h)

            draw.SimpleText(ply:getChar():getData("level", 1), "GroupsHUD", w/2, 0, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)

            DisableClipping(false)
        end

        local name = vgui.Create("DPanel", GroupPanel)
        if !left then
            surface.SetFont("GroupsHUD")
            local textW = surface.GetTextSize(ply:Nick())
            name:SetSize(textW, 20)
            name:MoveLeftOf(level, 5)
        else
            name:SetSize(200, 20)
            name:MoveRightOf(level, 7)
        end
        name:MoveAbove(hpBar, 3)
        name.Paint = function(s, w, h)
            if !IsValid(ply) then return end

            local nick = ply:Nick()

            if !left then
                surface.SetFont("GroupsHUD")
                local tw = surface.GetTextSize(nick)
                s:SetWide(tw)
                s:MoveLeftOf(level, 5)
            end

            ShadowText(nick, "GroupsHUD", 0, 0, col, Color(0, 0, 0, 255), 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        i = i + 1
        colI = colI + 1
    end
end
net.Receive("SyncGroups", SetupGroupVGUI)

hook.Add("HUDPaint", "GroupVoiceStatus", function()
    local group = LocalPlayer():GetGroup()
    if !group then return end

    local inVC = LocalPlayer():GetNWBool("InGroupVC")
    surface.SetDrawColor(254, 201, 95)
    surface.SetMaterial(inVC and micOn or micOff)
    surface.DrawTexturedRect(0, 0, 32, 32)

    local w, h = 64, 64
    for col, pos in pairs(group:GetPings()) do
        local distance = LocalPlayer():GetPos():DistToSqr(pos)
        if distance >= groupsConfig.PingDistance*groupsConfig.PingDistance then return end

        local scrPos = pos:ToScreen()
        local scale = math.Clamp(1 - distance/(1024*1024), 0.25, 1)
        w, h = w * scale, h * scale

        surface.SetDrawColor(col)
        surface.SetMaterial(pingMat)
        surface.DrawTexturedRect(scrPos.x - (w / 2), scrPos.y - (h / 2), w, h)
		draw.SimpleText("[" .. math.Round(jlib.UnitsToMeters(math.sqrt(distance)), 1) .. "m]", "GroupsHUD", scrPos.x, scrPos.y + (30 * scale), col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end)

hook.Add("PreDrawHalos", "GroupsWalls", function()
    if !drawFriends then return end
    if !isfunction(LocalPlayer().GetGroup) then return end

    local group = LocalPlayer():GetGroup()
    if !group then return end

    local plys = group:GetPlayers()

    local i = 1
    for ply, rank in pairs(plys) do
        if !IsValid(ply) then continue end
        if !ply:Alive() then i = i + 1 continue end

        if ply != LocalPlayer() and ply:GetPos():DistToSqr(LocalPlayer():GetPos()) < groupsConfig.WallsDistance*groupsConfig.WallsDistance then
            halo.Add({ply}, groupsConfig.Colors[i] or Color(255, 255, 255), 2, 2, 1, true, true)
        end

        i = i + 1
    end
end)

local infoText = [[
Key Binds:
O - Toggle group voice channel, current group voice status can be seen in the top left.
P - Ping the location you are looking at for all group members to see.

Commands:
/group - Use group only text chat.
/groups - Opens the groups management menu.
/groupinvite - Sends an invite to a player of your choosing if you are a group owner.

Other:
You can also invite someone to a group by opening the context menu (default C) and right clicking on a player.
Key binds can be changed by clicking the cog on groups management menu.

Credits:
jonjo
ThePotato2600 - helped a lot with testing
]]
local function GroupsMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 400)
    frame:SetTitle("Groups Management")
    frame:MakePopup()
    frame:Center()

    local infoButton = vgui.Create("DImageButton", frame)
    infoButton:SetSize(16, 16)
    infoButton:SetImage("icon16/information.png")
    infoButton:SetPos(frame:GetWide() - 90, 4)
    infoButton.DoClick = function(s)
        local infoFrame = vgui.Create("DFrame", frame)
        infoFrame:SetSize(300, 330)
        infoFrame:SetTitle("Groups Information")
        infoFrame:Center()

        local infoLabel = vgui.Create("DLabel", infoFrame)
        infoLabel:SetWrap(true)
        infoLabel:SetSize(250, 300)
        infoLabel:SetText(infoText)
        infoLabel:SetPos(0, 25)
        infoLabel:CenterHorizontal()
    end

    local settingsButton = vgui.Create("DImageButton", frame)
    settingsButton:SetSize(16, 16)
    settingsButton:SetImage("icon16/cog.png")
    settingsButton:SetPos(frame:GetWide() - 64, 4)
    settingsButton.DoClick = function(s)
        local settingsFrame = vgui.Create("DFrame", frame)
        settingsFrame:SetSize(300, 200)
        settingsFrame:SetTitle("Groups Settings")
        settingsFrame:Center()

        local vcLabel = vgui.Create("DLabel", settingsFrame)
        vcLabel:SetText("Voice Channel Bind")
        vcLabel:SizeToContents()
        vcLabel:SetPos(0, 55)
        vcLabel:CenterHorizontal()

        local vcBinder = vgui.Create("DBinder", settingsFrame)
        vcBinder:SetSize(100, 20)
        vcBinder:SetValue(vcBind)
        vcBinder:MoveBelow(vcLabel, 5)
        vcBinder:CenterHorizontal()
        vcBinder:SetTextColor(Color(220, 220, 220, 255))
        vcBinder.OnChange = function(self, num)
            vcBind = num
            SaveBinds()
            net.Start("GroupsBindChange")
                net.WriteString("voice")
                net.WriteInt(num, 32)
            net.SendToServer()
        end

        local pingLabel = vgui.Create("DLabel", settingsFrame)
        pingLabel:SetText("Ping Bind")
        pingLabel:MoveBelow(vcBinder, 10)
        pingLabel:SizeToContents()
        pingLabel:CenterHorizontal()

        local pingBinder = vgui.Create("DBinder", settingsFrame)
        pingBinder:SetSize(100, 20)
        pingBinder:SetValue(pingBind)
        pingBinder:MoveBelow(pingLabel, 5)
        pingBinder:CenterHorizontal()
        pingBinder:SetTextColor(Color(220, 220, 220, 255))
        pingBinder.OnChange = function(self, num)
            pingBind = num
            SaveBinds()
            net.Start("GroupsBindChange")
                net.WriteString("ping")
                net.WriteInt(num, 32)
            net.SendToServer()
        end

        local highlightToggle = vgui.Create("DButton", settingsFrame)
        highlightToggle:SetTextColor(Color(220, 220, 220, 255))
        highlightToggle:SetSize(100, 20)
        highlightToggle:SetText("Toggle Highlight")
        highlightToggle:CenterHorizontal()
        highlightToggle:MoveBelow(pingBinder, 5)
        highlightToggle.DoClick = function(self)
            drawFriends = !drawFriends
        end
    end

    local group = LocalPlayer():GetGroup()

    if !group then
        local name = vgui.Create("DTextEntry", frame)
        name:SetSize(130, 20)
        name:SetPlaceholderText("Name")
        name:Center()

        local create = vgui.Create("DButton", frame)
        create:SetSize(130, 20)
        create:Center()
        create:MoveBelow(name, 5)
        create:SetText("Create")
        create:SetTextColor(Color(220, 220, 220, 255))

        create.DoClick = function()
            local t = name:GetText()
            if t == "" then
                nut.util.notify("You must enter a name for your group")
                return
            elseif #t < groupsConfig.MinNameLen then
                nut.util.notify("The name of your group must be at least " .. groupsConfig.MinNameLen .. " characters long")
                return
            elseif #t > groupsConfig.MaxNameLen then
                nut.util.notify("The name of your group must be at most " .. groupsConfig.MaxNameLen .. " characters long")
                return
            end

            net.Start("GroupsCreate")
                net.WriteString(t)
            net.SendToServer()
            frame:Close()
        end
    else
        frame:SetTitle("Groups Management - " .. group:GetName())

        local options = vgui.Create("DPanel", frame)
        options:SetSize(450, 300)
        options:Center()

        local list = vgui.Create("DListView", options)
        list:SetSize(400, 100)
        list:CenterHorizontal()
        list:AddColumn("Player")
        list:AddColumn("Rank")

        local lines = {}
        for ply, rank in pairs(group:GetPlayers()) do
            if !IsValid(ply) then continue end

            local entry = list:AddLine(ply:Nick(), rank)
            lines[entry] = ply
        end

        list.OnRowSelected = function(s, i, line)
            local ply = lines[line]

            if LocalPlayer() != group:GetOwner() then return end
            if ply == LocalPlayer() then return end

            local menu = DermaMenu(frame)
            menu:SetPos(input.GetCursorPos())
            menu:MakePopup()
            menu:AddOption("Make owner", function()
                net.Start("GroupsPromote")
                    net.WriteEntity(ply)
                net.SendToServer()
                frame:Close()
            end)
            menu:AddOption("Remove from group", function()
                net.Start("GroupsRemove")
                    net.WriteEntity(ply)
                net.SendToServer()
                line:Remove()
            end)
        end

        if LocalPlayer() != group:GetOwner() then
            local leave = vgui.Create("DButton", options)
            leave:SetText("Leave")
            leave:SizeToContents()
            leave:Center()
            leave:MoveBelow(list, 10)
            leave:SetTextColor(Color(220, 220, 220, 255))
            leave.DoClick = function(s)
                net.Start("GroupsLeave")
                net.SendToServer()
                frame:Close()
            end

            return
        end

        local name = vgui.Create("DTextEntry", options)
        name:SetSize(130, 20)
        name:SetPlaceholderText("Name")
        name:CenterHorizontal()
        name:MoveBelow(list, 10)

        local rename = vgui.Create("DButton", options)
        rename:SetText("Rename")
        rename:SizeToContents()
        rename:Center()
        rename:MoveBelow(name, 5)
        rename:SetTextColor(Color(220, 220, 220, 255))
        rename.DoClick = function()
            local t = name:GetText()

            for k,v in pairs(GROUPS) do
                if v:GetName() == t then
                    nut.util.notify("This group name is already taken")
                    return
                end
            end

            if t == "" then
                nut.util.notify("You must enter a name for your group")
                return
            elseif #t < groupsConfig.MinNameLen then
                nut.util.notify("The name of your group must be at least " .. groupsConfig.MinNameLen .. " characters long")
                return
            elseif #t > groupsConfig.MaxNameLen then
                nut.util.notify("The name of your group must be at most " .. groupsConfig.MaxNameLen .. " characters long")
                return
            end

            net.Start("GroupsRename")
                net.WriteString(t)
            net.SendToServer()
            frame:SetTitle("Groups Management - " .. t)
        end

        local disband = vgui.Create("DButton", options)
        disband:SetText("Disband Group")
        disband:SizeToContents()
        disband:Center()
        disband:MoveBelow(rename, 5)
        disband:SetTextColor(Color(220, 220, 220, 255))
        disband.DoClick = function()
            net.Start("GroupsDisband")
            net.SendToServer()
            frame:Close()
        end
    end
end
net.Receive("GroupsOpenMenu", GroupsMenu)

local function GroupsInvite()
    local sender = net.ReadEntity()

    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 100)
    frame:Center()
    frame:SetPos((ScrW()/2) - (frame:GetWide()/2), ScrH())
    frame:SetTitle("Invite to join " .. (IsValid(sender) and sender:GetGroup():GetName() or "group") .. " - press F8 for cursor")

    local accept = vgui.Create("DButton", frame)
    accept:SetSize(100, 40)
    accept:SetText("ACCEPT")
    accept:SetPos(((frame:GetWide()/2) - (accept:GetWide())) - 2, ((frame:GetTall()/2) - (accept:GetTall()/2)) + 10)
    accept.Paint = function(s, w, h)
        surface.SetDrawColor(30, 216, 30)
        surface.DrawRect(0, 0, w, h)
    end
    accept.DoClick = function(s)
        frame:MoveTo((ScrW()/2) - (frame:GetWide()/2), ScrH(), 0.5, 0, -1, function() frame:Close() end)
        net.Start("GroupsAcceptInvite")
            net.WriteEntity(sender)
        net.SendToServer()
    end
    accept:SetTextColor(Color(240, 240, 240))

    local decline = vgui.Create("DButton",frame)
    decline:SetSize(100, 40)
    decline:SetText("DECLINE")
    decline:SetPos(((frame:GetWide()) - (decline:GetWide()*1.5)) + 2, ((frame:GetTall()/2) - (decline:GetTall()/2)) + 10)
    decline.Paint = function(s, w, h)
        surface.SetDrawColor(216, 30, 30)
        surface.DrawRect(0, 0, w, h)
    end
    decline.DoClick = function(s)
        frame:MoveTo((ScrW()/2) - (frame:GetWide()/2), ScrH(), 0.5, 0, -1, function() frame:Close() end)
    end
    decline:SetTextColor(Color(240, 240, 240))

    frame:MoveTo((ScrW()/2) - (frame:GetWide()/2), ScrH() - frame:GetTall(), 0.5)

    timer.Simple(30, function()
        if !IsValid(frame) then return end
        frame:MoveTo((ScrW()/2) - (frame:GetWide()/2), ScrH(), 0.5, 0, -1, function() frame:Close() end)
    end)
end
net.Receive("GroupsInvite", GroupsInvite)

local cursorShown = false
local cursorPos = {x = ScrW()/2, y = ScrH()/2}
hook.Add("PlayerButtonDown", "GroupsShowCursor", function(ply, key)
    if !IsFirstTimePredicted() then return end
    if ply != LocalPlayer() then return end
    if key == KEY_F8 then
        cursorShown = !cursorShown
        gui.EnableScreenClicker(cursorShown)
        if cursorShown then
            input.SetCursorPos(cursorPos.x, cursorPos.y)
        else
            cursorPos.x, cursorPos.y = input.GetCursorPos()
        end
    end
end)

net.Receive("GroupChat", function(len, ply)
    local message = net.ReadString()
    local sender = net.ReadEntity()

    LocalPlayer():GroupChat(message, sender)
end)
