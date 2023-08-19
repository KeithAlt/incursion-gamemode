local vars = {
	["IsRobot"] = {
		Setup = function(class)
			class.Color = class.Color or Color(0, 8, 134)
			class.bloodcolor = class.bloodcolor or BLOOD_COLOR_MECH
			class.noHunger = class.noHunger or (class.noHunger == nil and true)
			class.radImmune = class.radImmune or (class.radImmune == nil and true)
			class.noGas = class.noGas or (class.noGas == nil and true)
			class.noArmor = class.noArmor or (class.noArmor == nil and true)
			class.health = class.health or 1200
			class.fearImmune = class.fearImmune or true
			class.fearPower = class.fearPower or 0.5
			class.pushImmune = class.pushImmune or true
		end
	},
	["IsMutant"] = {
		Setup = function(class)
			class.Color = class.Color or Color(0, 134, 8)
			class.noGas = false// class.noGas or (class.noGas == nil and true)
			class.radImmune = class.radImmune or (class.radImmune == nil and true)
			class.bloodcolor = class.bloodcolor or BLOOD_COLOR_GREEN
			class.health = class.health or 750
			class.fearResist = class.fearResist or 1.5
			class.fearPower = class.fearPower or 0.75
			class.pushImmune = class.pushImmune or true
		end
	},
	["IsCreature"] = {
		Setup = function(class)
			class.Color = class.Color or Color(255, 74, 74)
			class.bloodcolor = class.bloodcolor or BLOOD_COLOR_YELLOW
			class.radImmune = class.radImmune or (class.radImmune == nil and true)
			class.noHunger = class.noHunger or (class.noHunger == nil and true)
			class.noArmor = class.noArmor or (class.noArmor == nil and true)
			class.noGas = class.noGas or (class.noGas == nil and true)
			class.weapons = class.weapons or {"swep_am_monster"}
			class.health = class.health or 400
			class.fearImmune = class.fearImmune or true
			class.fearPower = class.fearPower or 0.5

			class.specialBuffs = class.specialBuffs or {	-- Special buffs on spawn
				["E"] = 25,
			}
		end
	}
}

local function Init()
	MsgC(Color(255, 255, 0, 255), "[CLASSVAR] ", Color(255, 255, 255, 255), "Initializing class variables & applying...\n")

	for id, class in pairs(nut.class.list) do
		for k, _ in pairs(class) do
			if vars[k] and vars[k].Setup then
				vars[k].Setup(class)
			end
		end
	end
end

if SERVER then
	hook.Add("PlayerInitialSpawn", "Classvars", function()
		Init()
		hook.Remove("PlayerInitialSpawn", "Classvars")
	end)
else
	hook.Add("InitPostEntity", "Classvars", Init)
end
if nut then Init() end

local function GetClassTable(ply)
	local char = ply:getChar()
	return char and nut.class.list[char:getClass()] or nil
end

-- Armor support
hook.Add("CanEquipArmor", "Classvars", function(item, ply)
	local class = GetClassTable(ply)

	if class and class.noArmor then
		return false
	end
end)

hook.Add("PlayerLoadout", "Classvars", function(ply)
	local class = GetClassTable(ply)

	if class then
		if class.noGas then
			ply:SetNWBool("SH_GasMask", true)
		end

		if class.pushImmune then
			ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
		else
			ply:RemoveEFlags(EFL_NO_DAMAGE_FORCES)
		end
	end
end)