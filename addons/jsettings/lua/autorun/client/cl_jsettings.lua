-- Fonts
surface.CreateFont("jSliderTip", {font = "Roboto", size = 11})
surface.CreateFont("jSettings", {font = "Roboto", size = 19})
surface.CreateFont("jBinder", {font = "Roboto", size = 17})

-- Methods for adding options
jSettings.Options = {}
jSettings.CategoryIndex = {}
jSettings.Tips = {}

function jSettings.AddCategory(name)
	if !jSettings.CategoryIndex[name] then
		jSettings.CategoryIndex[name] = table.insert(jSettings.Options, {name = name})
	end
end

function jSettings.GetCategoryNum(name)
	return jSettings.CategoryIndex[name]
end

function jSettings.AddToggle(cat, label, convar, default)
	local i = jSettings.GetCategoryNum(cat)
	jSettings.Options[i][label] = {type = "jToggle", convar = convar}

	if default then
		jSettings.SetDefault(convar, default)
	end
end

function jSettings.AddSlider(cat, label, min, max, decimals, convar, default)
	local i = jSettings.GetCategoryNum(cat)
	jSettings.Options[i][label] = {type = "jSlider", pnlOptions = {Min = min, Max = max, Decimals = decimals}, convar = convar}

	if default then
		jSettings.SetDefault(convar, default)
	end
end

function jSettings.AddBinder(cat, label, down, up, default)
	local i = jSettings.GetCategoryNum(cat)
	jSettings.Options[i][label] = {type = "jBinder", down = down, up = up}

	if default then
		jBinds.SetDefault(default, down, up)
	end
end

function jSettings.SetDefault(convar, value)
	local cookieName = "jSettingsDefault_" .. convar
	if cookie.GetNumber(cookieName, 0) != 1 then
		cookie.Set(cookieName, 1)
		RunConsoleCommand(convar, tostring(value))

		return true
	end

	return false
end

function jSettings.AddTip(label, tip)
	jSettings.Tips[label] = tip
end

-- Adding options
jSettings.AddCategory("Performance")
jSettings.AddToggle("Performance", "PAC3", "pac_enable", 0)
jSettings.AddSlider("Performance", "PAC3 Draw Distance", 100, 2500, 0, "pac_draw_distance")
jSettings.AddSlider("Performance", "Radzone Fog Desinity", 0.3, 1, 2, "falloutRadsZonePlacer_fogDens")

jSettings.AddCategory("Graphics")
jSettings.AddSlider("Graphics", "Bloom", 0, 1, 1, "mat_bloomscale")
jSettings.AddToggle("Graphics", "Shadows", "r_shadows", 0)

jSettings.AddCategory("Audio")
jSettings.AddSlider("Audio", "PAC3 Volume", 0, 1, 2, "pac_ogg_volume")
jSettings.AddSlider("Audio", "Ambient Music Volume", 0, 100, 0, "nombat_volume")

jSettings.AddCategory("View")
jSettings.AddSlider("View", "FOV", 75, 100, 0, "fov_desired")
jSettings.AddToggle("View", "Third Person", "simple_thirdperson_enabled")
jSettings.AddToggle("View", "Freelook", "simple_thirdperson_freelook")
jSettings.AddBinder("View", "Third Person Toggle", {"simple_thirdperson_enable_toggle"})

jSettings.AddCategory("Binds")
jSettings.AddBinder("Binds", "Zoom", {"+zoom"}, {"-zoom"})
jSettings.AddBinder("Binds", "Toggle raise", {"say", "/toggleraise"})

-- UI
jSettings.DefaultPrimary = Color(45, 45, 45, 255)
jSettings.DefaultSecondary = Color(255, 255, 255, 255)
jSettings.DefaultAccent = jSettings.DefaultAccent or Color(0, 128, 128, 255)
hook.Add("InitPostEntity", "jSettingsAccent", function()
	jSettings.DefaultAccent = nut.gui.palette.color_primary
end)

