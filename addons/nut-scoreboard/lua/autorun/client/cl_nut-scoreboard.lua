FalloutScoreboard = FalloutScoreboard or {}

local anonymousWhitelist = { -- Added by Keith to apply anonminity to A-Team
	["STEAM_0:0:68317481"] = true, -- Keith
	["STEAM_0:1:54271280"] = true, -- Elliot
	["STEAM_0:0:12225865"] = true, -- Daniel Stevens
}

FalloutScoreboard.Print = jlib.GetPrintFunction("[Scoreboard]")

FalloutScoreboard.PaintFunctions = {
	[0] = function(this, w, h)
		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawRect(0, 0, w, h)
	end,
	[1] = function(this, w, h) end
}

FalloutScoreboard.StaffID = FACTION_STAFF or false

FalloutScoreboard.HeaderHeight = 28

FalloutScoreboard.FactionMaterials = FalloutScoreboard.FactionMaterials or {}
FalloutScoreboard.DefaultMaterials = FalloutScoreboard.FactionMaterials or {}
FalloutScoreboard.MaterialsPath = "factionicons"

function FalloutScoreboard.SetupFactionMaterials()
	FalloutScoreboard.Print("Setting up scoreboard materials")

	for _, fileName in ipairs(file.Find("materials/" .. FalloutScoreboard.MaterialsPath .. "/*.png", "GAME")) do
		local mat = Material(FalloutScoreboard.MaterialsPath .. "/" .. fileName)

		if fileName:StartWith("default") then
			table.insert(FalloutScoreboard.DefaultMaterials, mat)
		else
			local uniqueID = fileName:StripExtension()
			FalloutScoreboard.Print("Setting " .. uniqueID .. " material to " .. tostring(mat))
			FalloutScoreboard.FactionMaterials[uniqueID] = mat
		end
	end
end

