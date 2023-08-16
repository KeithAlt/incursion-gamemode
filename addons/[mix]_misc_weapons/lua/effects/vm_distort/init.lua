function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	
	self.Speed = data:GetMagnitude()

	self.Speed = self.Speed-0

	local emitter = ParticleEmitter( self.Position )
	local particle = emitter:Add( "Effects/strider_pinch_dudv", self.Position)

	particle:SetVelocity( Vector( 0, 0, 0))
	particle:SetDieTime(3)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(50)
	particle:SetEndSize(800)

	emitter:Finish()
end

function EFFECT:Render()
end

function EFFECT:Think( )
	return false	
end