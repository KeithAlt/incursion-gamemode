AddCSLuaFile()

ENT.Type = "ai"
ENT.Base = "base_entity"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
	if SERVER then
		if self.Model then
			self:SetModel(self.Model)
		end

		self:SetHullType(HULL_HUMAN)
		self:SetHullSizeNormal()
        self:SetSolid(SOLID_BBOX)
		self:DropToFloor()

		self:SetUseType(SIMPLE_USE)

		if isfunction(self.CustomInit) then
			self:CustomInit()
		end
	end
end

function ENT:GetEyePos()
	return self:GetPos() + Vector(5, 0, 68)
end

function ENT:LookAtAngRaw(ang)
    local yaw = math.Clamp(math.NormalizeAngle(ang.y - self:GetAngles().y), -60, 60)
    local pitch = math.Clamp(math.NormalizeAngle(ang.p), -15, 15)

	-- Causes visual artifacts if done in a draw hook, thus actual change is applied in Think
	self.PendingHeadPoseChange = { yaw = yaw, pitch = pitch, roll = 0 }
end

function ENT:LookAtAngInstant(ang)
	self:LookAtAngRaw(ang)
    self:SetEyeTarget(self:GetEyePos() + ang:Forward() * 100)
end

function ENT:LookAt(pos)
    local ang = (pos - self:GetEyePos()):Angle()
	self._LookTargetAngle = ang
end

function ENT:LookAtClosestPlayer()
	local myPos = self:GetPos()
	local myEyeDir = self:GetForward()

	local closestPly, closestPlyDist = nil, math.huge
	for _,p in pairs(player.GetAll()) do
		local pPos = p:EyePos()
		local diff = pPos - myPos

		-- If we're in front of NPC
		if diff:Dot(myEyeDir) > 0 then
			local dist = diff:Length()
			if dist < closestPlyDist then
				closestPly = p
				closestPlyDist = dist
			end
		end
	end

	local targetEnt = closestPly
	if IsValid(targetEnt) then
		self:LookAt(targetEnt:EyePos())
		return true
	end
	return false
end

function ENT:LookAtForwardVector()
	self._LookTargetAngle = self:GetAngles()
end

-- Passive, idle face/eye movement logic
function ENT:LookAroundIdly()
	if not self:LookAtClosestPlayer() then
		self:LookAtForwardVector()
	end
end

if CLIENT then
	function ENT:Think()
		if self.PendingHeadPoseChange then
			local phpc = self.PendingHeadPoseChange

			self:SetPoseParameter("head_yaw", phpc.yaw)
			self:SetPoseParameter("head_pitch", phpc.pitch)
			self:SetPoseParameter("head_roll", phpc.roll)
			self:InvalidateBoneCache()

			self.PendingHeadPoseChange = nil
		end

		if IsValid(self.VoiceChan) then
			if self.VoiceChan:GetState() ~= GMOD_CHANNEL_STOPPED then
				self.FFT = self.FFT or {}
				local freqBins = self.VoiceChan:FFT(self.FFT, FFT_256)

				local accum = 0
				for i=1,freqBins do accum = accum + self.FFT[i] end

				local finalWeight = accum / 3

				self:SetFlexWeight(43, finalWeight)
			else
				self:SetFlexWeight(43, 0)
				self.VoiceChan = nil
			end
		end

		if self:IsDormant() then
			self:NextThink(CurTime() + 1)
			return true
		else
			self:NextThink(CurTime() + 0.1)
			return true
		end
	end

	function ENT:Draw()
		self:DrawModel()

		if self._LookTargetAngle then
			self._LookCurAngle = self._LookCurAngle or Angle(0, 0, 0)

			local _cur = self._LookCurAngle
			local _target = self._LookTargetAngle

			local approachSpeed = FrameTime() * 150

			_cur.p = math.ApproachAngle(math.NormalizeAngle(_cur.p), math.NormalizeAngle(_target.p), approachSpeed)
			_cur.y = math.ApproachAngle(math.NormalizeAngle(_cur.y), math.NormalizeAngle(_target.y), approachSpeed)

			self:LookAtAngRaw(_cur)
			self:SetEyeTarget(self:GetEyePos() + _target:Forward() * 100)
		end
	end

	surface.CreateFont("CKitNPCOverheadTextx", {
		font = "Roboto",
		size = 75,
		weight = 800
	})
	function ENT:DrawOverheadText(text)
		local ang = LocalPlayer():EyeAngles()
		ang:RotateAroundAxis(ang:Right(), 90)
		ang:RotateAroundAxis(ang:Up(), -90)
		cam.Start3D2D(self:GetPos() + Vector(0, 0, 82), ang, 0.1)
		draw.SimpleTextOutlined(text, "CKitNPCOverheadTextx", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, nil, 3, Color(0, 0, 0))
		cam.End3D2D()
	end

	function ENT:SpeakFile(file)
		sound.PlayFile(file, "3d", function(chan)
			if IsValid(self.VoiceChan) then self.VoiceChan:Stop() end

			chan:SetPos(self:GetPos() + Vector(0, 0, 80))
			self.VoiceChan = chan
		end)
	end
	function ENT:SpeakUrl(url)
		sound.PlayURL(url, "3d", function(chan)
			if IsValid(self.VoiceChan) then self.VoiceChan:Stop() end

			chan:SetPos(self:GetPos() + Vector(0, 0, 80))
			self.VoiceChan = chan
		end)
	end

	net.Receive("casinokit_dealersound", function(len, cl)
		local dealer = net.ReadEntity()
		local sound = net.ReadString()
		local isFile = net.ReadBool()
		if IsValid(dealer) then
			if isFile then dealer:SpeakFile(sound) else dealer:SpeakUrl(sound) end
		end
	end)
end
if SERVER then
	function ENT:RunBehaviour()
		self:StartActivity(ACT_IDLE)
		while true do
			coroutine.wait(1e7)
			coroutine.yield()
		end
	end

	util.AddNetworkString("casinokit_dealersound")
	function ENT:SpeakFile(sound)
		net.Start("casinokit_dealersound")
		net.WriteEntity(self)
		net.WriteString(sound)
		net.WriteBool(true)
		net.SendPAS(self:GetPos())
	end
	function ENT:SpeakUrl(sound)
		net.Start("casinokit_dealersound")
		net.WriteEntity(self)
		net.WriteString(sound)
		net.WriteBool(false)
		net.SendPAS(self:GetPos())
	end
end
