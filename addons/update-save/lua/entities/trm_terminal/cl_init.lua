include('shared.lua')

sound.Add( {
	name = "terminal_fan",
	channel = CHAN_STATIC,
	volume = 1,
	level = 65,
	pitch = 100,
	sound = "terminalr/fan.wav"
} )

function ENT:Draw()
    self:DrawModel()
	if ( self:GetNWBool("Terminal:O/F") ) then
		local angles = self:GetAngles()
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.pos = self:GetPos() + angles:Forward()*6 + angles:Up()*13
			dlight.r = 30
			dlight.g = 129
			dlight.b = 50
			dlight.brightness = 2
			dlight.Decay = 1000
			dlight.Size = 80
			dlight.DieTime = CurTime() + 1
		end
		if ( CurTime() > self.NextDiskSound ) then
			self:EmitSound( "terminalr/disk/a/" .. math.random( 1, 15 ) .. ".wav", 65, 100, 1, CHAN_AUTO )
			self.NextDiskSound = CurTime() + math.random( 2, 15 ) * 0.1
		end
		if ( CurTime() > self.NextFanSound ) then
			self:EmitSound( "terminal_fan", 75, 100, 1, CHAN_AUTO )
			self.FanEnabled = true
			self.NextFanSound = CurTime() + 2.2
		end
	else
		if ( self.FanEnabled == true ) then
			self:StopSound( "terminal_fan" )
			self.FanEnabled = false
		end
	end
end

function ENT:Initialize()
	self.NextDiskSound = CurTime()
	self.NextFanSound = CurTime()
	self.FanEnabled = true
end
























