local CardGame = CasinoKit.class("CardGame", "Game")

local CardGamePlayer = CasinoKit.delegatingClass("CardGamePlayer", "Player")
CardGamePlayer:prop("hand")

function CardGamePlayer:getCardId(cardIndex)
	return 10 + self:getSeatIndex()*10 + cardIndex
end

function CardGamePlayer:dealCardRaw(card)
	local hand = self:getHand()
	if not hand then self:setHand{} end
	table.insert(self:getHand(), card)

	return self:getCardId(#self:getHand())
end

function CardGamePlayer:dealCard(card)
	local cardId = self:dealCardRaw(card)

	-- broadcast hidden card
	local out = CasinoKit.classes.OutBuffer()
	out:put(self:getSeatIndex())
	out:put(cardId)
	out:putCard(nil)
	self:getGame():broadcastMessage("newcd", out)

	-- send card player the revealed card
	local out = CasinoKit.classes.OutBuffer()
	out:put(cardId)
	out:putCard(card)
	self:sendMessage("revcd", out)
end

function CardGamePlayer:dealRevealedCard(card)
	local cardId = self:dealCardRaw(card)

	-- broadcast revealed card
	local out = CasinoKit.classes.OutBuffer()
	out:put(self:getSeatIndex())
	out:put(cardId)
	out:putCard(card)
	self:getGame():broadcastMessage("newcd", out)
end

function CardGamePlayer:revealCards()
	for i,h in pairs(self:getHand() or {}) do
		local out = CasinoKit.classes.OutBuffer()
		out:put(self:getCardId(i))
		out:putCard(h)
		self:getGame():broadcastMessage("revcd", out)
	end
end

function CardGame.static.getGamePlayer(player)
	return CardGamePlayer(player)
end
