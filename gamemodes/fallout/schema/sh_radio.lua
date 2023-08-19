local radios = { -- Legacy cross faction radio system that has multifaction support unlike new system
	{group = "MD", factions = {"crimsoncaravan", "cdc"}, color = Color(255, 155, 0)},
	{group = "NS", factions = {"crimsoncaravan", "ncr", "necrosis"}, color = Color(255, 251, 0, 199)},
}

nut.config.add("AdvertEnabled", true, "Toggle the use of advert")

local function endChatter(listener)
	timer.Simple(1, function()
		if (!listener:IsValid() or !listener:Alive()) then
			return false
		end;

		listener:EmitSound("npc/metropolice/vo/off"..math.random(1, 3)..".wav", math.random(60, 70), math.random(80, 120))
	end)
end;

for _, v in pairs(radios) do
	nut.chat.register(v.group:lower(), {
		format = "["..v.group.."] %s says: \"%s\"",
		onGetColor = function(speaker, text)
			return v.color
		end,
		onCanHear = function(speaker, listener)
			local dist = speaker:GetPos():Distance(listener:GetPos())
			local speakRange = nut.config.get("chatRange", 280)
			local faction = nut.faction.indices[listener:getChar():getFaction()]

			if !faction then return end

			if (dist <= speakRange) then
				return true
			end;

			if (table.HasValue(v.factions, faction["uniqueID"])) then
				endChatter(listener)
				return true
			end;

			return false
		end,
		onCanSay = function(speaker, text)
			local faction = nut.faction.indices[speaker:getChar():getFaction()]

			if !speaker:GetNW2Bool("GlobalRadioAccess") then
				jlib.Announce(speaker,
					Color(255,0,0), "[RADIO] ",
					Color(255,255,255), "You need to own and have a radio item turned on to use radio comms"
				)
				return false
			elseif (table.HasValue(v.factions, faction["uniqueID"])) then
				speaker:EmitSound("npc/metropolice/vo/on"..math.random(1, 2)..".wav", math.random(50, 60), math.random(80, 120))
				return true
			else
				speaker:ChatPrint("You don't belong to this faction.")
				return false
			end;
		end,
		prefix = {"/"..v.group:lower()},
	})
end;

nut.chat.register("broadcast", {
	format = "[BROADCAST] %s says: \"%s\"",
	onGetColor = function(speaker, text)
		return Color(255, 100, 100)
	end,
	onCanHear = function(speaker, listener)
		return true
	end,
	onCanSay = function(speaker, text)
		if #text > 512 then
			speaker:ChatPrint("Your broadcast is too long, it can only be 512 characters.")
			return false
		end

		local pos = speaker:GetPos()
		local range = nut.config.get("chatRange", 280) / 2

		local ents = ents.FindInSphere(pos, range)

		for _, v in pairs(ents) do
			print(v:GetClass())
			if (v:GetClass() == "nut_broadcaster") then
				return true
			end;
		end;

		speaker:ChatPrint("You must be nearby a broadcaster.")
		return false
	end,
	prefix = {"/broadcast"},
})

nut.chat.register("advert", {
	onCanHear = function(speaker, listener)
		return listener:GetNW2Bool("GlobalRadioAccess")
	end,
	onCanSay = function(speaker, text)
		if !nut.config.get("AdvertEnabled") then
			jlib.Announce(speaker,
				Color(255,0,0), "[ADVERT] ",
				Color(255,255,255), "Advert is disabled, utilize the broadcasting stations around the map instead."
			)
			return false
		end;

		if (string.len(text) > 512) then
			speaker:ChatPrint("Your advert is too long, it can only be 512 characters.")
			return false
		elseif !speaker:GetNW2Bool("GlobalRadioAccess") then
			jlib.Announce(speaker,
				Color(255,0,0), "[RADIO] ",
				Color(255,255,255), "You need to own and have a radio item turned on to use radio comms"
			)
			return false
		else
			speaker:EmitSound("npc/metropolice/vo/off" .. math.random(1, 3) .. ".wav", math.random(60, 70), math.random(80, 120))
			return true
		end;
	end,
	onChatAdd = function(speaker, text)
		local recognized = LocalPlayer():getChar():doesRecognize(speaker:getChar()) or LocalPlayer() == speaker
		chat.AddText(Color(255, 193, 71), (recognized and ("[GLOBAL] " .. speaker:Nick() .. " says: ") or "[GLOBAL]: ") .. text)
	end,
	prefix = {"/advert"},
})




