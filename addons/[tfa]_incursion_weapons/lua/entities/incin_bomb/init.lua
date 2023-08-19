 ENT.Type 			= "anim"      
 ENT.PrintName		= "Incinerator"  
 ENT.Author			= "Generic Default"  
 ENT.Contact		= ""  
 ENT.Purpose		= ""  
 ENT.Instructions	= ""  
 
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

if SERVER then

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()  
	self.CanTool = false 

	self.flightvector = self.Entity:GetForward() * ((80*55.5)/100)
	self.timeleft = CurTime() + 1
	self.Owner = self:GetOwner()
	self.Entity:SetModel( "models/weapons/misc/grenaderifle_projectile.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )            
	self.Entity:SetCollisionGroup(1)
	self.Entity:SetColor(Color(255, 90, 0))
	self.Entity:SetMaterial("models/props_combine/portalball001_sheet")
	self.Entity:SetModelScale(1)
	--self.Entity:SetAngles(Angle(90, 0, 0))
	self.InFlight = true

	timer.Simple(0.2, function()
		if IsValid(self) then
			self:Ignite(2, 5)
		end
	end)
end   

 function ENT:Think()

	Table	={} 			//Table name is table name
	Table[1]	=self.Owner 		//The person holding the gat
	Table[2]	=self.Entity 		//The cap

	local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + self.flightvector
		trace.filter = Table
	local tr = util.TraceLine( trace )
			if tr.HitSky then
				self.Entity:Remove()
				return true
			end
				if tr.Hit and self.InFlight then
					if not (tr.MatType == 70 or tr.MatType == 50) then
						util.BlastDamage(self.Entity, self.Owner, tr.HitPos, 200, 100) 
						local effectdata = EffectData()
						effectdata:SetOrigin(tr.HitPos)			// Where is hits
						effectdata:SetNormal(tr.HitNormal)		// Direction of particles
						effectdata:SetEntity(self.Entity)		// Who done it?
						effectdata:SetScale(1)			// Size of explosion
						effectdata:SetRadius(tr.MatType)		// What texture it hits
						effectdata:SetMagnitude(14)			// Length of explosion trails
						util.Effect( "Explosion", effectdata )
						util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
					self.Entity:Remove()
					else
						if (tr.Entity:IsPlayer() or tr.Entity:IsNPC()) then tr.Entity:TakeDamage(165, self.Owner, self.Entity)	end
						local effectdata = EffectData()
						effectdata:SetOrigin(tr.HitPos)			// Where is hits
						effectdata:SetNormal(tr.HitNormal)		// Direction of particles
						effectdata:SetEntity(self.Entity)		// Who done it?
						effectdata:SetScale(1)			// Size of explosion
						effectdata:SetRadius(tr.MatType)		// What texture it hits
						effectdata:SetMagnitude(10)			// Length of explosion trails
						util.Effect( "Explosion", effectdata )
						self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
						self.Entity:SetPos(tr.HitPos)
						local phys = self.Entity:GetPhysicsObject()
						phys:Wake()
						phys:SetMass(3)
						self.InFlight = false
						self:Remove()
					end
	
				end
	if CurTime() > self.timeleft then
		self:Explosion()
	end
				
	if self.InFlight then
		self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
		self.flightvector = self.flightvector - (self.flightvector/350)  + Vector(math.Rand(-0.05,0.05), math.Rand(-0.05,0.05),math.Rand(-0.05,0.05)) + Vector(0,0,-0.591)
		self.Entity:SetAngles(self.flightvector:Angle() + Angle(0,90,0))
	end
	
	self.Entity:NextThink( CurTime() )
	return true
end
 
	function ENT:Explosion()

		util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), 200, 85)
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())			// Where is hits
		effectdata:SetNormal(Vector(0,0,1))		// Direction of particles
		effectdata:SetEntity(self.Entity)		// Who done it?
		effectdata:SetScale(1.3)			// Size of explosion
		effectdata:SetRadius(67)		// What texture it hits
		effectdata:SetMagnitude(14)			// Length of explosion trails
		util.Effect( "Explosion", effectdata )
		self.Entity:Remove()
	end
end
