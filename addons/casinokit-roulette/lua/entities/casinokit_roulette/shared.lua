AddCSLuaFile()

DEFINE_BASECLASS("casinokit_table")
ENT.Base = "casinokit_table"

ENT.SeatCount = 0

ENT.Assets = CasinoKit.newDownload():withWorkshop(662520760)

ENT.Model = "models/casinokit/roulette.mdl"

ENT.Spawnable = true
ENT.Category = "Casino Kit"
ENT.PrintName = "Roulette table"

ENT.GameClass = "Roulette"

function ENT:OnGameConfigReceived(key, value)
	if key == "minbet" then
		assert(type(value) == "number" and value > 0)
		self:SetMinBet(value)
	elseif key == "maxtotalbet" then
		assert(type(value) == "number" and value >= 0)
		self:SetMaxTotalBet(value)
	elseif key == "rollinterval" then
		assert(type(value) == "number" and (value == 0 or value >= 25))
		self:SetRollInterval(value)
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", 0, "Rolling")
	self:NetworkVar("Float", 0, "LastRoll")
	self:NetworkVar("Float", 1, "RollInterval")
	self:NetworkVar("Int", 1, "MinBet")
	self:NetworkVar("Int", 2, "MaxTotalBet")
end

ENT.ROUL_INNER_RAD = 0.1
ENT.ROUL_INNER_HEIGHT = 0.15

ENT.ROUL_MID_HEIGHT = 0.15

ENT.ROUL_OUTER_RAD = 0.32
ENT.ROUL_OUTER_HEIGHT = 0.05

ENT.ROUL_BORDER_HEIGHT = 0.116
ENT.ROUL_TOTAL_RAD = 0.43 -- ~27 inch

ENT.ROUL_BALL_RAD = 0.021 -- 21mm

ENT.ROUL_BALL_MASS = 0.00374
ENT.ROUL_BALL_ROLLFRICTION_COEFFICIENT = 0.001
ENT.ROUL_BALL_ROLLSLIDEFRICTION_COEFFICIENT = 0.014

local roulSeq = {
	6, 21, 33, 16, 4, 23, 35, 14, 2, 0, 28, 9, 26, 30, 11, 7, 20,
	32, 17, 5, 22, 34, 15, 3, 24, 36, 13, 1, "00", 27, 10, 25, 29, 12, 8, 19, 31, 18,
}
local radPerNumber = math.pi*2 / #roulSeq

ENT.NumberSequence = roulSeq
ENT.RedNumbers = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36}

