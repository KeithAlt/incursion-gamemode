ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Heavy Plate Armor"
ENT.Category		= "Melee Arts 2"

ENT.Spawnable		= true
ENT.AdminOnly = true
ENT.DoNotDuplicate = false

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:Initialize()

	local model = ("models/hunter/tubes/tube1x1x2.mdl")
	
	self.Entity:SetModel(model)
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	self.Entity:SetNoDraw(true)
	
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(500)
	end

	self.Entity:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)

	
	if (activator:IsPlayer()) then
		if ( activator:GetNWBool("MeleeArtArmoredWarrior")==true ) then
			activator:PrintMessage(HUD_PRINTTALK, "You are already wearing this")
		return end
		--activator:GetActiveWeapon():SendWeaponAnim( ACT_VM_DRAW )
		activator:PrintMessage(HUD_PRINTTALK, "You don the heavy armor. You are now unbreakable!")
		activator:PrintMessage(HUD_PRINTTALK, "Remember, as a knight, your greatest weakness is gravity.")
		activator:EmitSound("items/ammopickup.wav")
		activator:SetModelScale(1.2)
		activator:SetNWBool("MeleeArtArmoredWarrior",true)
		activator:SetModel("models/models/danguyen/knight_set.mdl")
		
		self.Entity:Remove()
	end
end

end

if CLIENT then
function ENT:Initialize()
	self.cmodel = ClientsideModel("models/hunter/plates/plate1x1.mdl")
	self.cmodel:SetPos( self:GetPos() + Vector( 0, 0, 0 ))
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 360)
	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Forward(), 0)
	self.cmodel:SetParent( self )
	self.cmodel:SetMaterial("models/props_wasteland/wood_fence01a")
	self.cmodel:SetAngles( ang )
	self.cmodel:SetModelScale( 1,0 )
	self.xmodel = ClientsideModel("models/props_c17/signpole001.mdl")
	self.xmodel:SetPos( self:GetPos() + Vector( 0, 0, 0 ))
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 360)
	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Forward(), 0)
	self.xmodel:SetParent( self )
	self.xmodel:SetAngles( ang )
	self.xmodel:SetMaterial("models/props_wasteland/wood_fence01a")
	self.xmodel:SetModelScale( 0.8,0 )
	self.zmodel = ClientsideModel("models/models/danguyen/knight_set.mdl")
	self.zmodel:SetPos( self:GetPos() + Vector( 0, 0, 2 ))
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 360)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 0)
	self.zmodel:SetParent( self )
	self.zmodel:SetAngles( ang )
	self.zmodel:SetModelScale( 1.2,0 )
end
function ENT:OnRemove()
	self.cmodel:Remove()
	self.xmodel:Remove()
	self.zmodel:Remove()
end

end
print("The vest works!")