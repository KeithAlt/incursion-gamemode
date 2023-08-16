AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.Model = "models/fallout/weapons/w_minefrag.mdl"
ENT.Dist = 100

function ENT:Initialize()
	self.Time = CurTime()+1000
	self.ArmTime = CurTime()+2
	self:EmitSound("wep/mine/wpn_mine_arm.wav")
	self:SetModel("models/fallout/weapons/w_minefrag.mdl")
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
		  self:EmitSound("wep/mine/wpn_mine_tick.wav")
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

		if self.Disarmed && !self.Cooldown then
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
	elseif !self.Disarmed && !self.Cooldown then
		self.Disarmed = true
		jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,255,255), "You disarmed the mine!")
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
	local ent = ents.Create( "env_explosion" )
	ent:SetPos( self:GetPos() )
	ent:Spawn()
	ent:SetKeyValue( "iMagnitude", self.Dmg or "150" )
	ent:Fire( "Explode", 0, 0 )
	--
	local effectData = EffectData()
	effectData:SetScale(1)
	effectData:SetOrigin(self:GetPos())
	util.Effect( "effect_fo3_explosion", effectData )
	--
	self:EmitSound( "wep/explode/fx_explosion_grenade0"..math.random(1,3)..".wav", 511, 110, 1, CHAN_AUTO )
	self:Remove()
end

function ENT:ActivateMine()
	if self.Activated then return end
	self.Activated = true
	self.BlowTime = CurTime()+2
end
