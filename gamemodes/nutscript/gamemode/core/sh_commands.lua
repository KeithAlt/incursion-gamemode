nut.command.add("roll", {
	syntax = "[number maximum]",
	onRun = function(client, arguments)
		nut.chat.send(client, "roll", math.random(0, math.min(tonumber(arguments[1]) or 100, 100)))
	end
})

/**
nut.command.add("pm", {
	syntax = "<string target> <string message>",
	onRun = function(client, arguments)
		local message = table.concat(arguments, " ", 2)
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target)) then
			local voiceMail = target:getNutData("vm")

			if (voiceMail and voiceMail:find("%S")) then
				return target:Name()..": "..voiceMail
			end

			if ((client.nutNextPM or 0) < CurTime()) then
				nut.chat.send(client, "pm", message, false, {client, target})

				client.nutNextPM = CurTime() + 0.5
				target.nutLastPM = client
			end
		end
	end
})
**/

/**
nut.command.add("reply", {
	syntax = "<string message>",
	onRun = function(client, arguments)
		local target = client.nutLastPM

		if (IsValid(target) and (client.nutNextPM or 0) < CurTime()) then
			nut.chat.send(client, "pm", table.concat(arguments, " "), false, {client, target})
			client.nutNextPM = CurTime() + 0.5
		end
	end
})
**/

/**
nut.command.add("setvoicemail", {
	syntax = "[string message]",
	onRun = function(client, arguments)
		local message = table.concat(arguments, " ")

		if (message:find("%S")) then
			client:setNutData("vm", message:sub(1, 240))

			return "@vmSet"
		else
			client:setNutData("vm")

			return "@vmRem"
		end
	end
})
**/

nut.command.add("flaggive", {
	adminOnly = true,
	syntax = "<string name> [string flags]",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and target:getChar()) then
			local flags = arguments[2]

			if (!flags) then
				local available = ""

				-- Aesthetics~~
				for k, v in SortedPairs(nut.flag.list) do
					if (!target:getChar():hasFlags(k)) then
						available = available..k
					end
				end

				return client:requestString("@flagGiveTitle", "@flagGiveDesc", function(text)
					nut.command.run(client, "flaggive", {target:Name(), text})
				end, available)
			end

			target:getChar():giveFlags(flags)

			nut.util.notifyLocalized("flagGive", nil, client:Name(), target:Name(), flags)

			if SERVER then -- Custom func added by Keith to relay via Discord logging
				DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has given " .. target:Nick() .. " ( " .. target:SteamID() .. " ) " .. flags .. " flags", "Flag Assignment Log", Color(255,165,0), "Admin")
			end
		end
	end
})

nut.command.add("flagtake", {
	adminOnly = true,
	syntax = "<string name> [string flags]",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and target:getChar()) then
			local flags = arguments[2]

			if (!flags) then
				return client:requestString("@flagTakeTitle", "@flagTakeDesc", function(text)
					nut.command.run(client, "flagtake", {target:Name(), text})
				end, target:getChar():getFlags())
			end

			target:getChar():takeFlags(flags)

			nut.util.notifyLocalized("flagTake", nil, client:Name(), flags, target:Name())
		end
	end
})

nut.command.add("toggleraise", {
	onRun = function(client, arguments)
		if ((client.nutNextToggle or 0) < CurTime()) then
			client:toggleWepRaised()
			client.nutNextToggle = CurTime() + 0.5
		end
	end
})

nut.command.add("charsetmodel", {
	adminOnly = true,
	syntax = "<string name> <string model>",
	onRun = function(client, arguments)
		if (!arguments[2]) then
			return L("invalidArg", client, 2)
		end

		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and target:getChar()) then
			target:getChar():setModel(arguments[2])
			target:SetupHands()

			nut.util.notifyLocalized("cChangeModel", nil, client:Name(), target:Name(), arguments[2])
		end
		if SERVER then -- Custom func added by Keith to relay via Discord logging
			DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has changed the model of " .. target:Nick() .. " ( " .. target:SteamID() .. " ) to "  .. arguments[2], "Model Change Log" , Color(255,255,0), "Admin")
		end
	end
})

