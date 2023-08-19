local PANEL = {}

local sound
hook.Add("InitPostEntity", "XPSoundInit", function()
	sound = CreateSound(game.GetWorld(), "fallout/experience_up.wav")
end)

function PANEL:Init()
	self:SetSize(256, 64)
	self:SetSkin("fallout")
	self:DockPadding(6, 0, 0, 0)
	self:SetPos(64, (ScrH() / 2) - 64)
	self:SetPaintBackground(false)
end

function PANEL:open(xp, muteSound)
	lvl = self:Add("DLabel")
		lvl:Dock(FILL)
		lvl:SetText("+"..xp)
		lvl:SetFont("falloutBold")
		lvl:SetExpensiveShadow(1, Color(0, 0, 0))

	if !muteSound and sound then
		if sound:IsPlaying() then
			sound:Stop()
		end

		sound:SetSoundLevel(0)
		sound:PlayEx(0.6, 100)
	end

	self:SetAlpha(0)
	self:AlphaTo(255, 2)
	self:AlphaTo(0, 2, 4, function() self:Remove() end)
end

vgui.Register("nutGetXP", PANEL, "DPanel")
