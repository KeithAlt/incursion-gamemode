ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "TFBow Arrow Stuck"
ENT.Author = "TheForgottenArchitect"
ENT.Contact = "Don't"
ENT.Purpose = "Arrow Entity"
ENT.Instructions = "Arrow that's stuck in ground"
TFArrowEnts = TFArrowEnts or {}

function GetBoneCenter(ent, bone)
	local bonechildren = ent:GetChildBones(bone)

	if #bonechildren <= 0 then
		return ent:GetBonePosition(bone)
	else
		local bonepos = ent:GetBonePosition(bone)
		local tmppos = bonepos

		if tmppos then
			for i = 1, #bonechildren do
				local childpos = ent:GetBonePosition(bonechildren[i])

				if childpos then
					tmppos = (tmppos + childpos) / 2
				end
			end
		else
			return ent:GetPos()
		end

		return tmppos
	end
end

function GetClosestBone(ent, pos)
	local i, count, cbone, dist
	i = 1
	count = ent:GetBoneCount()
	cbone = 0
	dist = 99999999

	while (i < count) do
		local bonepos = ent:GetBonePosition(i)

		if bonepos:Distance(pos) < dist then
			dist = bonepos:Distance(pos)
			cbone = i
		end

		i = i + 1
	end

	return cbone
end

function GetClosestPhysBone(ent, pos)
	local i, count, cbone, dist
	i = 1
	count = ent:GetBoneCount()
	cbone = 0
	dist = 99999999

	while (i < count) do
		local bonepos = ent:GetBonePosition(i)
		local boneparpos = Vector(9999, 9999, 9999)
		local par = ent:GetBoneParent(i)

		if ent:TranslateBoneToPhysBone(i) and ent:TranslateBoneToPhysBone(i) >= 0 and bonepos:Distance(pos) < dist then
			dist = bonepos:Distance(pos)
			cbone = ent:TranslateBoneToPhysBone(i)
		end

		if i and i ~= -1 then
			local boneparpost = ent:GetBonePosition(par)
			boneparpos = (boneparpost + bonepos) / 2

			if ent:TranslateBoneToPhysBone(par) and ent:TranslateBoneToPhysBone(par) >= 0 and boneparpos:Distance(pos) < dist then
				dist = boneparpos:Distance(pos)
				cbone = ent:TranslateBoneToPhysBone(par)
			end
		end

		i = i + 1
	end

	return cbone
end

function ENT:UpdatePosition()
	local posoffnw, angoffnw, targentnw, targbonenw, enthasbonesnw
	posoffnw = self:GetNW2Vector("posoffnw", vector_origin)
	angoffnw = self:GetNW2Angle("angoffnw", Angle(0, 0, 0))
	targentnw = self:GetNW2Entity("targentnw")
	targbonenw = self:GetNW2Int("targbonenw", 0)
	enthasbonesnw = self:GetNW2Bool("enthasbonesnw", true)

	if IsValid(targentnw) then
		if (targentnw:IsNPC() or targentnw:IsPlayer()) and targentnw:Health() <= 0 then
			self:SetPos(Vector(0, 0, -1000))
		end

		local ent = targentnw
		local bonepos, bonerot

		if enthasbonesnw then
			if ent.SetupBones then
				ent:SetupBones(ent:GetBoneCount(), ent:GetPhysicsObjectCount() or 32)
			end

			bonepos, bonerot = ent:GetBonePosition(targbonenw)
			bonescale = ent:GetManipulateBoneScale(targbonenw):Length()
		else
			bonepos = ent:GetPos()
			bonerot = ent:GetAngles()
			bonescale = ent:GetModelScale()
		end

		local tmppos, tmprot

		if not bonepos then
			bonepos = ent:GetPos()
			bonerot = ent:GetAngles()
			bonescale = ent:GetModelScale()
		end

		tmppos, tmprot = LocalToWorld(posoffnw, angoffnw, bonepos, bonerot)
		tmprot:Normalize()
		self:SetPos(tmppos)
		self:SetAngles(tmprot)
		--[[
		if bonescale and bonescale<=0.01 then
			if self.Remove and SERVER then
				self.shouldcreatebloodpool = false
				self:Remove()
			end
		end
		]]--
	else
		self:SetPos(Vector(0, 0, -1000))
	end
end

local cv_al = GetConVar("sv_tfa_arrow_lifetime")

