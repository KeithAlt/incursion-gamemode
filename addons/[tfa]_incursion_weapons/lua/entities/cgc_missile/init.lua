AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Delay = 10

function ENT:Initialize()
	local mdl = self:GetModel()

	if not mdl or mdl == "" or mdl == "models/error.mdl" then
		self:SetModel("models/fallout/weapons/proj_missile.mdl")
	end

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.SpawnTime = CurTime()

	self.PhysObj = self.Entity:GetPhysicsObject()

	if (self.PhysObj:IsValid()) then
        self.PhysObj:Wake()
	end

	self:SetFriction(self.Delay)
	self.killtime = CurTime() + self.Delay

	timer.Simple(0, function()
		ParticleEffectAttach( "_gunfire_ar2_main", 1, self, 1 )
	end)
end

function ENT:Think()
	if self.killtime < CurTime() then
		self:Explode()

		return false
	end

	self:NextThink(CurTime())

	return true
end

/*---------------------------------------------------------
   Name: ENT:Explode()
---------------------------------------------------------*/
function ENT:Explode()
	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	local dmg = DamageInfo()
	dmg:SetAttacker(self.Owner)
	dmg:SetDamage(self.damage)

	for k, v in ipairs(ents.FindInSphere(self:GetPos(), 300)) do
		if v == self.Owner then dmg:SetDamage(self.damage * 10) end

		v:TakeDamageInfo(dmg)
	end


	// creates sound
	local effectdata = EffectData( )
	effectdata:SetOrigin( self:GetPos( ) ) -- Where is hits
	effectdata:SetNormal( Vector( 0, 0, 1 ) ) -- Direction of particles
	effectdata:SetEntity( self ) -- Who done it?
	effectdata:SetScale( 1.3 ) -- Size of explosion
	effectdata:SetRadius( 67 ) -- What texture it hits
	effectdata:SetMagnitude( 14 ) -- Length of explosion trails
	util.Effect( "Explosion", effectdata )
	
	util.ScreenShake( self:GetPos( ), 10, 5, 1, 3000 )
	ParticleEffect("vj_explosion2", self:GetPos(), Angle(0,0,0), nil)
	self:Remove()
end

/*---------------------------------------------------------
   Name: ENT:PhysicsCollide()
---------------------------------------------------------*/
function ENT:PhysicsCollide(data, physobj)
	util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
	self:Explode()
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 60 then
		--self.killtime = CurTime() - 1
		self:Explode()
	end
end
