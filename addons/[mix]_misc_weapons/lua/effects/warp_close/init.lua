function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	
	self.Speed = data:GetMagnitude()

	self.Speed = self.Speed-0

	local emitter = ParticleEmitter( self.Position )
	local particle = emitter:Add( "Effects/ruby_portal", self.Position)

	particle:SetVelocity( Vector( 0, 0, 0))
	particle:SetDieTime(4)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(100)
	particle:SetEndSize(0)
	particle:SetPos(self:GetPos() + Vector(0,0,200))	

	emitter:Finish()
end


function EFFECT:Think( )
	return false	
end

function EFFECT:Render()
	local Light = DynamicLight( self:EntIndex() )
	if ( Light ) then
		Light.Pos = (self:GetPos() + Vector(0,0,200))
		Light.r = 220
		Light.g = 0
		Light.b = 255
		Light.Brightness = 2
		Light.Size = 850
		Light.Decay = 200
		Light.DieTime = CurTime() + 7
	end
end