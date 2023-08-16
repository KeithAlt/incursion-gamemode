function EFFECT:Init(data) --from Hoobsug, since it was just what i was looking for. it's part of his old badass sweps. if he wants this taken out he can gimme a buzz
	
	//if not IsValid(data:GetEntity()) then return end
	//if not IsValid(data:GetEntity():GetOwner()) then return end
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	//if self.WeaponEnt == nil or self.WeaponEnt:GetOwner() == nil or self.WeaponEnt:GetOwner():GetVelocity() == nil then 
		//return
	//else
	
	//self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
	local emitter = ParticleEmitter(data:GetOrigin())

for i=1, 5 do
			local Blood = {}
			Blood[1] = "decals/yblood2"
			Blood[2] = "decals/yblood1"
			Blood[3] = "decals/yblood3"
			Blood[4] = "decals/yblood1"
			local particle = emitter:Add( Blood[math.random(1,4)], self.Position - self.Forward * 4, (Color(255,0,0,25)) )
			particle:SetVelocity( 10 * VectorRand() + 10 * VectorRand() + 10 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -500 ) )
			particle:SetAirResistance( 0 )
			//particle:SetColor(Color(255,0,0,25))

			particle:SetDieTime( 1 )

			particle:SetStartSize( 5 )
			particle:SetEndSize( 0 )
			
			particle:SetStartLength( 0 ) 
			particle:SetEndLength( 105 )

			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			//particle:SetBounce( 1 )
			particle:SetCollide( true )
			
			particle:SetCollideCallback( function()
				local tr = {}
			 	tr.start = particle:GetPos()
			 	tr.endpos = particle:GetPos() + particle:GetAngles():Forward() * 50
			 	tr.filter = particle
				local tr = util.TraceLine( tr )
			util.Decal( "YellowBlood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
			end)

end

emitter:Finish()
end
//end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end