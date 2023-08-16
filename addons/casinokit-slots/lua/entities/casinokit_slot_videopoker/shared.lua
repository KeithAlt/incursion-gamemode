DEFINE_BASECLASS"casinokit_machine"
ENT.Base = "casinokit_machine"

ENT.PrintName		= "Video Poker"
ENT.Author			= "Wyozi"
ENT.Category		= "Casino Kit"

ENT.Editable		= true
ENT.Spawnable		= true
ENT.AdminOnly		= true

local VAL_STRAIGHT_FLUSH = 9
local VAL_FOUROFAKIND = 8
local VAL_FULL_HOUSE = 7
local VAL_FLUSH = 6
local VAL_STRAIGHT = 5
local VAL_THREEOFAKIND = 4
local VAL_TWOPAIR = 3
local VAL_PAIR = 2
local VAL_HIGHCARD = 1

ENT.Paytable = {
	--royalflush = 800,
	[VAL_STRAIGHT_FLUSH] = 50,
	[VAL_FOUROFAKIND] = 25,
	[VAL_FULL_HOUSE] = 9,
	[VAL_FLUSH] = 6,
	[VAL_STRAIGHT] = 4,
	[VAL_THREEOFAKIND] = 3,
	[VAL_TWOPAIR] = 2,
}

ENT.VerbosePaytable = {
	{name = "Royal Flush", val = 800},
	{name = "Straight Flush", val = 50},
	{name = "Four of a Kind", val = 25},
	{name = "Full House", val = 9},
	{name = "Flush", val = 6},
	{name = "Straight", val = 4},
	{name = "Three of a Kind", val = 3},
	{name = "Two Pair", val = 2},
	{name = "Jacks or better", val = 1}
}

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Entity", 0, "Player")
	self:NetworkVar("String", 0, "Hand")
	self:NetworkVar("Int", 2, "HeldCards")
	self:NetworkVar("Float", 0, "TurnTimeout")
end

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