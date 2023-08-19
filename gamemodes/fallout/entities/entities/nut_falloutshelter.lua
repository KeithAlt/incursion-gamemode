AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName = "Fallout Shelter"
ENT.Category 	= "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/vex/seventysix/props/falloutshelter.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.rotation = 0

		self.door = ents.Create("prop_physics")
			self.door:SetModel("models/vex/seventysix/props/falloutshelter_door.mdl")
			self.door:SetPos(self:GetPos())
			self.door:SetAngles(self:GetAngles())
			self.door:SetParent(self)
			self.door:DrawShadow(false)
			self.door:Spawn()
			self.door.rotation = 0
			local Dphysics = self.door:GetPhysicsObject()
				Dphysics:EnableMotion(false)
				Dphysics:Sleep()
		self:DeleteOnRemove(self.door)
	end

	function ENT:DoorMove() -- Not the best way but it works.
		local time = 2
		local interval = 0.05
		local increment = 160 / (time / interval)

		if (IsValid(self.door)) then
			timer.Create("falloutshelter_"..self:GetCreationID(), interval, 0, function()
				if (self.door.rotation > self.rotation) then
					self.door:SetLocalAngles(self.door:GetLocalAngles() + Angle(0, 0 - increment, 0))
					self.door.rotation = self.door.rotation - increment
				elseif (self.door.rotation != self.rotation) then
					self.door:SetLocalAngles(self.door:GetLocalAngles() + Angle(0, increment, 0))
					self.door.rotation = self.door.rotation + increment
				end

				if (self.door.rotation == self.rotation) then
					timer.Remove("falloutshelter_"..self:GetCreationID())
				end
			end)
		end
	end

	function ENT:Use(activator)
		self.nextUse = self.nextUse or CurTime()
		if (self.nextUse > CurTime()) then
			return
		end
		self.nextUse = CurTime() + 5

		local occupant = false

		for i, v in pairs(ents.FindInSphere(self:GetPos(), 32)) do
			if (v:IsPlayer()) then
				occupant = v
				break
			end
		end

		if (self.rotation == 0) then -- Open Door
			if (occupant and occupant == activator) then
				timer.Simple(2, function() self:EmitSound("fallout/falloutshelter/falloutshelter_exit.wav") end)
			elseif (occupant != false and occupant != activator) then
				return
			end

			timer.Simple(2, function() self.door:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) end) -- Help stop people from getting stuck.

			self:EmitSound("fallout/falloutshelter/falloutshelter_open.wav")
			self.rotation = -160
		else -- Close Door
			if (occupant != false) then
				timer.Simple(2, function()
					if (40 >= math.random(0, 100)) then
						self:EmitSound("fallout/falloutshelter/falloutshelter_advert_"..math.random(1, 3)..".wav")
					else
						self:EmitSound("fallout/falloutshelter/falloutshelter_enter.wav")
					end
				end)
			end

			self.door:SetCollisionGroup(COLLISION_GROUP_NONE)

			self:EmitSound("fallout/falloutshelter/falloutshelter_close.wav")
			self.rotation = 0
		end

		self:DoorMove()
	end
end
