local COLOR = FindMetaTable("Color")

--[[
	Dark skin
]]
SKIN = {}

surface.CreateFont("DarkSkinSmall", {font = "Roboto", size = 14, weight = 400})
surface.CreateFont("DarkSkinRegular", {font = "Roboto", size = 18, weight = 400})
surface.CreateFont("DarkSkinMedium", {font = "Roboto", size = 24, weight = 400})
surface.CreateFont("DarkSkinLarge", {font = "Roboto", size = 32, weight = 400})
surface.CreateFont("DarkSkinHuge", {font = "Roboto", size = 56, weight = 400})

SKIN.PrintName    = "Dark Derma Skin"
SKIN.Author       = "jonjo"
SKIN.DermaVersion = 1
SKIN.GwenTexture  = Material("gwenskin/GModDefault.png")

SKIN.Font = "DarkSkinRegular"

SKIN.TextColor = Color(209, 209, 209, 255)
SKIN.HighlightColor = Color(3, 127, 252, 255)
SKIN.CursorColor = Color(255, 255, 255, 255)
SKIN.AccentColor = Color(255, 191, 0, 255)
SKIN.BackgroundColor = Color(33, 33, 33, 255)

local DownArrowNormal = GWEN.CreateTextureNormal(496, 272 + 32, 15, 15)
local DownArrowHover = GWEN.CreateTextureNormal(496, 272 + 16, 15, 15)
local DownArrowDisabled = GWEN.CreateTextureNormal(496, 272 + 48, 15, 15)
local DownArrowDown = GWEN.CreateTextureNormal(496, 272, 15, 15)
local MenuBGHover = GWEN.CreateTextureBorder(128, 256, 127, 31, 8, 8, 8, 8)

function SKIN:PaintFrame(pnl, w, h)
	if !pnl.IsDarkReady then
		pnl.lblTitle:SetFont(self.Font)

		pnl.IsDarkReady = true
	end

	surface.SetDrawColor(Color(33, 33, 33, 255))
	surface.DrawRect(1, 1, w - 2, h - 2)
	surface.SetDrawColor(pnl.AccentColor or self.AccentColor)
	surface.DrawOutlinedRect(0, 0, w, h)
	surface.DrawRect(0, 0, w, 25)
end

function SKIN:PaintWindowMaximizeButton() end
function SKIN:PaintWindowMinimizeButton() end

function SKIN:PaintTextEntry(pnl, w, h)
	if !pnl.IsDarkReady then
		pnl:SetTextColor(self.TextColor)
		pnl:SetHighlightColor(self.HighlightColor)
		pnl:SetCursorColor(self.CursorColor)
		pnl:SetFont(self.Font)
		pnl:ApplySchemeSettings()

		pnl.IsDarkReady = true
	end

	surface.SetDrawColor(Color(45, 45, 45, 240))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(Color(100, 100, 100, 25))
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

	surface.SetDrawColor(pnl.AccentColor or Color(35, 35, 35, 200))
	surface.DrawOutlinedRect(0, 0, w, h)

	--PlaceholderText support - credits: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/skins/default.lua
	if (pnl.GetPlaceholderText and pnl.GetPlaceholderColor and pnl:GetPlaceholderText() and pnl:GetPlaceholderText():Trim() != "" and pnl:GetPlaceholderColor() and (!pnl:GetText() or pnl:GetText() == "")) then
		local oldText = pnl:GetText()

		local str = pnl:GetPlaceholderText()
		if (str:StartWith("#")) then str = str:sub(2) end
		str = language.GetPhrase(str)

		pnl:SetText(str)
		pnl:DrawTextEntryText(pnl:GetPlaceholderColor(), pnl:GetHighlightColor(), pnl:GetCursorColor())
		pnl:SetText(oldText)

		return
	end

	pnl:DrawTextEntryText(pnl:GetTextColor(), pnl:GetHighlightColor(), pnl:GetCursorColor())
end

function SKIN:PaintMenuOption(pnl, w, h)
	if !pnl.IsDarkReady then
		pnl:SetTextColor(self.TextColor)
		pnl:SetFont(self.Font)

		pnl.IsDarkReady = true
	end

	surface.SetDrawColor(Color(35, 35, 35, 255))
	surface.DrawRect(0, 0, w, h)

	if pnl:IsHovered() then
		MenuBGHover(0, 0, w, h)
	end
