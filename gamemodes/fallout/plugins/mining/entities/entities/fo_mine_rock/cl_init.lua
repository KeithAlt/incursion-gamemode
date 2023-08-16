local PLUGIN = PLUGIN

include("shared.lua")

function ENT:Initialize()
	self.InsertEffect = ParticleEmitter(self:GetPos())
	self.LastAmount = -1
end

function ENT:GetFormatedHealth()
	local hp = self:getNetVar("mineHp", PLUGIN.DefaultHp)

	local floatStr = tostring(hp)
	local integer = math.Truncate(hp)
	local integerStr = tostring(integer)

	if (#floatStr - #integerStr == 0) then
		floatStr = floatStr..".00"
	elseif (#floatStr - #integerStr == 2) then
		floatStr = floatStr.."0"
	elseif (#floatStr - #integerStr > 3) then
		floatStr = string.Left(floatStr, 4)
	end

	return floatStr.."kg"
end

function ENT:Draw()
	self:DrawModel()

	if PLUGIN:InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then
		self:UpdateVisuals()
	else
		self.LastAmount = -1
	end
end

function ENT:UpdateVisuals()
	local rType = self:getNetVar("mineType", PLUGIN.DefaultType)
	local rAmount = self:getNetVar("mineHp", PLUGIN.DefaultHp)

	if ( self:GetSkin() ~= rType ) then
		self:SetSkin(rType)
	end

	local rMaxAmount = self:getNetVar("mineMaxHp", PLUGIN.DefaultMaxHp)
		
	if (rAmount <= 0) then
		if ( bg != 5 ) then
			self:SetBodygroup(0, 5)
			self.bg = 5
			self:RemoveAllDecals()
			self:SetCustomCollisionCheck(true)
		end
	elseif (rAmount < rMaxAmount * 0.1) then
		if ( bg != 4 ) then
			self:SetBodygroup(0, 4)
			self.bg = 4
		end
	elseif (rAmount < rMaxAmount * 0.25) then
		if ( bg != 3 ) then
			self:SetBodygroup(0, 3)
			self.bg = 3
		end
	elseif (rAmount < rMaxAmount * 0.5) then
		if ( bg != 2 ) then
			self:SetBodygroup(0, 2)
			self.bg = 2
		end
	elseif (rAmount < rMaxAmount * 0.75) then
		if ( bg != 1 ) then
			self:SetBodygroup(0, 1)
			self.bg = 1
		end
	elseif (rAmount <= rMaxAmount) then
		if ( bg != 0 ) then
			self:SetBodygroup(0, 0)
			self.bg = 0
		end
	end
end

ENT.DrawEntityInfo = true

local COLOR_LOCKED = Color(242, 38, 19)
local COLOR_UNLOCKED = Color(135, 211, 124)
local toScreen = FindMetaTable("Vector").ToScreen
local colorAlpha = ColorAlpha
local drawText = nut.util.drawText
local configGet = nut.config.get

surface.CreateFont("foMineType", {font = "Roboto", size = 65, weight = 450})
surface.CreateFont("foMineHp", {font = "Roboto", size = 35, weight = 450})

function ENT:onDrawEntityInfo(alpha)
	if ( self:getNetVar("mineHp", PLUGIN.DefaultHp) == 0 ) then
		return
	end

	local Pos = self:GetPos() + Vector(0, 0, 30)
	local Ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
	local position = toScreen(Pos, Ang)

	local x, y = position.x, position.y
	drawText(PLUGIN.Rocks[self:getNetVar("mineType", PLUGIN.DefaultType)][1], x, y - 40, colorAlpha(configGet("color"), alpha), 1, 1, "foMineType", alpha * 0.65)
	drawText(self:GetFormatedHealth(), x, y - 0, colorAlpha(configGet("color"), alpha), 1, 1, "foMineHp", alpha * 0.65)
end