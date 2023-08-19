nut.leveling.config = {maxLevel = 50, passiveInterval = 200, passiveAmount = 10, levelMultiplier = 75, intelBonus = 0.02}

function nut.leveling.giveXP(player, XP, silent, muteSound)
	local character = player:getChar()

	if !character then return end

	local CXP = character:getData("XP", 0)
	local CLV = character:getData("level", 0)
	local SKP = character:getData("skillPoints", 0)

	local XPR = nut.leveling.requiredXP(CLV + 1)

	XP = math.Round(XP * (1 + (player:getSpecial("L") * nut.leveling.config.intelBonus)), 2)
	CXP = CXP + XP

	if CXP >= XPR then
		CLV = CLV + 1
		character:setData("level", CLV)

		character:setData("skillPoints", SKP + 1)

		player:falloutNotify("You've reached level " .. CLV, "fallout/level_up.wav")
	elseif !silent then
		netstream.Start(player, "getXP", XP, muteSound or false)
	end

	character:setData("XP", CXP)
end

function PLUGIN:PlayerLoadedChar(client, character, lastChar)
	local id = client:SteamID64()
	if !timer.Exists(id .. "_leveling") then
		timer.Create(id .. "_leveling", nut.leveling.config.passiveInterval, 0, function()
			if IsValid(client) then
				nut.leveling.giveXP(client, nut.leveling.config.passiveAmount, true)
			else
				timer.Remove(id .. "_leveling")
			end
		end)
	end
end

function nut.leveling.RecalculateLevel(char)
	if char:getData("level", 0) > nut.leveling.spike then
		local levelShouldBe
		local currentLevel = char:getData("level", 0)
		local currentXP = char:getData("XP", 0)

		for potentialLevel = currentLevel, 1, -1 do
			local xpRequired = nut.leveling.requiredXP(potentialLevel)

			if xpRequired <= currentXP then
				levelShouldBe = potentialLevel
				break
			end
		end

		if levelShouldBe != currentLevel then
			print(char:getName() .. " is currently level " .. currentLevel .. " but should be level " .. levelShouldBe .. " fixing and resetting skills.")

			char:setData("level", levelShouldBe)
			char:setData("skillPoints", levelShouldBe + (Armor and Armor.Config.SkillPoints))
			char:setData("skerks", {})
			char:setData("special", {})

			return true
		end
	end
end

hook.Add("PlayerLoadedChar", "RecalculateLevel", function(ply, char, oldChar)
	if nut.leveling.RecalculateLevel(char) then
		ply:ChatPrint("Your skills have been reset due to your level being readjusted to fit with the new leveling algorithm.")
	end
end)