function ENT:Initialize()
	if SERVER then
		local mins = (self:OBBMins() and self:OBBMins() or Vector(0, 0, 0)) - Vector(1, 1, 1)
		local maxs = (self:OBBMaxs() and self:OBBMaxs() or Vector(0, 0, 0)) + Vector(1, 1, 1)
		self:PhysicsInitBox(mins, maxs)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:Wake()
			phys:SetMass(2)
			phys:EnableGravity(false)
			phys:EnableCollisions(false)
		end

		if self.SetUseType then
			self:SetUseType(SIMPLE_USE)
		end

		if cv_al:GetInt() ~= -1 then
			timer.Simple( cv_al:GetFloat(), function()
				if IsValid(self) then
					self:Remove()
				end
			end)
		end
	end

	self.glitchthreshold = 24 --threshold distance from bone to reset pos
	self.glitchthresholds = {}
	self.glitchthresholds["ValveBiped.Bip01_Head1"] = 8
	self.glitchthresholds["ValveBiped.Bip01_Head"] = 8
	self.glitchthresholds["ValveBiped.Bip01_R_Hand"] = 1
	self.glitchthresholds["ValveBiped.Bip01_L_Hand"] = 1
	self.glitchthresholds["ValveBiped.Bip01_Spine2"] = 40
	table.insert(TFArrowEnts, #TFArrowEnts + 1, self)

	if (self:GetModel() and self:GetModel() == "") then
		self:SetModel("models/weapons/w_tfa_arrow.mdl")
	end

	--[[
		if self.targent then
		self:SetOwner(self.targent)
	end
	]]
	--
	self:SetOwner(nil)

	if self.targent then
		constraint.NoCollide(self, self.targent, 0, 0)
	end

	--self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	--timer.Simple(0, function()
	if self.targent and IsValid(self.targent) then
		local ent, bone, bonepos, bonerot
		ent = self.targent
		bone = self.targent:TranslatePhysBoneToBone(self.targphysbone)
		self.targbone = bone

		if not ent:GetBoneCount() or ent:GetBoneCount() <= 1 or string.find(ent:GetModel(), "door") then
			bonepos = ent:GetPos()
			bonerot = ent:GetAngles()
			self.enthasbones = false
		else
			if ent.SetupBones then
				ent:SetupBones(ent:GetBoneCount(), ent:GetModelPhysBoneCount())
			end

			bonepos, bonerot = ent:GetBonePosition(bone)
			self.enthasbones = true
		end

		if self.enthasbones == true then
			local gpos = self:GetPos()
			local bonepos2 = GetBoneCenter(ent, bone)
			local tmpgts = self.glitchthresholds[ent:LookupBone(bone)] or self.glitchthreshold

			while gpos:Distance(bonepos2) > tmpgts do
				self:SetPos((gpos + bonepos2) / 2)
				gpos = (gpos + bonepos2) / 2
			end
		end

		if not bonepos then
			bonepos = ent:GetPos()
			bonerot = ent:GetAngles()
		end

		self.posoff, self.angoff = WorldToLocal(self:GetPos(), self:GetAngles(), bonepos, bonerot)
		self:SetNW2Vector("posoffnw", self.posoff)
		self:SetNW2Angle("angoffnw", self.angoff)
		self:SetNW2Entity("targentnw", self.targent)
		self:SetNW2Int("targbonenw", self.targbone)
		self:SetNW2Bool("enthasbonesnw", self.enthasbones)
	end

	if CLIENT then
		self:SetPredictable(false)
	end
	
	self:UpdatePosition()
	--end)
end

function ENT:Think()
	self:UpdatePosition()

	if SERVER then
		if not IsValid(self.targent) then
			self:Remove()

			return
		elseif self.targent then
			if ((self.targent:IsPlayer() or self.targent:IsNPC()) and self.targent:Health() <= 0) then
				local tmpragent
				if self.targent.GetRagdollEntity then
					tmpragent = self.targent:GetRagdollEntity()
				end
				if IsValid(tmpragent) and tmpragent ~= self.targent then
					self.targent = tmpragent
					self:SetNW2Entity("targentnw", self.targent)
				else
					self:Remove()
				end

				return
			end
		end
	end

	self:NextThink(CurTime() + 1 / 60)
end

function ENT:Use(activator, caller)
	if activator:IsPlayer() and activator:GetWeapon(self.gun) ~= nil then
		activator:GiveAmmo(1, activator:GetWeapon(self.gun):GetPrimaryAmmoType(), false)
		self:Remove()
	end
end

function ENT:OnRemove()
	table.RemoveByValue(TFArrowEnts, self)
end
