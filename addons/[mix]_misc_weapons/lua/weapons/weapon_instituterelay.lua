if SERVER then
	concommand.Add("instituterelay_setpoint",function(ply) -- Teleport kidnap position data
		local tppoints = file.Read("institutecapturepoint.txt","DATA")
		if not tppoints or string.len(tppoints) <= 0 then tppoints = "" end
		local tpTable = util.JSONToTable(tppoints)
		if not tpTable then tpTable = {} end

		tpTable[game.GetMap()] = ply:GetPos()
		file.Write("institutecapturepoint.txt",util.TableToJSON(tpTable))
	end)

	concommand.Add("instituteexit_setpoint",function(ply) -- Teleport release position data
		local tppoints = file.Read("instituteexitpoint.txt","DATA")
		if not tppoints or string.len(tppoints) <= 0 then tppoints = "" end
		local tpTable = util.JSONToTable(tppoints)
		if not tpTable then tpTable = {} end

		tpTable[game.GetMap()] = ply:GetPos()
		file.Write("instituteexitpoint.txt",util.TableToJSON(tpTable))
	end)

	function InstituteGetRelayPPos() -- Teleport capture position data
		local fl = file.Read("institutecapturepoint.txt","DATA")
		if not fl or string.len(fl) <= 0 then return end
		local tpTable = util.JSONToTable(fl)
		if not tpTable then return end
		if not tpTable[game.GetMap()] then return end

		return tpTable[game.GetMap()]
	end
	function InstituteGetExitPPos() -- Teleport release position data
		local fl = file.Read("instituteexitpoint.txt","DATA")
		if not fl or string.len(fl) <= 0 then return end
		local tpTable = util.JSONToTable(fl)
		if not tpTable then return end
		if not tpTable[game.GetMap()] then return end

		return tpTable[game.GetMap()]
	end
end

AddCSLuaFile()

SWEP.Author 		= "Claymore Gaming"
SWEP.Purpose		= "Teleportation Utility Equipment"
SWEP.Category	    = "Claymore Gaming"
SWEP.Instructions	= "LMB Teleport Victim\nRMB Free victim"

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false

SWEP.PrintName		= "Institute Abduction Relay"
SWEP.Slot			= 0
SWEP.SlotPos		= 0
SWEP.HoldType		= "passive"
SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.AttackDelay	= 8
SWEP.ISCourser 			= true
SWEP.droppable		= false
SWEP.NextAttackW	= 0
SWEP.IsAlwaysLowered = true
SWEP.FireWhenLowered = true
SWEP.NextAttackSPCL = 0.25


function SWEP:Deploy()
	if not IsFirstTimePredicted() then return end
	self.Owner:ChatPrint("[ REMINDER ]  LMB : Kidnap // RMB: Release")
end

function SWEP:DrawWorldModel()
end

function SWEP:Initialize()
end

function SWEP:Reload()
end

function SWEP:HUDShouldDraw( element )
	local hide = {
		CHudAmmo = true,
		CHudSecondaryAmmo = true,
	}
	if hide[element] then return false end
	return true
end