function ENT:GetNumberFromRad(rad)
	local index = math.floor((rad - radPerNumber/2) / radPerNumber)
	return self.NumberSequence[(index % #self.NumberSequence) + 1]
end

local wheelRotPerSec = 0.3
function ENT:WheelRotationAt(time)
	return time * wheelRotPerSec
end
function ENT:GetWheelAngle()
	return self:WheelRotationAt(CurTime())
end

function ENT:GetBallYFromRad(rad)
	return math.Remap(rad, self.ROUL_OUTER_RAD, self.ROUL_TOTAL_RAD, self.ROUL_OUTER_HEIGHT, self.ROUL_BORDER_HEIGHT - 0.03)
end

local acceleration = -0.6
function ENT:GetBallAngle(elapsed, strength)
	elapsed = self:ClampElapsed(elapsed, strength)
	local initialVelocity = strength
	local ballHorizDistance = initialVelocity*elapsed + 0.5*acceleration*elapsed^2
	return -(ballHorizDistance / self.ROUL_OUTER_RAD)
end

function ENT:GetBallStopTime(strength)
	return -strength / acceleration
end

function ENT:ClampElapsed(elapsed, strength)
	local ballHorizStopTime = self:GetBallStopTime(strength)
	local ballStopElapsed = 0
	if ballHorizStopTime < elapsed then
		return ballHorizStopTime, elapsed - ballHorizStopTime
	end
	return elapsed, 0
end

function ENT:GetBallNumber(start, strength)
	local elapsed, ballStopElapsed = self:ClampElapsed(CurTime() - start, strength)
	local ballHorizStopTime = -strength / acceleration
	local ballAng = -self:GetBallAngle(elapsed, strength)
	return self:GetNumberFromRad(self:WheelRotationAt(start + ballHorizStopTime) + -self:GetBallAngle(elapsed, strength))
end

function ENT:SimulateBall(start, strength)
	local elapsed, ballStopElapsed = self:ClampElapsed(CurTime() - start, strength)

	local initialVelocity = strength

	local ballAngle = self:GetBallAngle(elapsed, strength) % (math.pi*2)
	local ballHorizVelocity = initialVelocity + acceleration*elapsed

	-- convert to relative to wheel
	ballAngle = ballAngle + ballStopElapsed * wheelRotPerSec

	local ballRadius = self.ROUL_TOTAL_RAD - 0.02
	if ballHorizVelocity < 1 then
		local ballFrac = math.max(ballHorizVelocity, 0) ^ (1/1.5) -- note: normalize to 0-1 first if you edit

		ballRadius = math.Remap(ballFrac, 0, 1, self.ROUL_OUTER_RAD, self.ROUL_TOTAL_RAD - 0.02)
	end

	-- x flipped cuz texture is flipped. LAME but easieat hacky fix??
	return Vector(math.cos(ballAngle) * ballRadius, math.sin(ballAngle) * ballRadius, self:GetBallYFromRad(ballRadius) + 0.02)
end

function ENT:GetTimeToNextRoll()
	local interval = self:GetRollInterval()
	if interval == 0 then interval = 30 end

	return (interval - (CurTime() % interval))
end

ENT.BettingPositions = {}
do
	local table_x, table_y = -240, 100

    for i=1,36 do
		local col = math.floor((i-1) / 3)
		local row = 2 - ((i-1) % 3)

		local x, y, w, h = table_x + col * 40, table_y + row * 51, 40, 51
		local inner_margin = 5
		local inner_x, inner_y, inner_w, inner_h = x+inner_margin, y+inner_margin, w-inner_margin*2, h-inner_margin*2

		do
			local betId, betParam = "single", tostring(i)

			table.insert(ENT.BettingPositions, {
				betId = betId,
				betParam = betParam,

				inner_x = inner_x,
				inner_y = inner_y,
				inner_w = inner_w,
				inner_h = inner_h,

				chip_x = x + w/2,
				chip_y = y + h/2
			})
		end

		-- top and right (no functionality)

		-- bottom (with "split")
		do
			local betId = row == 2 and "street" or "split"
			local betParam = row == 2 and i or ((i-1) .. "-" .. i)

			table.insert(ENT.BettingPositions, {
				betId = betId,
				betParam = betParam,

				inner_x = inner_x,
				inner_y = y + h - inner_margin,
				inner_w = inner_w,
				inner_h = inner_margin * 2,

				chip_x = x + w/2,
				chip_y = y + h
			})
		end

		-- left (with "split")
		do

			local can_left_split = col > 0
			if can_left_split then
				local betId = "split"
				local betParam = i .. "-" .. (i-3)

				table.insert(ENT.BettingPositions, {
					betId = betId,
					betParam = betParam,

					inner_x = x - inner_margin,
					inner_y = inner_y,
					inner_w = inner_margin * 2,
					inner_h = inner_h,

					chip_x = x,
					chip_y = y + h/2
				})
			end
		end

		-- bottom_left
		do
			local can_corner = row < 2 and col > 0
			if can_corner then
				local betId = "corner"
				local betParam = i

				table.insert(ENT.BettingPositions, {
					betId = betId,
					betParam = betParam,

					inner_x = x - inner_margin,
					inner_y = y + h - inner_margin,
					inner_w = inner_margin * 2,
					inner_h = inner_margin * 2,

					chip_x = x,
					chip_y = y + h
				})
			end
		end
	end

	-- Add bets not directly connected to the grid
	for _,bet in pairs {
		{id = "00", x = -45, y = 0, w = 45, h = 80},
		{id = "0", x = -45, y = 80, w = 45, h = 80},

		{id = "1-12", text = "1st 12", x = 0, y = 158, w = 160, h = 37},
		{id = "13-24", text = "2nd 12", x = 160, y = 158, w = 160, h = 37},
		{id = "25-36", text = "3rd 12", x = 320, y = 158, w = 160, h = 37},

		{id = "1-18", text = "1 to 18", x = 0, y = 195, w = 80, h = 45},
		{id = "even", text = "EVEN", x = 80, y = 195, w = 80, h = 45},
		{id = "red", text = "RED", clr = clr_red_no, x = 160, y = 195, w = 80, h = 45},
		{id = "black", text = "BLACK", clr = clr_black_no, x = 240, y = 195, w = 80, h = 45},
		{id = "odd", text = "ODD", x = 320, y = 195, w = 80, h = 45},
		{id = "19-36", text = "19 to 36", x = 400, y = 195, w = 80, h = 45},

		{id = "column-3", x = 480, y = 0, w = 45, h = 50},
		{id = "column-2", x = 480, y = 50, w = 45, h = 50},
		{id = "column-1", x = 480, y = 100, w = 45, h = 50},
	} do
		table.insert(ENT.BettingPositions, {
			betId = bet.id,
			betParam = "",

			inner_x = table_x + bet.x,
			inner_y = table_y + bet.y,
			inner_w = bet.w,
			inner_h = bet.h,

			chip_x = table_x + bet.x + bet.w / 2,
			chip_y = table_y + bet.y + bet.h / 2
		})
	end
end

ENT.TDUIOffset = Vector(-12, 15.2, 13.5)
ENT.TDUIAngle = Angle(90, 180, 0)
ENT.TDUIScale = 0.081

function ENT:TDUIXYToWorldPosition(x, y)
	return self:LocalToWorld(self.TDUIOffset + Vector(y * self.TDUIScale, x * self.TDUIScale, 0))
end

local function withinNumbers(num)
	num = tonumber(num)
	return num and num >= 1 and num <= 36
end
function ENT:IsValidBet(id, param)
	if id == "single" then
		return withinNumbers(param)
	end

	if id == "split" then
		local split0, split1 = param:match("(%d+)%-(%d+)")
		if not withinNumbers(split0) or not withinNumbers(split1) then return false end

		local n0, n1 = tonumber(split0), tonumber(split1)
		if n0-3 == n1 then return true end -- left split
		if n0+1 == n1 and (n0 % 3) ~= 0 then return true end -- bottom split
		return false
	end

	if id == "street" then
		return withinNumbers(param) and (tonumber(param) - 1) % 3 == 0
	end

	if id == "corner" then
		return withinNumbers(param) and (tonumber(param) - 1) % 3 ~= 0 and tonumber(param) > 2
	end

	if id == "1-12" or id == "13-24" or id == "25-36" or id == "1-18" or id == "even" or
	   id == "red" or id == "black" or id == "odd" or id == "19-36" or id == "0" or
	   id == "00" or id == "column-1" or id == "column-2" or id == "column-3" then
		return true
	end

	return false
end

function ENT:BetToNiceString(betId, betParam)
	if betId == "single" then
		return betParam
	end

	if betParam and betParam ~= "" then
		return string.format("%s-%s", betId or "", betParam or "")
	else
		return betId
	end
end