-- Adv. Teleporter
-- By Anya O'Quinn / Slade Xanthas

AddCSLuaFile()

ENT.Type		= "anim"
ENT.Base		= "base_anim"
ENT.PrintName	= "Teleporter"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 	0, "Destination")
	self:NetworkVar("Float", 	0, "TeleUniqueID")
	self:NetworkVar("Float", 	1, "TeleDestinationUniqueID")
	self:NetworkVar("Int", 		0, "TeleRadius", 		{KeyName = "teleradius"})
	self:NetworkVar("String", 	0, "TeleSound", 		{KeyName = "telesound"})
	self:NetworkVar("String", 	1, "TeleEffect", 		{KeyName = "telesound"})
	self:NetworkVar("Bool", 	0, "TeleOnUse", 		{KeyName = "teleonuse"})
	self:NetworkVar("Bool", 	1, "TeleOnTouch", 		{KeyName = "teleontouch"})
	self:NetworkVar("Bool", 	2, "TeleShowBeam", 		{KeyName = "teleshowbeam"})
	self:NetworkVar("Bool", 	3, "TeleShowRadius", 	{KeyName = "teleshowradius"})
end

if CLIENT then

	function ENT:Initialize()

		self.Mat = Material("sprites/tp_beam001")
		self.Sprite = Material("sprites/blueglow2")
		self.LinkedColor = Color(0,255,0,255)
		self.UnlinkedColor = Color(255,0,0,255)
		
		self.RadiusSphere = ClientsideModel("models/dav0r/hoverball.mdl", RENDERGROUP_OPAQUE)
		
		if IsValid(self.RadiusSphere) then
			self.RadiusSphere:SetNoDraw(true)
			self.RadiusSphere:SetPos(self:LocalToWorld(self:OBBCenter()))
			self.RadiusSphere:SetParent(self)
		end
		
	end

	function ENT:Draw()

		self:DrawModel()

		local Destination = self:GetDestination()
		
		if IsValid(self) and IsValid(self.RadiusSphere) then
		
			if self:GetTeleRadius() and self:GetTeleShowRadius() then
			
				render.SuppressEngineLighting(true)	
				
				if IsValid(Destination) and IsValid(Destination:GetDestination()) and (self == Destination:GetDestination()) then
					render.SetColorModulation(0,1,0)
				else
					render.SetColorModulation(1,0,0)
				end

				render.SetBlend(1)
				self.RadiusSphere:DrawModel()
				render.SuppressEngineLighting(false)
				render.SetBlend(1)
				render.SetColorModulation(1,1,1)
				self.RadiusSphere:SetModelScale(self:GetTeleRadius() / 5,0)
				self.RadiusSphere:SetMaterial("models/props_combine/portalball001_sheet")
				
			end
		
		end

		if IsValid(self) and IsValid(Destination) and IsValid(Destination:GetDestination()) and (self == Destination:GetDestination()) and self:GetTeleShowBeam() and Destination:GetTeleShowBeam() then
			render.SetMaterial(self.Mat)
			render.DrawBeam(self:LocalToWorld(self:OBBCenter()), Destination:LocalToWorld(Destination:OBBCenter()), 4, 2, 0, self.LinkedColor)
			render.SetMaterial(self.Sprite)
			local rand = math.random(-2,2)
			render.DrawSprite(self:LocalToWorld(self:OBBCenter()), 6 + rand, 6 + rand, self.LinkedColor)
			render.DrawSprite(Destination:LocalToWorld(Destination:OBBCenter()), 6 + rand, 6 + rand, Destination.LinkedColor)
			self:SetRenderBoundsWS(self:GetPos(), Destination:GetPos())
		elseif IsValid(self) then			
			self:SetRenderBoundsWS(self:GetPos() + self:OBBMins(),self:GetPos() + self:OBBMaxs())
		end

	end
	
	function ENT:OnRemove()
		if IsValid(self.RadiusSphere) then
			self.RadiusSphere:Remove()
			self.RadiusSphere = nil
		end
	end

end

