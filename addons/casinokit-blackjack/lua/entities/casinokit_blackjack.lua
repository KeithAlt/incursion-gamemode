AddCSLuaFile()

local STOP_HARD = 0
local STOP_SOFT = 1

ENT.Spawnable = true
ENT.Category = "Casino Kit"
ENT.PrintName = "Blackjack table"

DEFINE_BASECLASS("casinokit_table")
ENT.Base = "casinokit_table"

ENT.GameClass = "Blackjack"

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Int", 4, "MinBet")
	self:NetworkVar("Int", 5, "MaxBet")
	self:NetworkVar("Int", 6, "TimeoutDelay")
	self:NetworkVar("Int", 7, "StopAt")
end

function ENT:Initialize()
	if self:GetMinBet() == 0 then
		self:SetMinBet(5)
		self:SetMaxBet(1e4)
		self:SetTimeoutDelay(15)
		self:SetStopAt(STOP_SOFT)
	end

	BaseClass.Initialize(self)

	-- NOTE: Custom fix for addressing CSS mounting annoyance
	self:SetModel("models/maxib123/table1.mdl")
	self:SetModelScale(0.82)
	self:PhysicsInit(SOLID_VPHYSICS)
end


function ENT:OnGameConfigReceived(key, value)
	if key == "minbet" then
		assert(type(value) == "number" and value > 0)
		self:SetMinBet(value)
	elseif key == "maxbet" then
		assert(type(value) == "number" and value > 0)
		self:SetMaxBet(value)
	elseif key == "timeoutdelay" then
		assert(type(value) == "number" and value > 0)
		self:SetTimeoutDelay(value)
	elseif key == "stopat" then
		assert(type(value) == "number" and (value >= 0 or value <= 1))
		self:SetStopAt(value)
	end
end
