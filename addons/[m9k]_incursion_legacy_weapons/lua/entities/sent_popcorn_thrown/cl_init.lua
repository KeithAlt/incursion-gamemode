include("shared.lua")

local emitter = ParticleEmitter(Vector(0,0,0))

local function kernel_init(particle, vel)
	particle:SetColor(255,255,255,255)
	particle:SetVelocity( vel or VectorRand():GetNormalized() * 15)
	particle:SetGravity( Vector(0,0,-200) )
	particle:SetLifeTime(0)
	particle:SetDieTime(math.Rand(5,10))
	particle:SetStartSize(2)
	particle:SetEndSize(0)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetCollide(true)
	particle:SetBounce(0.25)
	particle:SetRoll(math.pi*math.Rand(0,1))
	particle:SetRollDelta(math.pi*math.Rand(-10,10))
end

function ENT:Initialize()
	
	emitter:SetPos(LocalPlayer():GetPos())
	
	if IsValid(self) then
		local kt = "kernel_timer"..self:EntIndex()
		timer.Create(kt,0.01,0,function()
			if !emitter then
				emitter = ParticleEmitter(LocalPlayer():GetPos())
				return 
			end
			if !IsValid(self) then 
				timer.Destroy(kt)
				return 
			end
			if math.Rand(0,1) < 0.33 then
				local particle = emitter:Add( "particle/popcorn-kernel", self:GetPos() + VectorRand():GetNormalized() * 4 )
				if particle then
					kernel_init(particle)
				end
			end
		end)
	end

	net.Receive("Popcorn_Explosion",function () 

		if !self or !emitter then return end
		local pos = net.ReadVector()
		local norm = net.ReadVector()
		local bucketvel = net.ReadVector()
		local entid = net.ReadFloat()
		
		timer.Destroy("kernel_timer"..entid)
		
		for i = 1,150 do
			local particle = emitter:Add( "particle/popcorn-kernel", pos )
			if particle then
				local dir = VectorRand():GetNormalized()
				kernel_init(particle, ((-norm)+dir):GetNormalized() * math.Rand(0,200) + bucketvel*0.5 )
			end
		end
	end)
end
