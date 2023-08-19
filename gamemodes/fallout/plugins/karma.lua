local PLUGIN = PLUGIN
PLUGIN.name = "Karma"
PLUGIN.author = "Chancer"
PLUGIN.desc = "Karma allignment system."

local playerMeta = FindMetaTable("Player")

nut.config.add("karmaIncomeTime", 3600, "Time between faction karma income. (Requires server restart to take effect)", nil, {
	data = {min = 1, max = 84600},
	category = "Karma"
})

PLUGIN.titles = {
	{ --level 1
		[1] = "Vault Guardian", --good
		[2] = "Vault Dweller", --bad
		[3] = "Vault Delinquent", --neutral
	},

	{ --level 2
		[1] = "Vault Martyr",
		[2] = "Vault Renegade",
		[3] = "Vault Outlaw",
	},


	{ --3
		[1] = "Sentinel",
		[2] = "Seeker",
		[3] = "Opportunist",
	},

	{ --4
		[1] = "Defender",
		[2] = "Wanderer",
		[3] = "Plunderer",
	},

	{ --5
		[1] = "Dignitary",
		[2] = "Citizen",
		[3] = "Fat Cat",
	},

	{ --6
		[1] = "Peacekeeper",
		[2] = "Adventurer",
		[3] = "Marauder",
	},

	{ --7
		[1] = "Ranger of the Wastes",
		[2] = "Vagabond of the Wastes",
		[3] = "Pirate of the Wastes",
	},

	{ --8
		[1] = "Protector",
		[2] = "Mercenary",
		[3] = "Reaver",
	},

	{ --9
		[1] = "Urban Avenger",
		[2] = "Urban Ranger",
		[3] = "Urban Invader",
	},

	{ --10
		[1] = "Exemplar",
		[2] = "Observer",
		[3] = "Ne'er-do-well",
	},

	{ --11
		[1] = "Capital Crusader",
		[2] = "Capital Councilor",
		[3] = "Capital Crimelord",
	},

	{ --12
		[1] = "Paladin",
		[2] = "Keeper",
		[3] = "Defiler",
	},

	{ --13
		[1] = "Vault Legend",
		[2] = "Vault Descendant",
		[3] = "Vault Boogeyman",
	},

	{ --14
		[1] = "Ambassador of Peace",
		[2] = "Pinnacle of Survival",
		[3] = "Harbinger of War",
	},

	{ --15
		[1] = "Urban Legend",
		[2] = "Urban Myth",
		[3] = "Urban Superstition",
	},

	{ --16
		[1] = "Hero of the Wastes",
		[2] = "Strider of the Wastes",
		[3] = "Villain of the Wastes",
	},

	{ --17
		[1] = "Paragon",
		[2] = "Beholder",
		[3] = "Fiend",
	},

	{ --18
		[1] = "Wasteland Savior",
		[2] = "Wasteland Watcher",
		[3] = "Wasteland Destroyer",
	},

	{ --19
		[1] = "Saint",
		[2] = "Super-Human",
		[3] = "Evil Incarnate",
	},

	{ --20
		[1] = "Last, Best Hope for Humanity",
		[2] = "Paradigm of Humanity",
		[3] = "Scourge of Humanity",
	},

	{ --21
		[1] = "Restorer of Faith",
		[2] = "Soldier of Fortune",
		[3] = "Architect of Doom",
	},

	{ --22
		[1] = "Model of Selflessness",
		[2] = "Profiteer",
		[3] = "Bringer of Sorrow",
	},

	{ --23
		[1] = "Shepherd",
		[2] = "Egocentric",
		[3] = "Deceiver",
	},

	{ --24
		[1] = "Friend of the People",
		[2] = "Loner",
		[3] = "Consort of Discord",
	},

	{ --25
		[1] = "Champion of Justice",
		[2] = "Hero for Hire",
		[3] = "Stuff of Nightmares",
	},

	{ --26
		[1] = "Symbol of Order",
		[2] = "Model of Apathy",
		[3] = "Agent of Chaos",
	},

	{ --27
		[1] = "Herald of Tranquility",
		[2] = "Person of Refinement",
		[3] = "Instrument of Ruin",
	},

	{ --28
		[1] = "Lightbringer",
		[2] = "Moneygrubber",
		[3] = "Soultaker",
	},

	{ --29
		[1] = "Earthly Angel",
		[2] = "Gray Stranger",
		[3] = "Demon's Spawn",
	},

	{ --30
		[1] = "Messiah",
		[2] = "True Mortal",
		[3] = "Devil",
	},

}

