ENT.Type = "anim"
ENT.PrintName = "Orbital Resource Drop"
ENT.Author = "Vex"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/mosi/fallout4/props/fortifications/vaultcrate03.mdl")
		self:SetSkin(2)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
			physObj:SetMass(100)
			--physObj:SetVelocity(Vector(0, 0, -10000))
		end;

		self.fire = ents.Create("env_fire_trail")
		if IsValid(self.fire) then
			self.fire:SetPos(self:GetPos() + Vector(0, 0, 3))
			self.fire:Spawn()
			self.fire:SetParent(self)
		end;

		self:setNetVar("impact", false)

		self.generated = false
	end;

	function ENT:Use(activator)
		self.nextUse = self.nextUse or CurTime()
		if (self.nextUse > CurTime()) then
			return
		else
			self.nextUse = CurTime() + 1
		end;

		if (!self:getNetVar("items", nil) and !self:getNetVar("generated", false)) then
			nut.looter.generate(activator, self, 6, "orbit")
			self:setNetVar("generated", true)
		else
			netstream.Start(activator, "looterUI", self)
		end;
	end;

	function ENT:SpawnFunction(client, trace)
		if (!trace.Hit or trace.HitSky) then return end;

		local tr = util.TraceLine({
			start = trace.HitPos,
			endpos = trace.HitPos + Vector(0, 0, 100000)
		})

		local spawnPosition = tr.HitPos - Vector(0, 0, 10)

		local ent = ents.Create("nut_orbit_drop")

		ent:SetPos(spawnPosition)
		ent:Spawn()
		ent:Activate()
	end;

	function ENT:explode(data)
		local fx = EffectData()
		fx:SetOrigin(data.HitPos)
		fx:SetNormal(data.HitNormal)
		util.Effect("nut_mimpact", fx, true, true)
		util.Effect("nut_mairexplode", fx, true, true)

		sound.Play("ambient/explosions/explode_"..math.random(1,5)..".wav", self:GetPos(), 100, 100)
		sound.Play("physics/concrete/concrete_break"..math.random(2,3)..".wav", self:GetPos(), 100, 100)

		util.ScreenShake(self:GetPos(), 6, 9, 2.5, 10000)

		--self:Remove()
	end;

	function ENT:PhysicsCollide(data)
		if (self:getNetVar("impact")) then
			return
		end;

		self:explode(data)
		self:setNetVar("impact", true)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Sleep()
		end;

		timer.Simple(300, function()
			if (IsValid(self)) then
				self:EmitSound("fallout/orbit/self_destruct.wav")
				timer.Simple(5, function()
					self:explode(data)
					self:Remove()
				end)
			end;
		end)
	end;
end;

