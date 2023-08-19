AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.m_fDieTime = CurTime() + self.LifeTime

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:SetMass(1)
	end

	self:SetSubMaterial(0, "models/weapons/v_models/eq_cryogrenade/cryogrenade")
	self:SetElasticity(2)
end

function ENT:PhysicsCollide(data, phys)
	if (20 < data.Speed and 0.25 < data.DeltaTime) then
		self:EmitSound(self.BounceSound, nil, math.random(150, 175))
	end
end

function ENT:Think()
	if (self.m_bExploded) then
		self:Remove()
	elseif (self.m_fDieTime and self.m_fDieTime <= CurTime()) then
		self:Explode()
	end
end

function ENT:Explode(cooked)
	if (self.m_bExploded) then
		return end

	self.m_bExploded = true
	self:DoExplode()
end

function ENT:DoExplode()
	local mypos = self:LocalToWorld(self:OBBCenter())

	for _, pl in ipairs (player.GetAll()) do
		if (!pl:Alive()) then
			continue end

		local sp = pl:GetShootPos()
		local dir = (mypos - sp):GetNormal()

		local t = {
			start = sp,
			endpos = mypos,
			filter = player.GetAll(),
		}
		local dist = t.start:Distance(t.endpos)
		if (dist > CRYOGRENADE_SETTINGS.Range) then
			continue end

		local frac = 1 - dist / CRYOGRENADE_SETTINGS.Range

		local tr = util.TraceLine(t)
		if (!CRYOGRENADE_SETTINGS.LineOfSight or tr.Entity == self) then
			local e = ents.Create("status_sh_cryofrozen")
			e:SetPos(pl:EyePos())
			e:SetOwner(pl)
			e:SetParent(pl)
			e:Spawn()
			e.m_fEndTime = CurTime() + CRYOGRENADE_SETTINGS.MaxFreezeTime * (CRYOGRENADE_SETTINGS.ScaleFreezeTime and frac or 1)
		end
	end

	local eff = EffectData()
	eff:SetOrigin(mypos)
	util.Effect("cryo_explode", eff, true, true)

	self:Remove()
end