AddCSLuaFile()

ENT.Type 				= "anim"
ENT.PrintName 			= "Broadcaster"
ENT.Author 				= "Vex"
ENT.Category 			= "NutScript"
ENT.Spawnable 			= true
ENT.AdminSpawnable	 	= true
ENT.AdminOnly			= true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_lab/citizenradio.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Wake()
		end;
	end;
end;