AddCSLuaFile()

SWEP.PrintName = "Crimson Hands (Death)"
SWEP.Category = "Other"
SWEP.Author = "Keith"
SWEP.Purpose = "Hands of chaos, do not use unless told to"
SWEP.Instructions = "LMB - Madness // RMD - Decapitation // R - Spooky FX"

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/v_hands.mdl" )
SWEP.WorldModel = Model( "models/lazarusroleplay/headgear/m_fullhats01.mdl" )
SWEP.ViewModelFOV = 75
SWEP.DrawCrosshair 	= true
SWEP.UseHands = true
SWEP.ShowWorldModel = false
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false
SWEP.IsAlwaysLowered = true
SWEP.FireWhenLowered = true

function SWEP:PrimaryAttack()
	if !self.Owner:IsSuperAdmin() then
		self.Owner:ChatPrint("[ MSG FROM KETIH ]  You are trying to use something you shouldn't be. Don't go out looking for trouble or you will find it.")
		return
	end

	local ent = self.Owner:GetEyeTrace().Entity

	if ent and ent:IsPlayer() == true and !ent.inhell and SERVER then
		ent:ConCommand("dronesrewrite_do_hell")
		self.Owner:ChatPrint("[ ! ] " .. ent:Nick() .. " has been put into madness")
		ent.inhell = true

		timer.Simple(30, function()
			if IsValid(ent) then
				ent.inhell = nil
			end
		end)
	end
end

function SWEP:SecondaryAttack()
	if !self.Owner:IsSuperAdmin() then
		self.Owner:ChatPrint("[ MSG FROM KETIH ]  You are trying to use something you shouldn't be. Don't go out looking for trouble or you will find it.")
		return
	end

	local owner = self:GetOwner()

	owner:SetLagCompensated(true)

	if SERVER and IsFirstTimePredicted() then
		local target = owner:GetEyeTrace().Entity

		if IsValid(target) and target:IsPlayer() then
			owner:ChatPrint("[ ! ] " .. ent:Nick() .. " decapitated!")
			Dismemberment.QuickDismember(target, HITGROUP_HEAD, owner)
		end
	end

	owner:SetLagCompensated(false)
end

function SWEP:Reload()
	if !self.Owner:IsSuperAdmin() then
		self.Owner:ChatPrint("[ MSG FROM KETIH ]  You are trying to use something you shouldn't be. Don't go out looking for trouble or you will find it.")
		return
	end

	if self.Owner:KeyDown(IN_USE) and !self.phaseondown then -- Brad, if you're looking at this: I'm so sorry
			self.Owner:SetNotSolid(true)
			self.Owner:ChatPrint("[ ! ] Phase mode ON")
			self.phaseondown = true

			timer.Simple(3, function()
				self.phaseondown = nil
			end)
	return end
	if self.Owner:KeyDown(IN_WALK) and !self.phaseoffdown then
			self.Owner:SetNotSolid(false)
			self.Owner:ChatPrint("[ ! ] Phase mode OFF")
			self.phaseoffdown = true

			timer.Simple(3, function()
				self.phaseoffdown = nil
			end)
	return end
	if !self.soundcooldown then
		self.Owner:EmitSound("ambient/creatures/town_scared_breathing1.wav")
	end
	if !self.Owner:KeyDown(IN_USE) and !self.Owner:KeyDown(IN_WALK) then
		util.ScreenShake( self.Owner:GetPos(), 5, 5, 1, 500 )
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetPos() + Vector( 0, 0, 65 ) )
		effectdata:SetNormal( self.Owner:GetPos():GetNormal() )
		effectdata:SetEntity( self.Owner )
		util.Effect( "darkenergyshit", effectdata )
		self.soundcooldown = true

		timer.Simple(3, function()
			self.soundcooldown = nil
		end)
	end
end

/**function SWEP:IdleSound()
end**/

