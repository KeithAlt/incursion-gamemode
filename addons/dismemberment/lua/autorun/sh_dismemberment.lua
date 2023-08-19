Dismemberment = Dismemberment or {}
Dismemberment.PostRegistry = Dismemberment.PostRegistry or false
Dismemberment.Config = Dismemberment.Config or {}

AddCSLuaFile("dismemberment_config.lua")
include("dismemberment_config.lua")

--Util funcs
function Dismemberment.Print(msg)
	MsgC(Color(68, 181, 113, 255), "[Dismemberment] ", Color(255, 255, 255, 255), msg, "\n")
end

--Automatic Dismemberment.Config.Weapons population
function Dismemberment.AutoPopulateWeps()
	Dismemberment.Print("Populating dismemberment weapons table.")

	local wepRegistries = {
		nut.fallout.registry.melee,
		nut.fallout.registry.secondary,
		nut.fallout.registry.primary
	}

	for _, registry in ipairs(wepRegistries) do
		for uID, wepTbl in pairs(registry) do
			Dismemberment.Config.Weapons[wepTbl.class] = jlib.UpperFirstChar(wepTbl.type)
		end
	end
end

hook.Add("PostRegistry", "DismembermentConfig", function()
	Dismemberment.PostRegistry = true
	Dismemberment.AutoPopulateWeps()
end)

if Dismemberment.PostRegistry then
	Dismemberment.AutoPopulateWeps()
end

--Getters
function Dismemberment.GetDefaultCaliber()
	return Dismemberment.Config.Calibers[Dismemberment.Config.DefaultCaliber]
end

function Dismemberment.GetCaliber(wep)
	if IsValid(wep) then
		local caliberName = Dismemberment.Config.Weapons[wep:GetClass()]
		if caliberName then
			if Dismemberment.Config.Calibers[caliberName] then
				return Dismemberment.Config.Calibers[caliberName], caliberName
			else
				Dismemberment.Print("WARNING: Weapon with class " .. wep:GetClass() .. " is set to an invalid caliber: " .. caliberName .. "!")
				return Dismemberment.GetDefaultCaliber()
			end
		else
			Dismemberment.Print("WARNING: Weapon with class " .. wep:GetClass() .. " is being used and does not have a set caliber.")
			return Dismemberment.GetDefaultCaliber()
		end
	end
end

function Dismemberment.GetDismembermentZone(hit)
	return Dismemberment.Config.DismembermentZones[hit]
end

-- Get the damage multipliers in string form for weapons
function Dismemberment.getHitgroupDesc(wepClass)
	if !(Dismemberment and Dismemberment.Config and Dismemberment.Config.Calibers) then return end

	local wep = Dismemberment.Config.Weapons[wepClass] or false

	if !wep or !Dismemberment.Config.Calibers[wep] then
		return ""
	end

	local statString =
	"\n\n[ HIT MULTIPLIERS ]" ..
	"\n‣ HEAD = x" .. Dismemberment.Config.Calibers[wep]["Multipliers"][1] ..
	"\n‣ CHEST = x" .. Dismemberment.Config.Calibers[wep]["Multipliers"][2] ..
	"\n‣ LIMBS = x" .. Dismemberment.Config.Calibers[wep]["Multipliers"][3]

	return statString
end
