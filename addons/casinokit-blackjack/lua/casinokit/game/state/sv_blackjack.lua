local BjGameState = CasinoKit.class("BjGameState","State")
function BjGameState:dealCommunityCard(card,hidden)
	table.insert(self.global.community, card)

	local out = CasinoKit.classes.OutBuffer()
	if hidden then
		out:putCard(nil)
	else
		out:putCard(card)
	end
	self.game:broadcastMessage("ccard", out)
end


function BjGameState:sendBet(ply,value)
	if ply.real then -- if this is the split ply, get the real one
		ply = ply.real
	end
	if ply.split and not value then
		value = ply:getBet() + ply.split:getBet()
	end

	local out = CasinoKit.classes.OutBuffer()
	out:putInt(ply:getSeatIndex())
	out:putInt(value or ply:getBet())
	self:broadcastMessage("chips", out)
end

local BjIdleState = CasinoKit.class("BjIdleState","BjGameState")


function BjIdleState:enter()

	self.global.players = nil

	local function checkGame()

		local validStartingPlayers = {}
		local otherPlayers = {}
		for _,p in pairs(self.table:getValidPlayers()) do
			if p:canAffordChips(self.game:getMinBet()) then
				table.insert(validStartingPlayers, p)
			else
				table.insert(otherPlayers, p)
			end
		end

		if #validStartingPlayers >= 1 then
			-- Inform invalid players why they couldn't get into game
			for _,op in pairs(otherPlayers) do
				op:chatPrintML("couldnotjoingame because cantaffordmin")
			end

			self.global.players = CasinoKit.fn.map(validStartingPlayers, function(x)
				local p = CasinoKit.class("BjPlayer")(x)
				p:setGame(self.game)

				p:setInitBet(-1)
				if p:getPush() > 0 then
					p:setInitBet(p:getPush())
					p:setBet(p:getPush())
					self:sendBet(p)
					p:setPush(0)
				end

				return p
			end)

			self.global.community = {}

			self.global.deck = CasinoKit.classes.Deck()
			self.global.deck:shuffle()

			self:changeState("initBet")
		else
			self:createSimpleTimer(2, checkGame)
		end
	end
	self:createSimpleTimer(0.1, checkGame)
end


local BjInitBetState = CasinoKit.class("BjBetState","BjGameState")

function BjInitBetState:enter()
	self.log.v("Initial Bets")
	local timeoutDelay = self.game:getTimeoutDelay()

	local out = CasinoKit.classes.OutBuffer()
	out:putInt(timeoutDelay)
	self:broadcastMessage("tmout", out)

	local waitfortimer = false
	for _,p in pairs(self.global.players) do -- if everyone has bet, skip this state
		if not p:hasBet() then
			waitfortimer = true
			break
		end
	end
	if not waitfortimer then
		self:createSimpleTimer(0.1,function() self:changeState("initDeal") end)
		return
	end

	self:createSimpleTimer(timeoutDelay, function()
		for k,v in pairs(self.global.players) do
			if v:getInitBet() == -1 then
				self.game:kickPlayer(v)
				self.table:removePlayerAtSlot(v:getSeatIndex())
				v:chatPrintML("( You've been ejected for taking to long )")
			end
		end

		if #self.global.players > 0 then
			self:changeState("initDeal")
		else
			self:changeState("gameover")
		end
	end)
end


function BjInitBetState:checkStateChange() end

function BjInitBetState:onOutsideUserInput(ply, buf)
	-- update players

	-- find player in casinokit players and call onUserInput
	for _,cply in pairs(self.table:getValidPlayers()) do
		if cply:getGmodPlayer() == ply then
			cply = CasinoKit.class("BjPlayer")(cply)
			cply:setGame(self.game)
			cply:setInitBet(-1)
			table.insert(self.global.players,cply)
			if cply:getPush() > 0 then
				cply:setInitBet(cply:getPush())
				cply:setBet(cply:getPush())
				cply:setPush(0)
				self:sendBet(cply)
			else
				self:onUserInput(cply,buf)
			end
			break
		end
	end

	if not found then
		ply:ChatPrint("You are not seated at the table you are trying to communicate with")
	end

end

function BjInitBetState:onUserInput(ply, buf)
	local act = buf:getString()
	local bet
	if act == "bet" then
		bet = buf:getInt()
	else
		return
	end

	if ply:hasBet() then return end
	if not ply:canAffordChips(bet) then
		ply:chatPrintL("cantafford")
		return
	end

	assert(type(bet) == "number")
	if bet >= self.game:getMinBet() and bet <= self.game:getMaxBet() then

		ply:setInitBet(bet)
		ply:setBet(bet)
		ply:addChips(-bet,"blackjack bet")
		self:sendBet(ply)

		for k,v in pairs(self.global.players) do
			if not v:hasBet() then
				return
			end
		end

		self:changeState("initDeal")
	else
		ply:chatPrint("")
	end

end



local BjInitDealState = CasinoKit.class("BjInitDealState","BjGameState")