nut.command.add("charsetskin", {
	adminOnly = true,
	syntax = "<string name> [number skin]",
	onRun = function(client, arguments)
		local skin = tonumber(arguments[2])
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and target:getChar()) then
			target:getChar():setData("skin", skin)
			target:SetSkin(skin or 0)

			nut.util.notifyLocalized("cChangeSkin", nil, client:Name(), target:Name(), skin or 0)
		end
	end
})

nut.command.add("charsetbodygroup", {
	adminOnly = true,
	syntax = "<string name> <string bodyGroup> [number value]",
	onRun = function(client, arguments)
		local value = tonumber(arguments[3])
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and target:getChar()) then
			local index = target:FindBodygroupByName(arguments[2])

			if (index > -1) then
				if (value and value < 1) then
					value = nil
				end

				local groups = target:getChar():getData("groups", {})
					groups[index] = value
				target:getChar():setData("groups", groups)
				target:SetBodygroup(index, value or 0)

				nut.util.notifyLocalized("cChangeGroups", nil, client:Name(), target:Name(), arguments[2], value or 0)
			else
				return "@invalidArg", 2
			end
		end
	end
})

nut.command.add("charsetattrib", {
	adminOnly = true,
	syntax = "<string charname> <string attribname> <number level>",
	onRun = function(client, arguments)
		local attribName = arguments[2]
		if (!attribName) then
			return L("invalidArg", client, 2)
		end

		local attribNumber = arguments[3]
		attribNumber = tonumber(attribNumber)
		if (!attribNumber or !isnumber(attribNumber)) then
			return L("invalidArg", client, 3)
		end

		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target)) then
			local char = target:getChar()
			if (char) then
				for k, v in pairs(nut.attribs.list) do
					if (nut.util.stringMatches(L(v.name, client), attribName) or nut.util.stringMatches(k, attribName)) then
						char:setAttrib(k, math.abs(attribNumber))
						client:notifyLocalized("attribSet", target:Name(), L(v.name, client), math.abs(attribNumber))

						return
					end
				end
			end
		end
	end
})

nut.command.add("charaddattrib", {
	adminOnly = true,
	syntax = "<string charname> <string attribname> <number level>",
	onRun = function(client, arguments)
		local attribName = arguments[2]
		if (!attribName) then
			return L("invalidArg", client, 2)
		end

		local attribNumber = arguments[3]
		attribNumber = tonumber(attribNumber)
		if (!attribNumber or !isnumber(attribNumber)) then
			return L("invalidArg", client, 3)
		end

		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target)) then
			local char = target:getChar()
			if (char) then
				for k, v in pairs(nut.attribs.list) do
					if (nut.util.stringMatches(L(v.name, client), attribName) or nut.util.stringMatches(k, attribName)) then
						char:updateAttrib(k, math.abs(attribNumber))
						client:notifyLocalized("attribUpdate", target:Name(), L(v.name, client), math.abs(attribNumber))

						return
					end
				end
			end
		end
	end
})

nut.command.add("charsetname", {
	adminOnly = true,
	syntax = "<string name> [string newName]",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and !arguments[2]) then
			return client:requestString("@chgName", "@chgNameDesc", function(text)
				nut.command.run(client, "charsetname", {target:Name(), text})
			end, target:Name())
		end

		table.remove(arguments, 1)

		local targetName = table.concat(arguments, " ")

		if (IsValid(target) and target:getChar()) then
			nut.util.notifyLocalized("cChangeName", client:Name(), target:Name(), targetName)
			if SERVER then -- Custom func added by Keith to relay via Discord logging
				DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has changed the name of " .. target:Nick() .. " ( " .. target:SteamID() .. " ) to "  .. targetName, "Name Change Log" , Color(255,255,0), "Admin")
			end
			target:getChar():setName(targetName:gsub("#", "#​"))
		end
	end
})