if SERVER then

	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self.NextTeleport = CurTime()
		
		if Wire_CreateInputs then
			self.Inputs = Wire_CreateInputs(self, {"Teleport","Lock"})
		end
		
		self.tEnts = {}
		
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
		
		if self:GetTeleUniqueID() == 0 then 
			self:SetTeleUniqueID(RealTime() + self:EntIndex())
		end
		
		self:LinkUp()

	end

	function ENT:LinkUp()
	
		if IsValid(self:GetDestination()) then return end
		
		if self:GetTeleDestinationUniqueID() ~= 0 then
		
			for _,v in pairs(ents.FindByClass(self:GetClass())) do	
				if IsValid(v) 
				and v ~= self 
				and v:GetTeleUniqueID() ~= 0
				and v:GetTeleDestinationUniqueID() ~= 0
				and self:GetTeleDestinationUniqueID() == v:GetTeleUniqueID() 
				and v:GetTeleDestinationUniqueID() == self:GetTeleUniqueID() 
				then
					self:SetDestination(v)
					v:SetDestination(self)
					self.NextTeleport = CurTime() + 1
					v.NextTeleport = CurTime() + 1
					break
				end
			end	
			
		else
		
			for _,v in pairs(ents.FindByClass(self:GetClass())) do	
				
				if IsValid(self)
				and IsValid(v)
				and v ~= self
				and self.TeleKey
				and v.TeleKey
				and v.TeleKey == self.TeleKey
				and not IsValid(self:GetDestination())
				and not IsValid(v:GetDestination())
				and IsValid(self.Owner)
				and IsValid(v.Owner)
				and self.Owner == v.Owner
				then
					self:SetDestination(v)
					v:SetDestination(self)
					self:SetTeleDestinationUniqueID(v:GetTeleUniqueID())
					v:SetTeleDestinationUniqueID(self:GetTeleUniqueID())
					self.NextTeleport = CurTime() + 1
					v.NextTeleport = CurTime() + 1
					break
				end
				
			end	

		end

	end
	
	function ENT:PreEntityCopy()
		local dupeInfo = {}
		if IsValid(self) and IsValid(self:GetDestination()) then
			dupeInfo.DestinationID = self:GetDestination():EntIndex()
			duplicator.StoreEntityModifier(self, "DestinationDupeInfo", dupeInfo)
		end
	end
		
	function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
		self:SetDestination(CreatedEntities[Ent.EntityMods.DestinationDupeInfo.DestinationID])
	end

	function ENT:Setup(model, sound, effect, radius, ontouch, onuse, showbeam, showradius, key)

		self:SetTeleSound(sound)
		self:SetTeleEffect(effect)
		self:SetTeleOnTouch(ontouch)
		self:SetTeleOnUse(onuse)
		self:SetTeleRadius(radius)
		self:SetTeleShowBeam(showbeam)
		self:SetTeleShowRadius(showradius)
		
		if not self.TeleKey then 
			self.TeleKey = key
		end
		
		if not self:GetModel() then
			self:SetModel(model)
		end
		
		if not IsValid(self:GetDestination()) then
			self:LinkUp()
		end
		
		if IsValid(self:GetDestination()) and self:GetTeleShowBeam() ~= self:GetDestination():GetTeleShowBeam() then
			self:GetDestination():SetTeleShowBeam(self:GetTeleShowBeam())
		end

	end
	
	function ENT:Teleport(ent)

		if not IsValid(self) or not IsValid(self:GetDestination()) or not IsValid(ent) then return end
		
		self:EmitSound(self:GetTeleSound())
		self:GetDestination():EmitSound(self:GetDestination():GetTeleSound())
	
		local fx = EffectData()	
		fx:SetScale(1)
		fx:SetRadius(1)
		fx:SetMagnitude(7)
		fx:SetEntity(self)
		fx:SetOrigin(self:GetPos())
		util.Effect(self:GetTeleEffect(), fx, true, true)
		fx:SetEntity(self:GetDestination())
		fx:SetOrigin(self:GetDestination():GetPos())
		util.Effect(self:GetDestination():GetTeleEffect(), fx, true, true)
		
		ent:SetPos(self:GetDestination():GetPos()+self:GetDestination():GetUp() * 50) 

		table.insert(self.tEnts,ent)
		table.insert(self:GetDestination().tEnts,ent)

	end

	function ENT:Use(activator,caller)
		if IsValid(activator) and activator:IsPlayer() then
			self.Activator = activator
			self.IsBeingUsed = true
		end
	end

	-- OPTIMIZATION (Cat.jpeg)
	local isValid = IsValid
	local findInSphere = ents.FindInSphere
	local curTime = CurTime
	local Pairs = pairs
	local hasValue = table.HasValue
	
	function ENT:Think()
		if not isValid(self) then return end

		local currentTime = curTime()
		local destination = self:GetDestination()
		local teleported

		if isValid(destination) then
			local area = findInSphere(self:GetPos(),self:GetTeleRadius())
			local tEnts = self.tEnts
			local _getTeleOnTouch = self:GetTeleOnTouch()

			for i, ent in Pairs(area) do

				if isValid(ent) 
				and ent:IsPlayer()
				and ent ~= self
				and ent ~= destination
				and not hasValue(tEnts, ent) 
				and not hasValue(destination.tEnts, ent)
				and (_getTeleOnTouch or self.KeyOn or self.WireTeleport or (_getTeleOnTouch and self.IsBeingUsed)) 
				and not destination.Locked
				and self.NextTeleport < currentTime
				and destination.NextTeleport < currentTime then
					self:Teleport(ent)
					self.NextTeleport = currentTime + 2
					teleported = true
				end

			end	

			self.IsBeingUsed = false
							
			for i, v in Pairs(tEnts) do
				if not hasValue(area,v) then
					tEnts[i] = nil
				end
			end

		end
		
		local activator =  self.Activator

		if self.IsBeingUsed and isValid(activator) and activator:IsPlayer() and (activator:KeyReleased(IN_USE) or not activator:GetEyeTrace().Entity == self) then
			self.IsBeingUsed = false		
		end

		if not isValid(destination) then self:LinkUp() end

		if teleported then
			self:NextThink(self.NextTeleport)
		else
			self:NextThink(currentTime + 1)
		end

		return true
	end
	--

	local function On(pl, ent)
		if not IsValid(ent) then return end
		ent.KeyOn = true
		return true
	end

	local function Off(pl, ent)
		if not IsValid(ent) then return end
		ent.KeyOn = false
		return true
	end

	numpad.Register("Teleporter_On", On)
	numpad.Register("Teleporter_Off", Off)

	function ENT:TriggerInput(iname, value)

		if iname == "Teleport" then
		
			if value == 1 then 
				self.WireTeleport = true 
			end
			
			if value == 0 and self.WireTeleport then 
				self.WireTeleport = false 
			end
			
		end
		
		if iname == "Lock" then
		
			if value == 1 and not self.Locked then 
				self.Locked = true 
			end
			
			if value == 0 and self.Locked then 
				self.Locked = false 
			end

		end
		
	end

end

-- 37062385