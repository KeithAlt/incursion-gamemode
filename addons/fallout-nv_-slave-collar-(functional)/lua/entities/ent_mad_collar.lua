AddCSLuaFile()
ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Slave Collar"
ENT.Author			= "Xaxidoro"
ENT.Information		= ""
ENT.Category		= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Attach 			= nil
ENT.KillTime		= 0
if SERVER then
	/*---------------------------------------------------------
	   Name: Initialize
	---------------------------------------------------------*/
	function ENT:Initialize()
		// Use the helibomb model just for the shadow (because it's about the same size)
		self.Entity:SetModel("models/marvless/slavecollar.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_NOCLIP)
		self.Entity:SetSolid(SOLID_OBB)
		self.Entity:DrawShadow( false )
		self.Entity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self.Entity:SetModelScale( 1.5 )
		
		local phys = self.Entity:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:Wake()
		end
		
	end
	/*---------------------------------------------------------
	   Name: PhysicsCollide
	---------------------------------------------------------*/
	function ENT:PhysicsCollide(data, physobj)
		
	end
	/*---------------------------------------------------------
	   Name: OnTakeDamage
	---------------------------------------------------------*/
	function ENT:OnTakeDamage(dmginfo)
	end
	
	function ENT:Explode()
		local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
			effectdata:SetScale(1)
		util.Effect("Explosion", effectdata)
		util.Effect("HelicopterMegaBomb", effectdata)
		
		self.Attach:TakeDamage( 9999999999, self:GetOwner(), self.Entity )
		util.BlastDamage( self.Entity, self:GetOwner(), self.Entity:GetPos(), 100, 100 )
		self.Entity:Remove()
	end
	
	function ENT:Think()
		if not self.Attach then
			self.Entity:Remove()
		end		if self.Attach:IsPlayer() then
			if not self.Attach:Alive() then
				self.Entity:Remove()
			end		end
		
		if self.Attach:GetPos():Distance( self:GetOwner():GetPos() ) > ( self:GetOwner().SlaveDetonateDist or 400 ) then
			if not timer.Exists( self.Entity:EntIndex().."collar" ) then
				timer.Create( self.Entity:EntIndex().."collar", 1, 5, function()
					if not IsValid( self ) or not IsValid( self.Attach ) then
						return
					end
					if self.Attach:GetPos():Distance( self:GetOwner():GetPos() ) > 400 then
						self.KillTime = self.KillTime + 1
						self.Entity:EmitSound("slavecollar/beep.wav",85)
						if self.KillTime >= 5 then
							self:Explode()
						end
					else
						timer.Remove( self.Entity:EntIndex().."collar" )
						self.KillTime = 0
					end
				end )
			end
		else
		
		end
		
	end
	
end
if CLIENT then
	/*---------------------------------------------------------
	   Name: Initialize
	---------------------------------------------------------*/
	function ENT:Initialize()
		self.Entity:SetPredictable( false )
	end
	/*---------------------------------------------------------
	   Name: DrawPre
	---------------------------------------------------------*/
	function ENT:Draw()
		
		self.Entity:DrawModel()
	end
	
end
function ENT:OnRemove()
	if SERVER then
		self.Attach.slavecollar = nil
		self.Attach:SetNWEntity( "slavecollar", nil )
	end
	if self:GetOwner().Slaves then
		table.RemoveByValue( self:GetOwner().Slaves, self.Attach )
	end
end