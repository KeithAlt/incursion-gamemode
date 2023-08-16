
local tMats = {}
tMats.Glow1 = Material("sprites/light_glow02")
tMats.Glow2 = Material("sprites/flare1")

for _,mat in pairs(tMats) do

	mat:SetInt("$spriterendermode",9)
	mat:SetInt("$ignorez",1)
	mat:SetInt("$illumfactor",8)
	
end

local SmokeParticleUpdate = function(particle)

	if particle:GetStartAlpha() == 0 and particle:GetLifeTime() >= 0.5*particle:GetDieTime() then
		particle:SetStartAlpha(particle:GetEndAlpha())
		particle:SetEndAlpha(0)
		particle:SetNextThink(-1)
	else
		particle:SetNextThink(CurTime() + 0.1)
	end

	return particle

end


function EFFECT:Init(data)

	self.Scale = data:GetScale()
	self.ScaleSlow = math.sqrt(self.Scale)
	self.ScaleSlowest = math.sqrt(self.ScaleSlow)
	self.Normal = data:GetNormal()
	self.RightAngle = self.Normal:Angle():Right():Angle()
	self.Position = data:GetOrigin() - 12*self.Normal
	self.Position2 = self.Position + self.Scale*64*self.Normal
	self.DirVec = data:GetNormal()
	
	local CurrentTime = CurTime()
	self.Duration = 0.5*self.Scale 
	self.KillTime = CurrentTime + self.Duration
	self.GlowAlpha = 200
	self.GlowSize = 100*self.Scale
	self.FlashAlpha = 100
	self.FlashSize = 0

		local emitter = ParticleEmitter(self.Position)
				--dirt
		for i=1,math.ceil(self.Scale*250) do
			
			local vecang = (self.Normal + VectorRand()*math.Rand(0,3)):GetNormalized()
			local particle = emitter:Add("particles/Dirt",   self.Position + vecang*64*self.Scale)
			local size = math.Rand(10,250)
			particle:SetVelocity(vecang*math.Rand(10,20)*self.ScaleSlow)
			particle:SetGravity(Vector(math.Rand(-200,200),math.Rand(-200,200),0))
			particle:SetAirResistance(100)
			particle:SetDieTime(math.Rand(30.5,38.9)*self.Scale)
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(size)
			particle:SetEndSize(size)
			particle:SetRoll(math.Rand(-100,100))
			particle:SetRollDelta(math.Rand(0.1,0.5)*math.random(-1,1))
			particle:SetCollide(true)
			particle:SetColor(196,177,139)
			end
			--dirt embers
					for i=1,math.ceil(self.Scale*10) do
			
			local vecang = (self.Normal + VectorRand()*math.Rand(0,3)):GetNormalized()
			local particle = emitter:Add("effects/fire_embers"..math.random(1,3),   self.Position + vecang*64*self.Scale)
			local size = math.Rand(5,10)
			particle:SetVelocity(vecang*math.Rand(10,20)*self.ScaleSlow)
			particle:SetGravity(Vector(math.Rand(-200,200),math.Rand(-200,200),0))
			particle:SetAirResistance(100)
			particle:SetDieTime(math.Rand(25.5,28.9)*self.Scale)
			particle:SetStartAlpha(100)
			particle:SetEndAlpha(0)
			particle:SetStartSize(size)
			particle:SetEndSize(size)
			particle:SetRoll(math.Rand(-100,100))
			particle:SetRollDelta(math.Rand(0.1,0.5)*math.random(-1,1))
			particle:SetCollide(true)
			particle:SetColor(196,177,139)
			end
			
			--floating pillar of embers
		for i=1,math.ceil(self.Scale*30) do
			
			local vecang = (self.Normal + VectorRand()*math.Rand(0,3)):GetNormalized()
			local velocity = math.Rand(0,500)*vecang*self.Scale
			local particle = emitter:Add("effects/fire_embers"..math.random(1,3),   self.Position + vecang*64*self.Scale)
			local size = math.Rand(10,25)
			particle:SetVelocity(velocity)
			particle:SetGravity(Vector(0,0,math.Rand(0,100)))
			particle:SetAirResistance(100)
			particle:SetDieTime(math.Rand(25.5,30.9)*self.ScaleSlow)
			particle:SetStartAlpha(100)
			particle:SetEndAlpha(0)
			particle:SetStartSize(size)
			particle:SetEndSize(size)
			particle:SetRoll(math.Rand(100,100))
			particle:SetRollDelta(0.3*math.random(-1,1))
			particle:SetCollide(true)
			particle:SetColor(200,200,200)

		end
