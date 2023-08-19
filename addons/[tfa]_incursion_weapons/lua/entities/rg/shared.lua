ENT.Type 		= "anim"
ENT.PrintName	= "Rg"
ENT.Author		= "LeErOy NeWmAn"
ENT.Contact		= ""
ENT.Purpose		= ""
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

/*---------------------------------------------------------
   Name: OnRemove
   Desc: Called just before entity is deleted
---------------------------------------------------------*/
function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)

    local Ent = data.HitEntity

	if data.Speed >= 900 then
		
		util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal) 
		
		self.Entity:Remove()
		
		local explo = ents.Create("env_explosion")
		explo:SetOwner(self.GrenadeOwner)
		explo:SetPos(self.Entity:GetPos())
		explo:SetKeyValue("iMagnitude", "250")
		explo:SetKeyValue("spawnflags", "66")
		explo:Spawn()
		explo:Activate()
		explo:Fire("Explode", "", 0)

		local physExplo = ents.Create( "env_physexplosion" )
		physExplo:SetOwner( self.GrenadeOwner )
		physExplo:SetPos( self.Entity:GetPos() )
		physExplo:SetKeyValue( "Magnitude", "100" )	-- Power of the Physicsexplosion
		physExplo:SetKeyValue( "radius", "500" )	-- Radius of the explosion
		physExplo:SetKeyValue( "spawnflags", "10" )
		physExplo:Spawn()
		physExplo:Fire( "Explode", "", 0.02 )
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		util.Effect( "HelicopterMegaBomb", effectdata )	 -- Big flame

		local shake = ents.Create( "env_shake" )
		shake:SetOwner(self.GrenadeOwner)
		shake:SetPos( self.Entity:GetPos() )
		shake:SetKeyValue( "amplitude", "3500" )	-- Power of the shake
		shake:SetKeyValue( "radius", "900" )	-- Radius of the shake
		shake:SetKeyValue( "duration", "3" )	-- Time of shake
		shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
		shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )
		
		self.Entity:EmitSound("weapons/hegrenade/explode".. math.random(3, 5) .. ".wav", 150)
		
		local en = ents.FindInSphere(self.Entity:GetPos(), 75)
		
		for k, v in pairs(en) do
			if (v:GetPhysicsObject():IsValid()) then
				// Unweld and unfreeze props
				if (math.random(1, 100) < 10) then
					v:Fire("enablemotion", "", 0)
					constraint.RemoveAll(v)
				end
			end
		end
	end
	
end