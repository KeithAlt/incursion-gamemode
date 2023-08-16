local Bj = CasinoKit.class("Blackjack", "CardGame")


Bj.states = {
	idle = CasinoKit.class("BjIdleState"),
	initBet = CasinoKit.class("BjBetState"),
	initDeal = CasinoKit.class("BjInitDealState"),
	playing = CasinoKit.class("BjPlayingState"),
	reveal = CasinoKit.class("BjRevealState"),
	showdown = CasinoKit.class("BjShowdownState"),
	gameover = CasinoKit.class("GameOverState"),
}

Bj.initialState = "idle"


function Bj:getMinBet()
	local te = self:getTableEntity()
	return IsValid(te) and te:GetMinBet() or 5
end

function Bj:getMaxBet()
	local te = self:getTableEntity()
	return IsValid(te) and te:GetMaxBet() or 5
end

function Bj:getTimeoutDelay()
	local te = self:getTableEntity()
	return  IsValid(te) and te:GetTimeoutDelay() or -1
end

function Bj:getStopAt()
	local te = self:getTableEntity()
	return IsValid(te) and te:GetStopAt() or 0
end

function Bj:canGmodPlayerSitIn(gmodPly, seatIndex)
	if not gmodPly:CKit_CanAffordChips(self:getMinBet()) then
		return false, "cannot afford the minimum bet (" .. self:getMinBet() .. " chips). You can get chips from a dealer or chip exchange NPC."
	end
	return Bj.super.canGmodPlayerSitIn(self, gmodPly, seatIndex)
end 

function Bj:onOutsidePlayerInput(ply, buffer)
	if self:getState().onOutsideUserInput then
		self:getState():onOutsideUserInput(ply, buffer)
	end	
end


function Bj:persistTableSettings(out)
	Bj.super.persistTableSettings(self, out)
	
	out.minbet = self:getMinBet()
	out.maxbet = self:getMaxBet()
	out.stopat = self:getStopAt()
	out.timeoutdelay = self:getTimeoutDelay()
end

function Bj:getHandValue(hand)
	local value = 0
	local aces = 0
	local isSoft = false
	
	for _,c in pairs(hand) do
		if c:getRank():isAce() then
			aces = aces + 1
			value = value + 1
		elseif c:getRank():isFace() then
			value = value + 10
		else
			assert(type(tonumber(c:getRank():getValue())) == "number")
			value = value + tonumber(c:getRank():getValue())	
		end
	end

	if aces >= 1 and value <= 11 then
		value = value + 10
		isSoft = true
	end

	if value <= 21 and #hand >= 5 then
		value = 21
	end

	return value,isSoft
end

local BjPlayer = CasinoKit.class("BjPlayer", "CardGamePlayer")
BjPlayer:prop("InitBet")
BjPlayer:prop("Doubledown")
BjPlayer:prop("Insurance")
BjPlayer:prop("EvenMoney")
BjPlayer:prop("Split")
BjPlayer:prop("Bet")
BjPlayer:prop("Done")

function BjPlayer:hasBet()
	return self:getInitBet() ~= -1
end

function BjPlayer:getPush()
	return tonumber(self:getGmodPlayer():GetPData("CK_BlackjackPush",0)) or 0
end

function BjPlayer:setPush(amount)
	self:getGmodPlayer():SetPData("CK_BlackjackPush",amount)
end