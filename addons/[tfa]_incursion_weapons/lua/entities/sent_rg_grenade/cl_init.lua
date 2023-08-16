include("shared.lua")

function ENT:Initialize()

self.Emitter = ParticleEmitter(self.Entity:GetPos())
self.LastEmit = 0
self.SmokeKillTime = CurTime() + 5 -- Stop emitting smoke after awhile

end



function ENT:Draw()

	self.Entity:DrawModel()

	self.LastEmit = self.LastEmit or 0
	local CurrentTime = CurTime()

	if CurrentTime > self.SmokeKillTime then return end

	local Velocity = self.Entity:GetVelocity()
	local Speed = Velocity:Length()

	if CurrentTime < self.LastEmit + 2/Speed then return end

	local Pos = self.Entity:GetPos()

	local particle = self.Emitter:Add("particles/smokey", Pos)
	particle:SetVelocity(VectorRand()*12)
	particle:SetGravity(Vector(5,5,3))
	particle:SetDieTime(math.Rand(2,2.5))
	particle:SetStartAlpha(math.Rand(40,50))
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(9,14))
	particle:SetEndSize(math.Rand(35,45))
	particle:SetRoll(math.Rand(200,300))
	particle:SetRollDelta(math.Rand(-1,1))
	particle:SetColor(40,40,40)
	particle:SetAirResistance(5)

	self.LastEmit = CurrentTime

end


function ENT:OnRemove()

	self.Emitter:Finish()

end