--smoke mushroom
		for i=1,math.ceil(self.Scale*25) do
			
			      local vecang = VectorRand()*2
		            local spawnpos = self.Position 	
                        local velocity = math.Rand(50,300)*vecang			
				local particle = emitter:Add("particles/Dirt",   spawnpos - vecang*9*k)
                        local dietime = math.Rand(20.5,20.9)*self.Scale
				particle:SetVelocity(velocity*self.Scale)
				particle:SetDieTime(dietime)
                        particle:SetGravity(Vector(math.Rand(-90,90),math.Rand(-90,90),math.Rand(300,300)))
                        particle:SetAirResistance(105)
                        particle:SetStartAlpha(150)
				particle:SetStartSize(math.Rand(200,250)*self.ScaleSlow)
			      particle:SetEndSize(math.Rand(1300,1300)*self.ScaleSlow)
			      particle:SetRoll(math.Rand(10,10))
			      particle:SetRollDelta(0.3*math.random(-1,1))
				particle:SetColor(196,177,139)
		
		end
		
		--mushroom embers
				for i=1,math.ceil(self.Scale*150) do
			
			      local vecang = VectorRand()*3
		            local spawnpos = self.Position 	
                        local velocity = math.Rand(10,500)*vecang			
				local particle = emitter:Add("effects/fire_embers"..math.random(1,3),   spawnpos - vecang*9*k)
                        local dietime = math.Rand(20.5,20.9)*self.Scale
				particle:SetVelocity(velocity*self.Scale)
				particle:SetDieTime(dietime)
                        particle:SetGravity(Vector(math.Rand(-90,90),math.Rand(-90,90),math.Rand(-250,250)))
                        particle:SetAirResistance(65)
                        particle:SetStartAlpha(100)
				particle:SetStartSize(math.Rand(5,10)*self.ScaleSlow)
			      particle:SetEndSize(math.Rand(15,20)*self.ScaleSlow)
			      particle:SetRoll(math.Rand(-10,10))
			      particle:SetRollDelta(0.3*math.random(-1,1))
				particle:SetColor(255,255,255)
		
		end
		
		--mushroom fire
		for i=1,math.ceil(self.Scale*10) do
			
			      local vecang = VectorRand()*2
		            local spawnpos = self.Position 	
                        local velocity = math.Rand(50,200)*vecang			
				local particle = emitter:Add("particles/FireExplosion",   spawnpos - vecang*9*k)
                        local dietime = math.Rand(20.5,20.9)*self.Scale
				particle:SetVelocity(velocity*self.Scale)
				particle:SetDieTime(dietime)
                        particle:SetGravity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(200,200)))
                        particle:SetAirResistance(65)
                        particle:SetStartAlpha(10)
				particle:SetStartSize(math.Rand(100,200)*self.ScaleSlow)
			      particle:SetEndSize(math.Rand(300,500)*self.ScaleSlow)
			      particle:SetRoll(math.Rand(-10,10))
			      particle:SetRollDelta(0.3*math.random(-1,1))
				particle:SetColor(255,255,255)
		
		end

	--pillar of dust
		for i=1,math.ceil(self.Scale*40) do

			local vecang = (self.Normal + VectorRand()*math.Rand(0,5)):GetNormalized()
			local velocity = math.Rand(0,500)*vecang*self.Scale
			local particle = emitter:Add("particles/Dirt",   self.Position + vecang*math.Rand(-20,75)*self.Scale)
			local dietime = math.Rand(20.5,20.9)*self.Scale
			particle:SetVelocity(velocity)
			particle:SetGravity(Vector(0,0,math.Rand(0,100)))
			particle:SetAirResistance(75)
			particle:SetDieTime(dietime)
			particle:SetLifeTime(math.Rand(-0.12,-0.08))
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(80,100)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(300,400)*self.ScaleSlow)
		      particle:SetRoll(math.Rand(-10,10))
		      particle:SetRollDelta(0.3*math.random(-1,1))
			particle:SetColor(196,177,139)
			
		end
		
		--pillar of fire
		
				for i=1,math.ceil(self.Scale*20) do

			local vecang = (self.Normal + VectorRand()*math.Rand(0,5)):GetNormalized()
			local velocity = math.Rand(0,500)*vecang*self.Scale
			local particle = emitter:Add("particles/FireExplosion",   self.Position + vecang*math.Rand(-20,75)*self.Scale)
			local dietime = math.Rand(20.5,20.9)*self.Scale
			particle:SetVelocity(velocity)
			particle:SetGravity(Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(0,200)))
			particle:SetAirResistance(65)
			particle:SetDieTime(dietime)
			particle:SetLifeTime(math.Rand(-0.12,-0.08))
			particle:SetStartAlpha(10)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(100,150)*self.ScaleSlow)
			particle:SetEndSize(math.Rand(300,500)*self.ScaleSlow)
		      particle:SetRoll(math.Rand(-10,10))
		      particle:SetRollDelta(0.3*math.random(-1,1))
			particle:SetColor(200,200,200)
			
		end

	emitter:Finish()
	
		surface.PlaySound("weapons/fatman/fx_explosion_nuke_small_2d.wav")
		self.Entity:EmitSound("weapons/fatman/fx_explosion_nuke_small_3d.wav")

end


--THINK
-- Returning false makes the entity die
function EFFECT:Think()
	local TimeLeft = self.KillTime - CurTime()
	local TimeScale = TimeLeft/self.Duration
	local FTime = FrameTime()
	if TimeLeft > 0 then 

		self.FlashAlpha = self.FlashAlpha - 200*FTime
		self.FlashSize = self.FlashSize + 60000*FTime
		
		self.GlowAlpha = 200*TimeScale
		self.GlowSize = TimeLeft*self.Scale

		return true
	else
		return false	
	end
end



-- Draw the effect
function EFFECT:Render()

--base glow
render.SetMaterial(tMats.Glow1)
render.DrawSprite(self.Position2,7000*self.GlowSize,5500*self.GlowSize,Color(255,240,220,self.GlowAlpha))

--blinding flash
	if self.FlashAlpha > 0 then
		render.SetMaterial(tMats.Glow2)
		render.DrawSprite(self.Position2,self.FlashSize,self.FlashSize,Color(255,245,215,self.FlashAlpha))
	end


end



