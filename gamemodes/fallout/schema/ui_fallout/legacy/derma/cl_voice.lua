PlayerVoicePanels = {}

local PANEL = {}

function PANEL:Init()
	self:SetSkin("fallout")
	self:DockPadding(6, 6, 6, 6)
	self:SetSize(44, 44)
	self:Dock(RIGHT)
	self:DockMargin(6, 6, 6, 6)

	self.avatar = self:Add("AvatarImage")
	self.avatar:Dock(LEFT)
	self.avatar:SetSize(32, 32)
end

function PANEL:Setup(ply)
	if IsValid(PlayerVoicePanels[ply]) then self:Remove() end

	self.BackgroundColor, self.LineColor = hook.Run("VoiceNotifyColor", ply)

	self.ply = ply
	self.avatar:SetPlayer(ply)
	self.avatar.Think = function()
		if !IsValid(self.ply) then
			if self.ply != nil then
				PlayerVoicePanels[self.ply] = nil
			end
			self:Remove()
		end
	end
	self:InvalidateLayout()
end

vgui.Register("VoiceNotify", PANEL, "DPanel")

function SCHEMA:PlayerStartVoice(ply)
	if !IsValid(g_VoicePanelList) then return end

	SCHEMA:PlayerEndVoice(ply)

	if !IsValid(ply) then return end

	local pnl = g_VoicePanelList:Add("VoiceNotify")
	pnl:Setup(ply)

	PlayerVoicePanels[ply] = pnl
end

function SCHEMA:PlayerEndVoice(ply)
	if IsValid(PlayerVoicePanels[ply]) then
		PlayerVoicePanels[ply]:Remove()
		PlayerVoicePanels[ply] = nil
	end
end

local function CreateVoiceVGUI()
	g_VoicePanelList = vgui.Create("DPanel")

	g_VoicePanelList:ParentToHUD()
	g_VoicePanelList:SetPos(0, 0)
	g_VoicePanelList:SetSize(ScrW(), 56)
	g_VoicePanelList:SetPaintBackground(false)
end

hook.Add("InitPostEntity", "CreateVoiceVGUI", CreateVoiceVGUI)
