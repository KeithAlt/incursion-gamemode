local PANEL = {}

AccessorFunc(PANEL, "m_bDeleteSelf", "DeleteSelf")
AccessorFunc(PANEL, "m_iPadding", "Padding")

function PANEL:Init()
	self.Options = {}
	self:SetWide(125)
	self:SetDrawOnTop(true)
	self:SetIsMenu(true)
	self:SetDeleteSelf(true)
	self:SetPadding(5)
	RegisterDermaMenuForClose(self)
end

function PANEL:Open()
	if IsValid(self:GetParent()) then
		self:SetPos(self:GetParent():LocalCursorPos())
	else
		self:SetPos(input.GetCursorPos())
	end
	self:MakePopup()
end

function PANEL:AddOption(str, func)
	local pad = self:GetPadding()

	local btn = self:Add("UI_DButton")
	btn:Dock(TOP)
	btn:SetText(str)
	btn.DoClick = function(s)
		func()
		self:Remove()
	end
	btn:DockMargin(pad, pad, pad, 0)
	table.insert(self.Options, btn)

	self:SetTall((#self.Options * (btn:GetTall() + pad)) + pad)
end

vgui.Register("UI_DMenu", PANEL, "UI_DPanel_Bordered")
