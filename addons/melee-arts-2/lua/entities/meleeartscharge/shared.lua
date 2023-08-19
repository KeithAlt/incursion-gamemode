ENT.Type = "anim"
ENT.PrintName			= "Explosive Charge"
ENT.Author			= "danguyen"
ENT.Contact			= "sdfgsdfgsg"
ENT.Purpose			= "sdfgdfsgsdfgsdfg"
ENT.Instructions			= "sdfgsdfgsdfgfdsg"

include( "autorun/meleewoundautorun.lua" )

if SERVER then
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner
	
	self.Entity:SetModel("models/models/danguyen/cxdemoblock.mdl")
	self.Entity:SetHealth( 10 )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( true )
	--self.Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	self.Entity:SetNWBool("debounce",false)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(2)
		phys:AddAngleVelocity(phys:GetAngleVelocity()+Vector(0,1000,0))
	end
	self.timeleft = CurTime() + 5
	self.beep = CurTime() + 2
	self:Think()

end

 function ENT:Think()
	
	if self.timeleft < CurTime() and self.Entity:GetNWBool("debounce") == false then
		self:kaboom()	
		self.Entity:SetNWBool("debounce",true)
	end
	
	if self.beep < CurTime() and self.Entity:GetNWBool("debounce") == true then
		self.Entity:EmitSound( "ambient/levels/prison/radio_random4.wav")
		local effectdata = EffectData() 
		effectdata:SetOrigin( self:GetPos() ) 
		effectdata:SetNormal( self:GetPos():GetNormal() ) 
		effectdata:SetEntity( self ) 	
		util.Effect( "bombbeep", effectdata )
		self.beep = CurTime() + 2
	end
	
	if self.Entity:GetNWBool("activated") == true then
		for k,v in pairs(ents.FindInSphere(self:GetPos(),100)) do
			if v:IsValid() and v:IsNPC() then
				self.Entity:kaboom2()
			elseif v:IsValid() and v:IsPlayer() then
				self.Entity:kaboom2()
			end
		end
	end	
	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:OnTakeDamage(dmg)
	local effectdata = EffectData() 
	effectdata:SetOrigin( self:GetPos() ) 
	effectdata:SetNormal( self:GetPos():GetNormal() ) 
	effectdata:SetEntity( self ) 
	util.Effect( "cball_explode", effectdata ) 
	self.Entity:Remove()
end

function ENT:kaboom()
	self.Entity:SetNWBool("activated",true)
	self.Entity:EmitSound( "weapons/slam/mine_mode.wav" )
	local effectdata = EffectData() 
	effectdata:SetOrigin( self:GetPos() ) 
	effectdata:SetNormal( self:GetPos():GetNormal() ) 
	effectdata:SetEntity( self ) 
	util.Effect( "bombarm", effectdata ) 
	self.beep = CurTime() + 2
	--self.Entity:Remove()
end

function ENT:kaboom2()
	self.Entity:SetNWBool("activated",true)
	local effectdata = EffectData() 
	effectdata:SetOrigin( self:GetPos() ) 
	effectdata:SetNormal( self:GetPos():GetNormal() ) 
	effectdata:SetEntity( self ) 	
	util.Effect( "Explosion", effectdata )
	util.BlastDamage(self.Entity, self.Owner, self:GetPos(), 200, 150)
	util.ScreenShake( self.Entity:GetPos(), 500, 300, 4.5, 200 )
	for k,v in pairs(ents.FindInSphere(self:GetPos(),200)) do
		if v:IsValid() and v:IsPlayer() then
			chance = math.ceil(10*(1/(v:GetMaxHealth()/v:Health()))*3/5)
			MAWoundage:AddStatus(v, self.Entity:GetOwner(), "cripple", chance)
		end
	end
	--self.Entity:EmitSound( "physics/glass/glass_bottle_break2.wav" )		
	self.Entity:Remove()
end

function ENT:PhysicsCollide(data,phys)

	if data.Speed > 50 then
		self.Entity:EmitSound("physics/plastic/plastic_box_impact_hard1.wav")
	end
	
end

end

--[[if CLIENT then
function ENT:Initialize()
		self.cmodel = ClientsideModel( "models/props_junk/garbage_metalcan001a.mdl" )
		self.cmodel:SetPos( self:GetPos() )
					local ang = self:GetAngles()
			        ang:RotateAroundAxis(ang:Right(), 0)
			        ang:RotateAroundAxis(ang:Up(), 90)
				    ang:RotateAroundAxis(ang:Forward(), 0)
		self.cmodel:SetParent( self )
		self.cmodel:SetAngles( ang )
		
end

function ENT:OnRemove()
	self.cmodel:Remove()
end

function ENT:Draw()
end
end]]--