function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	local ent = self.Owner:GetEyeTrace().Entity
	if (!IsValid(ent)) then return end
	if (!ent:IsPlayer()) then return end

	if SERVER then
		self.Owner:ChatPrint("[ ! ]  Preparing to release")
	end
	self.NextAttackW = CurTime() + self.AttackDelay
	ParticleEffectAttach( "mr_cop_anomaly_electra_a", 1, self, 1 )
	self:EmitSound("npc/scanner/scanner_electric2.wav")
	self.Owner:EmitSound("ambient/levels/labs/teleport_weird_voices1.wav")

	local entFoV = ent:GetFOV()
	ent:SetFOV(60, 3)

	timer.Simple(2.9, function()
		self:StopParticles()
		self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	end)

	timer.Simple(3, function()
		if !IsValid(self.Owner:GetEyeTrace().Entity) then return end
		ParticleEffectAttach( "_sai_wormhole", 1, self, 1 )
		ParticleEffect("_sai_wormhole", self:GetPos(), self:GetAngles(), self)
	end)

	timer.Simple(5, function()
		self:StopParticles()
	end)

	timer.Simple(5, function()
		if SERVER then
			if not (ent:GetPos():Distance(self.Owner:GetPos()) < 150) then
				self:EmitSound("npc/roller/mine/rmine_explode_shock1.wav")
				self.Owner:falloutNotify("[!] You are not close enough to your target!", "ui/notify.mp3")
				return
			end
			if not ent:IsPlayer() then return end
			local weapon = ent:GetActiveWeapon()
			if weapon and weapon.ISCourser then return end

			local tppos = InstituteGetExitPPos()
			if not tppos then return end
			ent:falloutNotify("You have been released . . .", "ui/notify.mp3")
			ent:SetPos(tppos)
			ent:SetFOV( entFoV, 0.1 )
		end
	end)
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.NextAttackW > CurTime() then return end
	self.NextAttackW = CurTime() + self.AttackDelay
	if SERVER then
		self.Owner:ChatPrint("[ ! ]  Preparing to adbuct")
	end

	local ent = self.Owner:GetEyeTrace().Entity
	if (!IsValid(ent)) then return end
	if (!ent:IsPlayer()) then return end

	if not (ent:GetPos():Distance(self.Owner:GetPos()) < 150) then
		self:EmitSound("npc/roller/mine/rmine_explode_shock1.wav")
			self.Owner:falloutNotify("[!] You are not close enough to your target!", "ui/notify.mp3")
		return
	end

	--particle/warp4_warp - particle/warp_ripple

	ParticleEffectAttach( "mr_cop_anomaly_electra_a", 1, self, 1 )
	self:EmitSound("npc/scanner/scanner_electric2.wav")
	self.Owner:EmitSound("ambient/levels/labs/teleport_weird_voices1.wav")

	local entFoV = ent:GetFOV()
	ent:SetNWBool("IsBeingAbudcted", true)
	ent:SetFOV(50, 3)
	ent:Freeze(true)


	timer.Simple(2.9, function()
		self:StopParticles()
		self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	end)

	timer.Simple(3, function()
		ent:SetNWBool("IsBeingAbudcted", false)
		if !IsValid(self.Owner:GetEyeTrace().Entity) then return end
		ParticleEffectAttach( "_sai_wormhole", 1, self, 1 )
		ParticleEffect("_sai_wormhole", self:GetPos(), self:GetAngles(), self)
	end)

	timer.Simple(5, function()
		self:StopParticles()
	end)
	timer.Simple(5, function()
		if SERVER then
			local weapon = ent:GetActiveWeapon()
			if weapon and weapon.ISCourser then return end

			local tppos = InstituteGetRelayPPos()
			if not tppos then return end
			ent:falloutNotify("You have been taken . . .", "ui/notify.mp3")
			ent:SetPos(tppos)
			if entFoV < 75 then entFoV = 75 end -- prevent them from glithcing out in case they are scoped in when being abducted.
			ent:SetFOV( entFoV , 0.1 )
			ent:Freeze(false)
			ParticleEffect("explosion_huge_d", ent:GetPos(), Angle(0,90), self.Owner)
		end
	end)
end

function SWEP:Reload()
	if (self.NextAttackSPCL > CurTime()) then return end
	self.NextAttackSPCL = CurTime() + 0.25

	self.Owner:SetNWBool("IsBeingAbudcted", false)

	local pos = self.Owner:GetEyeTrace().HitPos
	if SERVER then
		local strikePosition = ents.Create("prop_physics") -- Give me mercy please // requires rewrite by Dev
		strikePosition:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		strikePosition:SetMoveType(MOVETYPE_NONE)
		strikePosition:SetRenderMode(RENDERMODE_NONE)
		strikePosition:DrawShadow(false)
		strikePosition:SetPos(pos + Vector(0,0,5))
		strikePosition:Spawn()
		strikePosition:SetNotSolid(true)
		strikePosition:EmitSound("cuszsda/spl.wav")

		strikePositionPhysics = strikePosition:GetPhysicsObject()
		strikePositionPhysics:EnableMotion(false)

		timer.Simple(1, function()
			strikePosition:EmitSound("cuszsda/explo.wav", 100, 110)
			strikePosition:Remove()
			util.BlastDamage(self.Owner, self, pos, 1000, 125)
			self.Owner:StopParticles()
		end)
	end

	ParticleEffect("super_turret", pos, Angle(0,90), self.Owner)

	timer.Simple(0.5, function()
		ParticleEffect("explosion_huge_d", pos, Angle(0,90), self.Owner)
		ParticleEffect("super_exp", pos, Angle(0,90), self.Owner)
		util.ScreenShake(pos, 35, 100, 2, 800)
	end)
end