-- EFFECTS START --
if (CLIENT) then
	local Air = {}

	function Air:Init(data)
		local vOrig = data:GetOrigin()

		self.Emitter = ParticleEmitter(vOrig)
		self.Emitter:SetNearClip(128,192)

		for i=1,24 do
			local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)
			if (smoke) then
				smoke:SetColor(0, 0, 0)
				smoke:SetVelocity(VectorRand():GetNormal()*math.random(200, 400))
				smoke:SetRoll(math.Rand(0, 360))
				smoke:SetRollDelta(math.Rand(-2, 2))
				smoke:SetDieTime(1)
				smoke:SetLifeTime(0)
				smoke:SetStartSize(50)
				smoke:SetStartAlpha(255)
				smoke:SetEndSize(150)
				smoke:SetEndAlpha(0)
				smoke:SetGravity(Vector(0,0,0))
			end;
		end;

		for i=1,8 do
			local flash = self.Emitter:Add("effects/muzzleflash2", vOrig)
			if (flash) then
				flash:SetColor(255, 255, 255)
				flash:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
				flash:SetRoll(math.Rand(0, 360))
				flash:SetDieTime(0.10)
				flash:SetLifeTime(0)
				flash:SetStartSize(150)
				flash:SetStartAlpha(255)
				flash:SetEndSize(350)
				flash:SetEndAlpha(0)
				flash:SetGravity(Vector(0,0,0))
			end;
		end;
	end;

	function Air:Think()
		return false
	end;

	function Air:Render()
		return false
	end;

	effects.Register(Air,"nut_mairexplode")

	local Impact = {}

	Impact.Refract = Material("effects/strider_pinch_dudv")

	function Impact:Init(data)
		self.Pos = data:GetOrigin()
		self.Normal = data:GetNormal():Angle() + Angle(0.01, 0.01, 0.01)

		local trdata = {}
		trdata.start = self.Pos
		trdata.endpos = self.Pos + data:GetNormal()
		local tr = util.TraceLine(trdata)
		util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

		self.LerpSize = 200
		self.EndSize = 1250

		self.LerpRefract = 1

		self.DieTime = CurTime() + 0.5
		self.FadeSpeed = 5

		self.Emitter = ParticleEmitter(self.Pos)
		self.Emitter:SetNearClip(128,192)

		local vOrig = self.Pos

		for i=1,24 do
			local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)

			if (smoke) then
				smoke:SetColor(0, 0, 0)
				smoke:SetVelocity(VectorRand():GetNormal()*math.random(300, 600))
				smoke:SetRoll(math.Rand(0, 360))
				smoke:SetRollDelta(math.Rand(-2, 2))
				smoke:SetDieTime(1)
				smoke:SetLifeTime(0)
				smoke:SetStartSize(100)
				smoke:SetStartAlpha(255)
				smoke:SetEndSize(300)
				smoke:SetEndAlpha(0)
				smoke:SetGravity(Vector(0,0,0))
			end;

			local smoke3 = self.Emitter:Add("particle/particle_smokegrenade", vOrig+Vector(math.random(-150,150),math.random(-150,150),0))

			if (smoke3) then
				smoke3:SetColor(50, 50, 50)
				smoke3:SetVelocity(VectorRand():GetNormal()*math.random(300, 600))
				smoke3:SetRoll(math.Rand(0, 360))
				smoke3:SetRollDelta(math.Rand(-2, 2))
				smoke3:SetDieTime(5)
				smoke3:SetLifeTime(0)
				smoke3:SetStartSize(100)
				smoke3:SetStartAlpha(255)
				smoke3:SetEndSize(300)
				smoke3:SetEndAlpha(0)
				smoke3:SetGravity(Vector(0,0,200))
			end;
		end;

		for i=1,12 do
			local heat = self.Emitter:Add("sprites/heatwave", vOrig+Vector(math.random(-150,150),math.random(-150,150),0))

			if (heat) then
				heat:SetColor(50, 50, 50)
				heat:SetVelocity(VectorRand():GetNormal()*math.random(50, 100))
				heat:SetRoll(math.Rand(0, 360))
				heat:SetRollDelta(math.Rand(-2, 2))
				heat:SetDieTime(3)
				heat:SetLifeTime(0)
				heat:SetStartSize(200)
				heat:SetStartAlpha(255)
				heat:SetEndSize(0)
				heat:SetEndAlpha(0)
				heat:SetGravity(Vector(0,0,0))
			end;
		end;

		for i=1,8 do
			local flash = self.Emitter:Add("effects/muzzleflash1", vOrig)
			if (flash) then
				flash:SetColor(255, 255, 255)
				flash:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
				flash:SetRoll(math.Rand(0, 360))
				flash:SetDieTime(0.10)
				flash:SetLifeTime(0)
				flash:SetStartSize(150)
				flash:SetStartAlpha(255)
				flash:SetEndSize(350)
				flash:SetEndAlpha(0)
				flash:SetGravity(Vector(0,0,0))
			end;
		end;
	end;

	function Impact:Think()
		self.LerpSize = Lerp(2 * self.FadeSpeed * FrameTime(), self.LerpSize, self.EndSize)
		self.LerpRefract = Lerp(2 * self.FadeSpeed * FrameTime(), self.LerpRefract, 0)

		if self.DieTime && CurTime() > self.DieTime then
			return false
		end;

		return true
	end;

	function Impact:Render()
		render.SetMaterial(self.Refract)
		render.UpdateRefractTexture()
		self.Refract:SetFloat("$refractamount", self.LerpRefract * 0.75)
		render.DrawQuadEasy(self.Pos + Vector(0,0,1), Vector(0, 0, 1), self.LerpSize, self.LerpSize)
		render.DrawQuadEasy(self.Pos + Vector(0,0,1), Vector(0, 0, -1), self.LerpSize, self.LerpSize)
	end;

	effects.Register(Impact,"nut_mimpact")
end;
-- EFFECTS END --