end

function SKIN:PaintComboDownArrow(pnl, w, h)
	if pnl.ComboBox:GetDisabled() then
		return DownArrowDisabled(0, 0, w, h)
	end

	if pnl.ComboBox.Depressed or pnl.ComboBox:IsMenuOpen() then
		return DownArrowDown(0, 0, w, h)
	end

	if pnl.ComboBox:IsHovered() then
		return DownArrowHover(0, 0, w, h)
	end

	DownArrowNormal(0, 0, w, h)
end

function SKIN:PaintComboBox(pnl, w, h)
	if !pnl.IsDarkReady then
		pnl:SetFont(self.Font)
		pnl:SetTextColor(self.TextColor)

		pnl.IsDarkReady = true
	end

	surface.SetDrawColor(Color(45, 45, 45, 240))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(Color(100, 100, 100, 25))
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

	surface.SetDrawColor(Color(35, 35, 35, 200))
	surface.DrawOutlinedRect(0, 0, w, h)
end

function SKIN:PaintButton(pnl, w, h)
	if !pnl.IsDarkReady then
		pnl:SetFont(self.Font)

		pnl.IsDarkReady = true
	end

	surface.SetDrawColor(Color(45, 45, 45, 240))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(Color(100, 100, 100, 25))
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

	surface.SetDrawColor(Color(35, 35, 35, 200))
	surface.DrawOutlinedRect(0, 0, w, h)

	if pnl:GetDisabled() or pnl.Depressed then
		return pnl:SetTextColor(Color(60, 60, 60, 255))
	end

	if pnl:IsHovered() then
		return pnl:SetTextColor(Color(255, 255, 255, 255))
	end

	pnl:SetTextColor(self.TextColor)
end

derma.DefineSkin("Dark", "Dark mode", SKIN)
DarkSkin = SKIN

--[[
	jAnimatedPanel
]]
PANEL = {}

function PANEL:Init()
	self:SetFramerate(30)
end

function PANEL:Paint(w, h)
	if !self.NextFrame or self.NextFrame <= CurTime() then
		self.NextFrame = CurTime() + self.Frametime
		self.CurFrame = (self.CurFrame or 1) + 1

		if self.CurFrame > #self:GetFrames() then
			self.CurFrame = 1
		end
	end

	local curFrame = self.CurFrame or 1

	local mat = self:GetFrames()[curFrame]

	if !mat then return end

	local imgW, imgH = mat:Width() * (self.Scale or 1), mat:Height() * (self.Scale or 1)

	surface.SetDrawColor(self:GetColor())
	surface.SetMaterial(mat)

	if self:GetKeepCentered() then
		surface.DrawTexturedRect((w / 2) - (imgW / 2), (h / 2) - (imgH / 2), imgW, imgH)
	else
		surface.DrawTexturedRect(0, 0, imgW, imgH)
	end
end

function PANEL:SetFramerate(framerate)
	self.Framerate = framerate
	self.Frametime = 1 / framerate
end

function PANEL:GetFramerate()
	return self.Framerate or 30
end

function PANEL:SetFrames(tbl)
	self.CurFrame = 1
	self.NextFrame = nil
	self.Frames = tbl
end

function PANEL:GetFrames()
	return self.Frames or {}
end

function PANEL:SetColor(col)
	self.Color = col
end

function PANEL:GetColor()
	return self.Color or Color(255, 255, 255, 255)
end

function PANEL:SizeToContents()
	local w, h = 0, 0

	for k, v in pairs(self:GetFrames()) do
		if v:Width() > w then w = v:Width() end
		if v:Height() > h then h = v:Height() end
	end

	self:SetSize(w, h)
end

function PANEL:SetScale(scale)
	self.Scale = scale
end

function PANEL:GetScale()
	return self.Scale
end

function PANEL:SetKeepCentered(bool)
	self.KeepCentered = bool
end

function PANEL:GetKeepCentered()
	return self.KeepCentered
end

vgui.Register("jAnimatedPanel", PANEL, "DPanel")

--[[
	jRemoteImage
	Purpose: Automatically download and display an image
]]
jlib.RemoteImageCache = {}

