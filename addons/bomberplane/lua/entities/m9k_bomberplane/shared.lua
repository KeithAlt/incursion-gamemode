if(SERVER) then
	AddCSLuaFile("shared.lua")
end

ENT.Type = "anim"
ENT.PrintName = "Bomber"
ENT.Author = "Chancer"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Category = "Bomber Plane"
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = true 

function ENT:SpawnFunction(owner, tr)
	if !tr.Hit
	then
		return
	end

	local ent = ents.Create(self.ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal)

	ent.Owner = owner
	
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	if(SERVER) then
		self.direction = self.Owner:GetForward() * Vector(1,1,0)
		self.lifeTime = CurTime() + 15 --15 second lifetime
		self.bombTime = CurTime() + 4
		self.droppedBombs = 0
	
		self.CanTool = false
	
		self:SetModel("models/fonv/vehicles/b29/b29_aperture.mdl")
		--self:SetMoveType(MOVETYPE_FLY)

		self:SetModelScale(0.5)
		self:SetPos(self:GetPos() + Vector(0,0,2700) - self.direction * 5000)
		
		local angle = self.direction:Angle()
		self:SetAngles(angle)

		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_BBOX)
		
		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			--physObj:EnableMotion(false)
			physObj:EnableGravity(false) --no gravity
			--physObj:Sleep()
			physObj:EnableCollisions(false) --no collisions
		end
	end

	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
end

function ENT:Think()
	if(SERVER) then
		if((self.lifeTime or 0) < CurTime()) then
			SafeRemoveEntity(self)
		else
			if(self.droppedBombs < 8 and self.bombTime < CurTime()) then
				self.bombTime = CurTime() + 0.4
				self.droppedBombs = self.droppedBombs + 1

				local velocity = self:GetVelocity() * 0.5

				--spawns the bombs
				local bomb = ents.Create("m9k_planebomb")
				bomb:SetPos(self:GetPos() + Vector(0,50,-20))
				bomb.Owner = self.Owner
				bomb:Spawn()
				bomb:Activate()
				local bombPhys = bomb:GetPhysicsObject()
				if(IsValid(bombPhys)) then
					bombPhys:SetVelocity(velocity)
				end
				
				local bomb = ents.Create("m9k_planebomb")
				bomb:SetPos(self:GetPos() + Vector(0,-50,-20))
				bomb.Owner = self.Owner
				bomb:Spawn()
				bomb:Activate()
				local bombPhys = bomb:GetPhysicsObject()
				if(IsValid(bombPhys)) then
					bombPhys:SetVelocity(velocity)
				end
			end
		
			if(self.direction) then
				local physObj = self:GetPhysicsObject()
				physObj:SetVelocity(self.direction * 1000)
				
				self:NextThink(CurTime())
				return true
			end
		end
	end
end
