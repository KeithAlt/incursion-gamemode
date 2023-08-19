nut.skerk = nut.skerk or {}
nut.skerk.skerks = nut.skerk.skerks or {}

nut.skerk.special = nut.skerk.special or {["S"] = 0, ["P"] = 0, ["E"] = 0, ["C"] = 0, ["I"] = 0, ["A"] = 0, ["L"] = 0}
nut.skerk.specialDis = nut.skerk.specialDis or {}

nut.config.add("Respec Cost Multiplier", true, "Should respec cost go up per use?", nil, {
	category = "Levelling"
})

nut.config.add("Respec Price", 10000, "How much should a respec cost?", nil, {
	data = {min = 1000, max = 100000},
	category = "Levelling"
})

function nut.skerk.register(id, data)
	nut.skerk.skerks[id] = data
end

function nut.skerk.hasSkerk(player, skerk, level)
	local char = player:getChar()

	local data = char:getData("skerks", {})

	if (data[skerk]) then
		if (level) then
			if (data[skerk] == level) then
				return data[skerk]
			else
				return false
			end
		else
			return data[skerk]
		end
	else
		return false
	end
end

function nut.skerk.skerkLevel(player, skerk)
	local char = player:getChar()

	local data = char:getData("skerks", {})

	if (data[skerk]) then
		return data[skerk]
	else
		return false
	end
end

do
	local playerMeta = FindMetaTable("Player")

	function playerMeta:hasSkerk(skerk, level)
		return nut.skerk.hasSkerk(self, skerk, level)
	end

	function playerMeta:getSpecialNoBuff(special)
		special = string.upper(special)

		local char = self:getChar()
		if !char then return 0 end

		local data = char:getData("special", {})

		return math.Clamp(data[special] or 0, 0, 25)
	end

	function playerMeta:getSpecial(special)
		return math.Clamp(self:getSpecialNoBuff(special) + self:GetBuff(special), 0, 30)
	end

	function playerMeta:GetBuff(stat)
		return self:GetNW2Int(stat .. "Buff", 0)
	end
end

if CLIENT then
	SpecialBuffs = {}

	concommand.Add("giveskillpoints", function(ply, cmd, args, argStr)
		if !ply:IsSuperAdmin() then return end
		if !args[1] or !args[2] or !isnumber(tonumber(args[2])) then
			print("Provide the players name and the amount")
			return
		end
		net.Start("special_AddSkillPoints")
			net.WriteString(args[1])
			net.WriteInt(tonumber(args[2]), 32)
		net.SendToServer()
	end)

	surface.CreateFont("StatDisplayFont", {font = "Verdana", size = 14, weight = 700})

	local statShort = {
		["S"] = "STR",
		["P"] = "PER",
		["E"] = "END",
		["C"] = "CHR",
		["I"] = "INT",
		["A"] = "AGL",
		["L"] = "LCK"
	}

	hook.Add("HUDPaint", "buffDisplay", function()
		local y = 0
		surface.SetFont("StatDisplayFont")
		surface.SetTextColor(nut.gui.palette.color_primary)

		local ply = LocalPlayer()

		for stat, short in pairs(statShort) do
			local buff = ply:GetBuff(stat)
			if buff == 0 then
				SpecialBuffs[stat] = nil
				continue
			end

			local buffTimeLeft = SpecialBuffs[stat] and SpecialBuffs[stat] - CurTime() or -1
			local text = short .. (buff > 0 and " +" or " -") .. buff .. " " .. (buffTimeLeft > 0 and string.FormattedTime(buffTimeLeft, "%02i:%02i") or "")
			surface.SetTextPos(0, y)
			surface.DrawText(text)

			y = y + 25
		end
	end)

	net.Receive("StartSPECIALBuff", function()
		local stat = net.ReadString()
		local endTime = net.ReadInt(32)

		if SpecialBuffs[stat] == -1 then
			return
		end

		SpecialBuffs[stat] = math.max(endTime, SpecialBuffs[stat] or -2)
	end)
end
