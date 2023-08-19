function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	
	self.Speed = data:GetMagnitude()

	self.Speed = self.Speed-0

	local emitter = ParticleEmitter( self.Position )
	local particle = emitter:Add( "Effects/strider_pinch_dudv", self.Position)

	particle:SetVelocity( Vector( 0, 0, 0))
	particle:SetDieTime(0.9)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(0)
	particle:SetEndSize(650)

	emitter:Finish()
end

function EFFECT:Render()
end