function FalloutScoreboard.GetFactionMaterial(id)
	return FalloutScoreboard.FactionMaterials[id] or FalloutScoreboard.DefaultMaterials[math.random(#FalloutScoreboard.DefaultMaterials)]
end

hook.Add("WorkshopDLPostInit", "ScoreboardIcons", FalloutScoreboard.SetupFactionMaterials)

function FalloutScoreboard.GetName(ply)
	return (LocalPlayer():Team() != FalloutScoreboard.StaffID and hook.Run("ShouldAllowScoreboardOverride", ply, "name")) and hook.Run("GetDisplayedName", ply) or ply:Nick()
end

function FalloutScoreboard.GetDesc(ply)
	return (LocalPlayer():Team() != FalloutScoreboard.StaffID and hook.Run("ShouldAllowScoreboardOverride", ply, "desc")) and hook.Run("GetDisplayedDescription", ply) or (ply:getChar() and ply:getChar():getDesc()) or ""
end

local PANEL = {}

function PANEL:Init()
	nut.gui.scoreboard = self

	self:SetSize(ScrW() * nut.config.get("sbWidth"), ScrH() * nut.config.get("sbHeight"))
	self:Center()

	self.Header = self:Add("DLabel")
	self.Header:SetText(GetHostName())
	self.Header:SetFont("nutBigFont")
	self.Header:SetContentAlignment(5)
	self.Header:SetTextColor(color_white)
	self.Header:SetExpensiveShadow(1, color_black)
	self.Header:Dock(TOP)
	self.Header:SizeToContentsY()
	self.Header:SetTall(self.Header:GetTall() + 16)

	self.Header.Paint = function(this, w, h)
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, w, h)
	end

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:Dock(FILL)
	self.Scroll:DockMargin(1, 0, 1, 0)
	self.Scroll.VBar:SetWide(0)

	self.List = self.Scroll:Add("DListLayout")
	self.List:Dock(TOP)

	self.FactionSlots = {}

	self.LocalChar = LocalPlayer():getChar()
	self.LocalFaction = LocalPlayer():Team()

	-- Set up our own faction
	if self.LocalFaction != 0 then
		self:GetFactionPanel(self.LocalFaction)
	end

	-- Set up all other factions
	for i, facTbl in ipairs(nut.faction.indices) do
		if i == self.LocalFaction then
			continue
		end

		if team.NumPlayers(i) > 0 then
			self:GetFactionPanel(i)
		end
	end

	self:SetUpPaints()
end

function PANEL:AddPlayer(ply, parent)
	if !ply:getChar() or anonymousWhitelist[ply:SteamID()] then return end -- Added by Keith to apply anonminity to A-Team
	local nick = FalloutScoreboard.GetName(ply)

	local plyPnl = parent:Add("DPanel")
	plyPnl.IsPlySlot = true
	plyPnl:Dock(TOP)
	plyPnl:SetTall(64)
	plyPnl:DockMargin(0, 0, 0, 1)
	plyPnl.Think = function(s)
		if !IsValid(ply) or !ply:getChar() then
			plyPnl:Remove()
			if IsValid(parent) then
				parent:InvalidateLayout(true)
				parent:SizeToChildren(false, true)
				self:SetUpPaints()
			end
		end
	end

	local mdl = plyPnl:Add("nutSpawnIcon")
	mdl:SetModel(ply:GetModel(), ply:GetSkin())
	mdl:SetSize(64, 64)
	mdl.DoClick = function()
		local menu = DermaMenu()
		local options = {}

		hook.Run("ShowPlayerOptions", ply, options)

		for k, v in SortedPairs(options) do
			menu:AddOption(L(k), v[2]):SetImage(v[1])
		end
		menu:Open()

		RegisterDermaMenuForClose(menu)
	end
	mdl:SetTooltip(L("sbOptions", ply:steamName()))
	mdl.Think = function(s)
		local ent = s.Entity

		if !IsValid(ply) or !IsValid(ent) then return end

		if ply:GetModel() != mdl:GetModel() or ply:GetSkin() != ent:GetSkin() then
			mdl:SetModel(ply:GetModel(), ply:GetSkin())
		end

		if IsValid(ent) then
			if IsValid(ply.Head) and !IsValid(ent.Head) then
				ent.Head = ClientsideModel(ply.Head:GetModel(), RENDERGROUP_OPAQUE)
				ent.Head:SetParent(ent)
				ent.Head:AddEffects(EF_BONEMERGE)
			elseif IsValid(ent.Head) and !IsValid(ply.Head) then
				ent.Head:Remove()
				ent.Head = nil
			end

			if IsValid(ent.Head) and IsValid(ply.Head) then
				ent.Head:SetColor(ply.Head:GetColor())
				ent.Head:SetSkin(ply.Head:GetSkin() or 0)

				for i = 0, table.Count(ply.Head:GetBodyGroups()) - 1 do
					ent.Head:SetBodygroup(i, ply.Head:GetBodygroup(i))
				end
			end
		end
	end
	mdl.PostDrawModel = function(s, ent)
		if IsValid(ent) and IsValid(ent.Head) then
			local col = ent.Head:GetColor()
			render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
			ent.Head:DrawModel()
		end
	end
	mdl:setHidden(nick != ply:Nick())
	plyPnl.Model = mdl

	local name = plyPnl:Add("DLabel")
	name:SetText(nick)
	name:Dock(TOP)
	name:DockMargin(65, 0, 48, 0)
	name:SetTall(18)
	name:SetFont("nutGenericFont")
	name:SetTextColor(color_white)
	name:SetExpensiveShadow(1, color_black)
	name.Think = function(s)
		if IsValid(ply) then
			s:SetText(FalloutScoreboard.GetName(ply))
		end
	end
	plyPnl.Name = name

	local ping = plyPnl:Add("DLabel")
	ping:SetPos(self:GetWide() - 48, 0)
	ping:SetSize(48, 64)
	ping:SetText("0")
	ping.Think = function(s)
		if IsValid(ply) then
			s:SetText(ply:Ping())
		end
	end
	ping:SetFont("nutGenericFont")
	ping:SetContentAlignment(6)
	ping:SetTextColor(color_white)
	ping:SetTextInset(16, 0)
	ping:SetExpensiveShadow(1, color_black)
	plyPnl.Ping = ping

	local desc = plyPnl:Add("DLabel")
	desc:Dock(FILL)
	desc:DockMargin(65, 0, 48, 0)
	desc:SetWrap(true)
	desc:SetContentAlignment(7)
	desc:SetText(FalloutScoreboard.GetDesc(ply))
	desc:SetTextColor(color_white)
	desc:SetExpensiveShadow(1, Color(0, 0, 0, 100))
	desc:SetFont("nutSmallFont")
	desc.Think = function(s)
		s:SetText(FalloutScoreboard.GetDesc(ply))
	end
	plyPnl.Desc = desc

	parent:SizeToChildren(false, true)

	return plyPnl
end

function PANEL:AddHeader(pnl, title, color, factionID)
	local header = pnl:Add("DButton")
	header:Dock(TOP)
	header:SetText(title)
	header:SetTextInset(3, 0)
	header:SetFont("nutMediumFont")
	header:SetTextColor(color_white)
	header:SetExpensiveShadow(1, color_black)
	header:SetTall(FalloutScoreboard.HeaderHeight)
	header.Paint = function(s, w, h)
		surface.SetDrawColor(ColorAlpha(color, 20))
		surface.DrawRect(0, 0, w, h)
	end

	header:Toggle()

	if factionID then
		local karmaTitle, karmaColor = nut.plugin.list["karma"]:getKarmaFancyFaction(factionID)
		local karmaIcon = header:Add("DButton")--vgui.Create("DPanel", header)
		karmaIcon:SetZPos(100000) --i do not know why this must be done
		karmaIcon:SetSize(48, 48)
		karmaIcon:SetText("")
		--karmaIcon:SetPos(0, -8)
		karmaIcon:Dock(RIGHT)
		karmaIcon:DockMargin(0,-8,-4,0)
		--karmaIcon:SetToolTip(karmaTitle)
		karmaIcon.Paint = function(panel, w,h)
			surface.SetMaterial(karmaTitle.icon)
			surface.SetDrawColor(karmaColor)
			surface.DrawTexturedRect(0, 0, 48, 48)
		end
		karmaIcon.OnCursorEntered = function()
			if IsValid(karmaIcon.tip) then return end

			local mousePosX, mousePosY = input.GetCursorPos()

			local boxColor = Color(math.max(karmaColor.r - 80, 0), math.max(karmaColor.g - 80, 0), math.max(karmaColor.b - 80, 0))
			local innerColor = Color(math.min(karmaColor.r + 30, 255), math.min(karmaColor.g + 30, 255), math.min(karmaColor.b + 30, 255))

			local tip = vgui.Create("UI_DPanel_Bordered")
			tip:SetSize(250, 100)
			tip:SetPos(mousePosX + 40, mousePosY)
			tip:DockPadding(6, 6, 6, 6)
			tip.Think = function() if (!IsValid(karmaIcon)) then tip:Remove() end end
			tip.Paint = function(p, w, h)
				surface.SetDrawColor(ColorAlpha(innerColor, 255))
				surface.DrawRect(0, 0, w, h)

				DisableClipping(true)
				surface.SetDrawColor(Color(0, 0, 0))
				surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

				surface.SetDrawColor(boxColor)
				surface.DrawOutlinedRect(0, 0, w, h)
				surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
				DisableClipping(false)
			end
			tip.text = tip:Add("UI_DLabel")
				tip.text:Dock(FILL)
				tip.text:SetContentAlignment(8)
				tip.text:SetWrap(true)
				tip.text:SetTextColor(boxColor)
				tip.text:SetText("           " ..karmaTitle.desc)

			karmaIcon.tip = tip
		end
		karmaIcon.OnCursorExited = function()
			if IsValid(karmaIcon.tip) then
				karmaIcon.tip:Remove()
			end
		end
	end
end

function PANEL:GetFactionPanel(factionID)
	if self.FactionSlots[factionID] then
		return self.FactionSlots[factionID]
	else
		local factionPnl
		local isStaff = self.LocalFaction == FalloutScoreboard.StaffID

		if factionID == self.LocalFaction or isStaff then
			factionPnl = self.List:Add("DListLayout")

			factionPnl.IsList = true

			self:AddHeader(factionPnl, team.GetName(factionID), team.GetColor(factionID), factionID)

			-- Do local player first so we're always at the top
			if factionID == self.LocalFaction then
				self:AddPlayer(LocalPlayer(), factionPnl)
			end

			for i, ply in ipairs(team.GetPlayers(factionID)) do
				if ply != LocalPlayer() then
					self:AddPlayer(ply, factionPnl)
				end
			end
		else
			factionPnl = self.List:Add("DPanel")
			factionPnl.IsSingle = true
			factionPnl:SetTall(FalloutScoreboard.HeaderHeight + 64)
			self:AddHeader(factionPnl, team.GetName(factionID), team.GetColor(factionID))


			local karmaTitle, karmaColor = nut.plugin.list["karma"]:getKarmaFancyFaction(factionID)
			local karmaIcon = factionPnl:Add("DButton")--vgui.Create("DPanel", header)
			karmaIcon:SetZPos(32766) --i do not know why this must be done
			karmaIcon:SetSize(48, 48)
			karmaIcon:SetText("")
			karmaIcon:SetPos(ScrW() * 0.3, 36)
			--karmaIcon:Dock(TOP)
			karmaIcon:SetMouseInputEnabled(true)
			--karmaIcon:SetToolTip(karmaTitle)
			karmaIcon.Paint = function(panel, w,h)
				surface.SetMaterial(karmaTitle.icon)
				surface.SetDrawColor(karmaColor)
				surface.DrawTexturedRect(0, 0, 48, 48)
			end
			karmaIcon.OnCursorEntered = function()
				if IsValid(karmaIcon.tip) then return end

				local mousePosX, mousePosY = input.GetCursorPos()

				local boxColor = Color(math.max(karmaColor.r - 80, 0), math.max(karmaColor.g - 80, 0), math.max(karmaColor.b - 80, 0))
				local innerColor = Color(math.min(karmaColor.r + 30, 255), math.min(karmaColor.g + 30, 255), math.min(karmaColor.b + 30, 255))

				local tip = vgui.Create("UI_DPanel_Bordered")
				tip:SetSize(250, 100)
				tip:SetPos(mousePosX + 40, mousePosY)
				tip:DockPadding(6, 6, 6, 6)
				tip.Think = function() if (!IsValid(karmaIcon)) then tip:Remove() end end
				tip.Paint = function(p, w, h)
					surface.SetDrawColor(ColorAlpha(innerColor, 255))
					surface.DrawRect(0, 0, w, h)

					DisableClipping(true)
					surface.SetDrawColor(Color(0, 0, 0))
					surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

					surface.SetDrawColor(boxColor)
					surface.DrawOutlinedRect(0, 0, w, h)
					surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
					DisableClipping(false)
				end
				tip.text = tip:Add("UI_DLabel")
					tip.text:Dock(FILL)
					tip.text:SetContentAlignment(8)
					tip.text:SetWrap(true)
					tip.text:SetTextColor(boxColor)
					tip.text:SetText("           " ..karmaTitle.desc)

				karmaIcon.tip = tip
			end
			karmaIcon.OnCursorExited = function()
				if IsValid(karmaIcon.tip)  then
					karmaIcon.tip:Remove()
				end
			end

			local txt = ""// .. team.NumPlayers(factionID)
			surface.SetFont("nutGenericFont")
			local _, h = surface.GetTextSize(txt)
			local name = factionPnl:Add("DLabel")
			name:SetText(txt)
			name:Dock(RIGHT)
			name:DockMargin(65, 32 - (h / 2), 48, 0)
			name:SetTall(18)
			name:SetFont("nutGenericFont")
			name:SetTextColor(color_red)
			name:SetText("  [☢]")
			name:SetExpensiveShadow(1, color_black)
			name.Think = function(s)
				local facPop = team.NumPlayers(factionID)

				if facPop >= (nut.config.get("warPopulation") or 8) then
					name:SetTextColor(color_green)
					return
				elseif facPop >= (nut.config.get("attackOffensivePop") or 6) then
					name:SetTextColor(color_yellow)
					return
				else
					name:SetTextColor(color_red)
				end
			end

			local factionUID = nut.faction.indices[factionID].uniqueID
			local mat = FalloutScoreboard.GetFactionMaterial(factionUID)
			local img = factionPnl:Add("DImage")
			img:SetPos(0, FalloutScoreboard.HeaderHeight)
			img:SetSize(64, 64)
			img:SetMaterial(mat)

			if LocalPlayer():CanCallAttack() then
				local declarationbutton = factionPnl:Add("DButton")
				declarationbutton:SetPos(0, FalloutScoreboard.HeaderHeight)
				declarationbutton:SetSize(64, 64)
				declarationbutton:SetZPos(32767) // Setting it to be on the absolute top.
				declarationbutton:SetText("")
				declarationbutton.Paint = function() end
				declarationbutton.DoClick = function()
					if IsValid(declarationPanel) then
						declarationPanel:Remove()
						return
					end
					if not LocalPlayer():CanCallAttack() then return end
					local mousePosX, mousePosY = input.GetCursorPos()
					declarationPanel = vgui.Create("UI_DFrame")
					declarationPanel:SetSize(150, 40)
					declarationPanel:SetTitle("Options")
					declarationPanel:SetPos(self:GetWide() - 140, mousePosY * .9 )
					declarationPanel:MakePopup() -- For whatever reason, changing this to DFrame and making it popup allows for interaction.
					declarationPanel.Think = function()
						// Sometimes might leave the little prompt open forcing you to click it.
						if not IsValid(nut.gui.scoreboard) then
							declarationPanel:Remove()
						end
					end

					//if !table.IsEmpty(WARDECLARATION.Attacks) and !WARDECLARATION.Types[WARDECLARATION.Attacks.type].canAssist then
					//	declarationPanel:Remove()
					//	return
					//end

					if not WARDECLARATION.IsInAttack(LocalPlayer():Team()) and WARDECLARATION.IsInAttack(factionID) and not WARDECLARATION.IsAssisting(LocalPlayer():Team()) then
						
						if table.Count(WARDECLARATION.Attacks.participants) < 3 then
							declarationPanel:SetTall( declarationPanel:GetTall( ) + 45 )
							local assistB = vgui.Create( "UI_DButton", declarationPanel )
							assistB:Dock( TOP )
							assistB:DockMargin( 5, 5, 5, 5 )
							assistB:SetContentAlignment( 5 )
							assistB:SetText("Skirmish")
							assistB.DoClick = function( )
								net.Start( "WARDECLARATION_SCOREBOARDTHREEWAY" )
								net.SendToServer( )
								declarationPanel:Remove( )
							end
						end
						
						
						declarationPanel:SetTall( declarationPanel:GetTall( ) + 45 )
						local assistB = vgui.Create( "UI_DButton", declarationPanel )
						assistB:Dock( TOP )
						assistB:DockMargin( 5, 5, 5, 5 )
						assistB:SetContentAlignment( 5 )
						assistB:SetText("Assist")
						assistB.DoClick = function( )
							net.Start( "WARDECLARATION_SCOREBOARDASSIST" )
							net.WriteInt( factionID, 8 )
							net.SendToServer( )
							declarationPanel:Remove( )
						end
						return
					end

					if WARDECLARATION.Attacks.enemy == LocalPlayer():Team() then declarationPanel:Remove() return end

					if WARDECLARATION.IsInAttack(factionID) and WARDECLARATION.IsAssisting(LocalPlayer():Team()) then
						declarationPanel:SetTall( declarationPanel:GetTall( ) + 45 )
						declarationPanel:SetWide( declarationPanel:GetWide( ) + 45 )
						declarationPanel:SetX( declarationPanel:GetX() - 45 )
						local assistB = vgui.Create( "UI_DButton", declarationPanel )
						assistB:Dock( TOP )
						assistB:DockMargin( 5, 5, 5, 5 )
						assistB:SetContentAlignment( 5 )
						assistB:SetText("Stop Assisting")
						assistB.DoClick = function( )
							net.Start( "WARDECLARATION_SCOREBOARDSTOPASSIST" )
								net.WriteInt( factionID, 8 )
							net.SendToServer( )
							declarationPanel:Remove( )
						end
						return
					end

					if WARDECLARATION.Attacks.calling == LocalPlayer():Team() then
						declarationPanel:SetTall( declarationPanel:GetTall( ) + 45 )
						local b = vgui.Create( "UI_DButton", declarationPanel )
						b:Dock( TOP )
						b:DockMargin( 5, 5, 5, 5 )
						b:SetContentAlignment( 5 )
						b:SetText( "Stop Attack" )
						b.DoClick = function( )
							net.Start( "WARDECLARATION_SCOREBOARDCANCEL" )
							net.SendToServer( )
							declarationPanel:Remove( )
						end
						return
					end

					if WARDECLARATION.Attacks.participants != nil and istable(WARDECLARATION.Attacks.participants[LocalPlayer():Team()]) then
						declarationPanel:SetTall( declarationPanel:GetTall( ) + 45 )
						declarationPanel:SetWide( declarationPanel:GetWide( ) + 45 )
						declarationPanel:SetX( declarationPanel:GetX() - 45 )

						local b = vgui.Create( "UI_DButton", declarationPanel )
						b:Dock( TOP )
						b:DockMargin( 5, 5, 5, 5 )
						b:SetContentAlignment( 5 )
						b:SetText( "Leave Skirmish" )
						b.DoClick = function( )
							net.Start( "WARDECLARATION_LEAVESKIRMISH" )
							net.SendToServer( )
							declarationPanel:Remove( )
						end
						return
					end

					for k, v in pairs( WARDECLARATION.Types ) do
						if v.adminOnly then continue end
						declarationPanel:SetTall( declarationPanel:GetTall( ) + 45 )
						local b = vgui.Create( "UI_DButton", declarationPanel )
						b:Dock( TOP )
						b:DockMargin( 5, 5, 5, 5 )
						b:SetContentAlignment( 5 )
						b:SetText( k )

						b.DoClick = function( )
							net.Start( "WARDECLARATION_SCOREBOARDCLICK" )
							net.WriteString( k )
							net.WriteInt( factionID, 8 )
							net.SendToServer( )
							declarationPanel:Remove( )
						end
					end

					declarationPanel.Think = function()
						if !IsValid(nut.gui.scoreboard) then
							declarationPanel:Remove()
						end
					end
				end
			end

			//img:SetImageColor(team.GetColor(factionID))
		end

		factionPnl.ID = table.insert(self.FactionSlots, factionPnl)

		factionPnl.Think = function(s)
			if team.NumPlayers(factionID) <= 0 then
				table.remove(self.FactionSlots, s.ID)
				s:Remove()

				if IsValid(self.List) then
					self.List:InvalidateLayout(true)
					self.List:SizeToChildren(false, true)
					self:SetUpPaints()
				end
			end
		end

		return factionPnl
	end
end

function PANEL:OnRemove()
	CloseDermaMenus()
end

function PANEL:SetUpPaints()
	local i = 0
	for _, slot in ipairs(self.FactionSlots) do
		if slot.IsList then
			for _, pnl in ipairs(slot:GetChildren()) do
				if pnl.IsPlySlot then
					pnl.Paint = FalloutScoreboard.PaintFunctions[i % 2]
					i = i + 1
				end
			end
		elseif slot.IsSingle then
			slot.Paint = FalloutScoreboard.PaintFunctions[i % 2]
			i = i + 1
		end
	end
end

function PANEL:Paint(w, h)
	nut.util.drawBlur(self, 10)
	surface.SetDrawColor(30, 30, 30, 100)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("nutScoreboardUpdated", PANEL, "EditablePanel")

hook.Add("ScoreboardShow", "NutScoreboardUpdate", function()
	GAMEMODE.ScoreboardHide = nil
	GAMEMODE.ScoreboardShow = nil

	if !IsValid(nut.gui.scoreboard) then
		vgui.Create("nutScoreboardUpdated")
	end

	if IsValid(nut.gui.score) then
		nut.gui.score:Remove()
	end

	if IsValid(nut.gui.scoreboard) then
		nut.gui.scoreboard:SetVisible(true)
		nut.gui.scoreboard:MakePopup()
		nut.gui.scoreboard:SetKeyboardInputEnabled(false)
	end
end)

hook.Add("ScoreboardHide", "NutScoreboardUpdate", function()
	if IsValid(nut.gui.scoreboard) then
		nut.gui.scoreboard:Remove()
	end
end)

hook.Add("CharacterLoaded", "ReloadScoreboard", function(char)
	if IsValid(nut.gui.scoreboard) then
		nut.gui.scoreboard:Remove()
	end
end)
