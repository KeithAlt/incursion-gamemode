local maxHistoryCVar = CreateClientConVar("ns_chatbox_maxhistory", 250, true, false, nil, 10, 10000)
local fadeStartCVar = CreateClientConVar("ns_chatbox_fadestart", 2)
local fadeEndCVar = CreateClientConVar("ns_chatbox_fadeend", 3)

jSettings.AddCategory("Chatbox")
jSettings.AddSlider("Chatbox", "Maximum chat log history", 50, 1000, 0, "ns_chatbox_maxhistory")
jSettings.AddSlider("Chatbox", "Fade start", 1, 10, 1, "ns_chatbox_fadestart")
jSettings.AddSlider("Chatbox", "Fade time", 1, 10, 1, "ns_chatbox_fadeend")
jSettings.AddTip("Fade start", "After this many seconds a chat message will begin to fade.")
jSettings.AddTip("Fade time", "How long it takes for a message to full fade once started.")
jSettings.AddTip("Maximum chat log history", "Maximum number of messages that will fill the chatbox at a time. Once this limit is reached the oldest messages will be removed.")

local PANEL = {}
local gradient = Material("vgui/gradient-d")
local gradient2 = Material("vgui/gradient-u")

local COLOR_FADED = Color(200, 200, 200, 100)
local COLOR_ACTIVE = color_white
local COLOR_WRONG = Color(255, 100, 80)

PANEL.MaxMessageHistory = 250