PLUGIN.titlesFact = {
	[80] = {
		desc = "Wasteland Saints\n\nThis faction dedicates itself to defending the innocent.",
		icon = Material("icons/glow_karma_saintly.png"),
	},

	[60] = {
		desc = "Wasteland Heroes\n\nThis faction is infamous for it's acts of heroism.",
		icon = Material("icons/glow_karma_saintly.png"),
	},

	[40] = {
		desc = "Wasteland Peacekeepers\n\nThis faction is known for it's acts of heroism.",
		icon = Material("icons/glow_karma_good.png"),
	},

	[20] = {
		desc = "Wasteland Saviors\n\nThis faction is known for occasional acts of heroism.",
		icon = Material("icons/glow_karma_good.png"),
	},

	[-20] = {
		desc = "Wasteland Renegades\n\nThis faction is known for following it's own rules.",
		icon = Material("icons/glow_karma_neutral.png"),
	},

	[-40] = {
		desc = "Wasteland Opportunists\n\nThis faction is known for acts of occasional evil.",
		icon = Material("icons/glow_karma_bad.png"),
	},

	[-60] = {
		desc = "Wasteland Marauders\n\nThis faction is known for it's acts of evil.",
		icon = Material("icons/glow_karma_bad.png"),
	},

	[-80] = {
		desc = "Wasteland Villians\n\nThis faction is infamous for it's acts of evil.",
		icon = Material("icons/glow_karma_evil.png"),
	},

	[-100] = {
		desc = "Wasteland Devils\n\nThis faction dedicates itself to chaos & ruin.",
		icon = Material("icons/glow_karma_evil.png"),
	},
}

--gets the player's karma with its fancy name and color info, use this for display things
function PLUGIN:getKarmaFancyFaction(faction)
	local factionTbl = nut.faction.indices[faction]
	local factionUID = factionTbl.uniqueID

	local karma = PLUGIN.factionKarma[factionUID] or {1,1} --just a fallback

	local karmaTotal = karma[1] + karma[2]
	local karmaRatio = (karma[1] - karma[2]) / (karma[1] + karma[2]) --ratio of good/bad

	local karmaCol = HSVToColor(120 * ((karmaRatio + 1) / 2), 1, 1)--Color(red, green, blue)

	local karmaTitle = { --default value, expected to be overwritten
		desc = "Wasteland Renegades\n\nThis faction is known for following it's own rules.",
		icon = Material("icons/karmaneutral.png"),
	}

	local karmaRatioPercent = karmaRatio * 100

	for k, v in SortedPairs(PLUGIN.titlesFact, true) do
		if(karmaRatioPercent > k) then
			karmaTitle = v
			break
		end
	end

	return karmaTitle, karmaCol --this shouldnt happen
end

