AddCSLuaFile()

ENT.Type 						= "anim"
ENT.PrintName 			= "Dynamic Loot Container"
ENT.Author 					= "Vex"
ENT.Category 				= "NutScript"
ENT.Spawnable 			= false
ENT.AdminSpawnable	= false
ENT.AdminOnly				= true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/cardboard_box001a.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
			physObj:EnableMotion(false)
		end;
	end;

	function ENT:Use(activator)
		self.nextUse = self.nextUse or CurTime()
		if (self.nextUse > CurTime()) then
			return
		else
			self.nextUse = CurTime() + 1
		end;

		if (!self:getNetVar("items", nil) and !self:getNetVar("generated", false)) or ((self.lastGenerated or 0) + 780 <= CurTime() and #self:getNetVar("items", {}) == 0) then
			self.lastGenerated = CurTime()
			nut.looter.generate(activator, self)
			self:setNetVar("generated", true) -- Items should be reading as an empty table when all items have been taken but it is not.
		else
			netstream.Start(activator, "looterUI", self)
		end;
	end;
end;
