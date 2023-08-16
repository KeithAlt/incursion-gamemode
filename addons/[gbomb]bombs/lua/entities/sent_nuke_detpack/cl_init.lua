
include('shared.lua')

local sndBeeb = Sound("weapons/c4/c4_beep1.wav")
local sndStop = Sound("ambient/_period.wav")

local matBeebLight = CreateMaterial("beepLight", "UnlitGeneric", {["$basetexture"] = "sprites/glow03", ["$spriterendermode"] = 9, ["$illumfactor"] = 8, ["$nocull"] = 0, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})


function ENT:Beep()
	self.Entity:EmitSound(sndBeeb)
	self.SpriteDrawTime = CurTime() + 0.3
	self.SpriteAlpha = 255
end	

function ENT:InitTimers()
	self.DetTime = self.Entity:GetNWInt("DetTime")
	self.strTimerName = "beeper "..self.Entity:__tostring()

	local mod3 = math.fmod(self.DetTime,3)
	local NewTime = (self.DetTime - mod3)/3

	local time1
	local time2
	local time3

		if NewTime > mod3 then
			time1 = NewTime + 2*mod3
			time2 = NewTime
			time3 = NewTime - mod3
		else
			time1 = NewTime + mod3
			time2 = NewTime
			time3 = NewTime
		end
		
	timer.Create(self.strTimerName, 1, 0, function() self:Beep() end)
	timer.Simple(time1, function() timer.Adjust(self.strTimerName, 0.5, 0, function() self:Beep() end) end)
	timer.Simple((time1 + time2), function() timer.Adjust(self.strTimerName, 0.25, 0, function() self:Beep() end) end)
end
	
function ENT:Initialize()
self.SpriteDrawTime = 0
self.SpriteAlpha = 255

timer.Simple(0.1, function() self:InitTimers() end)
end

function ENT:Draw()

	self.Entity:DrawModel()

	if self.SpriteDrawTime > CurTime() then
		render.SetMaterial(matBeebLight)
		render.DrawSprite(self.Entity:LocalToWorld(Vector(3,6,7)),32,32,Color(255,20,20,self.SpriteAlpha))
		self.SpriteAlpha = self.SpriteAlpha - 768*FrameTime()
	end

end

function ENT:OnRemove()

	if timer.Exists( self.strTimerName ) then
	timer.Remove( self.strTimerName )
	end

end




