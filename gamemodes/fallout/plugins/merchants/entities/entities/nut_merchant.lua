ENT.Type = "anim"
ENT.PrintName = "Merchant"
ENT.Category = "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/mossman.mdl")
		self:SetUseType(SIMPLE_USE)
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(true)
		self:SetSolid(SOLID_BBOX)
		self:PhysicsInit(SOLID_BBOX)

		self:setNetVar("instance", nil)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		timer.Simple(1, function()
			if (IsValid(self)) then
				self:setAnim()
			end;
		end)
	end;

	function ENT:setAnim()
		for i, v in ipairs(self:GetSequenceList()) do
			if (v:lower():find("idle") and v != "idlenoise") then
				return self:ResetSequence(i)
			end;
		end;

		self:ResetSequence(4)
	end;

	function ENT:SpawnFunction(client, trace)
		local angles = (trace.HitPos - client:GetPos()):Angle()
		angles.r = 0
		angles.p = 0
		angles.y = angles.y + 180

		local entity = ents.Create("nut_merchant")
		entity:SetPos(trace.HitPos)
		entity:SetAngles(angles)
		entity:Spawn()

		return entity
	end;

	function ENT:Use(activator)
		self.last = self.last or 0
		if (self.last < os.time()) then self.last = os.time() + 1 else return end;

		if (!self:getNetVar("instance")) then
			activator:ChatPrint("This merchant has not been configured.")
			return
		end;

		if (nut.merchants.instances[self:getNetVar("instance")]) then
			local instance = nut.merchants.instances[self:getNetVar("instance")]

			if (instance.template == "marketplace") then
				nut.db.query("SELECT * FROM nut_marketplace WHERE _sellerID = "..activator:getChar():getID(), function(data)
					netstream.Start(activator, "marketplaceUI", data)
				end)
				return
			elseif (nut.merchants.templates[instance.template]) then
				local template = nut.merchants.templates[instance.template]

				netstream.Start(activator, "merchantUI", instance, template, self:getNetVar("instance"))
			else
				activator:ChatPrint("This merchant is using an invalid template.")
			end;
		else
			activator:ChatPrint("This merchant is missing its data and needs to be reconfigured.")
		end;
	end;
end;