nut.chat.register("ooc", {
	onCanSay =  function(speaker, text)
		if !nut.config.get("allowGlobalOOC") then
			speaker:notifyLocalized("OOC Chat is disabled")
			jlib.Announce(speaker, Color(255,0,0), "[NOTICE] ", Color(255,200,200), "OOC Chat is disable - Do not contact staff asking it to be re-enabled.", Color(255,255,255),  "\n- You can request assistance via the '!help' command")
			return false
		else
			local delay = nut.config.get("oocDelay", 30)

			-- Only need to check the time if they have spoken in OOC chat before.
			if (delay > 0 and speaker.nutLastOOC) then
				local lastOOC = CurTime() - speaker.nutLastOOC

				-- Use this method of checking time in case the oocDelay config changes.
				if (lastOOC <= delay) then
					speaker:notifyLocalized("oocDelay", delay - math.ceil(lastOOC))

					return false
				end
			end

			if (string.len(text) > 512) then
				speaker:ChatPrint("Your advert is too long, it can only be 512 characters.")
				return false
			end;

			-- Save the last time they spoke in OOC.
			speaker.nutLastOOC = CurTime()
		end
	end,
	onChatAdd = function(speaker, text)
		local icon = "icon16/user.png"

		-- man, I did all that works and I deserve differnet icon on ooc chat
		-- if you dont like it
		-- well..
		-- it's on your own.
		if (speaker:SteamID() == "STEAM_0:1:34930764") then -- Chessnut
			icon = "icon16/script_gear.png"
		elseif (speaker:SteamID() == "STEAM_0:0:19814083") then -- Black Tea the edgiest man
			icon = "icon16/gun.png"
		elseif (speaker:IsSuperAdmin()) then
			icon = "icon16/shield.png"
		elseif (speaker:IsAdmin()) then
			icon = "icon16/star.png"
		elseif (speaker:IsUserGroup("moderator") or speaker:IsUserGroup("operator")) then
			icon = "icon16/wrench.png"
		elseif (speaker:IsUserGroup("vip") or speaker:IsUserGroup("donator") or speaker:IsUserGroup("donor")) then
			icon = "icon16/heart.png"
		end

		icon = Material(hook.Run("GetPlayerIcon", speaker) or icon)

		chat.AddText(icon, Color(255, 50, 50), " [OOC] ", speaker, color_white, ": "..text)
	end,
	prefix = {"//", "/ooc"},
	noSpaceAfter = true,
	filter = "ooc"
})

-- Local out of character.
nut.chat.register("looc", {
	onCanSay =  function(speaker, text)
		local delay = nut.config.get("loocDelay", 0)

		-- Only need to check the time if they have spoken in OOC chat before.
		if (delay > 0 and speaker.nutLastLOOC) then
			local lastLOOC = CurTime() - speaker.nutLastLOOC

			-- Use this method of checking time in case the oocDelay config changes.
			if (lastLOOC <= delay) then
				speaker:notifyLocalized("loocDelay", delay - math.ceil(lastLOOC))

				return false
			end
		end

		if (string.len(text) > 512) then
			speaker:ChatPrint("Your advert is too long, it can only be 512 characters.")
			return false
		end;

		-- Save the last time they spoke in OOC.
		speaker.nutLastLOOC = CurTime()
	end,
	onChatAdd = function(speaker, text)
		chat.AddText(Color(255, 50, 50), "[LOOC] ", nut.config.get("chatColor"), speaker:Name()..": "..text)
	end,
	onCanHear = nut.config.get("chatRange", 280),
	prefix = {".//", "[[", "/looc"},
	noSpaceAfter = true,
	filter = "ooc"
})
