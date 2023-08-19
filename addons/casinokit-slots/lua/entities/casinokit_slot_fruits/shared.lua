DEFINE_BASECLASS"casinokit_machine"
ENT.Base = "casinokit_machine"

ENT.PrintName		= "Slot: Fruits"
ENT.Author			= "Wyozi"
ENT.Category		= "Casino Kit"

ENT.Editable		= true
ENT.Spawnable		= true
ENT.AdminOnly		= true

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Float", 0, "Jackpot")

	self:NetworkVar("Float", 1, "Wheel1Rad")
	self:NetworkVar("Float", 2, "Wheel2Rad")
	self:NetworkVar("Float", 3, "Wheel3Rad")
end

ENT.WheelItems = {
	{ mat_path = "models/casinokit/slots/fruits/apple.png", name = "apple" },
	{ mat_path = "models/casinokit/slots/fruits/banana.png", name = "banana" },
	{ mat_path = "models/casinokit/slots/fruits/lemon.png", name = "lemon" },
	{ mat_path = "models/casinokit/slots/fruits/orange.png", name = "orange" },
	{ mat_path = "models/casinokit/slots/fruits/pear.png", name = "pear" },
	{ mat_path = "models/casinokit/slots/fruits/strawberry.png", name = "strawberry" },
	{ mat_path = "models/casinokit/slots/fruits/seven.png", name = "seven" },
}

ENT.WheelData = {
	{ deaccel = -4 },
	{ deaccel = -3.5 },
	{ deaccel = -3 }
}

local prob_one = 1 / #ENT.WheelItems
local prob_two = 2 / #ENT.WheelItems
local prob_allbutone = (#ENT.WheelItems - 1) / #ENT.WheelItems
local prob_allbuttwo = (#ENT.WheelItems - 2) / #ENT.WheelItems

-- probability of getting a fruit
local prob_fruit = prob_allbutone

-- Paytable requirements:
-- Each item has to be discrete (ie. if 'test' condition succeeds, it must not succeed in any other pay item)
ENT.Paytable = {
	{
		display = {"3x ", {"item", "seven"}},
		test = function(items)
			local c = 0
			for _,i in pairs(items) do
				if i.name == "seven" then c = c + 1 end
			end
			return c == 3
		end,
		probability = prob_one^3,
		value = 20,
		jackpot = true
	},
	{
		display = {"3x same fruit"},
		test = function(items)
			local l
			for _,i in pairs(items) do
				if i.name == "seven" or l and l ~= i.name then return false end
				l = i.name
			end
			return true
		end,
		probability = prob_fruit * prob_one^2, -- fruit; after that two of same
		value = 8
	},
	{
		display = {"1x", {"item", "lemon"}, "1x", {"item", "orange"}},
		test = function(items)
			local lc, oc = 0, 0
			for _,i in pairs(items) do
				if i.name == "lemon" then lc = lc + 1 end
				if i.name == "orange" then oc = oc + 1 end
			end
			return lc == 1 and oc == 1
		end,
		probability = 3 * (prob_one * 2 * (prob_one * prob_allbuttwo)),
		value = 2
	},
	{
		display = {"1x", {"item", "pear"}, "1x", {"item", "apple"}},
		test = function(items)
			local lc, oc = 0, 0
			for _,i in pairs(items) do
				if i.name == "pear" then lc = lc + 1 end
				if i.name == "apple" then oc = oc + 1 end
			end
			return lc == 1 and oc == 1
		end,
		probability = 3 * (prob_one * 2 * (prob_one * prob_allbuttwo)),
		value = 2
	},
	{
		display = {"2x ", {"item", "seven"}},
		test = function(items)
			local c = 0
			for _,i in pairs(items) do
				if i.name == "seven" then c = c + 1 end
			end
			return c == 2
		end,
		probability = 3 * (prob_one * prob_one * prob_allbutone),
		value = 2
	},
	{
		display = {"2x", {"item", "strawberry"}},
		test = function(items)
			local c = 0
			for _,i in pairs(items) do
				if i.name == "strawberry" then c = c + 1 end
			end
			return c == 2
		end,
		probability = 3 * (prob_one * prob_one * prob_allbutone),
		value = 1
	},
	{
		display = {"2x", {"item", "banana"}},
		test = function(items)
			local c = 0
			for _,i in pairs(items) do
				if i.name == "banana" then c = c + 1 end
			end
			return c == 2
		end,
		probability = 3 * (prob_one * prob_one * prob_allbutone),
		value = 1
	},
}

ENT.JackpotStart = 100
ENT.AddToJackpotPercentage = 0.35

function ENT:GetEstimatedHouseEdge()
	local bet = 1
	local E = 0
	for _,p in pairs(ENT.Paytable) do
		if not p.jackpot then
			E = E + bet*p.value*p.probability
		end
	end
	return bet - E
end

function ENT:GetSpinStopTime(wheel, startVel)
	return -startVel / self.WheelData[wheel].deaccel
end

function ENT:GetFinalRad(wheel, startVel)
	return self:GetRadAt(wheel, startVel, self:GetSpinStopTime(wheel, startVel))
end

function ENT:GetRadAt(wheel, startVel, time)
	local finished = nil

	local stopTime = self:GetSpinStopTime(wheel, startVel)
	if time >= stopTime then
		finished = true
		time = stopTime
	end
	
	return startVel * time + 0.5 * self.WheelData[wheel].deaccel * time^2, finished
end

function ENT:GetRadForItemIndex(i)
	return ((i-1) / #self.WheelItems) * math.pi * 2
end
function ENT:GetItemIndexForRad(rad)
	rad = rad % (math.pi*2)

	local radPerItem = (math.pi * 2) / #self.WheelItems 
	local flooredIndex = 1 + math.floor(rad / radPerItem)
	local extra = rad % radPerItem

	local baseIndex = (extra < (radPerItem / 2)) and flooredIndex or (flooredIndex + 1)
	
	if baseIndex > #self.WheelItems then
		return 1
	else
		return baseIndex
	end
end

function ENT:GetWheelStartRad(i)
	return self["GetWheel" .. i .. "Rad"](self)
end
function ENT:SetWheelStartRad(i, r)
	return self["SetWheel" .. i .. "Rad"](self, r)
end