PANEL = {}

PANEL.Expiry = 604800

function PANEL:Init()
	if !file.IsDir("remoteimages", "DATA") then
		file.CreateDir("remoteimages")
	end
end

function PANEL:Paint(w, h)
	if self.Material then
		surface.SetDrawColor(self:GetColor():Unpack())
		surface.SetMaterial(self.Material)
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

function PANEL:SetURL(imgURL, callback)
	jlib.Print("Fetching image " .. imgURL)

	local split = imgURL:Split("/")
	local location = "remoteimages/" .. split[#split]

	-- Check memory/disk cache before downloading the image
	if IsValid(jlib.RemoteImageCache[url]) then
		jlib.Print("Cached image found in memory")
		self.Material = jlib.RemoteImageCache[url]

		if isfunction(callback) then
			callback(true, self.Material)
		end
	elseif !file.Exists(location, "DATA") or os.time() - file.Time(location, "DATA") > self.Expiry then
		http.Fetch(imgURL, function(img, size, headers, code)
			jlib.Print("Caching image to " .. location)
			file.Write(location, img)
			self.Material = Material("data/" .. location)

			if isfunction(callback) then
				callback(true, self.Material)
			end
		end, function(err)
			if isfunction(callback) then
				callback(false, err)
			end
		end)
	else
		jlib.Print("Cached image found on disk")
		self.Material = Material("data/" .. location)

		if isfunction(callback) then
			callback(true, self.Material)
		end
	end

	jlib.RemoteImageCache[imgURL] = self.Material
end

function PANEL:GetURL()
	return self.URL
end

function PANEL:SetColor(col)
	self.Color = col
end

function PANEL:GetColor()
	return self.Color or Color(255, 255, 255, 255)
end

vgui.Register("jRemoteImage", PANEL, "DPanel")

--[[
	FactionSelect
	Get a list of factions/classes from the user
]]
PANEL = {}

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:Dock(FILL)

	self.Factions = {}
	self.Classes = {}

	self.FactionCheckBoxes = {}
	self.ClassCheckBoxes = {}

	-- Select all button
	local selectAll = self:Add("DButton")
	selectAll:Dock(TOP)
	selectAll:SetText("Select All")
	selectAll.DoClick = function()
		if selectAll.Selected then
			for i, faction in ipairs(nut.faction.indices) do
				self:RemoveFaction(faction.uniqueID)
			end
			selectAll:SetText("Select All")
		else
			for i, faction in ipairs(nut.faction.indices) do
				self:AddFaction(faction.uniqueID)
			end
			selectAll:SetText("Deselect All")
		end


		selectAll.Selected = !selectAll.Selected
	end

	-- Create checkboxes for each faction/class
	for i, faction in ipairs(nut.faction.indices) do
		local panel = self.Scroll:Add("DPanel")
		panel:Dock(TOP)
		panel:DockPadding(4, 4, 4, 4)
		panel:DockMargin(0, 0, 0, 4)

		local factionCheck = panel:Add("DCheckBoxLabel")
		factionCheck:Dock(TOP)
		factionCheck:SetText(faction.name)
		factionCheck:DockMargin(0, 0, 0, 4)
		factionCheck.Button.DoClick = function(this)
			local state = !this:GetChecked()

			if state then
				self:AddFaction(faction.uniqueID)
			else
				self:RemoveFaction(faction.uniqueID)
			end
		end
		-- Disabling the label so the button's DoClick isn't bypassed
		factionCheck.Label:SetDisabled(true)

		factionCheck.Classes = {}
		self.FactionCheckBoxes[faction.uniqueID] = factionCheck

		for j, class in ipairs(nut.class.list) do
			if class.faction == i then
				local classCheck = panel:Add("DCheckBoxLabel")
				classCheck:Dock(TOP)
				classCheck:DockMargin(16, 0, 0, 4)
				classCheck:SetText(class.name)
				classCheck.Button.DoClick = function(this)
					local state = !this:GetChecked()

					if state then
						self:AddClass(class.uniqueID)
					else
						self:RemoveClass(class.uniqueID)
					end
				end
				-- Same as above
				classCheck.Label:SetDisabled(true)

				classCheck.Faction = faction.uniqueID
				table.insert(factionCheck.Classes, class.uniqueID)
				self.ClassCheckBoxes[class.uniqueID] = classCheck

				panel:SetTall(panel:GetTall() + classCheck:GetTall() + 4)
			end
		end
	end
end

function PANEL:CheckFaction(faction, checked)
	local checkBox = self.FactionCheckBoxes[faction]
	checkBox:SetChecked(checked)

	-- Automatically add/remove classes based on the faction
	for i, classUID in ipairs(checkBox.Classes) do
		if checked then
			self:AddClass(classUID)
		else
			self:RemoveClass(classUID)
		end
	end
end

function PANEL:SetFactions(factions)
	self.Factions = factions

	for i, faction in ipairs(nut.faction.indices) do
		self:CheckFaction(faction.uniqueID, self.Factions[faction.uniqueID] and true or false)
	end
end

function PANEL:AddFaction(faction)
	self.Factions[faction] = true
	self:CheckFaction(faction, true)
end

function PANEL:RemoveFaction(faction)
	self.Factions[faction] = nil
	self:CheckFaction(faction, false)
end

function PANEL:GetFactions()
	return self.Factions
end

function PANEL:CheckClass(class, checked)
	local checkBox = self.ClassCheckBoxes[class]
	checkBox:SetChecked(checked)

	local factionCheck = self.FactionCheckBoxes[checkBox.Faction]

	-- Automatically add/remove the faction if all classes within are checked/unchecked
	if checked != factionCheck:GetChecked() then
		for i, classUID in ipairs(factionCheck.Classes) do
			local classCheck = self.ClassCheckBoxes[classUID]

			if classCheck:GetChecked() == factionCheck:GetChecked() then
				return
			end
		end

		if checked then
			self:AddFaction(checkBox.Faction)
		else
			self:RemoveFaction(checkBox.Faction)
		end
	end
end

function PANEL:SetClasses(classes)
	self.Classes = classes

	for i, class in ipairs(nut.class.list) do
		self:CheckClass(class.uniqueID, self.Classes[class.uniqueID] and true or false)
	end
end

function PANEL:AddClass(class)
	self.Classes[class] = true
	self:CheckClass(class, true)
end

function PANEL:RemoveClass(class)
	self.Classes[class] = nil
	self:CheckClass(class, false)
end

function PANEL:GetClasses()
	return self.Classes
end

vgui.Register("FactionSelect", PANEL, "DPanel")

--[[
	SearchableListView
	A DListView with search function
]]

PANEL = {}

function PANEL:Init()
	self.SearchBox = self:Add("DTextEntry")
	self.SearchBox:SetPlaceholderText("Search...")
	self.SearchBox.OnEnter = function(s, searchTerm)
		local curLines = {}

		for _, line in ipairs(self:GetLines()) do
			local curLine = {}
			for i = 1, #self.Columns do
				table.insert(curLine, line:GetValue(i))
			end
			table.insert(curLines, curLine)
		end

		self.OriginalLines = self.OriginalLines or curLines

		if searchTerm == "" then
			self:FillLines(self.OriginalLines)
		else
			local searchLines = {}

			for i, line in ipairs(self.OriginalLines) do
				for _, val in ipairs(line) do
					if string.find(val:lower(), searchTerm:lower(), nil, true) then
						table.insert(searchLines, line)
						break
					end
				end
			end

			self:FillLines(searchLines)
		end
	end

	self.SearchBoxAnimTime = 2

	self.SearchBox.GetY = function(s)
		return s:GetParent():GetTall() - s:GetTall()
	end

	self.SearchBox.Show = function(s)
		s.Hidden = false
		s.ShowTime = CurTime()
	end

	self.SearchBox.Hide = function(s)
		s.Hidden = true
		s.HideTime = CurTime()
	end

	self.SearchBox.Toggle = function(s)
		if s.Hidden then
			s:Show()
		else
			s:Hide()
		end
	end

	self.SearchBox.Think = function(s)
		if s.Hidden then
			s:SetPos(Lerp((CurTime() - s.HideTime) / self.SearchBoxAnimTime, s:GetPos(), -s:GetWide()), s:GetY())
		else
			s:SetPos(Lerp((CurTime() - s.ShowTime) / self.SearchBoxAnimTime, s:GetPos(), 0), s:GetY())
		end
	end

	-- Keep the button on top
	self.SearchBox.OnFocusChanged = function(s)
		s:SetZPos(s.Btn:GetZPos() - 1)
	end

	self.SearchBox:Hide()

	self.SearchBtn = self:Add("DImageButton")
	self.SearchBtn:SetSize(16, 16)
	self.SearchBtn:SetImage("icon16/magnifier.png")
	self.SearchBtn:SetPos(self:GetWide() - self.SearchBtn:GetWide() - 16, self:GetTall() - self.SearchBtn:GetTall())
	self.SearchBtn.DoClick = function()
		self.SearchBox:Toggle()
	end
	self.SearchBox.Btn = self.SearchBtn
	self.SearchBtn:SetZPos(self.SearchBtn:GetZPos() + 1)
end

function PANEL:FillLines(lines)
	self:Clear()

	for i, line in ipairs(lines) do
		self:AddLine(unpack(line))
	end
end

function PANEL:OnRowRightClick(lineID, line)
	local menu = DermaMenu()
	menu:SetPos(input.GetCursorPos())
	menu:MakePopup()

	for i, column in ipairs(self.Columns) do
		local name = column.Header:GetText()
		local value = line:GetColumnText(i)

		menu:AddOption("Copy " .. name, function()
			SetClipboardText(value)
		end):SetIcon("icon16/paste_plain.png")
	end
end

function PANEL:OnSizeChanged(w, h)
	self.SearchBox:SetPos(0, h - self.SearchBox:GetTall())
	self.SearchBox:SetWide(w)
	self.SearchBtn:SetPos(w - self.SearchBtn:GetWide() - 16, h - self.SearchBtn:GetTall())
	if self.SearchBox.Hidden then
		self.SearchBox:SetPos(-self.SearchBox:GetWide(), self.SearchBox:GetY())
	end
end

vgui.Register("SearchableListView", PANEL, "DListView")

--[[
	jModelPanel
	Purpose: Same as a model panel but with zoom/rotate controls
]]

PANEL = {}

AccessorFunc(PANEL, "fMaxFOV", "MaxFOV")
AccessorFunc(PANEL, "fMinFOV", "MinFOV")
AccessorFunc(PANEL, "fScrollSpeed", "ScrollSpeed")
AccessorFunc(PANEL, "fRotateSpeed", "RotateSpeed")

function PANEL:Init()
	vgui.GetControlTable(self.Base).Init(self)
	self:SetMaxFOV(100)
	self:SetMinFOV(40)
	self:SetScrollSpeed(2.5)
	self:SetRotateSpeed(1)
	self.LayoutEntity = function() return end
end

function PANEL:SetFOVClamped(fov)
	self:SetFOV(math.Clamp(fov, self:GetMinFOV(), self:GetMaxFOV()))
end

function PANEL:OnMouseWheeled(scrollDelta)
	self:SetFOVClamped(self:GetFOV() - (scrollDelta * self:GetScrollSpeed()))
end

function PANEL:OnMousePressed(btn)
	if btn == MOUSE_LEFT then
		if self.CurPosX then
			self.CurPosX = nil
			self.TotalRotate = self.Rotate
		else
			self.CurPosX = input.GetCursorPos()
		end
	end
end

function PANEL:OnMouseReleased(btn)
	if btn == MOUSE_LEFT then
		self.CurPosX = nil
		self.TotalRotate = self.Rotate
	end
end

function PANEL:PreDrawModel(ent)
	render.SetColorModulation(COLOR.ToVector(ent:GetColor()):Unpack())
end

function PANEL:Think()
	if !input.IsMouseDown(MOUSE_LEFT) then -- Catch if the mouse was lifed even outside of the panel
		self:OnMouseReleased(MOUSE_LEFT)
	end

	if self.CurPosX then
		local x, _ = input.GetCursorPos()
		self.Rotate = (self.TotalRotate or 0) - ((self.CurPosX - x) * self:GetRotateSpeed())

		self.Entity:SetAngles(Angle(0, self.Rotate, 0))
	end
end

vgui.Register("jModelPanel", PANEL, "DModelPanel")
