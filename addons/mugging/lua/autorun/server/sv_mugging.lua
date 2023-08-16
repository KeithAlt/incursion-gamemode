util.AddNetworkString("nutMugAction")
util.AddNetworkString("MUGGING_DisplayTimer")

local function getMugAmount(level)
	if level <= 10 then
		return nut.config.get("Level 1-10")
	end

	if (11 <= level) and (level <= 25) then
		return nut.config.get("Level 11-25")
	end

	if (26 <= level) and (level <= 40) then
		return nut.config.get("Level 26-40")
	end

	if (41 <= level) and (level <= 49) then
		return nut.config.get("Level 41-49")
	end

	if level >= 50 then
		return nut.config.get("Level 50+")
	end

	return false
end

-- Actions to perform when being mugged
net.Receive("nutMugAction", function(len, ply)
	local target = 	net.ReadEntity()

	if !(IsValid(target) or target:IsPlayer() or target:Alive()) then
		ply:notify("Invalid player target")
		return
	end

	if not target:getNetVar("restricted") then return end

	if target.HasWarning then -- If player is AFK; prevent mugging
		ply:notify("Player is AFK / cannot be mugged")
		return
	end

	local level = target:getChar():getData("level", 0)
	
	local charisma = math.Clamp(target:getSpecial("C"), 0, 25)
	local mugAmt = getMugAmount(level)
	local offset = 0
	if charisma > 0 then
		local percentageCharisma = (charisma * 2) / 100
		offset =  (percentageCharisma * mugAmt)
	end
	mugAmt = mugAmt - offset


	if !mugAmt then
		ErrorNoHalt("Failed to retrieve mug amount")
		return
	end

	if target.onVictimMugCooldown then -- if a potential victim has been mugged recently
		ply:notify("The victim is on a mug cooldown")
		jlib.Announce(ply, Color(255,0,0), "[MUGGING] ", Color(255,155,155), "The victim is on a mug cooldown:", Color(255,255,255), "\n· You can only take items from the victim due to this\n· Disclaimer: No, you cannot wait for the cooldown to expire")
		return
	end

	if ply.onMugCooldown then -- if a mugger has done so to recently
		ply:notify("You are on a mugging cooldown for " .. (math.Round(ply.onMugCooldown - CurTime(),0)) .. "s")
		jlib.Announce(ply, Color(255,0,0), "[MUGGING] ", Color(255,155,155), "You are on a mugging cooldown:", Color(255,255,255), "\n· You can only take items from the victim due to this\n· Disclaimer: No, you cannot wait for the cooldown to expire\n· However, a partner is able to mug for you (if you have one)")
		return
	end

	if charisma > 0 then
		ply:falloutNotify("The target is very charismatic! ( -" .. offset .. "© )")
	end

	jlib.RequestBool("Steal " .. mugAmt .. "©?", function(bool)

		if !bool then return end

		if !(IsValid(target) or target:getChar() or target:Alive()) then
			ply:notify("The victim is no longer present")
			return
		end

		local targetChar = target:getChar()
		local targetMoney = targetChar:getMoney()

		if targetMoney < mugAmt then
			ply:notify("The victim cannot afford to be mugged")
			return
		end

		-- Cooldown
		target.onVictimMugCooldown = CurTime() + nut.config.get("mugVictimCooldown")
		ply.onMugCooldown = CurTime() + nut.config.get("mugCooldown")

		if ply.mugHistory then
			ply.mugHistory = ply.mugHistory + 1
		else
			ply.mugHistory = 0
		end

		timer.Create(target:SteamID() .. "_muggingVictimCooldown", nut.config.get("mugVictimCooldown"), 0, function()
			if IsValid(target) and target.onVictimMugCooldown then
				target.onVictimMugCooldown = nil
			end
		end)

		timer.Create(ply:SteamID() .. "_muggingCooldown", nut.config.get("mugCooldown"), 0, function()
			if IsValid(ply) and ply.onMugCooldown then
				ply.onMugCooldown = nil
			end
		end)


		-- Give bad karma
		ply:addKarma(5, 2)
		ply:falloutNotify("⚖ You've lost karma for mugging", "ui/badkarma.ogg")

		-- Take caps
		if target.wasMugged then return end

		target.wasMugged = true
		targetChar:setMoney(targetChar:getMoney() - mugAmt)
		target:falloutNotify("You were robbed for " .. mugAmt .. "©", "ui/badkarma.ogg")
		ply:getChar():setMoney(ply:getChar():getMoney() + mugAmt)
		ply:falloutNotify("You stole " .. mugAmt .. "©")
		ply:ConCommand("say /me reaches into wallet and takes caps forcefully...")
		target:EmitSound("ui/ui_items_takeall.mp3")

		timer.Simple(0.5, function() -- Prevent a duplication exploit via cooldown
			if IsValid(target) and target.wasMugged then
				target.wasMugged = false
			end
		end)

		// pk marked
		local char = ply:getChar()
		local pkTime = nut.config.get("PK Active Time")
		char:setVar("pkReady", true)
		ply:falloutNotify("You have been marked PK Active . . .")
		
		// set to id to compare characters rather than 5 hooks
		ply.recentmug = char:getID()

		// start timer on client
		net.Start("MUGGING_DISPLAYTIMER")
			net.WriteUInt(pkTime, 16)
		net.Send(ply)

		timer.Create(char:getID() .. "-PKTimer", pkTime, 1, function()
			if IsValid(ply) then
				if char != nil then
					char:setVar("pkReady", nil)
				end

				ply:falloutNotify("[!] You are no longer PK Active . . .")
				ply.recentmug = nil
			end
		end)

		-- Logging
		jlib.Announce(ply, Color(255,0,0), "[MUGGING] ", Color(255,155,155), "You've mugged a player!", Color(255,255,255), "\n· You cannot mug again for " .. (math.Round(ply.onMugCooldown - CurTime(),0)) .. "s\n· This mugging has been logged by staff")
		jlib.Announce(target, Color(255,0,0), "[MUGGING] ", Color(255,155,155), "You've been mugged!", Color(255,255,255), "\n· The details of this have been logged by staff" .. "\n· You can hunt down your mugger to bring instant wasteland justice within the next " .. nut.config.get("PK Active Time") .. " seconds, after that you must capture him.\n· Remember your weapons are stripped!")
		jlib.AlertStaff("A player has been mugged on the server\n · Total muggings by this robber ( " .. ply:SteamID() .. " ): " ..  ply.mugHistory .. "\n · Repeated alerts may imply abusive behavior\n · Details of the mugging are available via Discord")
		DiscordEmbed(jlib.SteamIDName(ply) .. " has mugged " .. jlib.SteamIDName(target) .. " for " .. mugAmt .. "©", "👛 Mugging Log 👛" , Color(255,0,0), "Admin")
	end, ply, "YES (MUG)", "NO (CANCEL)")
end)

// f1 menu'd
hook.Add("OnCharKicked", "PKMug_DisablePK", function(ply, char)
	if ply.recentmug then
		timer.Remove(char:getID() .. "-PKTimer")
		ply.recentmug = nil
		char:setVar("pkReady", nil)
		jlib.AlertStaff("A player has F1'd while being PK Active\n · Character Name: " .. char:getName() .. "\n · SteamID: " .. ply:SteamID())

		print("removed pk timer - swap - staff notification")
	end
end)

hook.Add("PlayerDisconnected", "PKMug_DisablePKLeave", function(ply)
	local char = ply:getChar()
	if !char then return end

	if ply.recentmug then
		char:setVar("pkReady", nil)
		timer.Remove(char:getID() .. "-PKTimer")
		jlib.AlertStaff("A player has disconnected while being PK Active\n · Character Name: " .. char:getName() .. "\n · SteamID: " .. ply:SteamID())
	end
end)

hook.Add("PostPlayerDeath", "PK-MugDeath", function(ply)
	if ply.recentmug and ply.recentmug == ply:getChar():getID() then
		timer.Remove(ply.recentmug .. "-PKTimer")
		ply.recentmug = nil
		ply:Kill()
		ply:getChar():setData("pos",nil)
	end
end)