AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Utility Large"
ENT.Category = "NutScript : Fallout Doors"
ENT.Spawnable = true
ENT.AdminOnly = true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_lab/blastdoor001c.mdl")
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
		self.dummy:SetModel("models/fallout/dungeons/utility/utldoorbg01.mdl")
		self.dummy:DrawShadow(false)
		self.dummy:SetPos(self:GetPos())
		self.dummy:SetAngles(self:GetAngles())
		self.dummy:SetParent(self)
		self.dummy:Spawn()
		self.dummy:Activate()
		
		self.dummy:SetPlaybackRate(0.1)
		
		self:DeleteOnRemove(self.dummy)
	end;

	function ENT:Use(player)
		self.nextUse = self.nextUse or CurTime()
		if (self.nextUse > CurTime()) then
			return
		else
			self.nextUse = CurTime() + 4
		end;
		
		if (self:getNetVar("password") == false) then
			if (self:getNetVar("open") != true) then
				self.dummy:Fire("SetAnimation", "open", 0)
				self:setNetVar("open", true)
				self:EmitSound("fallout/doors/drs_metalutilitylarge_open.wav", 65)
				timer.Simple(3.5, function() self:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end)
			else
				self.dummy:Fire("SetAnimation", "close", 0)
				self:setNetVar("open", false)
				self:EmitSound("fallout/doors/drs_metalutilitylarge_close.wav", 65)
				self:SetCollisionGroup(COLLISION_GROUP_NONE)
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
				self:EmitSound("fallout/ui_hacking_passgood.wav", 60)
				
				timer.Simple(0.25, function()
					if (self:getNetVar("open") != true) then
						self.dummy:Fire("SetAnimation", "open", 0)
						self:setNetVar("open", true)
						self:EmitSound("fallout/doors/drs_metalutilitylarge_open.wav", 65)
						timer.Simple(3.5, function() self:SetCollisionGroup(COLLISION_GROUP_DEBRIS) end)
					else
						self.dummy:Fire("SetAnimation", "close", 0)
						self:setNetVar("open", false)
						self:EmitSound("fallout/doors/drs_metalutilitylarge_close.wav", 65)
						self:SetCollisionGroup(COLLISION_GROUP_NONE)
					end;
				end)
			else
				self:EmitSound("fallout/ui_hacking_passbad.wav", 60)
			end;
		end;
	end;
else
	function ENT:Draw()
	
	end;
end;