function jSettings.SetPercent(pnl, num)
	pnl.Percent = math.Clamp(num, 0, 1)
end

function jSettings.GetPercent(pnl, num)
	return pnl.Percent or 0
end

local PANEL = {}

AccessorFunc(PANEL, "Toggled", "Toggled", FORCE_BOOL)
AccessorFunc(PANEL, "Primary", "Primary")
AccessorFunc(PANEL, "Secondary", "Secondary")

PANEL.SetPercent = jSettings.SetPercent
PANEL.GetPercent = jSettings.GetPercent
PANEL.SetValue = PANEL.SetToggled
PANEL.GetValue = PANEL.GetToggled

function PANEL:Init()
	self:SetCursor("hand")
	self:SetSize(45, 20)
	self:SetToggled(false)
	self:SetPrimary(jSettings.DefaultPrimary)
	self:SetSecondary(jSettings.DefaultSecondary)
end

function PANEL:Paint(w, h)
	local toggled = self:GetToggled()
	local curPercent = self:GetPercent()
	local factor = 7

	draw.RoundedBox(h / 2, 0, 0, w, h, self:GetPrimary())

	if toggled and curPercent < 1 then
		self:SetPercent(Lerp(FrameTime() * factor, curPercent, 1))
	elseif !toggled and curPercent > 0 then
		self:SetPercent(Lerp(FrameTime() * factor, curPercent, 0))
	end

	local r = h / 2.5
	local p = self:GetPercent()
	local pad = r / 4

	surface.SetDrawColor(self:GetSecondary():Unpack())
	jlib.DrawCircle(r + pad + ((w - (r * 2) - (pad * 2)) * p), h / 2, r, math.max(20, r * 0.8))
end

function PANEL:OnMouseReleased()
	self:Toggle()
end

function PANEL:Toggle()
	self:SetToggled(!self:GetToggled())
	if isfunction(self.OnChange) then
		self:OnChange(self:GetToggled())
	end
end

function PANEL:SetToggleInstant(bool)
	if bool then
		self:SetPercent(1)
	else
		self:SetPercent(0)
	end
	self:SetToggled(bool)
end

function PANEL:ConvertValue(val)
	return tobool(val)
end

function PANEL:SetConVar(convar)
	if ConVarExists(convar) then
		self:SetToggleInstant(self:ConvertValue(GetConVar(convar):GetString()))

		function self:OnChange(newVal)
			RunConsoleCommand(convar, tostring(newVal and 1 or 0))
		end
	end
end

vgui.Register("jToggle", PANEL, "DPanel")

PANEL = {}

AccessorFunc(PANEL, "Primary", "Primary")
AccessorFunc(PANEL, "Secondary", "Secondary")
AccessorFunc(PANEL, "Accent", "Accent")
AccessorFunc(PANEL, "Min", "Min", FORCE_NUMBER)
AccessorFunc(PANEL, "Max", "Max", FORCE_NUMBER)
AccessorFunc(PANEL, "Decimals", "Decimals", FORCE_NUMBER)

PANEL.SetPercent = jSettings.SetPercent
PANEL.GetPercent = jSettings.GetPercent

function PANEL:Init()
	self:SetCursor("hand")
	self:SetSize(100, 12)
	self:SetPrimary(jSettings.DefaultPrimary)
	self:SetSecondary(jSettings.DefaultSecondary)
	self:SetAccent(jSettings.DefaultAccent)
	self:SetPercent(0.5)
	self:SetMin(0)
	self:SetMax(1)
	self:SetDecimals(2)
	self.TipShownFor = 0
end

