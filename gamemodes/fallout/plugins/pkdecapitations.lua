local PLUGIN = PLUGIN
PLUGIN.name = "PK Decapitations"
PLUGIN.author = "Chancer"
PLUGIN.desc = " "

--most of the net library things in here were taken out of bountyhunting addon

if(SERVER) then
	util.AddNetworkString("PKForceNameChange")
	util.AddNetworkString("PKSubmitNameChange")

	function PLUGIN:PostPlayerDeath(victim)
		local char = victim:getChar()
		if(!char) then return end
		if(!char:getVar("pkReady")) then return end --if the char is marked for pk
		char:setVar("pkReady", nil)
		if char:getData("isSynth") then
			char:setData("isSynth", nil)
		end

		if IsValid(victim) then
			--victim:Decapitate()

			if !hcWhitelist.isRobot(victim) then
				local position = victim:GetPos() + victim:GetUp() * 50 --spawn position of head
				nut.item.spawn("playerhead", position, function(item)
					item:setData("headowner", victim:Name())
				end)
			end

			--name change force also recustomizes character when a name is submitted
			net.Start("PKForceNameChange")
			net.Send(victim)
		end
	end

	function PLUGIN:PKEnable(client, target)
		if(!client:IsAdmin()) then return end

		local char = target:getChar()

		char:setVar("pkReady", true)

		nut.chat.send(target, "pknotify", "")

		client:falloutNotify(target:Name().. " has been set for Perma Kill.")
		target:falloutNotify("You have been set for Perma Kill.")
	end

	--PK forced name change, moved from bountyhunter addon to here
	net.Receive("PKSubmitNameChange", function(len, ply)
		local newName = net.ReadString()
		local oldName = ply:Nick()
		local char = ply:getChar()
		local level = char:getData("level")

		if level and (level >= 5) then

			if (level < 50) then
				local newLevel = char:getData("level") - 5

				char:setData("level", newLevel)
				char:setData("XP", nut.leveling.requiredXP(newLevel))
				char:setData("skillPoints", (level + (Armor and Armor.Config.SkillPoints)) - 5)

			jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,255,255),
				Color(255,155,155), "Permanent Kill Information:", Color(255,255,255),
				"\n- ", Color(255,240,70), "500 © ", Color(255,255,255),  "has been lost",
				"\n- ",Color(255,240,70), nut.leveling.requiredXP(newLevel) .. " EXP ", Color(255,255,255), "has been lost",
				"\n- You may respec your S.P.E.C.I.A.L",
				"\n· You cannot be PK'd again until you perform an action that justifies it on this new character",
				"\n· All previous IC memories or grudges you had previously are now forgotten/void"
			)

				if char:hasMoney(500) then
					char:giveMoney(-500)
		 		end
			else -- if ply is over LVL50, only deduct 2 LVLs
				local newLevel = char:getData("level") - 2

				char:setData("level", newLevel)
				char:setData("XP", nut.leveling.requiredXP(newLevel))
				char:setData("skillPoints", (level + (Armor and Armor.Config.SkillPoints)) - 2)

				jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,255,255),
					Color(255,155,155), "Permanent Kill Information:", Color(255,255,255),
					"\n- ", Color(255,240,70), "1000 © ", Color(255,255,255),  "has been lost",
					"\n- ",Color(255,240,70), nut.leveling.requiredXP(newLevel) .. " EXP ", Color(255,255,255), "has been lost",
					"\n- You have been issued a S.P.E.C.I.A.L respec",
					"\n· All previous IC memories or grudges you had are now forgotten/void",
					"\n· You cannot be PK'd again until you perform an action that justifies it on this new character"
				)

				if char:hasMoney(1000) then
					char:giveMoney(-1000)
		 		end
			end

			CharBrand.RemoveBrand(ply) -- Removes the players desc. brand if any exist
			char:setData("skerks", {}) -- Reset players skills
			char:setData("special", {})	-- Reset players SPECIAL
		end

		if char then
			char:setName(newName)
			ServerLog(oldName .. " has been PKed and chose '" .. newName .. "' as their new name.\n")
		else
			ply:notify("Failed to find valid character.")
		end

		local isHuman = Armor.IsHuman(char)

		if isHuman then
			Armor.ReCreate(ply) --recustomize character here
		end
	end)

	netstream.Hook("nut_pkConfirmed", function(client, target)
		PLUGIN:PKEnable(client, target)
		nut.log.addRaw(client:Nick() .. " ( " .. client:SteamID() .. " ) has confirmed a PK state on " .. target:Nick() .. "( " .. target:SteamID() .. " )", "Staff PK Log")
		DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) has confirmed a PK state on " .. target:Nick() .. "( " .. target:SteamID() .. " )", "Staff PK Log" , Color(255,255,0), "Admin")
	end)
