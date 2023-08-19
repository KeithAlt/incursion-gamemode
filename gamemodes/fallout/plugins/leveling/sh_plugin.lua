nut.leveling = {}

PLUGIN.name = "Leveling 2.0"
PLUGIN.author = "Vex"
PLUGIN.desc = "A new and improved version of leveling, how dank."

nut.util.include("sv_plugin.lua")
nut.util.include("cl_plugin.lua")

nut.leveling.spike = 50

function nut.leveling.requiredXP(level)
	local XPR = 0

	if level > nut.leveling.spike then
		XPR = nut.leveling.requiredXP(nut.leveling.spike) + math.floor(1.22 ^ level)
	elseif level > 0 then
		XPR = (92 + (level * 2)) * (math.max(level - 1, 0)) + 200
	end

	return XPR
end
