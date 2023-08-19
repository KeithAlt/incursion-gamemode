/**ENT.Type = "anim"
ENT.Base = "nut_switcher"
ENT.PrintName = "Switcher Example"
ENT.Author = "Chancer"
ENT.Spawnable = false -- Set to false as this is just an example
ENT.AdminOnly = true
ENT.Category = "Switcher Entities"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.name = "Model Switcher"
ENT.model = "models/props_canal/bridge_pillar02.mdl" --model of the entity
--ENT.nsfaction = "" --faction that it switches you to
--ENT.nsclass = "" --class that it switches you to (only works if in correct faction)
ENT.nsmodel = "models/Barney.mdl" --model that it switches you to
ENT.TransformTime = 1 --how long it takes to transform
ENT.NotifDescription = "Do you want to switch models?" --confirmation message

function ENT:Initialize()
	if(SERVER) then
		self:SetModel(self.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local pos = self:GetPos()

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(false)
			physicsObject:Sleep()
		end
	end
end
