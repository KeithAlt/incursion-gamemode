
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.StartHealth = 500

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	
	local ent = ents.Create( "explosive_car" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	
	self.Entity:SetModel( "models/props_vehicles/car004a_physics.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	 
	local phys = self.Entity:GetPhysicsObject()
	
		  if (phys:IsValid()) then
			phys:Wake()
		  end
	self.Entity:SetMaxHealth(self.StartHealth)
	self.Entity:SetHealth(self.StartHealth)
	self.BombActive = true
	self.Smoking = false
	self.Flaming = false
	self.smoke = ents.Create("env_smokestack")
	self.fire  = ents.Create("env_fire")
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
	
	if !self.BombActive then return end
	local particlePos = self.Entity:GetPos() + self.Entity:GetForward() * 55 + self.Entity:GetUp() * 8
	if !self.Smoking then
		if self.Entity:Health() <= (self.StartHealth / 2) then
			self.smoke:SetPos(particlePos)
			self.smoke:SetKeyValue("InitialState", "1")
			self.smoke:SetKeyValue("Speed", "8")
			self.smoke:SetKeyValue("Rate", "5")
			self.smoke:SetKeyValue("StartSize", "15")
			self.smoke:SetKeyValue("EndSize", "30")
			self.smoke:SetKeyValue("JetLength", "35")
			self.smoke:SetKeyValue("SpreadSpeed", "2")
			self.smoke:SetKeyValue("rendercolor", "100 100 100")
			self.smoke:SetKeyValue("renderamt", tostring(math.Clamp(2.5 * self.Entity:Health(), 0, 255)))
			self.smoke:SetKeyValue("SmokeMaterial", "particles/smokey")
			self.smoke:Spawn()
			self.smoke:SetParent(self.Entity)
			self.Smoking = true
		end
	end
	if !self.Flaming then
		if self.Entity:Health() <= (self.StartHealth / 3) then
			if self.Entity and self.Entity:IsValid() then
				self.fire:SetPos(particlePos)
				self.fire:SetKeyValue("startdisabled", "0")
				self.fire:SetKeyValue("health", "15")
				self.fire:SetKeyValue("firesize", "35")
				self.fire:SetKeyValue("fireattack", "2")
				self.fire:SetKeyValue("firetype", "normal")
				self.fire:SetKeyValue("ignitionpoint", "0")
				self.fire:SetKeyValue("damage", "10")
				self.fire:SetKeyValue("spawnflags", "1 + 4 + 128 + 256")
				self.fire:Spawn()
				self.fire:Fire("enable", "", 0)
				self.fire:Fire("startfire", "", 0)
				self.fire:SetParent(self.Entity)
				self.Flaming = false
			end
		end
	end
	
	if dmginfo:IsExplosionDamage() and dmginfo:GetDamage() >= 50 then
		self:Detonate(dmginfo)
	end
	if self.Entity:Health() - dmginfo:GetDamage() <= 0 then
		self:Detonate(dmginfo)
	else
		//self.Entity:TakeDamage(dmginfo:GetDamage(), dmginfo:GetAttacker())
		self.Entity:SetHealth(self.Entity:Health() - dmginfo:GetDamage())
	end
end

function ENT:Detonate(dmginfo)
	self.BombActive = false
	local eplx = ents.Create("env_explosion")
		eplx:SetPos(self.Entity:GetPos())
		eplx:SetKeyValue("iMagnitude", "0")
		eplx:SetOwner(dmginfo:GetAttacker())
		eplx:Spawn()
		eplx:Fire("explode", "", 0)
		eplx:Fire("kill", "", 0)
		
		util.BlastDamage( self.Entity, dmginfo:GetAttacker(), self.Entity:GetPos(), 300, 200 )
		
		local effect = EffectData()
			effect:SetOrigin(self.Entity:GetPos())
			effect:SetScale(5)
		util.Effect("immolate", effect)
		
		self.Entity:SetModel("models/props_vehicles/car005b_physics.mdl")
		
		local phys = self.Entity:GetPhysicsObject()
		phys:ApplyForceCenter( Vector(0,0,phys:GetMass() * 425) )
		phys:AddAngleVelocity( Vector(math.random(-100, 100),math.random(-100, 100),math.random(-100, 100)) )
		
		self.smoke:Fire("kill", "", 0)
		self.fire:Fire("kill", "", 0)
end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:Touch(ent)

end

/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use( activator, caller )

end

function ENT:Think()

end


