--Territory/Spawn Making
FalloutGuilds.ContextMenuOpen = false

hook.Add("OnContextMenuOpen", "GuildToggle", function() FalloutGuilds.ContextMenuOpen = true end)
hook.Add("OnContextMenuClose", "GuildToggle", function() FalloutGuilds.ContextMenuOpen = false end)

hook.Add("PlayerButtonDown", "GuildTerritories", function(ply, btn)
    if btn == MOUSE_RIGHT and FalloutGuilds.ContextMenuOpen and IsFirstTimePredicted() then
        local guild, guildID = FalloutGuilds.GetGuild(LocalPlayer())

        if !guild then return end

        if !FalloutGuilds.IsOwner(guildID, LocalPlayer()) then
            return
        end

        local tr = ply:GetEyeTrace()

        if IsValid(tr.Entity) then return end

        local pos = tr.HitPos

        local territoryID

        for id, territory in pairs(guild.territories) do
            if pos:WithinAABox(territory.mins, territory.maxs) then
                territoryID = id
                break
            end
        end

        local menu = vgui.Create("DMenu")
        menu:SetPos(input.GetCursorPos())
        menu:MakePopup()

		local hasEnoughMembers = table.Count(FalloutGuilds.Guilds[guildID].members) >= FalloutGuilds.Config.MinMembers
        local canMakeTerritory = table.Count(guild.territories) < FalloutGuilds.Config.MaxTerritories and hasEnoughMembers

        if !territoryID and canMakeTerritory then
            if FalloutGuilds.TerrStart then
                FalloutGuilds.TerrEnd = pos
            end

            if !FalloutGuilds.TerrStart then
                menu:AddOption("Set Territory Start", function()
                    FalloutGuilds.TerrStart = pos
                end):SetIcon("icon16/add.png")
            else
                menu:AddOption("Set Territory End", function()
                    local mins = Vector()
                    local maxs = Vector()

                    if FalloutGuilds.TerrStart.x < pos.x then
                        mins.x = FalloutGuilds.TerrStart.x
                        maxs.x = pos.x
                    else
                        mins.x = pos.x
                        maxs.x = FalloutGuilds.TerrStart.x
                    end

                    if FalloutGuilds.TerrStart.y < pos.y then
                        mins.y = FalloutGuilds.TerrStart.y
                        maxs.y = pos.y
                    else
                        mins.y = pos.y
                        maxs.y = FalloutGuilds.TerrStart.y
                    end

                    if FalloutGuilds.TerrStart.z < pos.z then
                        mins.z = FalloutGuilds.TerrStart.z
                        maxs.z = pos.z
                    else
                        mins.z = pos.z
                        maxs.z = FalloutGuilds.TerrStart.z
                    end

                    Derma_StringRequest("Territory Name", "WARNING: Choosing the same name as another territory will overwrite it.", "", function(text)
                        if FalloutGuilds.TerritoryOverlap(mins, maxs) then
                            nut.util.notify("Your territory cannot overlap with another territory!")
                            return
                        end

                        local area = (maxs.x - mins.x) * (maxs.y - mins.y)

                        if FalloutGuilds.TotalTerritoryArea(guildID) + area > FalloutGuilds.Config.MaxArea then
                            nut.util.notify("Area too big!")
                            return
                        end

                        if #text < 4 then nut.util.notify("The name must be at least 4 characters") return end

                        net.Start("GuildCreateTerritory")
                            net.WriteVector(mins)
                            net.WriteVector(maxs)
                            net.WriteString(text)
                        net.SendToServer()
                    end)

                    FalloutGuilds.TerrStart = nil
                end):SetIcon("icon16/add.png")
            end

            menu.OnRemove = function(s)
                FalloutGuilds.TerrEnd = nil
            end
        elseif territoryID then
            menu:AddOption("Remove Territory", function()
                net.Start("GuildRemoveTerritory")
                    net.WriteString(territoryID)
                net.SendToServer()
            end):SetIcon("icon16/delete.png")

            local spawnID

            for id, spawnPos in pairs(guild.territories[territoryID].spawns) do
                if pos:Distance(spawnPos) < 5 then
                    spawnID = id
                    break
                end
            end

            if !spawnID and hasEnoughMembers then
                menu:AddOption("Add Spawn", function()
                    net.Start("GuildAddTerritorySpawn")
                        net.WriteString(territoryID)
                        net.WriteVector(pos)
                    net.SendToServer()
                end):SetIcon("icon16/add.png")
            elseif spawnID then
                menu:AddOption("Remove Spawn", function()
                    net.Start("GuildRemoveTerritorySpawn")
                        net.WriteString(territoryID)
                        net.WriteUInt(spawnID, 32)
                    net.SendToServer()
                end):SetIcon("icon16/delete.png")
            end
        end
    end
end)

