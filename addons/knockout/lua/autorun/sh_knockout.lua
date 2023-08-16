AddCSLuaFile("knockout_config.lua")

knockoutConfig = {}
include("knockout_config.lua")

hook.Add("OnEntityCreated", "NoCollideRagdolls", function(ent)
    if ent:IsRagdoll() then
        timer.Simple(0, function()
			if IsValid(ent) then
        		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
			end
        end)
    end
end)

knockoutConfig.skerks = {
	["knockout"] = {
		["title"] = "Heavy Hitter",
		["desc"] = "Your increased strength allows you to knock out your enemies from behind.",
		["model"] = "models/halokiller38/fallout/weapons/melee/spikedknuckles.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "You can knock out non-power armored foes by hitting them in the back of the head with a blunt melee weapon.",
				["level"] = 10,
				["points"] = 2,
				["special"] = {
					["S"] = 10,
				}
			},
			[2] = {
				["desc"] = "You can knock out power armored foes by hitting them in the back of the head with a fully charged strike and blunt melee weapon.",
				["level"] = 20,
				["points"] = 5,
				["special"] = {
					["S"] = 15,
				}
			}
		}
	},
	["knockoutchance"] = {
		["title"] = "Melee Warrior",
		["desc"] = "Your increased strength gives you a chance to knockout your enemies. Your chance to knockout is reduced by " .. knockoutConfig.powerArmorPenalty .. "% if the opponent is wearing power armor.",
		["model"] = "models/mosi/fallout4/props/weapons/melee/boxingglove.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "You have a " .. knockoutConfig.knockoutChance[1] .. "% chance to knock out your foe when striking them with any melee weapon. You cannot knockout enemies wearing power armor.",
				["level"] = 15,
				["points"] = 3,
				["special"] = {
					["S"] = 15,
				}
			},
			[2] = {
				["desc"] = "You have a " .. knockoutConfig.knockoutChance[2] .. "% chance to knock out your foe when striking them with any melee weapon. You can knockout enemies wearing power armor.",
				["level"] = 30,
				["points"] = 3,
				["special"] = {
					["S"] = 20,
				}
			}
		}
	}
}

local function RegisterSkerks()
	print("Registering knockout skerks")

	for id, skerk in pairs(knockoutConfig.skerks) do
		nut.skerk.register(id, skerk)
	end
end

if CLIENT then
	hook.Add("InitPostEntity", "KnockoutSkerkRegister", RegisterSkerks)
else
	hook.Add("PlayerSpawn", "KnockoutSkerkRegister", function()
		RegisterSkerks()
		hook.Remove("PlayerSpawn", "KnockoutSkerkRegister")
	end)
end

hook.Add("PlayerSwitchWeapon", "KnockoutForce", function(ply)
	if IsValid(ply:GetNWEntity("KnockoutDoll")) then
		return true
	end
end)
