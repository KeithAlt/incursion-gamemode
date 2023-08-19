util.AddNetworkString("special_AddSkillPoints")

function nut.skerk.giveSkerk(player, skerk, level)
	if (nut.skerk.skerks[skerk]) then
		local char = player:getChar()

		local data = char:getData("skerks", {})

		data[skerk] = level or 1

		char:setData("skerks", data)

		return true
	else
		return false
	end
end

local PLAYER = FindMetaTable("Player")

function PLAYER:setSpecial(stat, new)
	stat = string.upper(stat)

	local char = self:getChar()
	if !char then return end

	local special = char:getData("special", {})
	special[stat] = new
	char:setData("special", special)

	hook.Run("SPECIALStatChanged", self, char, stat, new)
end

netstream.Hook("nutSkerkUpgrade", function(player, skerk)
	if (!nut.skerk.skerks[skerk]) then return false, "Invalid Skill" end;

	local char = player:getChar()
	local points = char:getData("skillPoints", 0)
	local level = char:getData("level", 0)
	local skerks = char:getData("skerks", {})

	local tier = skerks[skerk] or 0
	tier = tier + 1

	local data = nut.skerk.skerks[skerk]

	if (tier > #data["tiers"]) then
		return false, "Max Tier Reached!"
	elseif (data["tiers"][tier]["level"] > level) then
		return false, "Level Not High Enough"
	elseif (data["tiers"][tier]["points"] > points) then
		return false, "Not Enough Points"
	elseif (data["tiers"][tier]["prerequisite"]) then
		for i, v in pairs(data["tiers"][tier]["prerequisite"]) do
			if (!skerks[i]) then
				return false, "Missing Required Skill"
			elseif (skerks[i] < v) then
				return false, "Required Skill Level Not High Enough"
			end;
		end;
	end;

	skerks[skerk] = tier

	char:setData("skerks", skerks)
	char:setData("skillPoints", points - data["tiers"][tier]["points"])
	return true
end)

netstream.Hook("nutSkerkUpgradeSpecial", function(player, stat)
	local char = player:getChar()
	local points = char:getData("skillPoints", 0)
	local special = char:getData("special", {})

	special[stat] = special[stat] or 0

	if (!nut.skerk.special[stat]) then
		return false, "Invalid Stat"
	elseif (points < 1) then
		return false, "Not Enough Points"
	elseif (special[stat] >= 25) then
		return false, "Stat Maxed Out"
	elseif (nut.skerk.specialDis[i]) then
		return false, "Stat Disabled"
	end

	special[stat] = special[stat] + 1
	char:setData("special", special)
	char:setData("skillPoints", points - 1)

	hook.Run("SPECIALStatChanged", player, char, stat, special[stat])

	return true
end)

net.Receive("special_AddSkillPoints", function(len, ply)
	if !ply:IsSuperAdmin() then return end
	local plyName = net.ReadString()
	local amt = net.ReadInt(32)
	if !plyName or !amt then return end
	local target
	for k,v in pairs(player.GetAll()) do
		if string.match(v:Nick():lower(), plyName) then target = v end
	end
	if !target then ply:PrintMessage(HUD_PRINTCONSOLE, "Player not found") return end
	local char = target:getChar()
	if !char then return end
	local curSkillPoints = char:getData("skillPoints", nil)
	if !curSkillPoints then return end
	char:setData("skillPoints", curSkillPoints + amt)
	ply:PrintMessage(HUD_PRINTCONSOLE, "Successfully given points")
end)
