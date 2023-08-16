ENT.Type = "anim"
ENT.PrintName			= "Firecracker"
ENT.Author			= "danguyen"
ENT.Contact			= "sdfgsdfgsg"
ENT.Purpose			= "sdfgdfsgsdfgsdfg"
ENT.Instructions			= "sdfgsdfgsdfgfdsg"

if SERVER then
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner
	
	self.Entity:SetModel("models/models/danguyen/mj_dbd_firecracker.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( true )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	self.Entity:SetModelScale(2)
	self.Entity:SetNWBool("debounce",false)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	phys:SetMass(5)
	end
	if self.Entity:GetNWBool("MAinstantdetonate") == false then
		self.timeleft = CurTime() + 2
	else
		self.timeleft = CurTime() + 0
	end
	self:Think()
	
	sound.Add( {
		name = "fuseburn",
		channel = CHAN_STATIC,
		volume = 0.2,
		level = 80,
		pitch = { 150 },
		sound = "weapons/flaregun/burn.wav"
	} )
	self.Entity:EmitSound("fuseburn")

end

 function ENT:Think()
	
	if self.timeleft < CurTime() and self.Entity:GetNWBool("debounce") == false then
		self:kaboom()	
		self.Entity:SetNWBool("debounce",true)
	end
	



	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:kaboom()
	self.Entity:StopSound("fuseburn")
	local effectdata = EffectData() 
	effectdata:SetOrigin( self:GetPos() ) 
	effectdata:SetNormal( self:GetPos():GetNormal() ) 
	effectdata:SetEntity( self ) 
	util.Effect( "cball_explode", effectdata ) 	
	util.Effect( "cball_bounce", effectdata ) 	
	util.Effect( "firecrackerexplode", effectdata )
	self.Entity:EmitSound( "firecrackaz.wav", 80 )		
	util.ScreenShake( self.Entity:GetPos(), 500, 300, 4.5, 200 )
	for k,v in pairs(ents.FindInSphere(self:GetPos(),140)) do
		if v:IsValid() and v:IsNPC() then
			v:LostEnemySound()
			v:ClearEnemyMemory()
			v:SetCondition( 11 )
			v:SetSchedule( 40 )
		elseif v:IsValid() and v:IsPlayer() then
			local wep = v:GetActiveWeapon()
			wepCheck = string.find( wep:GetClass(), "meleearts" )
			v:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255 ), 0.8, 0 )
			v:EmitSound("vo/npc/male01/pain09.wav")
			v:ViewPunch( Angle( -40, 0, 0 ) )
			if wepCheck then
				wep.NextStun = CurTime() + 3
			end
		end
			
	end
	
	self.Entity:Remove()
end

function ENT:PhysicsCollide(data,phys)

	if data.Speed > 50 then
		self.Entity:EmitSound("physics/cardboard/cardboard_box_impact_hard7.wav")
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
