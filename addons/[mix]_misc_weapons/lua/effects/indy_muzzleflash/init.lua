EFFECT.mat = Material("effects/indy_muzzleflash")

function EFFECT:Init()
	self.Time = 0	
	self.Size = 0
end

function EFFECT:Think()
	self.Time = self.Time + FrameTime()
	self.Size = 1000 * self.Time^math.random(1,5)
	
	if self.Time >= 0.01 then return false end
	
	return true
end

function EFFECT:Render()
	local Pos = self:GetPos() + (EyePos()-self:GetPos()):GetNormal()
	local color = Color(255,255,255,255 * -self.Time)

	render.SetMaterial(self.mat)
	render.DrawSprite(Pos, self.Size, self.Size, color)
end