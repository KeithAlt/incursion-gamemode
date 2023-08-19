local Roulette = CasinoKit.class("Roulette", "Game")

Roulette.states = {
	idle = CasinoKit.classes.RouletteState
}

Roulette.initialState = "idle"

function Roulette:getMinBet()
	local te = self:getTableEntity()
	return IsValid(te) and te:GetMinBet() or 1
end
function Roulette:getMaxTotalBet()
	local te = self:getTableEntity()
	return IsValid(te) and te:GetMaxTotalBet() or 1
end
function Roulette:getRollInterval()
	local te = self:getTableEntity()
	return  IsValid(te) and te:GetRollInterval() or 1
end

function Roulette:persistTableSettings(out)
	Roulette.super.persistTableSettings(self, out)

	out.minbet = self:getMinBet()
	out.maxtotalbet = self:getMaxTotalBet()
	out.rollinterval = self:getRollInterval()
end