hook.Add("PostDrawOpaqueRenderables", "GuildDraw", function()
    cam.Start3D()

    if FalloutGuilds.TerrStart then
        render.DrawWireframeBox(FalloutGuilds.TerrStart, Angle(0, 0, 0), Vector(0, 0, 0), ((FalloutGuilds.TerrEnd or LocalPlayer():GetEyeTrace().HitPos) - FalloutGuilds.TerrStart) + Vector(0, 0, 100), Color(0, 0, 0, 255), true)
    end

    if FalloutGuilds.ContextMenuOpen then
        local guild = FalloutGuilds.GetGuild(LocalPlayer())

        if !guild then
            cam.End3D()
            return
        end

        for id, territory in pairs(guild.territories) do
            render.DrawWireframeBox(territory.mins, Angle(0, 0, 0), Vector(0, 0, 0), (territory.maxs - territory.mins) + Vector(0, 0, 100), Color(0, 0, 0, 255), true)

            for _, pos in pairs(territory.spawns) do
                local r = 10

                render.SetColorMaterial()
                render.DrawSphere(pos, r, 50, 50, Color(255, 0, 0, 240))
            end
        end
    end

    cam.End3D()
end)

--Networking
net.Receive("GuildUpdate", function()
    local id = net.ReadUInt(32)
    local guild = jlib.ReadCompressedTable()

    FalloutGuilds.Guilds[id] = guild
end)

net.Receive("GuildFullUpdate", function()
    FalloutGuilds.Guilds = jlib.ReadCompressedTable()
end)

--Entering territories
FalloutGuilds.Alpha = 0

surface.CreateFont("GuildTerritory", {font = "Roboto", size = ScreenScale(12), weight = 400})

hook.Add("HUDPaint", "GuildEnterTerritory", function()
    if FalloutGuilds.InTerritory and FalloutGuilds.Alpha >= 0 then
        FalloutGuilds.Alpha = math.min(255 * math.sin((CurTime() - FalloutGuilds.TimeEntered) * 0.8), 255)

        draw.SimpleTextOutlined("Entering " .. FalloutGuilds.Guilds[FalloutGuilds.InTerritory.owner].name .. " Territory - " .. FalloutGuilds.InTerritory.name, "GuildTerritory", ScrW() / 2, 300, Color(255, 255, 255, FalloutGuilds.Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, FalloutGuilds.Alpha))
    end
end)

timer.Create("GuildEnterTerritory", 0.45, 0, function()
    if !IsValid(LocalPlayer()) then return end

    local pos = LocalPlayer():GetPos()

    if FalloutGuilds.InTerritory then
        if !pos:WithinAABox(FalloutGuilds.InTerritory.mins, FalloutGuilds.InTerritory.maxs) then
            print("Left " .. FalloutGuilds.InTerritory.name)
            FalloutGuilds.Alpha = 0
            FalloutGuilds.InTerritory = nil
        end
    else
        for gID, guild in pairs(FalloutGuilds.Guilds) do
            for terrID, territory in pairs(guild.territories) do
                if pos:WithinAABox(territory.mins, territory.maxs) and !FalloutGuilds.InTerritory then
                    print("Entered " .. territory.name)
                    FalloutGuilds.TimeEntered = CurTime()
                    FalloutGuilds.InTerritory = territory
                    break
                end
            end
        end
    end
end)

--Guild management menu
surface.CreateFont("GuildMenu", {font = roboto, size = 24, weight = 400})

