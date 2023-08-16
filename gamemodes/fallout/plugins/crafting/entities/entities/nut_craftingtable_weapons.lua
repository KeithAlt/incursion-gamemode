AddCSLuaFile()

ENT.Type 				= "anim"
ENT.PrintName 			= "Weapon Bench"
ENT.Author 				= "Vex"
ENT.Category 			= "NutScript : Crafting"
ENT.Spawnable 			= true
ENT.AdminSpawnable	 	= true
ENT.AdminOnly			= true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/mosi/fallout4/furniture/workstations/weaponworkbench01.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Wake()
		end;
	end;

	function ENT:Use(activator)
		self.nextUse = self.nextUse or CurTime()
		if (self.nextUse > CurTime()) then
			return
		else
			self.nextUse = CurTime() + 2
		end;

		nut.crafting.open(activator, "weapons")
	end;
end;
