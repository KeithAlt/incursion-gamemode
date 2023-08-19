
TRACER_FLAG_USEATTACHMENT	= 0x0002;
SOUND_FROM_WORLD			= 0;
CHAN_STATIC					= 6;

EFFECT.Speed				= 2100;
EFFECT.Length				= 64;
//EFFECT.WhizSound			= Sound( "nomad/whiz.wav" );		-- by Robinhood76 (http:--www.freesound.org/people/Robinhood76/sounds/96556/)
EFFECT.WhizDistance			= 72;

local MaterialMain			= Material( "pw_fallout/sprites/blast1.png" );

function EFFECT:Init( data )

	self.StartPos = data:GetStart();
	self.EndPos = data:GetOrigin();
	--
	if not self.StartPos or not self.EndPos then return end
	
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos );

	local diff = ( self.EndPos - self.StartPos );
	
	self.Normal = diff:GetNormal();
	self.StartTime = 0;
	self.LifeTime = ( diff:Length() + self.Length ) / self.Speed;
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()
	
	timer.Simple(self.LifeTime - 0.1,function()
		if not self or not self.EndPos then return end
		--
		local hit = EffectData()
		hit:SetOrigin( self.EndPos )
		util.Effect( "effect_fo3_alienblasterhit", hit )
	end)
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

