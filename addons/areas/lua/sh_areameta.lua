Areas = Areas or {}
Areas.Meta = Areas.Meta or {}

Areas.Meta.__index = Areas.Meta

function Areas.Meta:__tostring()
	return "Area [" .. self.ID .. "][" .. self.Name .. "]"
end

function Areas.Meta:Init()
	if self.ID then
		Areas.Instances[self.ID] = self
	else
		self.ID = table.insert(Areas.Instances, self)
	end
	self.Players = {}
	self.Name = self.Name or "Name"

	if SERVER then
		self:Broadcast()
	end
end

function Areas.Meta:IsValid()
	return self.Mins and self.Maxs and self.ID
end

function Areas.Meta:SetName(name)
	self.Name = name

	if SERVER then
		net.Start("AreasSetName")
			net.WriteInt(self.ID, 32)
			net.WriteString(name)
		net.Broadcast()
	end
end

function Areas.Meta:GetName()
	return self.Name
end

function Areas.Meta:SetBounds(mins, maxs)
	OrderVectors(mins, maxs)
	self.Mins = mins
	self.Maxs = maxs

	if SERVER then
		net.Start("AreasSetBounds")
			net.WriteInt(self.ID, 32)
			net.WriteVector(self.Mins)
			net.WriteVector(self.Maxs)
		net.Broadcast()
	end
end

function Areas.Meta:GetBounds()
	return self.Mins, self.Maxs
end

function Areas.Meta:GetMins()
	return self.Mins
end

function Areas.Meta:GetMaxs()
	return self.Maxs
end

function Areas.Meta:GetCenter()
	return (self.Mins + self.Maxs) / 2
end

function Areas.Meta:GetPerimeter()
	return (self.Maxs.x - self.Mins.x) + (self.Maxs.y - self.Mins.y) + (self.Maxs.z - self.Mins.z)
end

function Areas.Meta:GetArea()
	return (self.Maxs.x - self.Mins.x) * (self.Maxs.y - self.Mins.y) * (self.Maxs.z - self.Mins.z)
end

function Areas.Meta:AddPlayer(ply)
	if !IsValid(ply) then return end

	self.Players[ply] = true
	ply:SetArea(self.ID)
	hook.Run("PlayerEnteredArea", ply, self)

	if SERVER then
		net.Start("AreasAddPlayer")
			net.WriteInt(self.ID, 32)
			net.WriteEntity(ply)
		net.Broadcast()
	end
end

function Areas.Meta:RemovePlayer(ply)
	self.Players[ply] = nil

	if !IsValid(ply) then return end

	if ply:GetArea() == self then --In case they entered a different area on the same tick
		ply:SetArea(0)
	end
	hook.Run("PlayerLeftArea", ply, self)

	if SERVER then
		net.Start("AreasRemovePlayer")
			net.WriteInt(self.ID, 32)
			net.WriteEntity(ply)
		net.Broadcast()
	end
end

function Areas.Meta:GetPlayers()
	return self.Players
end

function Areas.Meta:GetPlayersSequential()
	local plys = {}

	for ply, _ in pairs(self.Players) do
		plys[#plys + 1] = ply
	end

	return plys
end

function Areas.Meta:IsPlayerInArea(ply)
	return self.Players[ply] or false
end

function Areas.Meta:IsInBounds(vec)
	if self:IsValid() then
		return vec:WithinAABox(self:GetBounds())
	else
		return false
	end
end

function Areas.Meta:Distance(vec)
	return vec:Distance(self:GetCenter())
end

function Areas.Meta:IsPlayerInBounds(ply)
	return self:IsInBounds(ply:LocalToWorld(ply:OBBCenter()))
end

function Areas.Meta:UpdatePlayers()
	for i, ply in ipairs(player.GetAll()) do
		local inArea, inBounds = self:IsPlayerInArea(ply), self:IsPlayerInBounds(ply)
		if !inArea and inBounds then
			self:AddPlayer(ply)
		elseif inArea and !inBounds then
			self:RemovePlayer(ply)
		end
	end
end

if SERVER then
	Areas.Meta.Think = Areas.Meta.UpdatePlayers

	function Areas.Meta:Broadcast()
		net.Start("AreasInstance")
			jlib.WriteCompressedTable(self)
		net.Broadcast()
	end

	function Areas.Meta:NetworkTo(ply)
		net.Start("AreasInstance")
			jlib.WriteCompressedTable(self)
		net.Send(ply)
	end
end

if CLIENT then
	function Areas.Meta:Draw(color)
		if self:IsValid() then
			render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), self.Mins, self.Maxs, color or Color(255, 255, 255, 255), false)
		end
	end
end

function Areas.Meta:Remove()
	Areas.Instances[self.ID] = nil

	if SERVER then
		net.Start("AreasRemove")
			net.WriteInt(self.ID, 32)
		net.Broadcast()
	end

	hook.Run("AreaRemoved", self.ID)

	self = nil
end

function Areas.Instance()
	Areas.Print("Creating new area instance.")

	local instance = {}
	setmetatable(instance, Areas.Meta)
	instance:Init()

	hook.Run("AreaCreated", instance)

	return instance
end