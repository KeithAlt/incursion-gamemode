
TRACER_FLAG_USEATTACHMENT	= 0x0002;
SOUND_FROM_WORLD			= 0;
CHAN_STATIC					= 6;

EFFECT.Speed				= 1200;
EFFECT.Length				= 64;
//EFFECT.WhizSound			= Sound( "nomad/whiz.wav" );		-- by Robinhood76 (http:--www.freesound.org/people/Robinhood76/sounds/96556/)
EFFECT.WhizDistance			= 72;

local MaterialMain			= Material( "effects/combinemuzzle2_dark" );

function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin();
	--
	if not self.StartPos or not self.EndPos then return end
		
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos );

	local diff = ( self.EndPos - self.StartPos );
	
	self.Normal = diff:GetNormal();
	self.StartTime = 0;
	self.LifeTime = ( diff:Length() + self.Length ) / self.Speed;
	-- whiz by sound
	local weapon = data:GetEntity();
	
	local vOffset = data:GetOrigin()
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()
	self.Scale = data:GetScale()
	self.Magnitude = data:GetMagnitude()
	self.Emitter = ParticleEmitter( self.Origin )
	
	--util.ParticleTracerEx( "plasma_projectile_trail", self.StartPos, self.EndPos, true, self.Entity:EntIndex() or 0, -1 )
	--ParticleEffect( "plasma_projectile_trail", self.StartPos, Angle(0,0,0), self.Entity )
	ParticleEffectAttach( "plasma_projectile_trail", PATTACH_ABSORIGIN_FOLLOW, self.Entity, -1 )	
	
	timer.Simple(self.LifeTime - 0.1,function()
		if !IsValid(self) then return end
		self:PlasmaHit(vOffset,data:GetNormal())
	end)
end

function EFFECT:PlasmaHit(vOffset,normal)

	local emitter = ParticleEmitter( vOffset )

		for i=1,5 do 
			local Flash = self.Emitter:Add( "effects/combinemuzzle2_dark", self.Origin )
			if (Flash) then
				Flash:SetVelocity( VectorRand()*50 )
				Flash:SetAirResistance( 200 )
				Flash:SetDieTime( 0.5 )
				Flash:SetStartAlpha( 155 )
				Flash:SetEndAlpha( 0 )
				Flash:SetStartSize( 40 )
				Flash:SetEndSize( 0 )
				Flash:SetRoll( math.Rand(180,480) )
				Flash:SetGravity( Vector( math.Rand(-100, 100) * self.Scale, math.Rand(-100, 100) * self.Scale, math.Rand(0, -100) ) ) 	
				Flash:SetRollDelta( math.Rand(-2,2) )
				Flash:SetColor(70,255,70)	
			end
		end


		for i=1,2 do 
			local particle = emitter:Add( "effects/combinemuzzle2_dark", vOffset )

				particle:SetVelocity( 10 * normal )
				particle:SetAirResistance( 600 )

				particle:SetDieTime( 0.3 )

				particle:SetStartAlpha( math.Rand(0, 55) )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( 8 * i )
				particle:SetEndSize( 5 * i )

				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )

				particle:SetColor(70,255,70)	
				particle:SetGravity( Vector( math.Rand(-100, 100) * self.Scale, math.Rand(-100, 100) * self.Scale, math.Rand(0, -100) ) ) 		
		end
		
	
			local particle = emitter:Add( "effects/combinemuzzle2_dark", vOffset )

				particle:SetVelocity( 80 * normal + 20 * VectorRand() )
				particle:SetAirResistance( 200 )

				particle:SetDieTime( math.Rand(0.2, 0.45) )
				particle:SetStartAlpha( math.Rand(0, 55) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random(25,30) )
				particle:SetEndSize( 3 )

				particle:SetColor(70,255,70)	
				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )

	emitter:Finish()
				Sound( "weapons/plasmarifle/impacts/fx_plasma_impact_01.wav", self.Origin,75, 100)
	
end

function EFFECT:Think()
	local endDistance = self.Speed * self.StartTime;
	local startDistance = endDistance - self.Length;
	
	startDistance = math.max( 0, startDistance );
	local startPos = self.StartPos + self.Normal * startDistance;

	self.Entity:SetPos( startPos )
	-- --
	self.LifeTime = self.LifeTime - FrameTime();
	self.StartTime = self.StartTime + FrameTime();
	--
	return self.LifeTime > 0;
end


function EFFECT:Render()

end

