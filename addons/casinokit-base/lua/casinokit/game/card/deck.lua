local Deck = CasinoKit.class("Deck")

function Deck:initialize()
	Deck.super.initialize(self)

	self.cardStack = {}

	self:addCards()
end

-- Add all cards
function Deck:addCards()
	for _,suit in pairs(CasinoKit.classes.Suit.valueList) do
		for _,rank in pairs(CasinoKit.classes.Rank.valueList) do
			local card = CasinoKit.classes.Card(suit, rank)
			table.insert(self.cardStack, card)
		end
	end
end

-- https://coronalabs.com/blog/2014/09/30/tutorial-how-to-shuffle-table-items/
function Deck:shuffle()
	local t = self.cardStack

	local rand = CasinoKit.rand.random
	local iterations = #t
	local j

	for i = iterations, 2, -1 do
		local r = rand()
		assert(r and type(r) == "number" and r >= 0 and r <= 1)

		j = math.floor(r * i)

		t[i], t[j] = t[j], t[i]
	end
end

function Deck:pop()
	return table.remove(self.cardStack, #self.cardStack)
end

function Deck:getCardCount()
	return #self.cardStack
end
