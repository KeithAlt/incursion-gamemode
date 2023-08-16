AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetHealth(CRYOGRENADE_SETTINGS.IceHealth)

	self.m_fStartTime = CurTime()

	local owner = self:GetOwner()
	if (IsValid(owner) and owner:Alive()) then
		owner.m_CryoFrozen = self
		owner.m_bIsFrozen = true
		owner.m_vFreezePos = owner:GetPos()
		owner:Freeze(true)
		owner:EmitSound("physics/glass/glass_impact_bullet" .. math.random(4) .. ".wav")

		local vm = owner:GetViewModel()
		if (IsValid(vm)) then
			self.m_fCycleFreeze = vm:GetCycle()
			vm:SetPlaybackRate(0)
		end

		local wep = owner:GetActiveWeapon()
		if (IsValid(wep)) then
			self.m_fReloadFreeze = wep:GetSaveTable().m_flNextPrimaryAttack
			wep.m_OldThink = wep.Think
			wep.Think = function() end
		end
	end

	self.m_TrackTrains = ents.FindByClass("func_tracktrain")
end

function ENT:Think()
	local owner = self:GetOwner()
	if !owner:Alive() then self:Remove() end
	if (IsValid(owner) and owner:Alive() and CurTime() <= self.m_fEndTime) then
		if (!owner.m_vFreezePos) then
			owner.m_vFreezePos = owner:GetPos()
		end

		local neartrain = false
		for _, v in pairs (self.m_TrackTrains or {}) do
			if (v:GetPos():Distance(owner:GetPos()) < 128) then
				neartrain = true
				break
			end
		end

		if (!neartrain) then
			owner:SetPos(owner.m_vFreezePos)
		end
		owner:SetLaggedMovementValue(0)
		owner:SetLocalVelocity(vector_origin)

		local vm = owner:GetViewModel()
		if (IsValid(vm) and self.m_fCycleFreeze) then
			vm:SetCycle(self.m_fCycleFreeze)
		end

		local wep = owner:GetActiveWeapon()
		if (IsValid(wep) and self.m_fReloadFreeze) then
			local t = self.m_fReloadFreeze

			wep:SetSaveValue("m_flNextPrimaryAttack", t)
			wep:SetSaveValue("m_flNextSecondaryAttack", t)
		end
	else
		self:Remove()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if (IsValid(owner)) then
		owner.m_CryoFrozen = nil
		owner.m_bIsFrozen = false
		owner:SetLaggedMovementValue(1)
		owner:Freeze(false)
		owner:EmitSound("physics/glass/glass_largesheet_break" .. math.random(3) .. ".wav")

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

hook.Add("CanPlayerSuicide", "CRYO_CanPlayerSuicide", function(ply, dmginfo)
	if (ply.m_bIsFrozen and !CRYOGRENADE_SETTINGS.AllowFreezeSuicide) then
		return false
	end
end)

hook.Add("EntityTakeDamage", "CRYO_EntityTakeDamage", function(ply, dmginfo)
	local e = ply.m_CryoFrozen
	if (IsValid(e)) then
		if (e:Health() > 0) then
			e:SetHealth(e:Health() - dmginfo:GetDamage())

			if (e:Health() <= 0) then
				e:Remove()
			end
		end
	end
end)

hook.Add("PostPlayerDeath", "CRYO_PostPlayerDeath", function(ply)
	if (CRYOGRENADE_SETTINGS.ExplodeOnDeath and engine.ActiveGamemode() ~= "terrortown" and ply.m_bIsFrozen) then
		local eff = EffectData()
		eff:SetOrigin(ply:GetPos())
		eff:SetEntity(ply)
		util.Effect("cryo_death", eff, true, true)

		SafeRemoveEntity(ply:GetRagdollEntity())
	end
end)

hook.Add("PlayerSay", "CRYO_PlayerSay", function(ply, text, teamchat)
	if (!CRYOGRENADE_SETTINGS.AllowPlayerTextChat and ply.m_bIsFrozen) then
		ply:SendLua("CRYO_CantTalk()")
		return ""
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "CRYO_PlayerCanHearPlayersVoice", function(listener, talker)
	if (!CRYOGRENADE_SETTINGS.AllowPlayerVoiceChat and talker.m_bIsFrozen) then
		return false
	end
end)