nut.command.add("chargiveitem", {
	superAdminOnly = true,
	syntax = "<string name> <string item>",
	onRun = function(client, arguments)
		if (!arguments[2]) then
			return L("invalidArg", client, 2)
		end

		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and target:getChar()) then
			local uniqueID = arguments[2]:lower()

			if (!nut.item.list[uniqueID]) then
				for k, v in SortedPairs(nut.item.list) do
					if (nut.util.stringMatches(v.name, uniqueID)) then
						uniqueID = k
						print(k)

						if SERVER then -- Custom func added by Keith to relay via Discord logging
							DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has given " .. target:Nick() .. " ( " .. target:SteamID() .. " ) " .. k .. " item via using commands", "Item Creator Logs", Color(255,0,0), "Admin")
						end
						break
					end
				end
			end

			local inv = target:getChar():getInv()
			local succ, err = target:getChar():getInv():add(uniqueID)

			if (succ) then
				target:notifyLocalized("itemCreated")
				if(target != client) then
					client:notifyLocalized("itemCreated")
				end
			else
				target:notify(tostring(succ))
				target:notify(tostring(err))
			end
		end
	end
})

nut.command.add("charkick", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target)) then
			local char = target:getChar()
			if (char) then
				for k, v in ipairs(player.GetAll()) do
					v:notifyLocalized("charKick", client:Name(), target:Name())
				end

				char:kick()
			end
		end
	end
})

nut.command.add("charban", {
	syntax = "<string name>",
	adminOnly = true,
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target)) then
			local char = target:getChar()

			if (char) then
				nut.util.notifyLocalized("charBan", client:Name(), target:Name())

				char:setData("banned", true)
				char:kick()
			end
		end
	end
})

nut.command.add("charunban", {
	syntax = "<string name>",
	adminOnly = true,
	onRun = function(client, arguments)
		if ((client.nutNextSearch or 0) >= CurTime()) then
			return L("charSearching", client)
		end

		local name = table.concat(arguments, " ")

		for k, v in pairs(nut.char.loaded) do
			if (nut.util.stringMatches(v:getName(), name)) then
				if (v:getData("banned")) then
					v:setData("banned")
				else
					return "@charNotBanned"
				end

				return nut.util.notifyLocalized("charUnBan", nil, client:Name(), v:getName())
			end
		end

		client.nutNextSearch = CurTime() + 15

		nut.db.query("SELECT _id, _name, _data FROM nut_characters WHERE _name LIKE \"%"..nut.db.escape(name).."%\" LIMIT 1", function(data)
			if (data and data[1]) then
				local charID = tonumber(data[1]._id)
				local name = data[1]._name
				local data = util.JSONToTable(data[1]._data or "[]")

				client.nutNextSearch = 0

				if (!data.banned) then
					return client:notifyLocalized("charNotBanned")
				end

				data.banned = nil

				nut.db.updateTable({_data = data}, nil, nil, "_id = "..charID)
				nut.util.notifyLocalized("charUnBan", nil, client:Name(), v:getName())
			end
		end)
	end
})