function PANEL:Paint(w, h)
	if !input.IsMouseDown(MOUSE_LEFT) then
		self.IsSliding = false
	end

	if self.IsSliding then
		local oldPercent = self:GetPercent()
		local newPercent = self:LocalCursorPos() / w
		if oldPercent != newPercent then
			self:SetPercent(newPercent)
			if isfunction(self.OnChange) then
				self:OnChange(self:GetValue())
			end
		end
	end

	draw.RoundedBox(h / 2, 0, 0, w, h, self:GetPrimary())
	draw.RoundedBox(h / 2, 0, 0, w * self:GetPercent(), h, self:GetAccent())

	local r = h / 1.5

	DisableClipping(true)

	surface.SetDrawColor(self:GetSecondary():Unpack())
	jlib.DrawCircle(w * self:GetPercent(), h / 2, r, math.max(20, h * 0.8))

	local tipW, tipH = h * 1.75, h * 1.5

	local tipAnimTime = 0.1

	if self:IsHovered() or self.IsSliding then
		self.TipShownFor = Lerp(FrameTime() / tipAnimTime, self.TipShownFor, tipAnimTime)
	else
		self.TipShownFor = math.max(self.TipShownFor - FrameTime(), 0)
	end

	if self.TipShownFor > 0 then
		local x = w * self:GetPercent() - (tipW / 2)
		local y = (-r * 2) - 3

		local sX, sY = self:LocalToScreen(x, y)
		local progress = self.TipShownFor / tipAnimTime

		render.SetScissorRect(sX, sY + tipH, sX + tipW, (sY + tipH) - (tipH * progress), true)

		surface.SetDrawColor(0, 0, 0, 255)
		jlib.DrawTip(x, y, tipW, tipH)

		surface.SetDrawColor(self:GetAccent():Unpack())
		jlib.DrawTip(x + 1, y + 1, tipW - 2, tipH - 3, math.Round(self:GetValue(), self:GetDecimals()) , "jSliderTip", self:GetSecondary(), self:GetPrimary())

		render.SetScissorRect(0, 0, 0, 0, false)
	end

	DisableClipping(false)
end

function PANEL:OnMousePressed()
	self.IsSliding = true
end

function PANEL:OnMouseReleased()
	self.IsSliding = false
end

function PANEL:SetValue(num)
	self:SetPercent((num - self:GetMin()) / (self:GetMax() - self:GetMin()))
end

function PANEL:GetValue()
	return (self:GetMax() - self:GetMin()) * self:GetPercent() + self:GetMin()
end

function PANEL:ConvertValue(val)
	return tonumber(val)
end

function PANEL:SetConVar(convar)
	if ConVarExists(convar) then
		self:SetValue(self:ConvertValue(GetConVar(convar):GetString()))

		function self:OnChange(newVal)
			RunConsoleCommand(convar, tostring(newVal))
		end
	end
end

vgui.Register("jSlider", PANEL, "DPanel")

PANEL = {}

AccessorFunc(PANEL, "Primary", "Primary")
AccessorFunc(PANEL, "Secondary", "Secondary")
AccessorFunc(PANEL, "Accent", "Accent")
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "Value", "Value", FORCE_NUMBER)

PANEL.OSetValue = PANEL.SetValue

function PANEL:Init()
	self:SetPrimary(jSettings.DefaultPrimary)
	self:SetSecondary(jSettings.DefaultSecondary)
	self:SetAccent(jSettings.DefaultAccent)
	self:SetFont("jBinder")
	self:SetCursor("hand")
end