else
	--PK forced name change, moved from bountyhunter addon to here
	net.Receive("PKForceNameChange", function()
		local frame = vgui.Create("DFrame")
		frame:SetTitle("PK Name Change")
		frame:SetSize(600, 600)
		frame:Center()
		frame:ShowCloseButton(false)
		frame:MakePopup()

		local firstName = frame:Add("DTextEntry")
		firstName:SetWide(300)
		firstName:SetPlaceholderText("Name")
		firstName:Center()

		local lastName = frame:Add("DTextEntry")
		lastName:SetWide(300)
		lastName:SetPlaceholderText("Last Name")
		lastName:CenterHorizontal()
		lastName:MoveBelow(firstName, 5)

		local submitBtn = frame:Add("DButton")
		submitBtn:SetText("Submit")
		submitBtn:Dock(BOTTOM)
		submitBtn.DoClick = function(s)
			--Same name validation steps as from the character creator
			local f, l = firstName:GetText(), lastName:GetText()

			if !f or !l then
				Derma_Message("Your character's first or last name cannot be blank.", nil, "OK")
				return
			end

			if f:find("%s") or l:find("%s") then
				Derma_Message("Your character name cannot contain any spaces.", nil, "OK")
				return
			elseif f:find("%d") or l:find("%d") then
				Derma_Message("Your character name cannot contain any numbers.", nil, "OK")
				return
			elseif f:find("%p") or l:find("%p") then
				Derma_Message("Your character name cannot contain any punctuation.", nil, "OK")
				return
			elseif f:len() < 1 or l:len() < 1 then
				Derma_Message("Your character's first or last name cannot be blank.", nil, "OK")
				return
			elseif (f:len() + l:len()) < 5 then
				Derma_Message("Your character's name cannot be shorter than five letters.", nil, "OK")
				return
			elseif (f:len() + l:len()) > 24 then
				Derma_Message("Your character's name cannot be longer than twenty four letters.", nil, "OK")
				return
			end

			frame:Close()

			net.Start("PKSubmitNameChange")
				net.WriteString(f .. " " .. l)
			net.SendToServer()
		end
	end)

	netstream.Hook("nut_pkConfirm", function(target)
		Derma_Query("Do you want to toggle PK status on " ..target:Name().. "?", "Confirmation", "Yes", function()
			netstream.Start("nut_pkConfirmed", target)
		end, "No")
	end)
end

nut.command.add("pk", {
	syntax = "<string name>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if(IsValid(target) and target:getChar()) then
			netstream.Start(client, "nut_pkConfirm", target)
		end
	end
})

--turns off pk if there is ever a reason for that
nut.command.add("pkoff", {
	syntax = "<string name>",
	adminOnly = true,
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])

		if(IsValid(target) and target:getChar()) then
			local char = target:getChar()

			char:setVar("pkReady", nil)
		end
	end
})

--a chat type for notifying surround players
nut.chat.register("pknotify", {
	onChatAdd = function(speaker, text)
		surface.PlaySound("vat_kill.mp3")
		chat.AddText(Color(255, 0, 0), speaker:Name(), Color(255,80,80), " has been marked for death.")
	end,
	onCanHear = 800,
	noSpaceAfter = true,
	filter = "ic",
})
