ENT.Type 		= "anim"
ENT.PrintName		= "Pulse Grenade"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

if SERVER then

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner

	self.Entity:SetModel("models/halokiller38/fallout/weapons/explosives/stungrenade.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	end
	
	self.timeleft = CurTime() + 3
	self:Think()
	self.CanTool = false
end

 function ENT:Think()
	
	if self.timeleft < CurTime() then
			self:Explosion()
	end

	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:Explosion()

	local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetEntity(self.Entity)
		effectdata:SetStart(self.Entity:GetPos())
		effectdata:SetNormal(Vector(0,0,1))
		util.Effect("m9k_pulse_splode", effectdata)
		
	local scorchstart = self.Entity:GetPos() + ((Vector(0,0,1)) * 5)
	local scorchend = self.Entity:GetPos() + ((Vector(0,0,-1)) * 5)
	
	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), 500, 50)
	util.ScreenShake(self.Entity:GetPos(), 500, 500, 1.25, 500)
	self.Entity:Remove()
	util.Decal("Scorch", scorchstart, scorchend)
end

--[[function ENT:OtherExplosion()

	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), 100, 100)
	util.ScreenShake(self.Entity:GetPos(), 500, 500, 1.25, 500)	
	
	local scorchstart = self.Entity:GetPos() + ((Vector(0,0,1)) * 5)
	local scorchend = self.Entity:GetPos() + ((Vector(0,0,-1)) * 5)

	pos = self.Entity:GetPos() --+Vector(0,0,10)
	
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetEntity(self.Entity)
		effectdata:SetStart(pos)
		effectdata:SetNormal(Vector(0,0,1))
	util.Effect("m9k_pulse_splode", effectdata)
	
	local fire = EffectData()
		fire:SetOrigin(pos)
		fire:SetEntity(self.Owner) //i dunno, just use it!
		fire:SetScale(1)
	util.Effect("m9k_pulse_splode", fire)
	
	for i=1, 30 do 
			
		ouchies = {}
		ouchies.start = pos
		ouchies.endpos = pos + (Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(0,1)) * 64000)
		ouchies.filter = self.Entity
		ouchies = util.TraceLine(ouchies)
		
		if ouchies.Hit then
			local bullet = {}
			bullet.Num 		= 2
			bullet.Src 		= pos			-- Source
			bullet.Dir 		= ouchies.Normal			-- Dir of bullet
			bullet.Spread 	= Vector(.001,.001, 0)			-- Aim Cone
			bullet.Tracer	= 1							-- Show a tracer on every x bullets
			bullet.TracerName = "m9k_effect_mad_penetration_trace"
			bullet.Force	= 100					-- Amount of force to give to phys objects
			bullet.Damage	= 100

			self.Owner:FireBullets(bullet)
			if ouchies.Entity == self.Owner then 
				ouchies.Entity:TakeDamage(100 * math.Rand(.70,1), self.Owner, self.Entity)
			end
		end
	end
	
	self.Entity:Remove()
	util.Decal("Scorch", scorchstart, scorchend)
end
]]--
/*---------------------------------------------------------
PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end
	
	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter(impulse)
	
end

end

if CLIENT then
function ENT:Draw()
	self.Entity:DrawModel()
end
end