function PANEL:SetBind(down, up)
	self:SetValue(jBinds.LookupBinding(down, up))

	function self:OnChange(newVal)
		if self.OldValue then
			jBinds.UnBind(self.OldValue)
		end

		if newVal then
			jBinds.Bind(newVal, down, up)
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(h / 2, 0, 0, w, h, self:GetPrimary())
	local textCol = self:IsHovered() and self:GetSecondary() or self:GetAccent()
	local keyDisplay = self.WaitingForKey and "..." or string.upper(input.GetKeyName(self:GetValue() or -1) or "none")
	draw.SimpleText(keyDisplay, self:GetFont(), w / 2, h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:SetWaitingForKey(bool)
	self.WaitingForKey = bool
	self:SetKeyboardInputEnabled(bool)
	if bool then
		self:RequestFocus()
	end
end

function PANEL:GetWaitingForKey()
	return self.WaitingForKey
end

function PANEL:OnMousePressed(mouse)
    if mouse == MOUSE_LEFT then
		self:SetWaitingForKey(true)
	end
end

function PANEL:OnKeyCodeReleased(key)
	if self:GetWaitingForKey() then
		if key != KEY_ESCAPE then
			self:SetValue(key)
		end
		self:SetWaitingForKey(false)

		return true
	end
end

function PANEL:SetValue(val)
	self.OldValue = self:GetValue()
	self:OSetValue(val)

	if isfunction(self.OnChange) then
		self:OnChange(val)
	end
end

vgui.Register("jBinder", PANEL, "DPanel")

PANEL = {}

AccessorFunc(PANEL, "Primary", "Primary")
AccessorFunc(PANEL, "Secondary", "Secondary")
AccessorFunc(PANEL, "Accent", "Accent")
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "Padding", "Padding", FORCE_NUMBER)

function PANEL:Init()
	self:SetFont("UI_Regular")
	self:SetSize(self:GetParent():GetWide(), 20)
	self:SetPrimary(jSettings.DefaultPrimary)
	self:SetSecondary(jSettings.DefaultSecondary)
	self:SetAccent(jSettings.DefaultAccent)
end

