
local RouletteCl = CasinoKit.class("RouletteCl", "CardGameCl")

function RouletteCl:getGameFriendlyName()
	return ""
end

function RouletteCl:getGameFriendlySubtext()
	return L("Minimum bet %d", self:getMinBet())
end

function RouletteCl:getMinBet()
	local te = self:getTableEntity()
	return  IsValid(te) and te:GetMinBet() or 1
end
function RouletteCl:getMaxTotalBet()
	local te = self:getTableEntity()
	return  IsValid(te) and te:GetMaxTotalBet() or 1
end
function RouletteCl:getRollInterval()
	local te = self:getTableEntity()
	return  IsValid(te) and te:GetRollInterval() or 1
end

function RouletteCl:addGameSettings(settings)
	settings:integer("Minimum bet", "minbet", self:getMinBet(), 1, 10000)
	settings:integer("Max Total Bet", "maxtotalbet", self:getMaxTotalBet(), 0, 1000000)
	settings:integer("Roll Interval", "rollinterval", self:getRollInterval(), 25, 120)

	RouletteCl.super.addGameSettings(self, settings)
end

function RouletteCl:getHelpHTML()
	return [[
	<h2>Roulette rules</h2>
	<p>
		Place bets on what number the ball will fall on during the next spin.
	</p>
	<h3>Bet types</h3>
	<b>Number (35 to 1)</b> Bet on a single number.<br/>
	<b>Zero (35 to 1)</b> Bet on a zero or a double zero.<br/>
	<b>Split (17 to 1)</b> Bet on a pair of numbers (horizontal or vertical).<br/>
	<b>Street (11 to 1)</b> Bet on a row (for instance 1, 2, 3).<br/>
	<b>Corner (8 to 1)</b> Bet on a four number set (for instance 1, 2, 4, 5).<br/>
	<b>Dozen (2 to 1)</b> Bet on a set of 12 numbers (for instance 1-12).<br/>
	<b>Column (2 to 1)</b> Bet on a column (for instance 1, 4, 7, ...).<br/>
	<b>Parity (1 to 1)</b> Bet on even or odd.<br/>
	<b>Color (1 to 1)</b> Bet on red or black.<br/>
	<b>Half (1 to 1)</b> Bet on a set of 18 numbers (for instance 1-18).<br/>
	]]
end