nut.command.add("givemoney", {
	syntax = "<number amount>",
	onRun = function(client, arguments)
		local number = tonumber(arguments[1])
		number = number or 0
		local amount = math.floor(number)

		if (!amount or !isnumber(amount) or amount <= 0) then
			return L("invalidArg", client, 1)
		end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer() and target:getChar()) then
			amount = math.Round(amount)

			if (!client:getChar():hasMoney(amount)) then
				return
			end

			nut.log.addRaw(client:Nick() .. " attempted to give " .. amount .. " caps to " .. target:Nick())

			if hook.Run("PlayerCashExchange", client, target) == false then return end --added by jonjo

			target:getChar():giveMoney(amount)
			client:getChar():takeMoney(amount)

			target:falloutNotify("You received " .. nut.currency.get(amount), "shelter/sfx/nukacaps_collect_l1.ogg") -- By Keith, custom notification
			client:falloutNotify("You gave " .. nut.currency.get(amount), "shelter/sfx/nukacaps_collect_l1.ogg")
	/**		target:notifyLocalized("moneyTaken", nut.currency.get(amount))
			client:notifyLocalized("moneyGiven", nut.currency.get(amount))
	**/
			nut.log.addRaw(client:Nick() .. " gave " .. amount .. " caps to " .. target:Nick())

			if SERVER then -- Custom func added by Keith to relay via Discord logging
				DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has given " .. target:Nick() .. "( " .. target:SteamID() .. " ) " .. amount .. " Caps", "Payment Transfer Log", Color(0,255,0), "Admin")
			end
		end
	end
})

nut.command.add("charsetmoney", {
	superAdminOnly = true,
	syntax = "<string target> <number amount>",
	onRun = function(client, arguments)
		local amount = tonumber(arguments[2])

		if (!amount or !isnumber(amount) or amount < 0) then
			return "@invalidArg", 2
		end

		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target)) then
			local char = target:getChar()

			if (char and amount) then
				amount = math.Round(amount)
				char:setMoney(amount)
				client:notifyLocalized("setMoney", target:Name(), nut.currency.get(amount))
			end
		end
		if SERVER then -- Custom func added by Keith to relay via Discord logging
			DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has set " .. target:Nick() .. " ( " .. target:SteamID() .. " ) Caps to " .. amount, "Money Set Logs", Color(255,0,0), "Admin")
		end
	end
})

nut.command.add("dropmoney", {
	syntax = "<number amount>",
	onRun = function(client, arguments)
		local amount = tonumber(arguments[1])

		if (!amount or !isnumber(amount) or amount < 1) then
			return "@invalidArg", 1
		end

		amount = math.Round(amount)

		if (!client:getChar():hasMoney(amount)) then
			return
		end

		client:getChar():takeMoney(amount)
		local money = nut.currency.spawn(client:getItemDropPos(), amount)
		money.client = client
		money.charID = client:getChar():getID()

		if SERVER then -- Custom func added by Keith to relay via Discord logging
			DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has dropped " .. amount .. " Caps", "Payment Drop Log", Color(0,255,0), "Admin")
		end
	end
})

nut.command.add("plywhitelist", {
	adminOnly = true,
	syntax = "<string name> <string faction>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		local name = table.concat(arguments, " ", 2)

		if (IsValid(target)) then
			local faction = nut.faction.teams[name]

			if (!faction) then
				for k, v in ipairs(nut.faction.indices) do
					if (nut.util.stringMatches(L(v.name, client), name) or nut.util.stringMatches(v.uniqueID, name)) then
						faction = v

						break
					end
				end
			end

			if (faction) then
				if (target:setWhitelisted(faction.index, true)) then
					for k, v in ipairs(player.GetAll()) do
						v:notifyLocalized("whitelist", client:Name(), target:Name(), L(faction.name, v))
					end
				end
				if SERVER then -- Custom func added by Keith to relay via Discord logging
					DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has whitelisted " .. target:Nick() .. " ( " .. target:SteamID() .. " ) to "  .. faction.name, "Faction Whitelist Log" , Color(255,255,0), "Admin")
				end
			else
				return "@invalidFaction"
			end
		end
	end
})

nut.command.add("chargetup", {
	onRun = function(client, arguments)
		local entity = client.nutRagdoll

		if (IsValid(entity) and entity.nutGrace and entity.nutGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and !entity.nutWakingUp) then
			entity.nutWakingUp = true

			client:setAction("@gettingUp", 5, function()
				if (!IsValid(entity)) then
					return
				end

				entity:Remove()
			end)
		end
	end
})

