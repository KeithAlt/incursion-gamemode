
TRACER_FLAG_USEATTACHMENT	= 0x0002;
SOUND_FROM_WORLD			= 0;
CHAN_STATIC					= 6;

EFFECT.Speed				= 5500;
EFFECT.Length				= 64;
//EFFECT.WhizSound			= Sound( "nomad/whiz.wav" );		-- by Robinhood76 (http:--www.freesound.org/people/Robinhood76/sounds/96556/)
EFFECT.WhizDistance			= 72;

local MaterialMain			= Material( "pw_fallout/sprites/blast1.png" );

function EFFECT:GetTracerOrigin( data )

	-- this is almost a direct port of GetTracerOrigin in fx_tracer.cpp
	local start = data:GetStart();
	
	-- use attachment?
	if( bit.band( data:GetFlags(), TRACER_FLAG_USEATTACHMENT ) == TRACER_FLAG_USEATTACHMENT ) then

		local entity = data:GetEntity();
		
		if( not IsValid( entity ) ) then return start; end
		if( not game.SinglePlayer() and entity:IsEFlagSet( EFL_DORMANT ) ) then return start; end
		
		if( entity:IsWeapon() and entity:IsCarriedByLocalPlayer() ) then
			-- can't be done, can't call the real function
			-- local origin = weapon:GetTracerOrigin();
			-- if( origin ) then
			-- 	return origin, angle, entity;
			-- end
			
			-- use the view model
			local pl = entity:GetOwner();
			if( IsValid( pl ) ) then
				local vm = pl:GetViewModel();
				if( IsValid( vm ) and not LocalPlayer():ShouldDrawLocalPlayer() ) then
					entity = vm;
				else
					-- HACK: fix the model in multiplayer
					if( entity.WorldModel ) then
						entity:SetModel( entity.WorldModel );
					end
				end
			end
		end
		entity = data:GetEntity()
		if !entity:IsCarriedByLocalPlayer() or LocalPlayer():ShouldDrawLocalPlayer() then
          local wep = entity:GetOwner().FalloutWep
		  if !IsValid(wep) then return start end
		  local attachment = wep:GetAttachment( data:GetAttachment() );
		  if( attachment ) then
			start = attachment.Pos;
			return start
		  end
        end
	end
	
	local ViewModel = LocalPlayer():GetViewModel()
	local att = ViewModel:GetAttachment( data:GetAttachment() )
	if ( att ) then
	  start = att.Pos
	  self.ViewModelTracer = true
	end
	
	return start;

end


function EFFECT:Init( data )

	self.StartPos = self:GetTracerOrigin( data );
	self.EndPos = data:GetOrigin();
	
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
				Flash:SetVelocity( VectorRand() )
				Flash:SetAirResistance( 200 )
				Flash:SetDieTime( 0.15 )
				Flash:SetStartAlpha( 255 )
				Flash:SetEndAlpha( 0 )
				Flash:SetStartSize( 50 )
				Flash:SetEndSize( 0 )
				Flash:SetRoll( math.Rand(180,480) )
				Flash:SetRollDelta( math.Rand(-1,1) )
				Flash:SetColor(165,234,255)	
			end
		end


		for i=1,2 do 
			local particle = emitter:Add( "effects/stunstick", vOffset )

				particle:SetVelocity( 10 * normal )
				particle:SetAirResistance( 600 )

				particle:SetDieTime( 0.2 )

				particle:SetStartAlpha( math.Rand(0, 55) )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( 8 * i )
				particle:SetEndSize( 5 * i )

				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )

				particle:SetColor(255,255,255)	
				particle:SetGravity( Vector( math.Rand(-100, 100) * self.Scale, math.Rand(-100, 100) * self.Scale, math.Rand(0, -100) ) ) 		
		end
		
	
			local particle = emitter:Add( "effects/combinemuzzle1_dark", vOffset )

				particle:SetVelocity( 80 * normal + 20 * VectorRand() )
				particle:SetAirResistance( 200 )

				particle:SetDieTime( math.Rand(0.2, 0.25) )

				particle:SetStartSize( math.random(15,20) )
				particle:SetEndSize( 3 )

				particle:SetColor(165,234,255)	
				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )

	emitter:Finish()
end

function EFFECT:Think()
	self.LifeTime = self.LifeTime - FrameTime();
	self.StartTime = self.StartTime + FrameTime(); 

	return self.LifeTime > 0;

end


function EFFECT:Render()

	local endDistance = self.Speed * self.StartTime;
	local startDistance = endDistance - self.Length;
	
	startDistance = math.max( 0, startDistance );
	endDistance = math.max( 0, endDistance );

	local startPos = self.StartPos + self.Normal * startDistance;
	local endPos = self.StartPos + self.Normal * endDistance;
	local wide = 8
	local tall = 22
	
	render.SetMaterial( MaterialMain );
	local normal = self.Normal:Angle()
	normal:RotateAroundAxis( normal:Up(), -90 )
	normal = normal:Forward()
	render.DrawQuadEasy( startPos, normal, wide, tall, Color(255,255,255), 90 )
	render.DrawQuadEasy( startPos, -normal, wide, tall, Color(255,255,255), -90 )
	
	local normal = self.Normal:Angle()
	normal:RotateAroundAxis( normal:Forward(), 180 )
	normal = normal:Forward()
	render.DrawQuadEasy( startPos, normal, wide, wide, Color(255,255,255), 0 )
	render.DrawQuadEasy( startPos, -normal, wide, wide, Color(255,255,255), 0 )	
	
end

