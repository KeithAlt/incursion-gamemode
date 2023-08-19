SCHEMA.name 	 = "Fallout"
SCHEMA.introName = "Fallout"
SCHEMA.author 	 = "Claymore Gaming"
SCHEMA.desc 	 = "Fallout"

nut.currency.set("", "Ⓒ", "Ⓒ")

nut.fallout = nut.fallout or {}

nut.fallout.templates = nut.fallout.templates or {}
nut.fallout.registry = nut.fallout.registry or {}

--[[local preventLoad = { -- Plugins we don't want to load.
	"pac", 			-- Interferes with our own PAC restriction.
	"storage", 	-- This plugin continues to be a massive pain.
	"strength", -- We manage stats like this ourselves.
	"stamina", 	-- Ditto to the above.
}

for i, v in pairs(preventLoad) do
	hook.Add("PluginShouldLoad", v, function() return false end)
end]]

nut.util.includeDir("libs", nil, true)
nut.util.includeDir("hooks")
nut.util.includeDir("ui_fallout", nil, true)
nut.util.includeDir("registers")

nut.util.include("sh_radio.lua")
--nut.util.include("sh_pacrestrict.lua")

--[[function SCHEMA:InitializedPlugins()
	if (SERVER) then
		nut.loot.registerTable("master")
		--nut.loot.addItem("common", "master", "watermelon")
		--nut.loot.addItem("common", "master", "tato")
	end
end]]

-- LEGACY CODE --
nut.fallout.color = nut.fallout.color or {}

nut.fallout.color.main 		= Color(255, 199, 44)
nut.fallout.color.secondary	= Color(98, 76, 16)
nut.fallout.color.background 	= Color(98, 76, 16, 102)
nut.fallout.color.hover		= Color(0, 0, 0)

if (SERVER) then
	do
		local playerMeta = FindMetaTable("Player")

		function playerMeta:falloutNotify(message, sound)
			netstream.Start(self, "falloutNotify", message, sound)
		end
	end

	function SCHEMA:GetGameDescription()
		return "falloutrp"
	end
else
	nut.fallout.notices = nut.fallout.notices or {}

	function nut.fallout.notify(message, sound)
		vgui.Create("nutFalloutNotice"):open(message, sound)
	end

	netstream.Hook("falloutNotify", nut.fallout.notify)
end;
-- LEGACY CODE END --

-- COMMANDS --
nut.command.add("beclass", {
	syntax = "<invalid>",
	onRun = function(client, arguments)
		return false
	end
})

nut.command.add("meta", {
	syntax = "<invalid>",
	onRun = function(client, arguments)
		if !client.metaAntiSpam or client.metaAntiSpam < CurTime() and SERVER then
			local char = client:getChar()
			local char_class = char:getData("class") or nut.class.list[char:getClass()].name or nil

			if !isnumber(char_class) then
				for k, v in pairs(nut.class.list) do
					if nut.class.list[k].uniqueID == char:getData("class") then
						char_class = nut.class.list[k].name
						break
					end
				end
			elseif !char_class then
				client:ChatPrint("[ WARNING ]  You do not have a class assigned to your character!\n- If you are experiencing gameplay issues, this is probably why\n- Contact a staff member to request your previous class to be reassigned")
				return
			end

			local karmaNet = client:getNetVar("karma", {})

			--- Multiple ChatPrint calls due too much data within one call will fail to send
			client:ChatPrint(
				"________________________________"	..
				"\n➣ Your SteamID: " .. client:SteamID() ..
				"\n➣ Your ping: " .. client:Ping() .. " ms"
			)

			client:ChatPrint(
				"➣ Your faction: " .. team.GetName(client:Team()) ..
				"\n➣ Your class: " .. char_class ..
				"\n➣ Your level: " .. (char:getData("level") or "0") ..
				"\n➣ Your health: " .. client:Health()
			)

			client:ChatPrint(
			"➣ Your description: " .. "\n[ "	.. char:getDesc() .. " ]" ..
				"\n➣ Your karma title: " .. (karmaNet.title or "None") ..
				"\n➣ Your karma level: " .. (karmaNet.level or "None")
			)

			client:ChatPrint(
				"➣ Your max health: " .. client:GetMaxHealth() ..
				"\n➣ Your max run speed: " .. math.Round(Armor.GetRunSpeed(client) * client:GetSpeedBuff()) ..
				"\n➣ Your fear resistance: " .. (client.fearResist or nut.config.get("fearRPdefaultFearResist")) ..
				"\n➣ Your fear power: " .. (client.fearPower or nut.config.get("fearRPdefaultFearPower")) ..
				"\n\n WARNING: Much of the above stats are dictated\n by attributes such as hunger/thirst/SPECIAL\n________________________________"
			)

			client.metaAntiSpam = CurTime() + 8
		end
	end
})