function PANEL:Init()
	local border = 32
	local scrW, scrH = ScrW(), ScrH() * 0.82
	local w, h = scrW * 0.40, scrH * 0.55

	nut.gui.chat = self

	self:SetSize(w, h)
	self:SetPos(border, scrH - h - border)

	self.active = false

	self.tabs = self:Add("DPanel")
	self.tabs:Dock(TOP)
	self.tabs:SetTall(24)
	self.tabs:DockPadding(3, 3, 3, 3)
	self.tabs:DockMargin(4, 4, 4, 4)
	self.tabs:SetVisible(false)

	self.arguments = {}

	self.scroll = self:Add("DScrollPanel")
	self.scroll:SetPos(4, 30)
	self.scroll:SetSize(w - 8, h - 70)
	self.scroll:GetVBar():SetWide(0)
	self.scroll.PaintOver = function(this, w, h)
		local entry = self.text

		if (self.active and IsValid(entry)) then
			local text = entry:GetText()

			if (text:sub(1, 1) == "/") then
				local arguments = self.arguments or {}
				local command = string.PatternSafe(arguments[1] or ""):lower()

				nut.util.drawBlur(this)

				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawRect(0, 0, w, h)

				local i = 0
				local color = nut.config.get("color")

				for k, v in SortedPairs(nut.command.list) do
					local k2 = "/"..k

					if (k2:match(command)) then
						local x, y = nut.util.drawText(k2.."  ", 4, i * 20, color)

						if (k == command and v.syntax) then
							local i2 = 0

							for argument in v.syntax:gmatch("([%[<][%w_]+[%s][%w_]+[%]>])") do
								i2 = i2 + 1
								local color = COLOR_FADED

								if (i2 == (#arguments - 1)) then
									color = COLOR_ACTIVE
								end

								x = x + nut.util.drawText(argument.."  ", x, i * 20, color)
							end
						end

						i = i + 1
					end
				end
			end
		end
	end

	self.lastY = 0

	self.list = {}
	self.filtered = {}

	chat.GetChatBoxPos = function()
		return self:LocalToScreen(0, 0)
	end

	chat.GetChatBoxSize = function()
		return self:GetSize()
	end

	local buttons = {}

	for k, v in SortedPairsByMemberValue(nut.chat.classes, "filter") do
		if (!buttons[v.filter]) then
			self:addFilterButton(v.filter)
			buttons[v.filter] = true
		end
	end
end

function PANEL:Paint(w, h)
	if (self.active) then
		nut.util.drawBlur(self, 10)

		surface.SetDrawColor(250, 250, 250, 2)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 240)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end

local TEXT_COLOR = Color(255, 255, 255, 200)

function PANEL:setActive(state)
	self.active = state

	if (state) then
		self.entry = self:Add("EditablePanel")
		self.entry:SetPos(self.x + 4, self.y + self:GetTall() - 32)
		self.entry:SetWide(self:GetWide() - 8)
		self.entry.Paint = function(this, w, h)
		end
		self.entry.OnRemove = function()
			hook.Run("FinishChat")
		end
		self.entry:SetTall(28)

		nut.chat.history = nut.chat.history or {}

		self.text = self.entry:Add("DTextEntry")
		self.text:Dock(FILL)
		self.text.History = nut.chat.history
		self.text:SetHistoryEnabled(true)
		self.text:DockMargin(3, 3, 3, 3)
		self.text:SetFont("nutChatFont")
		self.text.OnEnter = function(this)
			local text = this:GetText()

			this:Remove()

			self.tabs:SetVisible(false)
			self.active = false
			self.entry:Remove()

			if (text:find("%S")) then
				if (!(nut.chat.lastLine or ""):find(text, 1, true)) then
					nut.chat.history[#nut.chat.history + 1] = text
					nut.chat.lastLine = text
				end

				netstream.Start("msg", text)
			end
		end
		self.text:SetAllowNonAsciiCharacters(true)
		self.text.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawOutlinedRect(0, 0, w, h)

			this:DrawTextEntryText(TEXT_COLOR, nut.config.get("color"), TEXT_COLOR)
		end
		self.text.OnTextChanged = function(this)
			local text = this:GetText()

			hook.Run("ChatTextChanged", text)

			if (text:sub(1, 1) == "/") then
				self.arguments = nut.command.extractArgs(text:sub(2))
			end
		end

		self.entry:MakePopup()
		self.text:RequestFocus()
		self.tabs:SetVisible(true)
		self.scroll:SetVisible(true)

		hook.Run("StartChat")
	end
end

local function OnDrawText(text, font, x, y, color, alignX, alignY, alpha)
	alpha = alpha or 255

	surface.SetTextPos(x+1, y+1)
	surface.SetTextColor(0, 0, 0, alpha)
	surface.SetFont(font)
	surface.DrawText(text)

	surface.SetTextPos(x, y)
	surface.SetTextColor(color.r, color.g, color.b, alpha)
	surface.SetFont(font)
	surface.DrawText(text)
	--draw.SimpleTextOutlined(text, font, x, y, ColorAlpha(color, alpha), 0, alignY, 1, ColorAlpha(color_black, alpha * 0.6))
end

local function PaintFilterButton(this, w, h)
	if (this.active) then
		surface.SetDrawColor(40, 40, 40)
	else
		local alpha = 120 + math.cos(RealTime() * 5) * 10

		surface.SetDrawColor(ColorAlpha(nut.config.get("color"), alpha))
	end

	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:addFilterButton(filter)
	local name = L(filter)

	local tab = self.tabs:Add("DButton")
	tab:SetFont("nutChatFont")
	tab:SetText(name:upper())
	tab:SizeToContents()
	tab:DockMargin(0, 0, 3, 0)
	tab:SetWide(tab:GetWide() + 32)
	tab:Dock(LEFT)
	tab:SetTextColor(color_white)
	tab:SetExpensiveShadow(1, Color(0, 0, 0, 200))
	tab.Paint = PaintFilterButton
	tab.DoClick = function(this)
		this.active = !this.active

		local filters = NUT_CVAR_CHATFILTER:GetString():lower()

		if (filters == "none") then
			filters = ""
		end

		if (this.active) then
			filters = filters..filter..","
		else
			filters = filters:gsub(filter.."[,]", "")

			if (!filters:find("%S")) then
				filters = "none"
			end
		end

		self:setFilter(filter, this.active)
		RunConsoleCommand("nut_chatfilter", filters)
	end

	if (NUT_CVAR_CHATFILTER:GetString():lower():find(filter)) then
		tab.active = true
	end
end

function PANEL:addText(...)
	local text = "<font=nutChatFont>"

	if (CHAT_CLASS) then
		text = "<font="..(CHAT_CLASS.font or "nutChatFont")..">"
	end

	for k, v in ipairs({...}) do
		if (type(v) == "IMaterial") then
			local ttx = v:GetName()
			text = text.."<img="..ttx..","..v:Width().."x"..v:Height()..">"
		elseif (type(v) == "table" and v.r and v.g and v.b) then
			text = text.."<color="..v.r..","..v.g..","..v.b..">"
		elseif (type(v) == "Player") then
			local color = jlib.GetTeamColor(v)

			text = text.."<color="..color.r..","..color.g..","..color.b..">"..v:Name():gsub("<", "&lt;"):gsub(">", "&gt;")
		else
			text = text..tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
			text = text:gsub("%b**", function(value)
				local inner = value:sub(2, -2)

				if (inner:find("%S")) then
					return "<font=nutChatFontItalics>"..value:sub(2, -2).."</font>"
				end
			end)
		end
	end

	text = text.."</font>"

	local panel = self.scroll:Add("nutMarkupPanel")
	panel:SetWide(self:GetWide() - 8)
	panel:setMarkup(text, OnDrawText)
	panel.start = CurTime() + fadeStartCVar:GetFloat()
	panel.finish = panel.start + fadeEndCVar:GetFloat()
	panel.Think = function(this)
		if self.active then
			this:SetAlpha(255)
		elseif this.Alpha or 255 > 0 then
			this.Alpha = (1 - math.TimeFraction(this.start, this.finish, CurTime())) * 255
			this:SetAlpha(this.Alpha)
		elseif this:GetAlpha() != 0 then
			this:SetAlpha(0)
		end
	end

	self.list[#self.list + 1] = panel

	while #self.list > maxHistoryCVar:GetInt() do
		local pnl = self.list[1]
		if IsValid(pnl) then
			pnl:Remove()
		end
		table.remove(self.list, 1)
	end

	local class = CHAT_CLASS and CHAT_CLASS.filter and CHAT_CLASS.filter:lower() or "ic"

	if (NUT_CVAR_CHATFILTER:GetString():lower():find(class)) then
		self.filtered[panel] = class
		panel:SetVisible(false)
	else
		panel:SetPos(0, self.lastY)

		self.lastY = self.lastY + panel:GetTall()
		self.scroll:ScrollToChild(panel)
	end

	panel.filter = class

	return panel:IsVisible()
end

function PANEL:setFilter(filter, state)
	if (state) then
		for k, v in ipairs(self.list) do
			if (v.filter == filter) then
				v:SetVisible(false)
				self.filtered[v] = filter
			end
		end
	else
		for k, v in pairs(self.filtered) do
			if (v == filter) then
				if IsValid(k) then
					k:SetVisible(true)
				end
				self.filtered[k] = nil
			end
		end
	end

	self.lastY = 0

	local lastChild

	for k, v in ipairs(self.list) do
		if (v:IsVisible()) then
			v:SetPos(0, self.lastY)
			self.lastY = self.lastY + v:GetTall() + 2
			lastChild = v
		end
	end

	if (IsValid(lastChild)) then
		self.scroll:ScrollToChild(lastChild)
	end
end

function PANEL:Think()
	if (gui.IsGameUIVisible() and self.active) then
		self.tabs:SetVisible(false)
		self.active = false

		if (IsValid(self.entry)) then
			self.entry:Remove()
		end
	end

	--hides chatbox is char gui is open
	if IsValid(nut.gui.char) and IsValid(self.scroll) then
		self.scroll:SetVisible(false)
	end

	--this more complicated code turns it back on, but that's unnecessary since opening the chat does that anyways
	--[[
	if (IsValid(nut.gui.char)) then
		if(IsValid(self.scroll) and !self.hiddenScroll) then
			self.scroll:SetVisible(false)

			self.hiddenScroll = true
		end
	else --makes it visible again when it is no longer there
		if(IsValid(self.scroll) and self.hiddenScroll) then
			self.scroll:SetVisible(true)

			self.hiddenScroll = nil
		end
	end
	--]]
end
vgui.Register("nutChatBox", PANEL, "DPanel")
