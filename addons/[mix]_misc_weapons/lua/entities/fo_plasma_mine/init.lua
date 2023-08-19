AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.Model = "models/halokiller38/fallout/weapons/mines/plasmamine.mdl"
ENT.Dist = 100

function ENT:Initialize()
	self.Time = CurTime()+1000
	self.ArmTime = CurTime()+2
	self:EmitSound("wep/mine/wpn_mine_arm.wav", 75, 80)
	self:SetModel(self.MODEL or "models/halokiller38/fallout/weapons/mines/plasmamine.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit( SOLID_VPHYSICS )
end

function ENT:Think()
	if CurTime() <= self.ArmTime then return end
	  if self.Activated then
	    if CurTime() >= self.BlowTime then
		  self:ExplodeMine()
		return end
		self.NextBeep = self.NextBeep or CurTime()-1
		if self.NextBeep <= CurTime() && self.Disarmed == false or self.Disarmed == nil then
		  self:EmitSound("wep/mine/wpn_mine_tick.wav", 75, 80)
		  self.NextBeep = CurTime()+0.1
		end
	  return end
	  if CurTime() >= self.Time then
	    self:ActivateMine()
		return
	  end
	  for k,v in pairs(ents.FindInSphere(self:GetPos(),self.Dist)) do
	    if v:IsPlayer() or v:IsNPC() or v:GetClass():find("npc") then
		--if v:GetPos():Distance(self:GetPos()) <= self.Dist then
		  self:ActivateMine()
		end
	end
end

function ENT:Use(ply)
	if self.Cooldown or self.NextUse and self.NextUse >= CurTime() then return end
		local dist = ply:GetPos():Distance(self:GetPos())

	  if dist > (self.Dist*.75) then
	    self.NextUse = CurTime()+0.2
	  return end

		if self.Disarmed == true && !self.Cooldown then
			self.Time = CurTime()+120
			self.ArmTime = CurTime()+4
			self:ActivateMine()
			self:EmitSound("wep/mine/wpn_mine_arm.wav")
			self.Disarmed = false
			ply:falloutNotify("☑ You have re-activated the mine", "ui/badkarma.ogg")
			self.Cooldown = true

			for i=1, 25 do
				timer.Simple(i/8, function()
					if !IsValid(self) then return end
					self:EmitSound("wep/mine/wpn_mine_tick.wav")
				end)
		end
	elseif self.Disarmed == false or self.Disarmed == nil && !self.Cooldown then
		self.Disarmed = true
		ply:falloutNotify("☑ You have disarmed the mine", "ui/goodkarma.ogg")
		self:EmitSound("wep/mine/wpn_mine_disarm.wav")
		self.Cooldown = true
 end
--
timer.Simple(3, function()
		if !IsValid(self) then return end
		self.Cooldown = nil
	end)
end

function ENT:Touch(ent)
	if self.Disarmed or CurTime() <= self.ArmTime or ent:IsWorld() then return end
	self:ExplodeMine()
end

function ENT:OnTakeDamage()
	self:ExplodeMine()
end

function ENT:SetDmg(dmg)
	self.Dmg = dmg
end

function ENT:ExplodeMine()
	if self.Exploded or self.Disarmed then return end

	self.Exploded = true

	util.BlastDamage(self, self, self:GetPos(), 300, 125)
	util.ScreenShake(self:GetPos(), 25, 25, 1, 1500)

	ParticleEffect("pgex*", self:GetPos(), self:GetAngles(), NULL)
	ParticleEffect("_sai_green_fire_3", self:GetPos(), self:GetAngles(), self)

	self:EmitSound("weapons/plasmagrenade/plasma_grenade_explosion.ogg")

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1500)) do
		if v:IsPlayer() and v:Alive() and v:GetMoveType() ~= MOVETYPE_NOCLIP then
			v:ScreenFade(SCREENFADE.IN, Color(0,255,0, 55), 0.5, 0.5)

			if v:GetPos():Distance(self:GetPos()) < 500 then
				v:Ignite(6)
			end
		end
	end

	self:Remove()
end

function ENT:ActivateMine()
	if self.Activated then return end
	self.Activated = true
	self.BlowTime = CurTime()+2
end