function BjInitDealState:enter()
	-- players -> dealer -> players -> dealer hidden. Because 'muh immersion'
	for _,p in pairs(self.global.players) do
		p:dealRevealedCard(self.global.deck:pop())
	end

	self:dealCommunityCard(self.global.deck:pop())

	for _,p in pairs(self.global.players) do
		p:dealRevealedCard(self.global.deck:pop())
	end

	self:dealCommunityCard(self.global.deck:pop(),true)

	self:createSimpleTimer(1 + #self.global.players, function() self:changeState("playing") end)
end

local BjPlayingState = CasinoKit.class("BjPlayingState","BjGameState")

function BjPlayingState:findNextTurnPlayer()
	local nextPlayer = self.ply
	for i=1, #self.global.players do
		nextPlayer = table.FindNext(self.global.players, nextPlayer)
		if not nextPlayer or nextPlayer == self.ply then
			return nil
		end

		if nextPlayer:hasBet() and not nextPlayer:getDone() then
			return nextPlayer
		end
	end
end

function BjPlayingState:nextTurn()

	if #self.global.players < 1 then
		self.log.v("Game playercount < 1; moving to gameover")
		self:changeState("gameover")
		return
	end

	local nextPlayer = self:findNextTurnPlayer()
	if not nextPlayer then
		self.log.v("No nextTurnPlayer found; moving to showdown")
		self:changeState("reveal")
		return
	end

	self.log.v("Changing player turn from ", self.ply, " to ", nextPlayer)

	self:restartState(nextPlayer)
end

function BjPlayingState:extendTime()
	local timeoutDelay = self.game:getTimeoutDelay()

	local out = CasinoKit.classes.OutBuffer()
	out:putInt(timeoutDelay)
	self:broadcastMessage("etime", out)

	if self.timer then
		self.timer:stop()
	end
	self.timer = self:createSimpleTimer(timeoutDelay, function() self:timeout() end)
end

function BjPlayingState:checkStateChange() end
function BjPlayingState:timeout()
	self.log.v("Player ", self.ply, " has timed out")
	self.game:kickPlayer(self.ply)
	self.table:removePlayerAtSlot(self.ply:getSeatIndex())
	self.ply:chatPrintML("( You've been ejected for taking to long )")

	self.game:broadcastGameplayMessage(self.ply:toShortString().." timedout")

	self:nextTurn()
end

function BjPlayingState:enter(ply)
	self.log.v("Betting state ", self.class.name, " entered with ", ply)

	-- find a valid player
	if not ply then
		ply = self:findNextTurnPlayer()
		self.log.v("No turn player was given entering betting state; selecting turn player ", ply)
	end

	-- no players in whole game??
	if not ply then
		self.log.v("No players in whole game??. Moving to gameover")
			self:changeState("gameover")
		return
	end

	self.ply = ply

	local timeoutDelay = self.game:getTimeoutDelay()

	local out = CasinoKit.classes.OutBuffer()
	out:put(ply:getSeatIndex())
	out:put(timeoutDelay)
	self:broadcastMessage("nturn", out)

	self.timer = self:createSimpleTimer(timeoutDelay, function() self:timeout() end)
end

function BjPlayingState:splitCards(ply)
	ply:setSplit(true)
	ply:addChips(-ply:getInitBet())
	-- create second player
	ply.split = CasinoKit.class("BjPlayer")(ply)
	ply.split.real = ply
	ply.split:setGame(self.game)
	ply.split:setInitBet(ply:getInitBet())
	ply.split:setBet(ply.split:getInitBet())
	self:sendBet(ply)

	local curPlyIndex = table.KeyFromValue(self.global.players, ply)
	table.insert(self.global.players, curPlyIndex+1, ply.split)

	-- split the hand
	local hand = ply:getHand()
	ply:setHand({hand[1]})
	ply.split:setHand({hand[2]})

	ply:dealRevealedCard(self.global.deck:pop())
	ply.split:dealRevealedCard(self.global.deck:pop())

	local out = CasinoKit.classes.OutBuffer()
	out:put(ply:getSeatIndex())
	self:broadcastMessage("split", out)
end

function BjPlayingState:onUserInput(ply, buf)
	local act = buf:getString()

	if ply:getSplit() and ply:getDone() then -- set it to the split player
		ply = ply.split
	end

	local cards = ply:getHand()
	local value = self.game:getHandValue(cards)
	local dealerCard = self.global.community[1]:getRank()

	if act == "hit" then
		if #cards < 5 and value < 21 then
			self.game:emitGEvent("bj-hit", {ply = ply:getGmodPlayer()})

			ply:dealRevealedCard(self.global.deck:pop())
			if self.game:getHandValue(ply:getHand()) >= 21 then
				ply:setDone(true)
				self:nextTurn()
			else
				self:extendTime()
			end
		end
	elseif act == "stand" then
		self.game:emitGEvent("bj-stand", {ply = ply:getGmodPlayer()})

		ply:setDone(true)
		self:nextTurn()
	elseif act == "split" then
		if ply:getSplit() then
			ply:chatPrintL("blackjac_alreadysplit")
			return
		end
		if not ply:canAffordChips(ply:getInitBet()) then
			ply:chatPrintL("cantafford")
			return
		end

		self.game:emitGEvent("bj-split", {ply = ply:getGmodPlayer()})
		self:splitCards(ply)
	elseif act == "doubledown" then
		if #cards == 2 then
			if not ply:canAffordChips(ply:getInitBet()) then
				ply:chatPrintL("cantafford")
				return
			end

			self.game:emitGEvent("bj-doubledown", {ply = ply:getGmodPlayer()})

			ply:dealRevealedCard(self.global.deck:pop())
			ply:setDoubledown(true)

			-- add initial bet on top
			if ply.real then
				ply.real:addChips(-ply:getInitBet(),"blackjack doubledown")
			else
				ply:addChips(-ply:getInitBet(),"blackjack doubledown")
			end
			ply:setBet(ply:getBet() + ply:getInitBet() )
			self:sendBet(ply)

			ply:setDone(true)
			self:nextTurn()
		end
	elseif act == "insurance" then
		if #cards == 2 and dealerCard:isAce() then
			if not ply:getInsurance() then
				local amount = math.floor(ply:getInitBet()/2)
				if not ply:canAffordChips(amount) then
					ply:chatPrintL("cantafford")
					return
				end

				self.game:emitGEvent("bj-insurance", {ply = ply:getGmodPlayer()})

				ply:setInsurance(true)

				if ply.real then
					ply.real:addChips(-amount,"blackjack insurance")
				else
					ply:addChips(-amount,"blackjack insurance")
				end
				ply:setBet(ply:getBet() + amount )
				self:sendBet(ply)

				self:extendTime()
			else
				ply:chatPrint("blackjack insuranceplaced")
			end
		end
	elseif act == "evenmoney" then
		if #cards == 2 and value == 21 then
			self.game:emitGEvent("bj-evenmoney", {ply = ply:getGmodPlayer()})

			if ply.real then
				ply.real:addChips(2*ply:getInitBet(),"blackjack evenmoney")
			else
				ply:addChips(2*ply:getInitBet(),"blackjack evenmoney")
			end
			ply:setBet(0)
			self:sendBet(ply)
			ply:setEvenMoney(true)
			ply:setDone(true)
			self:nextTurn()
		end
	end

end

local BjRevealState = CasinoKit.class("BjRevealState","BjGameState")
function BjRevealState:enter()

	-- reveal hidden card
	local card = self.global.community[2]
	local out = CasinoKit.classes.OutBuffer()
	out:putCard(card)
	self.game:broadcastMessage("bjrev", out)

	-- loop until at soft/hard 17
	local function dealerDeal()
		local chand = self.global.community
		local value,soft = self.game:getHandValue(chand)

		if value < 17 or (value <= 17 and soft and self.game:getStopAt() == 1) --[[soft]] then
			self:dealCommunityCard(self.global.deck:pop())

			self.game:emitGEvent("bj-dealer-deal", {oldValue = value, newValue = self.game:getHandValue(self.global.community)})
		else
			self:changeState("showdown")
		end
		self:createSimpleTimer(1,dealerDeal)
	end
	self:createSimpleTimer(1,dealerDeal)

end


local BjShowdownState = CasinoKit.class("BjShowdownState","BjGameState")
function BjShowdownState:enter()
	self.game:emitGEvent("bj-showdown", {})

	-- go to idle for now
	local chand = self.global.community
	local value = self.game:getHandValue(chand)


	for _,p in pairs(self.global.players) do
		local pmessages = {}

		if not p:getEvenMoney() then
			if p:getInsurance() then
				if #chand == 2 and value == 21 then
					p:addChips(p:getInitBet(),"blackjack insurance")
					table.insert(pmessages,{msg="blackjack_woninsurance", n=p:getInitBet()/2})
				else
					table.insert(pmessages,{msg="blackjack_lostinsurance", n=p:getInitBet()/2})
				end
				p:setBet(p:getBet() - p:getInitBet()/2)
			end

			local pvalue = self.game:getHandValue(p:getHand())

			if pvalue <= 21 and (value > 21 or pvalue > value) then
				if pvalue == 21 then
					p:addChips(math.floor(p:getBet()*2.5))
					table.insert(pmessages,{msg="blackjack_wonbetbj", n=math.floor(p:getBet()*1.5)})
				else
					p:addChips(p:getBet()*2)
					table.insert(pmessages,{msg="blackjack_wonbet", n=p:getBet()})
				end
			elseif pvalue <= 21 and pvalue == value then
				p:setPush(p:getBet())
				table.insert(pmessages,{msg="blackjack_pushbet", n=p:getBet()})
			else
				table.insert(pmessages,{msg="blackjack_lostbet", n=p:getBet()})
			end
			self:sendBet(p,p:getPush())
		else -- evenmoney
			table.insert(pmessages,{msg="blackjack_tookevenmoney",n=-1})
		end
		local out = CasinoKit.classes.OutBuffer()
		out:putArray(pmessages, function(_, tbl)
			out:putString(tbl.msg)
			out:putInt(tbl.n)
		end)
		p:sendMessage("rsult", out)

	end


	self:createSimpleTimer(5, function() self:changeState("gameover") end)
end