if(SERVER) then
	PLUGIN.factionKarma = {} --global faction karma

	--gets global faction karma values based on every character
	function PLUGIN:getGlobalFactionKarma()
		nut.db.query("SELECT _faction, _data FROM nut_characters", function(data)
			if (data and #data > 0) then
				for id, charInfo in pairs(data) do
					local faction = charInfo._faction

					local charData = util.JSONToTable(charInfo._data)

					if(charData and charData.karma and istable(charData.karma)) then
						local good = charData.karma[1] or 0
						local bad = charData.karma[2] or 0

						if(!PLUGIN.factionKarma[faction]) then
							PLUGIN.factionKarma[faction] = {}
						end

						PLUGIN.factionKarma[faction][1] = (PLUGIN.factionKarma[faction][1] or 0) + good
						PLUGIN.factionKarma[faction][2] = (PLUGIN.factionKarma[faction][2] or 0) + bad
					end
				end
			end
		end)
	end

	function PLUGIN:InitializedPlugins()
		PLUGIN:getGlobalFactionKarma()
	end

	function PLUGIN:PlayerInitialSpawn(client)
		PLUGIN:networkFactionKarma(client) --networks faction global karmas
	end

	--whenever a player loads a character
	function PLUGIN:PlayerLoadedChar(client)
		PLUGIN:networkKarma(client)
	end

	--called when a character is transferred to another faction
	function PLUGIN:CharacterFactionTransfered(character, oldFaction, faction)
		local client = character:getPlayer()

		PLUGIN:networkKarma(client)
	end

	--networks a specific client's karma info
	function PLUGIN:networkFactionKarma(client)
		local factionKarmaJSON = util.TableToJSON(PLUGIN.factionKarma)

		netstream.Start(client, "nut_karmaFactionNetwork", factionKarmaJSON)
	end

	--networks a specific client's karma info
	function PLUGIN:networkFactionKarmaPartial(client, faction)
		local factionKarma = PLUGIN.factionKarma[faction]

		netstream.Start(client, "nut_karmaFactionPartialNetwork", faction, factionKarma)
	end

	--networks a specific client's karma info
	function PLUGIN:networkKarma(client)
		local title, level, col, karma = client:getKarmaFancy()

		if(title) then
			local karmaTotal = karma[1] + karma[2]

			local karmaTbl = {
				title = title,
				level = level,
				karma = karmaTotal,
				karmaRaw = karma,
				col = col,
			}

			client:setNetVar("karma", karmaTbl)
		else
			client:setNetVar("karma", nil)
		end
	end

	--determines whether a killer gains/loses karma
	function PLUGIN:killKarma(client, attacker)
		local karmaRatio = client:getKarmaRatio()

		local neutral
		local align
		if(karmaRatio > 0.3) then --good karma ratio
			align = 2 --gain bad karma for killing good
		elseif(karmaRatio < -0.3) then --bad karma ratio
			align = 1 --gain good karma for killing bad
		else
			neutral = true
		end

		local faction = attacker:getChar():getFaction()
		local factionTbl = nut.faction.indices[faction] or {}
		local factionKarma = factionTbl.karma or {}

		if(!neutral) then
			local karmaGain = 5 * ((factionKarma.kill and factionKarma.kill[align]) or 1) --faction modifier
			attacker:addKarma(karmaGain, align)
		else
			local karmaGainGood = 2.5 * ((factionKarma.kill and factionKarma.kill[1]) or 1) --faction modifier
			local karmaGainBad = 2.5 * ((factionKarma.kill and factionKarma.kill[2]) or 1) --faction modifier

			attacker:addKarma(karmaGainGood, 1)
			attacker:addKarma(karmaGainBad, 2)
		end
	end

	--called when someone levels up
	function PLUGIN:onLevelUp(client, newLevel)
		local title, level = client:getKarmaFancy()
		--put your notification here
		client:falloutNotify("Your Karma Level has Increased: " .. "LVL " .. level, "ui/found.wav")
		client:falloutNotify("Title: " .. title)
	end

	--check when a player dies to see if another player killed them
	function PLUGIN:PlayerDeath(client, inflictor, attacker)
		if IsValid(attacker) and IsValid(client) and attacker:IsPlayer() then
			PLUGIN:killKarma(client, attacker)
		else
			local owner = inflictor.Owner
			if IsValid(owner) and owner:IsPlayer() and IsValid(client) then
				PLUGIN:killKarma(client, owner)
			end
		end
	end

	--sets the player's karma
	function playerMeta:setKarma(amount, align)
		if(!isnumber(amount)) then
			return false
		end

		local char = self:getChar()

		local karma = self:getKarma()
		karma[align] = amount

		char:setData("karma", karma) --charData saves to db

		PLUGIN:networkKarma(self)

		return true
	end

	--adds to the player's karma
	function playerMeta:addKarma(amount, align)
		if(!isnumber(amount)) then
			return false
		end

		local oldLevel = self:getLevel() --level before karma given

		local char = self:getChar()

		local karma = self:getKarma()
		karma[align] = karma[align] + amount

		char:setData("karma", karma)

		PLUGIN:networkKarma(self) --level after karma given

		local newLevel = self:getLevel()

		--checks if they levelled up from the added karma
		if(newLevel > oldLevel) then
			PLUGIN:onLevelUp(self, newLevel)
		end

		local factionIndex = char:getFaction()
		local factionTbl = nut.faction.indices[factionIndex]
		local factionID = factionTbl.uniqueID

		if(PLUGIN.factionKarma[factionID]) then
			PLUGIN.factionKarma[factionID][align] = PLUGIN.factionKarma[factionID][align] + amount

			--not really necessary since it's ratios and unlikely to change significantly during gameplay, uncomment if you want it
			--PLUGIN:networkFactionKarmaPartial(self, factionID)
		end

		return true
	end

	timer.Create("nut_karmaIncome", nut.config.get("karmaIncomeTime", 3600), 0, function()
		for k, client in pairs(player.GetAll()) do
			if !(IsValid(client) and client:getChar() and client:getChar():getFaction()) then return end

			local faction = client:getChar():getFaction()
			local factionTbl = nut.faction.indices[faction] or {}
			local factionKarma = factionTbl.karma or {}

			if(factionKarma and factionKarma.passive) then
				for align, karma in pairs(factionKarma.passive) do
					client:addKarma(karma, align)
				end
			end
		end
	end)
else
	netstream.Hook("nut_karmaFactionNetwork", function(factionTbl)
		PLUGIN.factionKarma = util.JSONToTable(factionTbl)
	end)

	netstream.Hook("nut_karmaFactionPartialNetwork", function(faction, factionKarma)
		PLUGIN.factionKarma[faction] = factionKarma
	end)

	--when you look at other players
	function PLUGIN:DrawCharInfo(client, character, info)
		local recog = LocalPlayer():getChar():doesRecognize(character)

		if(recog) then
			local karma = client:getNetVar("karma", {})

			if(karma.title and karma.level and karma.col) then
				info[#info + 1] = {karma.title.. " (LVL " ..karma.level.. " Karma)", karma.col}
			end
		end
	end
end

--gets the player's karma with faction offset, use this for most non-display things
function playerMeta:getKarma()
	local char = self:getChar()

	local karma
	if(SERVER) then
		karma = char:getData("karma", {0, 0})
	else --grab the networked variable just to make sure it's accurate for clientside
		karma = self:getNetVar("karma", {}).karmaRaw or char:getData("karma", {0, 0})
	end

	return karma
end

--gets the player's level
function playerMeta:getLevel()
	local karma = self:getKarma()
	local karmaTotal = karma[1] + karma[2]

	local thresh = 0

	--figures out what level the player is and gets their title
	for level, v in ipairs(PLUGIN.titles) do
		thresh = thresh + 100 + (15 * (level - 1)) --calculates threshold for karma levels

		if(karmaTotal < thresh) then
			return (level - 1)
		end
	end

	return 0
end

--gets the player's karma with faction offset, use this for most non-display things
function playerMeta:getKarmaRatio(karma)
	local char = self:getChar()

	if !char then return end

	karma = karma or char:getData("karma", {0,0})

	local ratio = (karma[1] - karma[2]) / (karma[1] + karma[2])

	return ratio
end

--gets the player's karma with its fancy name and color info, use this for display things
function playerMeta:getKarmaFancy()
	local karma = self:getKarma()
	local karmaTotal = karma[1] + karma[2]
	local karmaRatio = self:getKarmaRatio(karma) --ratio of good/bad

	local align --alignment

	if(karmaRatio > 0.3) then --good karma ratio
		align = 1
	elseif(karmaRatio < -0.3) then --bad karma ratio
		align = 3
	else --neutral karma ratio
		align = 2
	end

	--red = bad (-1)
	--green = good (1)
	--neutral = grayish (0)
	local red = math.max(255 * (karma[2]/karmaTotal), 30)
	local green = math.max(255 * (karma[1]/karmaTotal), 30)
	local blue = math.max(122 * (1 - math.abs(karmaRatio)), 30)

	local col = Color(red, green, blue)

	local thresh = 0
	local previous = {}

	--figures out what level the player is and gets their title
	for level, v in ipairs(PLUGIN.titles) do
		thresh = thresh + 100 + (15 * (level - 1)) --calculates threshold for karma levels

		if(karmaTotal < thresh) then
			return previous[align], (level - 1), col, karma --returns a bunch of things since it's fancy
		elseif(level >= #PLUGIN.titles) then --if max level
			return v[align], level, col, karma
		end

		previous = v
	end

	return false --this shouldnt happen
end

--sets karma
nut.command.add("charsetkarma", {
	adminOnly = true,
	syntax = "<string name> <number karma> <string alignment>",
	onRun = function(client, arguments)
		if(!arguments[3]) then
			client:notify("No alignment specified ('good' or 'bad')")
			return false
		end

		local target = nut.command.findPlayer(client, arguments[1])

		local karma = tonumber(arguments[2])

		local align
		if(string.find(string.lower(arguments[3]), "good")) then
			align = 1 --good karma
		else
			align = 2 --bad karma
		end

		if(IsValid(target) and target:getChar()) then
			target:setKarma(karma, align)

			client:notify(target:Name().. "'s " ..arguments[3].. " karma set to " ..arguments[2].. ".")
		end
	end
})

--adds karma
nut.command.add("charaddkarma", {
	adminOnly = true,
	syntax = "<string name> <number karma> <string alignment>",
	onRun = function(client, arguments)
		if(!arguments[3]) then
			client:notify("No alignment specified ('good' or 'bad')")
			return false
		end

		local target = nut.command.findPlayer(client, arguments[1])

		local karma = tonumber(arguments[2])

		local align

		if(string.find(string.lower(arguments[3]), "good")) then
			align = 1 --good karma
		else
			align = 2 --bad karma
		end

		if(IsValid(target) and target:getChar()) then
			target:addKarma(karma, align)

			client:notify(target:Name().. " successfully given " ..karma.. " " ..arguments[3].. " karma.")
		end
	end
})

--gets karma
nut.command.add("chargetkarma", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if(IsValid(target) and target:getChar()) then
			local karma = target:getKarma()

			client:notify(target:Name().. " has " ..karma[1].. " good karma and " ..karma[2].. " bad karma.")
		end
	end
})

--used this for testing purposes, not really needed otherwise
--reset karma
nut.command.add("charresetkarma", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if(IsValid(target) and target:getChar()) then
			target:getChar():setData("karma", nil)
		end
	end
})

--gets karma and prints it in chat for the user
nut.command.add("karma", {
	syntax = "<string name>",
	onRun = function(client, arguments)
		local target = client

		if(IsValid(target) and target:getChar()) then
			local karma = target:getKarma()
			local karmaNet = target:getNetVar("karma", {})

			client:ChatPrint("[ KARMA STATS ]")
			client:ChatPrint("· Title - " .. karmaNet.title)
			client:ChatPrint("· Level - " .. karmaNet.level)
			client:ChatPrint("· Good Karma - " ..karma[1])
			client:ChatPrint("· Bad Karma - " ..karma[2])
		end
	end
})
