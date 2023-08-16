AddCSLuaFile()

ENT.Type 						= "anim"
ENT.PrintName 			= "Armor Modding Table"
ENT.Author 					= "Vex"
ENT.Category 				= "NutScript : Crafting"
ENT.Spawnable 			= true
ENT.AdminSpawnable	= true
ENT.AdminOnly				= true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/mosi/fallout4/furniture/workstations/weaponworkbench02.mdl")
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
		end

		if (activator:getChar():getArmorJ()) then
			local items = {}
			for i, v in pairs(activator:getChar():getInv():getItems()) do
				items[v.uniqueID] = true
			end
			netstream.Start(activator, "nutArmorModOpen", items, activator:getChar():getArmorJ().type)
		else
			activator:ChatPrint("Equip the armor you are modding before using the bench.")
		end
	end
end
