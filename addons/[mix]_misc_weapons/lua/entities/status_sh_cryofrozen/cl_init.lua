include("shared.lua")

function CRYO_BONE_POSITIONS(ent, numbones)
	local cryo = ent.m_CryoFrozen
	if (!IsValid(cryo)) then
		return end

	for i, m in pairs (cryo.m_BoneMatrixes) do
		local b = ent:GetBoneName(i)
		if (b ~= "__INVALIDBONE__") then
			local mat = Matrix()
			mat:SetTranslation(m[1])
			mat:SetAngles(m[2])
			ent:SetBoneMatrix(i, mat)
		end
	end
end

function ENT:Initialize()
	self:DrawShadow(false)

	self.m_BoneMatrixes = {}

	local owner = self:GetOwner()
	if (IsValid(owner)) then
		owner.m_CryoFrozen = self
		owner.m_bIsFrozen = true
		owner:SetupBones()

		local vm = owner:GetViewModel()
		if (IsValid(vm)) then
			self.m_fCycleFreeze = vm:GetCycle()
			vm:SetPlaybackRate(0)
		end

		local wep = owner:GetActiveWeapon()
		if (IsValid(wep)) then
			wep.m_OldThink = wep.Think
			wep.Think = function() end
		end

		if (!owner.m_bCryoSetup) then
			owner.m_bCryoSetup = true

			owner:AddCallback("BuildBonePositions", function(ent, numbones)
				CRYO_BONE_POSITIONS(ent, numbones)
			end)
		end

		for i = 0, owner:GetBoneCount() - 1 do
			local bn = owner:GetBoneName(i)
			if (bn == "__INVALIDBONE__") then
				continue end

			local mat = owner:GetBoneMatrix(i)
			if (!mat) then
				continue end

			self.m_BoneMatrixes[i] = {mat:GetTranslation(), mat:GetAngles()}
		end

		if (owner == LocalPlayer() and CRYOGRENADE_SETTINGS.PrintInChat) then
			chat.AddText(CRYOGRENADE_SETTINGS.ChatMessageColor, CRYOGRENADE_SETTINGS.FrozenChatMessageContents)
		end
	end
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if (IsValid(owner)) then
		owner.m_CryoFrozen = nil
		owner.m_bIsFrozen = false

		local vm = owner:GetViewModel()
		if (IsValid(vm)) then
			vm:SetPlaybackRate(1)
		end

		local wep = owner:GetActiveWeapon()
		if (IsValid(wep)) then
			wep.Think = wep.m_OldThink
			wep.m_OldThink = nil
		end
	end
end

function ENT:Draw()
end

local undocolor = false

local function Post()
	if (undocolor) then
		undocolor = false
		render.SetColorModulation(1, 1, 1)
	end
end

-- Player
hook.Add("PrePlayerDraw", "CRYO_PrePlayerDraw", function(ply)
	if (ply.m_bIsFrozen) then
		undocolor = true
		render.SetColorModulation(0, 3, 3)
	end
end)

hook.Add("PostPlayerDraw", "CRYO_PostPlayerDraw", function(ply)
	Post()
end)

-- Viewmodel
hook.Add("PreDrawViewModel", "CRYO_PreDrawViewModel", function(vm, ply, weapon)
	if (!IsValid(ply)) then
		return end

	local e = ply.m_CryoFrozen
	if (!IsValid(e)) then
		return end

	if (IsValid(vm) and e.m_fCycleFreeze) then
		vm:SetCycle(e.m_fCycleFreeze)

		undocolor = true
		render.SetColorModulation(0, 3, 3)
	end
end)

hook.Add("PostDrawViewModel", "CRYO_PostDrawViewModel", function(vm, ply, weapon)
	if (!IsValid(weapon) or (weapon:IsScripted() and !weapon.UseHands)) then
		Post()
	end
end)

hook.Add("PostDrawPlayerHands", "CRYO_PostDrawPlayerHands", function(hands, vm, ply, weapon)
	Post()
end)

-- Other
function CRYO_CantTalk()
	if (CRYOGRENADE_SETTINGS.PrintInChat) then
		chat.AddText(CRYOGRENADE_SETTINGS.ChatMessageColor, CRYOGRENADE_SETTINGS.CantChatMessageContents)
	end
end

hook.Add("PlayerBindPress", "CRYO_PlayerBindPress", function(ply, bind, press)
	if (!CRYOGRENADE_SETTINGS.AllowPlayerVoiceChat and press and string.find(bind, "+voicerecord") and LocalPlayer().m_bIsFrozen) then
		CRYO_CantTalk()
		return true
	end
end)

hook.Add("HUDShouldDraw", "CRYO_HUDShouldDraw", function(h)
	if (h == "CHudWeaponSelection" and LocalPlayer().m_bIsFrozen) then
		return false
	end
end)

hook.Add("RenderScreenspaceEffects", "CRYO_RenderScreenspaceEffects", function()
	if (CRYOGRENADE_SETTINGS.DrawOverlay and LocalPlayer().m_bIsFrozen) then
		DrawMaterialOverlay("overlays/vignette_frozen", 1)
	end
end)