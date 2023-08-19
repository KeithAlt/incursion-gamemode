--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author

	Alydus Base Systems
	
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]
ENT.Type = "anim"ENT.Base = "alydusbasesystems_module_base"ENT.Spawnable = trueENT.Category = "Alydus Base Systems"ENT.PrintName = "Module - Searchlight"ENT.Author = "Alydus"ENT.Contact = "Alydus"ENT.Purpose = ""ENT.Instructions = ""
if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		local spinSpeed = 50
		if IsValid(self:GetNWEntity("alydusBaseSystems.Owner")) and self:GetNWInt("alydusBaseSystems.Health", 0) >= 1 and self:GetNWInt("alydusBaseSystems.Ammo") >= 1 then		
		end
	end
else
	AddCSLuaFile()
end
function ENT:Initialize()
	if SERVER then
		self:SetModel("models/props_wasteland/light_spotlight01_lamp.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(1000000)
			phys:Wake()
		end
		self:SetNWEntity("alydusBaseSystems.Owner", nil)
		self:SetNWInt("alydusBaseSystems.Health", GetConVar("sv_alydusbasesystems_config_module_defaulthealth"):GetInt())
		self.firingDelay = 0.0001
		self.nextFire = 0		
        if IsValid(self:Getowning_ent()) then
            self:SetNWEntity("alydusBaseSystems.Owner", self:Getowning_ent())
        end
		if WireAddon then
			self.Outputs = Wire_CreateOutputs(self, {
				"Module Health"
			})			
			Wire_TriggerOutput(self, "Module Health", self:GetNWInt("alydusBaseSystems.Health", 0))
		end
        self:DropToFloor()
        self.lightEffect =  ents.Create("prop_physics")
        self.lightEffect:SetModel("models/effects/vol_light128x512.mdl")
        self.lightEffect:SetPos(self:GetPos())
        self.lightEffect:SetAngles(self:GetAngles() + Angle(-90, 0, 0))
        self.lightEffect:SetParent(self)
        self.lightEffect:DrawShadow(false)
        self.lightEffect:Spawn()
        self.lightEffect:SetNoDraw(true)
        self.lightMuzzle = ents.Create("env_sprite")
        self.lightMuzzle:SetPos(self:GetPos() + (self:GetAngles():Forward() * 15))
        self.lightMuzzle:SetAngles(self:GetAngles())
		self.lightMuzzle:SetKeyValue("model", "sprites/light_glow01.vmt")
		self.lightMuzzle:SetKeyValue("scale", 5)
		self.lightMuzzle:SetKeyValue("rendermode", 5)
		self.lightMuzzle:SetKeyValue("renderfx", 7)
        self.lightMuzzle:SetParent(self)
        self.lightMuzzle:Spawn()
        self.lightMuzzle:SetNoDraw(true)		
        self.lightTarget = nil
        self.randomOffset = math.random(1, 180)
	end
end
function ENT:Think()
	if SERVER then
		if not IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) or self:GetNWInt("alydusBaseSystems.Health", 0) <= 0 or self:IsPlayerHolding() or (IsValid(self:GetPhysicsObject()) and self:GetPhysicsObject():IsMotionEnabled()) then
			if not self.lightEffect:SetNoDraw() then
				self.lightEffect:SetNoDraw(true)
			end
			if not self.lightMuzzle:SetNoDraw() then
				self.lightMuzzle:SetNoDraw(true)
			end
			return
		end
		if self.lightEffect:SetNoDraw() then
			self.lightEffect:SetNoDraw(false)
		end
		if self.lightMuzzle:SetNoDraw() then
			self.lightMuzzle:SetNoDraw(false)
		end
		if not IsValid(self.lightTarget) or self.lightTarget:GetPos():Distance(self:GetPos()) > 750 then
			self.lightTarget = nil
			local potentialTargets = {}
			for _, ent in pairs(ents.FindInSphere(self:GetPos(), 1000)) do
				if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer()) and ent != self:GetNWEntity("alydusBaseSystems.Owner", nil) then
					if CPPI then
						local isBuddy = false
						local owner = self:GetNWEntity("alydusBaseSystems.Owner", nil)
						if IsValid(owner) and not isnumber(owner:CPPIGetFriends()) then
							for _, buddy in pairs(owner:CPPIGetFriends()) do
								if buddy == ent then
									isBuddy = true
								end
							end
							if not isBuddy then
								table.insert(potentialTargets, ent)
							end
						else
							table.insert(potentialTargets, ent)
						end
					else
						table.insert(potentialTargets, ent)
					end
				end
			end
			if #potentialTargets >= 1 then
				self.lightTarget = table.Random(potentialTargets)
			end
		end
		if IsValid(self.lightTarget) then
			self:PointAtEntity(self.lightTarget)
		else
			self:SetAngles(Angle(40, CurTime() * 25 + self.randomOffset, 0))
		end
	end
end