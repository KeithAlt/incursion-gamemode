ENT.Type = "anim"
ENT.PrintName			= "Plane Bomb"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions			= ""
ENT.Spawnable			= false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

ENT.PoorBastard = false
ENT.Target = false

if SERVER then

AddCSLuaFile("shared.lua")

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	self.CanTool = false
	self.lifeTime = CurTime() + 60

	self:SetModel("models/maxofs2d/hover_classic.mdl") --fix that
	self:SetMoveType(MOVETYPE_FLY)
	self:DrawShadow(true)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:MassiveFuckingExplosion()
	if not IsValid(self.Owner) then
		self.Entity:Remove()
		return
	end

	local ground = self:GetPos()

	pos = self:GetPos()
	lowerleft = pos + Vector(870,500,0)
	lowerright = pos +  Vector(-870,500,0)
	top = pos + Vector(0,-1000,0)

	tr1= {}
	tr1.start = lowerleft
	tr1.endpos = ground
	tr1.filter = self.Entity
	tr1 = util.TraceLine(tr1)

	tr2= {}
	tr2.start = lowerleft
	tr2.endpos = ground
	tr2.filter = self.Entity
	tr2 = util.TraceLine(tr2)

	tr3= {}
	tr3.start = lowerright
	tr3.endpos = ground
	tr3.filter = self.Entity
	tr3 = util.TraceLine(tr3)

	tr4= {}
	tr4.start = lowerright
	tr4.endpos = ground
	tr4.filter = self.Entity
	tr4 = util.TraceLine(tr4)

	if tr2.HitPos != ground then
		self:SmallerExplo(tr2.HitPos, tr2.Normal)
	end

	if tr3.HitPos != ground then
		self:SmallerExplo(tr3.HitPos, tr3.Normal)
	end

	if tr4.HitPos != ground then
		self:SmallerExplo(tr4.HitPos, tr4.Normal)
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(ground)
		effectdata:SetRadius(160)
		effectdata:SetMagnitude(115)
	util.Effect("HelicopterMegaBomb", effectdata)

	local exploeffect = EffectData()
		exploeffect:SetOrigin(ground)
		exploeffect:SetStart(ground)
	util.Effect("Explosion", exploeffect, true, true)

	local effectdata = EffectData()
	effectdata:SetOrigin(ground)			// Where is hits
	effectdata:SetNormal(Vector(0,0,1))		// Direction of particles
	effectdata:SetEntity(self.Owner)		// Who done it?
	effectdata:SetScale(3)			// Size of explosion
	effectdata:SetRadius(67)		// What texture it hits
	effectdata:SetMagnitude(3)			// Length of explosion trails
	util.Effect( "m9k_artillerycinematicboom", effectdata )
	--generic default, you are a god among men

	util.BlastDamage(self.Entity, (self:OwnerCheck()), ground, 650, 250)

	local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(ground)
		shake:SetKeyValue("amplitude", "4000")	// Power of the shake
		shake:SetKeyValue("radius", "5000")		// Radius of the shake
		shake:SetKeyValue("duration", "2.5")	// Time of shake
		shake:SetKeyValue("frequency", "255")	// How har should the screenshake be
		shake:SetKeyValue("spawnflags", "4")	// Spawnflags(In Air)
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)
		shake:Fire("Kill", "", 3)

		self.Entity:Remove()
end

function ENT:SmallerExplo(targ, norm)
	util.BlastDamage(self, (self:OwnerCheck()), targ, 550, 250)

	local effectdata = EffectData()
		effectdata:SetOrigin(targ)
		effectdata:SetRadius(120)
		effectdata:SetMagnitude(115)
	util.Effect("HelicopterMegaBomb", effectdata)

	local exploeffect = EffectData()
		exploeffect:SetOrigin(targ)
		exploeffect:SetStart(targ)
	util.Effect("Explosion", exploeffect, true, true)
end


function ENT:OwnerCheck()
	if IsValid(self.Owner) then
		return (self.Owner)
	else
		return (self.Entity)
	end
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()
	if not IsValid(self) then return end
	if not IsValid(self.Entity) then return end

	if not IsValid(self.Owner) then
		SafeRemoveEntity(self)
	end

	if(!self.lifeTime) then
		SafeRemoveEntity(self)
	end

	if(self.lifeTime < CurTime()) then
		SafeRemoveEntity(self)
	end
end

function ENT:PhysicsCollide(data, physobj)
	self:MassiveFuckingExplosion()

	self.lifeTime = 0 --delete it
end
end