nut.command.add("setclass", {
	adminOnly = true,
	syntax = "<string target> <string class>",
	onRun = function(client, arguments)
		local class = table.concat(arguments, " ", 2)
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target)) then
			local char = target:getChar()

			local num = isnumber(tonumber(class)) and tonumber(class) or -1

			if (nut.class.list[num]) then
				local v = nut.class.list[num]

				char:setClass(num)
				client:ChatPrint(target:GetName().." class has been set to "..v.name..".")

				jlib.Announce(client, Color(255,255,0), "[META] ", Color(255,255,155), "Your class has been set to ", Color(255,255,0), v.name)

				char:setData("class", v.uniqueID)

				if v.Officer then -- NOTE/FIXME: Prevents a lot of shit from breaking but should be improved
					client:notify("Please reload your character")
					char:kick()
				end

				return
			else
				for k, v in ipairs(nut.class.list) do
					if v.uniqueID == class then
						char:setClass(k)

						jlib.Announce(client, Color(255,255,0), "[META] ", Color(255,255,155), "Your class has been set to ", Color(255,255,0), v.name)

						char:setData("class", v.uniqueID)

						if v.Officer then -- NOTE/FIXME: Prevents a lot of shit from breaking but should be improved
							client:notify("Please reload your character")
							char:kick()
						end

						return
					end
				end

				for k, v in ipairs(nut.class.list) do
					if (nut.util.stringMatches(v.uniqueID, class) or nut.util.stringMatches(L(v.name, client), class)) then
						char:setClass(k)
						jlib.Announce(client, Color(255,255,0), "[META] ", Color(255,255,155), "Your class has been set to ", Color(255,255,0), v.name)
						char:setData("class", v.uniqueID)

						if v.Officer then -- NOTE/FIXME: Prevents a lot of shit from breaking but should be improved
							client:notify("Please reload your character")
							char:kick()
						end

						return
					end
				end

				client:ChatPrint("Unable to find class!")
			end
		else
			client:ChatPrint("Invalid Target")
		end
	end;
})

nut.command.add("clearworlditems", {
	syntax = "",
	superAdminOnly = true,
	onRun = function(client, arguments)
		local count = 0
		for i, v in pairs(ents.FindByClass("nut_item")) do
			v:Remove()
			count = count + 1
		end
		for i, v in pairs(ents.FindByClass("farm_seed")) do
			v:Remove()
			count = count + 1
		end
		client:ChatPrint("Cleared "..count.." world iddtems!")
	end
})

nut.command.add("checkmoney", {
	syntax = "",
	adminOnly = true,
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		if (target) then
			client:ChatPrint(target:GetName().." has: "..target:getChar():getMoney().." Cap(s)")
		else
			client:ChatPrint("Invalid Target")
		end
	end
})

hook.Add("GetMaxPlayerCharacter", "FALLOUT_ATeamCharLimit", function(ply)
	if ply:GetUserGroup() == "founder" then
		return 8
	end

	return nut.config.get("maxChars", 5)
end)
/**nut.command.add("charsetmoney", {
	superAdminOnly = true,
	syntax = "<string target> <number amount>",
	onRun = function(client, arguments)
		local amount = tonumber(arguments[2])

		if (!amount or !isnumber(amount) or amount < 0) then
			return "@invalidArg", 2
		end;

		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target)) then
			local char = target:getChar()

			if (char and amount) then
				amount = math.Round(amount)
				char:setMoney(amount)
				client:notifyLocalized("setMoney", target:Name(), nut.currency.get(amount))
			end
		end
	end
})**/

/**function SCHEMA:PlayerLoadedChar(client, character) -- Created by Vex as solution for a logic error in NS Core hooks
	if (character:getData("class", false)) then
		local dat = character:getData("class", false)

		if (!isnumber(dat)) then
			for i, v in ipairs(nut.class.list) do
				if (v.uniqueID == dat) then
					character:setClass(i)
					break
				end
			end
		else
			character:setData("class", nil)
			print("[CLASS-LOG] Setting" .. client:Nick() .. "'s class to nil'")
		end
	end
end**/

