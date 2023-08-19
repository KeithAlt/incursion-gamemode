include("shared.lua")

function ENT:Initialize()

	self.Emitter = ParticleEmitter(self.Entity:GetPos())

end

/*---------------------------------------------------------
   Name: Draw
   Desc: Draw it!
---------------------------------------------------------*/
function ENT:Draw()
	self.Entity:DrawModel()
	
	local vel = self.Entity:GetVelocity()
	local vellen = vel:Length()

	if vellen < 1000 then return end

	local particle = self.Emitter:Add("particle/particle_smokegrenade", self.Entity:GetPos())
	particle:SetVelocity(Vector(math.Rand(5,10),math.Rand(5,10),math.Rand(5,10)))
	particle:SetGravity(Vector(0,0,-math.Rand(50,100)))
	particle:SetDieTime(math.Rand(0.5,3))
	particle:SetStartAlpha(math.Rand(200,255))
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(0.1,1))
	particle:SetEndSize(math.Rand(10,35))
	particle:SetRoll(math.Rand(200,300))
	particle:SetRollDelta(math.Rand(-1,1))
	particle:SetColor( 225, 225, 225 )
	particle:SetAirResistance(15)
	particle:SetLighting(true)
	particle:SetCollide( true )
	
end

function ENT:OnRemove()

	self.Emitter:Finish()

end
