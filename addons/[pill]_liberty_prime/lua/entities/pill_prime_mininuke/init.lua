
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/fallout/mininuke.mdl")
	self:SetMoveCollide(COLLISION_GROUP_PROJECTILE)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(0.5)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
	end
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:PhysicsCollide(data, physobj)
	local radius = 400
	local dmg = GetConVarNumber("sk_libertyprime_dmg_bomb")
	local owner = IsValid(self:GetOwner()) && self:GetOwner() || self
	local pos = self:GetPos()
	local ang = Angle(0,0,0)
	local entParticle = ents.Create("info_particle_system")
	entParticle:SetKeyValue("start_active", "1")
	entParticle:SetKeyValue("effect_name", "mininuke_explosion")
	entParticle:SetPos(pos)
	entParticle:SetAngles(ang)
	entParticle:Spawn()
	entParticle:Activate()
	timer.Simple(1, function() if IsValid(entParticle) then entParticle:Remove() end end)
	self:EmitSound("explosion/explosion_nuke_small_3d.mp3", 165, 100)
	util.BlastDamage(self, owner, pos, radius, dmg, function(ent)
		if !IsValid(self:GetOwner()) then return true end
		return self:GetOwner():Disposition(ent) == D_HT
	end, DMG_BLAST, true)
	util.ScreenShake(pos, 5, dmg, math.Clamp(dmg /100, 0.1, 2), radius *2)

	local effectData = EffectData()
	effectData:SetScale(1)
	effectData:SetOrigin(self:GetPos())
	util.Effect("nuke_blastwave_fallout",effectData,true,true);



	local iDistMin = 26
	local tr
	for i = 1, 6 do
		local posEnd = pos
		if i == 1 then posEnd = posEnd +Vector(0,0,75)
		elseif i == 2 then posEnd = posEnd -Vector(0,0,75)
		elseif i == 3 then posEnd = posEnd +Vector(0,75,0)
		elseif i == 4 then posEnd = posEnd -Vector(0,75,0)
		elseif i == 5 then posEnd = posEnd +Vector(75,0,0)
		elseif i == 6 then posEnd = posEnd -Vector(75,0,0) end
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = posEnd
		tracedata.filter = self
		local trace = util.TraceLine(tracedata)
		local iDist = pos:Distance(trace.HitPos)
		if trace.HitWorld && iDist < iDistMin then
			iDistMin = iDist
			tr = trace
		end
	end
	if tr then
		util.Decal("Scorch",tr.HitPos +tr.HitNormal,tr.HitPos -tr.HitNormal)
	end
	self:Remove()
	return true
end

function ENT:OnRemove()
end

function ENT:Think()
end

