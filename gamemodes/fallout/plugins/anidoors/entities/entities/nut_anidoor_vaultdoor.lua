AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Vault Door"
ENT.Category = "NutScript : Fallout Doors"
ENT.Spawnable = true
ENT.AdminOnly = true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/fallout/dungeons/vault/roomu/vurmgearexit01.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)
		
		self:setNetVar("password", false)
		self:setNetVar("open", false)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Wake()
		end;
		
		self.dummy = ents.Create("prop_dynamic")
		self.dummy:SetModel("models/fallout/dungeons/vault/roomu/vgeardoor01.mdl")
		self.dummy:DrawShadow(false)
		self.dummy:SetPos(self:GetPos() - self:GetAngles():Forward() * 125 - self:GetAngles():Right() * 41.501)
		self.dummy:SetAngles(self:GetAngles())
		self.dummy:SetParent(self)
		self.dummy:Spawn()
		self.dummy:Activate()
		
		self.dummy:SetPlaybackRate(0.1)
		
		self:DeleteOnRemove(self.dummy)
		
		self.dummy2 = ents.Create("prop_dynamic")
		self.dummy2:SetModel("models/hunter/blocks/cube4x4x1.mdl")
		self.dummy2:DrawShadow(false)
		self.dummy2:SetPos(self:GetPos() - self:GetAngles():Forward() * 125 - self:GetAngles():Right() * 45 + self:GetAngles():Up() * 23)
		self.dummy2:SetAngles(self:GetAngles() + Angle(90, 0, 0))
		self.dummy2:SetParent(self)
		self.dummy2:Spawn()
		self.dummy2:Activate()
		self.dummy2:SetSolid(SOLID_VPHYSICS)
		self.dummy2:PhysicsInit(SOLID_VPHYSICS)
		self.dummy2:SetNoDraw(true)
		self:DeleteOnRemove(self.dummy2)
	end;

	function ENT:Use(player)
		self.nextUse = self.nextUse or CurTime()
		if (self.nextUse > CurTime() or !player:KeyDown(IN_SPEED) or !player:KeyDown(IN_DUCK)) then
			return
		else
			self.nextUse = CurTime() + 25
		end;
		
		if (self:getNetVar("password") == false) then
			if (self:getNetVar("open") != true) then
				self.dummy:Fire("SetAnimation", "open", 0)
				self:setNetVar("open", true)
				self:EmitSound("fallout/doors/drs_vaultgear_open_stereo.wav", 80)
				timer.Simple(20, function() self.dummy2:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end)
			else
				self.dummy:Fire("SetAnimation", "close", 0)
				self:setNetVar("open", false)
				self:EmitSound("fallout/doors/drs_vaultgear_close_stereo.wav", 80)
				timer.Simple(5, function() self.dummy2:SetCollisionGroup(COLLISION_GROUP_NONE) end)
			end;
		else
			local inv = player:getChar():getInv()
			local found = false
			
			for _, v in pairs(inv:getItemsByUniqueID("keycard")) do
				if (v:getData("password", false) == self:getNetVar("password", false)) then
					found = true
					break
				end;
			end;
			
			
			if (found == true) then
				if (self:getNetVar("open") != true) then
					self.dummy:Fire("SetAnimation", "open", 0)
					self:setNetVar("open", true)
					self:EmitSound("fallout/doors/drs_vaultgear_open_stereo.wav", 80)
					timer.Simple(20, function() self.dummy2:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end)
				else
					self.dummy:Fire("SetAnimation", "close", 0)
					self:setNetVar("open", false)
					self:EmitSound("fallout/doors/drs_vaultgear_close_stereo.wav", 80)
					timer.Simple(5, function() self.dummy2:SetCollisionGroup(COLLISION_GROUP_NONE) end)
				end;
			end;
		end;
	end;
end;