function FalloutGuilds.Menu()
    local hasGuild = net.ReadBool()
    local members
    local guild
    local guildID
    if hasGuild then
        members = jlib.ReadCompressedTable()
        guild, guildID = FalloutGuilds.GetGuild(LocalPlayer())
    end

    local frame = vgui.Create("UI_DFrame")
    frame:SetTitle("Guild" .. (guild and (" - " .. guild.name) or ""))
    frame:SetSize(800, 600)
    frame:Center()
    frame:MakePopup()
    jlib.AddBackgroundBlur(frame)

    local close = frame:Add("UI_DButton")
    close:SetText("Close")
    close:SetFont("GuildMenu")
    close:Dock(BOTTOM)
    close.DoClick = function(s)
        frame:Close()
    end

    if hasGuild then
        if FalloutGuilds.IsOfficer(guildID, LocalPlayer()) then
            local inviteButton = frame:Add("UI_DButton")
            inviteButton:SetText("Invite")
            inviteButton:SetFont("GuildMenu")
            inviteButton:Dock(BOTTOM)
            inviteButton.DoClick = function(s)
                local players = player.GetAll()

                local menu = vgui.Create("DMenu")
                menu:SetPos(input.GetCursorPos())
				menu:MakePopup()

                for _, ply in pairs(players) do
                    local char = ply:getChar()

                    if !char or FalloutGuilds.IsOwnerAny(ply) then
                        continue
                    end

                    menu:AddOption(ply:Nick(), function()
                        net.Start("GuildInvite")
                            net.WriteEntity(ply)
                        net.SendToServer()
                    end):SetIcon("icon16/user_add.png")
                end
            end
        end

        if FalloutGuilds.IsOwner(guildID, LocalPlayer()) then
            local disbandButton = frame:Add("UI_DButton")
            disbandButton:SetText("Disband")
            disbandButton:SetFont("GuildMenu")
            disbandButton:Dock(BOTTOM)
            disbandButton.DoClick = function(s)
                net.Start("GuildDisband")
                net.SendToServer()

                frame:Close()
            end
        else
            local leaveButton = frame:Add("UI_DButton")
            leaveButton:SetText("Leave")
            leaveButton:SetFont("GuildMenu")
            leaveButton:Dock(BOTTOM)
            leaveButton.DoClick = function(s)
                net.Start("GuildLeave")
                net.SendToServer()

                frame:Close()
            end
        end

        local memberList = frame:Add("DListView")
        memberList:SetTall(450)
        memberList:Dock(TOP)
        memberList:AddColumn("Name")
        memberList:AddColumn("Rank")
        memberList:AddColumn("Status")

        local ranks = {
            [0] = "Member",
            [1] = "Officer",
            [2] = "Owner"
        }

        for _, member in SortedPairsByMemberValue(members, "rank", true) do
            local name = member.name
            local rankName = ranks[member.rank]

            local ply = player.GetBySteamID64(member.steamID)
            local status = IsValid(ply) and ply:getChar():getID() == member.charID

            memberList:AddLine(name, rankName, status and "Online" or "Offline").member = member
        end

        if FalloutGuilds.IsOfficer(guildID, LocalPlayer()) then
            memberList.OnRowRightClick = function(s, lineID, line)
                local member = line.member

                if member.charID == LocalPlayer():getChar():getID() then
                    return
                end

                local menu = frame:Add("DMenu")
                menu:SetPos(frame:LocalCursorPos())

                menu:AddOption("Kick Member", function()
                    net.Start("GuildKick")
                        net.WriteInt(member.charID, 32)
                    net.SendToServer()

                    line:Remove()
                end):SetIcon("icon16/delete.png")

                if FalloutGuilds.IsOwner(guildID, LocalPlayer()) then
                    if member.rank == 0 then
                        menu:AddOption("Promote Member", function()
                            net.Start("GuildPromote")
                                net.WriteInt(member.charID, 32)
                            net.SendToServer()

                            line:SetColumnText(2, ranks[1])
                            member.rank = 1
                        end):SetIcon("icon16/award_star_gold_1.png")
                    elseif member.rank == 1 then
                        menu:AddOption("Demote Member", function()
                            net.Start("GuildDemote")
                                net.WriteInt(member.charID, 32)
                            net.SendToServer()

                            line:SetColumnText(2, ranks[0])
                            member.rank = 0
                        end):SetIcon("icon16/exclamation.png")
                    end

                    menu:AddOption("Transfer Ownership", function()
                        net.Start("GuildTransferOwner")
                            net.WriteInt(member.charID, 32)
                        net.SendToServer()

                        frame:Close()
                    end):SetIcon("icon16/rosette.png")
                end
            end
        end
    else
        local nameEntry = frame:Add("DTextEntry")
        nameEntry:SetPlaceholderText("Guild Name")
        nameEntry:SetWide(300)
        nameEntry:Center()

        local createButton = frame:Add("DButton")
        createButton:SetText("Create")
        createButton:SetWide(300)
        createButton:SetTall(20)
        createButton:SetTextColor(Color(255, 255, 255, 255))
        createButton:Center()
        createButton:MoveBelow(nameEntry)
        createButton.DoClick = function(s)
            local name = nameEntry:GetText()

            if #name < 4 then
                nut.util.notify("Name must be at least 4 characters.")
                return
            end

            net.Start("GuildCreate")
                net.WriteString(name)
            net.SendToServer()

            frame:Close()

			chat.AddText("Note: You will need at least " .. FalloutGuilds.Config.MinMembers .. " total guild members to create territories.\nOnce you meet that requirement you can hold " .. input.LookupBinding("+menu_context"):upper() .. " and right click the ground where you would like to place your territory.")
        end
    end
