PLUGIN.name = "Mining"
PLUGIN.author = "SuperMicronde"
PLUGIN.desc = "Ore mining"

-- Rocks config
PLUGIN.HarvestMul = 20
PLUGIN.DefaultHp = 5
PLUGIN.DefaultMaxHp = 5
PLUGIN.DefaultType = 0
PLUGIN.DefaultRefreshAmount = 5
PLUGIN.DefaultRefreshRate = 300

-- Refinery stuff
PLUGIN.MaxMelts = 4 --How many ores can be melt at one refinery at once

PLUGIN.Recipes = {
	["bar_bronze"] = {30, {ore_bronze = 1, coal = 1}},
	["bar_gold"] = {30, {ore_gold = 1, coal = 1}},
	["bar_iron"] = {30, {ore_iron = 1, coal = 1}},
	["bar_silver"] = {30, {ore_silver = 1, coal = 1}}
}

-- Includes
nut.util.include("sv_plugin.lua")
nut.util.include("cl_plugin.lua")

-- Util
function PLUGIN:TableSum(tbl)
	local i = 0

	for _, v in pairs(tbl) do
		i = i + v
	end

	return i
end

function PLUGIN:InDistance(pos01, pos02, dist)
	local inDistance = pos01:DistToSqr(pos02) < (dist * dist)
	return  inDistance
end

-- Precache
util.PrecacheModel("models/zerochain/props_mining/zrms_resource_point.mdl")
game.AddParticles("particles/zrms_pickaxe_vfx.pcf")
game.AddParticles("particles/zrms_ore_vfx.pcf")
PrecacheParticleSystem("zrms_ore_refresh")
PrecacheParticleSystem("zrms_ore_mine")
PrecacheParticleSystem("pickaxe_hit01")