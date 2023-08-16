local PANEL = {}

function PANEL:Init()
	self:SetSize(448, 32)
	self:SetSkin("fallout")
	self:DockPadding(12, 6, 6, 6)
	self:SetPos(64, 64)
	self:SetDrawOnTop(true)
end

function PANEL:open(message, sound)
	self.id = table.insert(nut.fallout.notices, self)

	local txt = self:Add("DLabel")
	txt:Dock(FILL)
	txt:SetText(message)
	txt:SetFont("falloutRegular")
	txt:SetExpensiveShadow(1, Color(0, 0, 0))

	if isstring(sound) then
		surface.PlaySound(sound)
	end

	local count = self.id - 1

	if count > 0 then
		self:SetPos(64, 64 + ((self:GetTall() + 12) * count))
	end

	self:SetAlpha(0)
	self:AlphaTo(255, .3)
	self:AlphaTo(0, .3, 5, function()
		for i = self.id, #nut.fallout.notices do
			local pnl = nut.fallout.notices[i]
			pnl:MoveTo(64, 64 + ((self:GetTall() + 12) * (i - 2)), 0.5)
			pnl.id = pnl.id - 1
		end

		table.RemoveByValue(nut.fallout.notices, self)
		self:Remove()
	end)
end

vgui.Register("nutFalloutNotice", PANEL, "DPanel")
