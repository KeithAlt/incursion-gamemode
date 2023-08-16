ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= ".308 Ammo"
ENT.Category		= "Fallout Ammo"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:SpawnFunction(ply, tr)

	if (!tr.Hit) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create("308Ammo")
	
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	ent.Planted = false
	
	return ent
end


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	local model = ("models/items/BoxSRounds.mdl")
	
	self.Entity:SetModel(model)
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.Entity:SetUseType(SIMPLE_USE)
end


/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide(data, physobj)
	
	// Play sound on bounce
	if (data.Speed > 80 and data.DeltaTime > 0.2) then
		self.Entity:EmitSound("Default.ImpactSoft")
	end
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmginfo)

	// React physically when shot/getting blown
	self.Entity:TakePhysicsDamage(dmginfo)
end


/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use(activator, caller)

	if (activator:IsPlayer()) and not self.Planted then
		// Give the collecting player some free health
		activator:GiveAmmo(50, "308")
		self.Entity:Remove()
	end
	
end

end

if CLIENT then

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
end

/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	
	self.Entity:DrawModel()
	
	local ledcolor = Color(230, 45, 45, 255)

  	local TargetPos = self.Entity:GetPos() + (self.Entity:GetUp() * 4) + (self.Entity:GetRight() * -2.5) + (self.Entity:GetForward() * -3.3)//-1.2

	local FixAngles = self.Entity:GetAngles()
	local FixRotation = Vector(48, -90, 0)
	
	FixAngles:RotateAroundAxis(FixAngles:Right(), FixRotation.x)
	FixAngles:RotateAroundAxis(FixAngles:Up(), FixRotation.y)
	FixAngles:RotateAroundAxis(FixAngles:Forward(), FixRotation.z)

	self.Text = "308Ammo"
	
	cam.Start3D2D(TargetPos, FixAngles, .07)
		draw.SimpleText(self.Text, "DermaLarge", 31, -22, ledcolor, 1, 1)
	cam.End3D2D()
end

end