nut.command.add("plytransfer", {
	adminOnly = true,
	syntax = "<string name> <string faction>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		local name = table.concat(arguments, " ", 2)

		if (IsValid(target) and target:getChar()) then
			local faction = nut.faction.teams[name]

			if (!faction) then
				for k, v in pairs(nut.faction.indices) do
					if (nut.util.stringMatches(L(v.name, client), name)) then
						faction = v

						break
					end
				end
			end

			if (faction) then
				target:getChar().vars.faction = faction.uniqueID
				target:getChar():setFaction(faction.index)

				if (faction.onTransfered) then
					faction:onTransfered(target)
				end

				for k, v in ipairs(player.GetAll()) do
					nut.util.notifyLocalized("cChangeFaction", v, client:Name(), target:Name(), L(faction.name, v))
				end

				target:getChar():setData("class", nil)
				if SERVER then -- Custom func added by Keith to relay via Discord logging
					DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has changed the faction of " .. target:Nick() .. " ( " .. target:SteamID() .. " ) to "  .. faction.name, "Faction Change Log" , Color(255,255,0), "Admin")
				end
			else
				return "@invalidFaction"
			end
		end
	end
})

hook.Add("PlayerNoClip", "nsClippyClip", function(ply, state)
    if (ply:IsAdmin()) then
        if (state) then
            ply:SetNoDraw(true)
        else
			if pk_pills and IsValid(pk_pills.getMappedEnt(ply)) then -- Confirm our player is not in a pill
            	ply:SetNoDraw(true)
			else
				ply:SetNoDraw(false)
			end
        end

        return true
    else
        return false
    end
end)

hook.Add("InitializedPlugins", "CommandReplacer", function()
	print("Replacing doorsetfaction command")

	nut.command.list.doorsetfaction.onRun = function(client, arguments)
		if client:IsAdmin() == false or client:IsSuperAdmin() == false then return end -- Added by Keith // Prevent all users from using cmd

		local PLUGIN = nut.plugin.list.doors

		-- Get the door the player is looking at.
		local entity = client:GetEyeTrace().Entity

		-- Validate it is a door.
		if (IsValid(entity) and entity:isDoor() and !entity:getNetVar("disabled")) then
			local faction
			local factions = {}

			-- Check if the player supplied a faction name.
			if (arguments[1]) then
				-- Get all of the arguments as one string.
				local name = table.concat(arguments, " ")

				-- Loop through each faction, checking the uniqueID and name.
				for k, v in pairs(nut.faction.teams) do
					if k == name then
						faction = v
						break
					elseif nut.util.stringMatches(k, name) or nut.util.stringMatches(L(v.name, client), name) then
						faction = v
						table.insert(factions, v)
					end
				end
			end

			--Halt the command if there was more than 1 faction found and inform the user.
			if #factions > 1 then
				local factionStr = "More than one faction found: ("

				for k, v in pairs(factions) do
					factionStr = factionStr .. v.name .. ": " .. v.uniqueID .. ", "
				end

				factionStr = factionStr:TrimRight(" ")
				factionStr = factionStr:TrimRight(",")

				factionStr = factionStr .. "). Use one of the unique IDs that are displayed to the right of the colon to be more specific."

				if #factionStr > 255 then
					client:ChatPrint("More than one faction found, please be more specific.")

					return
				end

				client:ChatPrint(factionStr)

				return
			end

			-- Check if a faction was found.
			if (faction) then
				entity.nutFactionID = faction.uniqueID
				entity:setNetVar("faction", faction.index)

				PLUGIN:callOnDoorChildren(entity, function()
					entity.nutFactionID = faction.uniqueID
					entity:setNetVar("faction", faction.index)
				end)

				client:notifyLocalized("dSetFaction", L(faction.name, client))
			-- The faction was not found.
			elseif (arguments[1]) then
				client:notifyLocalized("invalidFaction")
			-- The player didn't provide a faction.
			else
				entity:setNetVar("faction", nil)

				PLUGIN:callOnDoorChildren(entity, function()
					entity:setNetVar("faction", nil)
				end)

				client:notifyLocalized("dRemoveFaction")
			end

			-- Save the door information.
			PLUGIN:SaveDoorData()
		else
			client:ChatPrint("No valid door found.")
		end
	end
end)

-- COMMANDS END --
