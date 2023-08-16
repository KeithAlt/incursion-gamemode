AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Delay = 10

function ENT:Initialize()
	local mdl = self:GetModel()

	if not mdl or mdl == "" or mdl == "models/error.mdl" then
		self:SetModel("models/weapons/w_missile_launch.mdl")
	end

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)   
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.SpawnTime = CurTime()
 
	self.PhysObj = self.Entity:GetPhysicsObject()

	if (self.PhysObj:IsValid()) then
        self.PhysObj:Wake()
	end

	self:SetFriction(self.Delay)
	self.killtime = CurTime() + self.Delay
	self:DrawShadow(true)
end

function ENT:Think()
	if self.killtime < CurTime() then
		self:Explode()

		return false
	end

	self:NextThink(CurTime())

	return true
end

local effectdata, shake

/*---------------------------------------------------------
   Name: ENT:Explode()
---------------------------------------------------------*/
function ENT:Explode()

	if not IsValid(self.Owner) then
		self:Remove()

		return
	end

	local trace = {}
	trace.start = self.Entity:GetPos() + Vector(0, 0, 32)
	trace.endpos = self.Entity:GetPos() - Vector(0, 0, 128)
	trace.Entity = self.Entity
	trace.mask  = 16395
	local Normal = util.TraceLine(trace).HitNormal

	self.Scale = 2
	self.EffectScale = self.Scale ^ 0.65

	local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)

	local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetNormal(Normal)
		effectdata:SetScale(self.EffectScale)
	util.Effect("effect_sim_ignition", effectdata)
	
	local explo = ents.Create("env_explosion")
		explo:SetOwner(self.Owner)
		explo:SetPos(self.Entity:GetPos())
		explo:SetKeyValue("iMagnitude", "50")
		explo:SetKeyValue("iRadiusOverride", "250")
		explo:Spawn()
		explo:Activate()
		explo:Fire("Explode", "", 0)
		explo:Fire("kill","",0.1)
	
	local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(self.Entity:GetPos())
		shake:SetKeyValue("amplitude", "2000")	// Power of the shake
		shake:SetKeyValue("radius", "900")		// Radius of the shake
		shake:SetKeyValue("duration", "2.5")	// Time of shake
		shake:SetKeyValue("frequency", "255")	// How har should the screenshake be
		shake:SetKeyValue("spawnflags", "4")	// Spawnflags(In Air)
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)
		shake:Fire("kill","",0.1)
	
	local ar2Explo = ents.Create("env_ar2explosion")
		ar2Explo:SetOwner(self.Owner)
		ar2Explo:SetPos(self.Entity:GetPos())
		ar2Explo:Spawn()
		ar2Explo:Activate()
		ar2Explo:Fire("Explode", "", 0)
		ar2Explo:Fire("kill","",0.1)
	
	self:Remove()
end

/*---------------------------------------------------------
   Name: ENT:PhysicsCollide()
---------------------------------------------------------*/
function ENT:PhysicsCollide(data, physobj) 

	util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal) 

	self:Explode()
	self.Entity:Remove()
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 60 then
		--self.killtime = CurTime() - 1
		self:Explode()
	end
end