nut.command.add("plyunwhitelist", {
	adminOnly = true,
	syntax = "<string name> <string faction>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		local name = table.concat(arguments, " ", 2)

		if (IsValid(target)) then
			local faction = nut.faction.teams[name]

			if (!faction) then
				for k, v in ipairs(nut.faction.indices) do
					if (nut.util.stringMatches(L(v.name, client), name) or nut.util.stringMatches(v.uniqueID, name)) then
						faction = v

						break
					end
				end
			end

			if (faction) then
				if (target:setWhitelisted(faction.index, false)) then
					for k, v in ipairs(player.GetAll()) do
						v:notifyLocalized("unwhitelist", client:Name(), target:Name(), L(faction.name, v))
					end
				end
			else
				return "@invalidFaction"
			end
		end
	end
})

nut.command.add("beclass", {
	syntax = "<string class>",
	onRun = function(client, arguments)
		local class = table.concat(arguments, " ")
		local char = client:getChar()

		if (IsValid(client) and char) then
			local num = isnumber(tonumber(class)) and tonumber(class) or -1

			if (nut.class.list[num]) then
				local v = nut.class.list[num]

				if (char:joinClass(num)) then
					client:notifyLocalized("becomeClass", L(v.name, client))

					return
				else
					client:notifyLocalized("becomeClassFail", L(v.name, client))

					return
				end
			else
				for k, v in ipairs(nut.class.list) do
					if (nut.util.stringMatches(v.uniqueID, class) or nut.util.stringMatches(L(v.name, client), class)) then
						if (char:joinClass(k)) then
							client:notifyLocalized("becomeClass", L(v.name, client))

							return
						else
							client:notifyLocalized("becomeClassFail", L(v.name, client))

							return
						end
					end
				end
			end

			client:notifyLocalized("invalid", L("class", client))
		else
			client:notifyLocalized("illegalAccess")
		end
	end
})

/**
nut.command.add("chardesc", {
	syntax = "<string desc>",
	onRun = function(client, arguments)
		if client.charDescCooldown and client.charDescCooldown > CurTime() then return end -- Custom check added by Keith to prevent Discord Embed abuse
		client.charDescCooldown = CurTime() + 3

		arguments = table.concat(arguments, " ")

		if (!arguments:find("%S")) then
			return client:requestString("@chgDesc", "@chgDescDesc", function(text)
				nut.command.run(client, "chardesc", {text})
			end, client:getChar():getDesc())
		end

		local info = nut.char.vars.desc
		local result, fault, count = info.onValidate(arguments)

		if (result == false) then
			return "@"..fault, count
		end

		if SERVER then -- Custom func added by Keith to relay via Discord logging
			DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has changed their description from - " .. client:getChar():getDesc() .. " - to - " .. arguments, "Character Description Change Log" , Color(255,255,0), "Admin")
		end

		client:getChar():setDesc(arguments)

		return "@descChanged"
	end
})
**/

/**nut.command.add("plytransfer", {
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
				if SERVER then -- Custom func added by Keith to relay via Discord logging
					DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has changed the faction of " .. target:Nick() .. " ( " .. target:SteamID() .. " ) to "  .. faction.name, "Faction Change Log" , Color(255,255,0), "Admin")
				end
			else
				return "@invalidFaction"
			end
		end
	end
})**/ -- RUNS THROUGH /schema

// Credit goes to SmithyStanley
nut.command.add("clearinv", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function (client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and target:getChar()) then
			for k, v in pairs(target:getChar():getInv():getItems()) do
				v:remove()
			end

			client:notifyLocalized("resetInv", target:getChar():getName())

			if SERVER then -- Custom func added by Keith to relay via Discord logging
				jlib.AlertStaff(client:Nick() .. " ( " .. client:SteamID() .. " ) " ..  "has cleared the inventory of " .. target:Nick() .. " ( " .. target:SteamID() .. " )")
				DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has cleared the inventory of " .. target:Nick() .. " ( " .. target:SteamID() .. " )", "Inventory Clear Log", Color(255,165,0), "Admin")
			end
		end
	end
})
