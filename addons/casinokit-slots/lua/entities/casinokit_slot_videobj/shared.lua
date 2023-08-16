DEFINE_BASECLASS"casinokit_machine"
ENT.Base = "casinokit_machine"

ENT.PrintName		= "Video Blackjack"
ENT.Author			= "Wyozi"
ENT.Category		= "Casino Kit"

ENT.Editable		= true
ENT.Spawnable		= true
ENT.AdminOnly		= true

ENT.DealerStandAt = 17

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("String", 0, "DealerHand")
	self:NetworkVar("String", 1, "PlayerHand")

	self:NetworkVar("Float", 0, "TurnTimeout")
end

local VBJHand = CasinoKit.class("VideoBJHand")

function VBJHand:_getRawString()
	assert(false, "getRawString not impl")
end
function VBJHand:_setRawString(s)
	assert(false, "setRawString not impl")
end

function VBJHand:getCount()
	return math.floor((#self:_getRawString()) / 2)
end

function VBJHand:clear()
	self:_setRawString("")
end

local function cardIter(cardstr, i)
	i = i + 1

	if ((i-1) * 2) >= #cardstr then
		return
	end

	local card = string.sub(cardstr, (i-1)*2 + 1, (i-1)*2 + 2)

	if card and card ~= "" and card ~= "XX" then
		return i, CasinoKit.classes.Card.fromTwoByteString(card)
	else
		return i
	end
end

-- returns Iterator<Card>
function VBJHand:cards()
	local str = self:_getRawString()
	return cardIter, str, 0
end

function VBJHand:getValue()
	local aceCount = 0
	local acelessValue = 0

	for _,c in self:cards() do
		if c then
			if c:getRank():isAce() then
				aceCount = aceCount + 1
			else
				local val = c:getRank():getValue()
				if c:getRank():isFace() then
					val = 10
				end
				acelessValue = acelessValue + val
			end
		end
	end

	if aceCount == 0 then -- aceless hand
		return acelessValue
	elseif acelessValue + aceCount*11 <= 21 then -- soft total
		return acelessValue + aceCount*11, acelessValue + aceCount*1
	else -- hard total
		return acelessValue + aceCount*1
	end
end

function VBJHand:addCard(card)
	self:_setRawString(self:_getRawString() .. card:toTwoByteString())
end
function VBJHand:revealCard(i, card)
	local raw = self:_getRawString()
	local nstr = raw:sub(1, i * 2) .. card:toTwoByteString() .. raw:sub((i + 1) * 2 + 1)
	self:_setRawString(nstr)
end
function VBJHand:addHiddenCard()
	self:_setRawString(self:_getRawString() .. "XX")
end

function ENT:InitializeHands()
	self.DealerHand = VBJHand()
	self.DealerHand._getRawString = function() return self:GetDealerHand() end
	self.DealerHand._setRawString = function(_,ns) self:SetDealerHand(ns) end

	self.PlayerHand = VBJHand()
	self.PlayerHand._getRawString = function() return self:GetPlayerHand() end
	self.PlayerHand._setRawString = function(_,ns) self:SetPlayerHand(ns) end
end
--[[

local test = VBJHand()

local str = "S4SA"
test._getRawString = function() return str end
test._setRawString = function(_, ns) str = ns end

test:addCard(CasinoKit.classes.Card.fromTwoByteString("D2"))

for k,v in test:cards() do
	print(k, v)
end
]]

function ENT:GetHandAsObjs()
	local hand = self:GetHand()

	local hando = {}
	for i=0,4 do
		local card = string.sub(hand, 1+i*2, 2+i*2)
		if card == "" then card = nil end

		local cardObj = self:CardStringToCard(card)
		hando[1+i] = cardObj
	end
	return hando
end

function ENT:CardStringToCard(cardStr)
	if cardStr then
		return CasinoKit.classes.Card.fromTwoByteString(cardStr)
	end
end