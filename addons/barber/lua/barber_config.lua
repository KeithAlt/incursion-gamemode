-- Customers must be sat in a vehicle with one of these models to have their hair cut
Barber.Config.Chairs = {
	"models/nova/chair_wood01.mdl",
	"models/nova/chair_plastic01.mdl",
	"models/nova/chair_office01.mdl"
}

-- VIP bodygroup settings, put the IDs here eg {0, 4, 11}
Barber.Config.VIPHairs = {
	["male"] = {32},
	["female"] = {36, 37},
	["ghoul"] = {}
}
Barber.Config.VIPBeards = {
	["male"] = {},
	["female"] = {},
	["ghoul"] = {}
}

-- Skillcheck difficulty settings
Barber.Config.ScratchSpeed = 400
Barber.Config.MinRange = 35
Barber.Config.MaxRange = 70
Barber.Config.IntelligenceBonus = 150 -- The amount of speed that will be subtracted at max intelligence

-- Types of accessory that will cover the hair
Barber.Config.HatTypes = {"hat"}