function PANEL:Paint(w, h)
	local text = self:GetText()

	surface.SetFont(self:GetFont() or "jSettings")
	local tW = surface.GetTextSize(text)

	draw.SimpleText(self:GetText() or "", self:GetFont(), w / 2, h / 2, self:GetAccent(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local lineSpacing = self:GetPadding() or 15
	local lineW = math.floor((w / 2) - (lineSpacing * 2) - (tW / 2))
	local lineH = 3

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(lineSpacing, h / 2 - 1, lineW, lineH)
	surface.DrawRect(w - lineW - lineSpacing, h / 2 - 1, lineW, lineH)

	surface.SetDrawColor(self:GetAccent():Unpack())
	surface.DrawLine(lineSpacing + 1, h / 2, lineSpacing + lineW - 2, h / 2)
	surface.DrawLine(w - lineW - lineSpacing + 1, h / 2, w - lineSpacing - 2, h / 2)
end

vgui.Register("jSeperator", PANEL, "DPanel")

PANEL = {}

AccessorFunc(PANEL, "Primary", "Primary")
AccessorFunc(PANEL, "Secondary", "Secondary")
AccessorFunc(PANEL, "Accent", "Accent")
AccessorFunc(PANEL, "TipText", "TipText", FORCE_STRING)
AccessorFunc(PANEL, "TipFont", "TipFont", FORCE_STRING)

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetPrimary(jSettings.DefaultPrimary)
	self:SetSecondary(jSettings.DefaultSecondary)
	self:SetAccent(jSettings.DefaultAccent)
	self:SetTipFont("jSliderTip")
end

function PANEL:Paint()
	local tipText = self:GetTipText()
	if tipText != "nil" and self:IsHovered() then
		DisableClipping(true)

		local font = self:GetTipFont()
		local w = 120
		local wrapped, h = jlib.WrapText(w, tipText, font)
		h = h + 15

		local cX, cY = self:CursorPos()
		local x, y = cX - (w / 2), cY - h

		surface.SetDrawColor(0, 0, 0, 255)
		jlib.DrawTip(x, y, w, h)

		surface.SetDrawColor(self:GetAccent():Unpack())
		jlib.DrawTip(x + 1, y + 1, w - 2, h - 3, wrapped, font, self:GetSecondary(), self:GetPrimary())

		DisableClipping(false)
	end
end

vgui.Register("jSettingsLabel", PANEL, "DLabel")

-- Constructing the menu
function jSettings.Fill(menu)
	local pnl = menu:Add("DPanel")
	pnl:SetWide(math.min(500, menu:GetWide()))
	pnl:SetTall(menu:GetTall() - 25)
	pnl:SetPos(0, 25)
	pnl:CenterHorizontal()
	pnl:SetPaintBackground(false)

	local scroll = pnl:Add("UI_DScrollPanel")
	scroll:SetSize(pnl:GetSize())
	scroll:Dock(FILL)

	-- To avoid colliding with the scroll bar
	local container = scroll:Add("DPanel")
	container:SetWide(pnl:GetWide() - 30)
	container:SetPaintBackground(false)
	container:SetPos(15)

	local space = 10

	local lastPnl

	for i, option in pairs(jSettings.Options) do
		local category = option.name

		local spacer = container:Add("jSeperator")
		spacer:SetText(category)
		spacer:SetPos(0, space)
		spacer:SetWide(container:GetWide())
		if IsValid(lastPnl) then
			spacer:MoveBelow(lastPnl, space)
		end

		lastPnl = spacer

		for labelTxt, settings in pairs(option) do
			if labelTxt == "name" then continue end

			local panel = container:Add("DPanel")
			panel:SetSize(container:GetWide(), 20)
			panel:SetPaintBackground(false)

			local label = panel:Add("jSettingsLabel")
			label:SetFont("jSettings")
			label:SetText(labelTxt)
			label:SizeToContents()
			label:SetColor(jSettings.DefaultAccent)
			label:SetPos(10, 0)
			label:CenterVertical()
			label:SetTipText(jSettings.Tips[labelTxt])

			local control = panel:Add(settings.type)
			control:SetPos(panel:GetWide() - control:GetWide() - 10, 0)
			control:CenterVertical()

			if IsValid(lastPnl) then
				panel:MoveBelow(lastPnl, space)
			end

			for k, v in pairs(settings.pnlOptions or {}) do
				control[k] = v
			end

			if control.SetConVar then
				control:SetConVar(settings.convar)
			elseif control.SetBind then
				control:SetBind(settings.down, settings.up)
			end

			lastPnl = panel
		end
	end

	container:SizeToChildren(false, true)
end

function jSettings.OpenMenu()
	local menu = vgui.Create("DFrame")
	menu:SetTitle("Settings")
	menu:SetSize(350, 400)
	menu:Center()
	menu:MakePopup()

	jSettings.Fill(menu)
end

hook.Run("jSettingsInit")

-- Experimental performance settings
jSettings.Experimental = jSettings.Experimental or {}
jSettings.Experimental.ConVar = "experimental_perf_settings"
jSettings.Experimental.Settings = {
	mat_queue_mode = "2",
	r_threaded_renderables = "1",
	r_queued_ropes = "1",
	r_rootlod = "2",
	r_entityclips = "1",
	r_fastzreject = "1",
	r_norefresh = "1",
	mat_vsync = "0",
	mat_trilinear = "0",

	gmod_mcore_test = "1",
	cl_threaded_client_leaf_system = "1",
	cl_threaded_bone_setup = "1",
	fps_max = "300",
	lod_TransitionDist = "-1",
	mat_forcemanagedtextureintohardware = "0",

	cl_smooth = "0",
	cl_smoothtime = "0.01",
	cl_updaterate = "40",
	cl_lagcompensation = "1",
	cl_pred_optimize = "2"
}

CreateClientConVar(jSettings.Experimental.ConVar, "0")
cvars.AddChangeCallback(jSettings.Experimental.ConVar, function(_, old, new)
	if tobool(new) then -- Set the experimental values
		jSettings.Print("Enabling experimental performance settings")

		for cvar, value in pairs(jSettings.Experimental.Settings) do
			RunConsoleCommand(cvar, value)
		end
	else -- Reset experimental cvars to default
		jSettings.Print("Disabling experimental performance settings")

		for cvar, _ in pairs(jSettings.Experimental.Settings) do
			RunConsoleCommand(cvar, GetConVar(cvar):GetDefault())
		end
	end
end)

jSettings.AddToggle("Performance", "Experimental Performance Settings", jSettings.Experimental.ConVar)
