AddCSLuaFile()

// if SERVER then
// 	jlib.AddDirectory("sound/blackhole")
// end

ENT.Type      = "anim"
ENT.Base      = "base_anim"

ENT.PrintName = "Psyker Black Hole"
ENT.Author    = "jonjo"
ENT.Category  = "Claymore Gaming"

ENT.Spawnable = false

ENT.Radius = 1200
ENT.RadiusSqrd = ENT.Radius ^ 2
ENT.MinSpeed = 50
ENT.MaxSpeed = 250
ENT.LaunchSpeed = 700

ENT.DefaultLife = 10

ENT.SoundLevel = 100

if SERVER then
	function ENT:Initialize()
		self:SetCreateTime(CurTime())

		util.ScreenShake(self:GetPos(), 6, 6, self:GetLife(), self.Radius)

		self:SetModel("models/Items/AR2_Grenade.mdl")
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ParticleEffectAttach("nr_blackhole", PATTACH_ABSORIGIN_FOLLOW, self, 1)

		local physObj = self:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:EnableMotion(false)
		end
	end

	function ENT:Think()
		if CurTime() >= self:GetDieTime() then
			-- As the black hole closes launch any players within range in a random direction
			for i, ply in ipairs(player.GetAll()) do
				local distSqrd = self:GetPos():DistToSqr(ply:GetPos())
				if distSqrd <= self.RadiusSqrd then
					ply:SetVelocity(VectorRand() * self.LaunchSpeed)
				end
			end

			SafeRemoveEntity(self)
			return
		end

		for i, ply in ipairs(player.GetAll()) do
			local distSqrd = self:GetPos():DistToSqr(ply:GetPos())
			if distSqrd <= self.RadiusSqrd then
				local normal = (self:GetPos() - ply:GetPos()):GetNormalized()
				local speedFactor = math.Clamp(1 - (distSqrd / self.RadiusSqrd), 0, 1)
				local speed = (self.MaxSpeed - self.MinSpeed) * speedFactor + self.MinSpeed
				ply:SetVelocity(normal * speed)

				if ply:OnGround() then
					ply.ForceJump = true
				end
			end
		end
	end
else
	ENT.MinFade = ENT.Radius
	ENT.MaxFade = ENT.Radius * 1.5

	ENT.Sounds = {
		Start = {path = Sound("blackhole/bh_start.wav"), loop = false, volume = 1.5, play = true},
		Loop = {path = Sound("blackhole/bh_loop.wav"), loop = true, volume = 2.2, play = true},
		End = {path = Sound("blackhole/bh_end.wav"), loop = false, volume = 1.5, play = false}
	}

	function ENT:Initialize()
		self.EndSoundDuration = SoundDuration(self.Sounds.End.path)

		for name, soundDat in pairs(self.Sounds) do
			-- Specifically using sound.PlayFile because IGmodAudioChannels support setting the volume above 100%
			sound.PlayFile("sound/" .. soundDat.path, "3d noplay" .. (soundDat.loop and " noblock" or ""), function(chnl, errID, errStr)
				chnl:SetPos(self:GetPos())
				chnl:EnableLooping(soundDat.loop)
				chnl:SetVolume(soundDat.volume)
				chnl:Set3DFadeDistance(self.Radius, self.MaxFade)
				if soundDat.play then
					chnl:Play()
				end

				self[name .. "Sound"] = chnl
			end)
		end
	end

	function ENT:Think()
		if IsValid(self.EndSound) and self.EndSound:GetState() != GMOD_CHANNEL_PLAYING and CurTime() >= self:GetDieTime() - (self.EndSoundDuration / 3) then
			self.EndSound:Play()
		end
	end

	function ENT:OnRemove()
		self.LoopSound:Stop()
	end
end

function ENT:GetDieTime()
	return self:GetCreateTime() + self:GetLife()
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Life")
	self:NetworkVar("Float", 1, "CreateTime")

	if SERVER then
		self:SetLife(self.DefaultLife)
		self:SetCreateTime(-1)
	end
end

hook.Add("SetupMove", "ForceJump", function(ply, mv, cmd)
	if ply.ForceJump and ply:OnGround() and !mv:KeyDown(IN_JUMP) then
		mv:AddKey(IN_JUMP)
		ply.ForceJump = false
	end
end)
