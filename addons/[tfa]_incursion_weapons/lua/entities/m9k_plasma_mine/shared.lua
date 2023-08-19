ENT.Type = "anim"
ENT.PrintName			= "Plasma mine"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions			= ""

if SERVER then

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner

	self.Entity:SetModel("models/halokiller38/fallout/weapons/mines/plasmamine.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	self.Entity:SetAngles(Angle(-90, 0, 0))
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	end
	self.timeleft = CurTime() + 3
	self:Think()
	self.CanTool = false
end

 function ENT:Think()

	if self.timeleft < CurTime() then
 	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 140 ) ) do
		if v:IsPlayer() || v:IsNPC() then					// If its alive then
		local trace = {}						// Make sure theres not a wall in between
		trace.start = self.Entity:GetPos()
		trace.endpos = v:GetPos()			// Trace to the torso
		trace.filter = self.Entity
		local tr = util.TraceLine( trace )				// If the trace hits a living thing then
		if tr.Entity:IsPlayer() || tr.Entity:IsNPC() then self:Explosion() end
		end
	end
	end

	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:Explosion()
	if not IsValid(self) then return end

	util.BlastDamage(self, self:GetOwner() or nil, self:GetPos(), 300, 125)
	util.ScreenShake(self:GetPos(), 25, 25, 1, 1500)

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1500)) do
		if v:IsPlayer() and v:Alive() and v:GetMoveType() ~= MOVETYPE_NOCLIP then
			v:ScreenFade(SCREENFADE.IN, Color(0,255,0, 55), 0.5, 0.5)

			if v:GetPos():Distance(self:GetPos()) < 500 then
				v:Ignite(6)
			end
		end
	end

	ParticleEffect("pgex*", self:GetPos(), self:GetAngles(), NULL)
	ParticleEffect("_sai_green_fire_3", self:GetPos(), self:GetAngles(), self)

	self:EmitSound("weapons/plasmagrenade/plasma_grenade_explosion.ogg")

	timer.Simple(0.5, function()
		if IsValid(self) then
			self:EmitSound("ambient/energy/weld" .. math.random(1,2) .. ".wav")
		end
	end)
end

function ENT:VectorGet()
	local startpos = self.Entity:GetPos()

	local downtrace = {}
	downtrace.start = startpos
	downtrace.endpos = startpos + self.Entity:GetUp()*-5
	downtrace.filter = self.Entity
	tracedown = util.TraceLine(downtrace)

	if (tracedown.Hit) then
		return (tracedown.HitNormal)
	else
		return(Vector(0,0,1))
	end

end

/*---------------------------------------------------------
OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
local GoodLuck = math.random(1,5)
	if GoodLuck == 1 then
		self:Explosion()
	end
end

end