end
net.Receive("GuildOpenMenu", FalloutGuilds.Menu)

function FalloutGuilds.Invite()
    local guildID = net.ReadInt(32)

    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 100)
    frame:Center()
    frame:SetPos((ScrW()/2) - (frame:GetWide()/2), ScrH())
    frame:SetTitle("Invite to join guild: " .. FalloutGuilds.Guilds[guildID].name .. " - press F8 for cursor")

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
        net.Start("GuildInviteResponse")
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
net.Receive("GuildInvite", FalloutGuilds.Invite)

function FalloutGuilds.SpawnClasses()
	local frame = vgui.Create("DFrame")
	frame:SetSize(600, 600)
	frame:SetTitle("Guild Spawn Classes")
	frame:Center()
	frame:MakePopup()

	local lbl = frame:Add("DLabel")
	lbl:SetText("Double click an entry to move it to the other side.")
	lbl:SizeToContents()
	lbl:SetWide(frame:GetWide())
	lbl:SetContentAlignment(5)
	lbl:SetPos(0, 30)

	local notSpawnLbl = frame:Add("DLabel")
	notSpawnLbl:SetText("Classes that spawn on their default faction's spawns.")
	notSpawnLbl:SizeToContents()
	notSpawnLbl:SetPos(((6 + 290) / 2) - notSpawnLbl:GetWide() / 2, 60)

	local spawnLbl = frame:Add("DLabel")
	spawnLbl:SetText("Classes that spawn on their guild's spawns.")
	spawnLbl:SizeToContents()
	spawnLbl:SetPos(((6 + (290 * 3) + 12) / 2) - spawnLbl:GetWide() / 2, 60)

	local spawn
	local notSpawn
	local spawnClasses = {}

	local confirmBtn = frame:Add("DButton")
	confirmBtn:Dock(BOTTOM)
	confirmBtn:SetText("Confirm")
	confirmBtn.DoClick = function(s)
		frame:Close()

		net.Start("GuildSpawnClasses")
			jlib.WriteCompressedTable(spawnClasses)
		net.SendToServer()
	end

	spawn = frame:Add("DListView")
	spawn:AddColumn("Faction")
	spawn:AddColumn("Class")
	spawn:SetWide(290)
	spawn:Dock(RIGHT)
	spawn:DockMargin(6, 45, 6, 6)
	spawn.DoDoubleClick = function(s, lineID, line)
		notSpawn:AddLine(line:GetColumnText(1), line:GetColumnText(2))
		s:RemoveLine(lineID)

		spawnClasses[line.uniqueID] = nil
	end

	notSpawn = frame:Add("DListView")
	notSpawn:AddColumn("Faction")
	notSpawn:AddColumn("Class")
	notSpawn:SetWide(290)
	notSpawn:Dock(LEFT)
	notSpawn:DockMargin(6, 45, 6, 6)
	notSpawn.DoDoubleClick = function(s, lineID, line)
		spawn:AddLine(line:GetColumnText(1), line:GetColumnText(2))
		s:RemoveLine(lineID)

		spawnClasses[line.uniqueID] = true
	end

	for k, v in pairs(nut.class.list) do
		if FalloutGuilds.Config.SpawnClasses[v.uniqueID] then
			spawn:AddLine(nut.faction.indices[v.faction].name, v.name).uniqueID = v.uniqueID
			spawnClasses[v.uniqueID] = true
		else
			notSpawn:AddLine(nut.faction.indices[v.faction].name, v.name).uniqueID = v.uniqueID
		end
	end

	spawn:SortByColumn(1)
	notSpawn:SortByColumn(1)
end
net.Receive("GuildSpawnClasses", FalloutGuilds.SpawnClasses)

net.Receive("GuildUpdateSpawnClass", function()
	FalloutGuilds.Config.SpawnClasses = jlib.ReadCompressedTable()
	PrintTable(FalloutGuilds.Config.SpawnClasses)
end)
