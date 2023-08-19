-- Adapted from the sandbox freeze effect

local matRefract = Material( "models/spawn_effect" )

function EFFECT:Init(data)
	self.Target = data:GetEntity()
	self.StartTime = CurTime()
	self.Length = 0.1
end

function EFFECT:Think()
	return self.StartTime + self.Length > CurTime()
end

function EFFECT:Render()
	if (!IsValid(self.Target)) then return end

	local delta = ((CurTime() - self.StartTime) / self.Length) ^ 0.1
	local idelta = 1 - delta

	local size = 1
	halo.Add({self.Target}, Color( 192, 57, 43, 255 * idelta), size, size, 0.1, true, false)
end