util.AddNetworkString("AmbushDrawHUD")
util.AddNetworkString("AmbushPlayAmbience")

-- If a player is killed during an ambush
hook.Add("PlayerDeath", "AmbushDeathMessage", function(victim, inflictor, attacker)
	if (IsValid(inflictor) and inflictor.AmbushState) or (IsValid(attacker) and attacker.AmbushState) then

		victim:falloutNotify("You were killed in an ambush . . .", "shelter/sfx/recipe_duplicate.ogg")

		jlib.Announce(victim, Color(255, 0, 0), "[NOTICE] ", Color(255, 140, 140), "You were killed in an ambush", Color(255, 255, 255), 
			"\n・ You cannot return to the skirmish location until it has concluded" ..
			"\n・ You cannot mention the ambush in IC discussion platforms"
		)

	end
end)

-- Validate the player. This should be put in jlib
local function Validate(ply)
	if IsValid(ply) and ply:getChar() and ply:getChar():getFaction() then
		return true
	end
end

-- Announce an ambush to all players
local function AnnounceAmbush()
	for k, v in pairs(player.GetAll()) do
		if Validate(v) then
			Ambush.PlayAmbience(v)
		end
	end
end

-- Get all players part of a faction. This should be put in jlib
function GetAllFactionMembers(faction_id)
	if !faction_id then return end

	local FactionMembers = {}
	local index = 0

	for k, v in pairs(player.GetAll()) do
		if Validate(v) and v:GetFaction() == faction_id then
			table.insert(FactionMembers, index, v)
			index = index + 1
		end
	end

	return FactionMembers
end

-- SV call to draw ambush gui on target player
function Ambush.DrawHUD(ply, bool)
	if !Validate(ply) then return end

	net.Start("AmbushDrawHUD")
	net.WriteBool(bool or false)
	net.Send(ply)
end

-- SV call to play ambient battle sounds
function Ambush.PlayAmbience(ply)
	if !Validate(ply) then return end

	net.Start("AmbushPlayAmbience")
	net.Send(ply)
end

-- Gets the players faction ID. This should be put in jlib
function PLAYER:GetFaction()
	if !Validate(self) then return end
	local fac = self:getChar():getFaction()
	return fac
end

-- Is faction on cooldown?
function Ambush.HasCooldown(faction_id)
	if !faction_id then return end

	if nut.faction.indices[faction_id].ambushCooldown then
		return true
	else
		return false
	end
end

-- Create a cooldown for the next ambush
function Ambush.CreateCooldown(faction_id, time)
	if !(faction_id or isstring(faction_id)) or !(time or isnumber(time)) or timer.Exists(faction_id .. "AmbushTime") then return end

	nut.faction.indices[faction_id].ambushCooldown = true

	-- Timer for cooldown on next ambush
	timer.Create(faction_id .. "_AmbushCooldown", time, 1, function()
		nut.faction.indices[faction_id].ambushCooldown = false
	end)
end

-- Setter for active state of an ambush
function Ambush.SetActive(faction_id, bool)
	if !faction_id then return end

	if bool then
		local fac = faction_id
		nut.faction.indices[faction_id].AmbushActive = bool

		-- Announce ambush to all players
		timer.Simple(5, function()
			AnnounceAmbush()
		end)

		timer.Create(faction_id .. "_AmbushTimer", nut.config.get("ambushDuration") or 100, 1, function()
			Ambush.End(fac)
		end)

		Ambush.CreateCooldown(fac,  (nut.config.get("ambushDuration") or 100) + (nut.config.get("ambushCooldown") or 300))

	elseif bool == false then
		nut.faction.indices[faction_id].AmbushActive = false
	end
end

-- Getter for active state of an ambush
function Ambush.GetActive(faction_id)
	if !faction_id then return end

	if nut.faction.indices[faction_id].AmbushActive then
		return true
	else
		return false
	end
end

-- Start an ambush state for that faction
function Ambush.Start(faction_id, requester)
	if !faction_id then return end

	if nut.faction.indices[faction_id].AmbushActive then
		requester:notify("You already have an active ambush")
		return
	elseif nut.faction.indices[faction_id].NotAttackable then
		requester:notify("You cannot ambush in this faction")
		return
	elseif Ambush.HasCooldown(faction_id) then
		requester:notify("Your faction is currently on an ambush cooldown")
		return
	end

	local factionMembers = GetAllFactionMembers(faction_id)
	Ambush.SetActive(faction_id, true)

	for k, v in pairs(factionMembers) do
		Ambush.DrawHUD(v, true)
		v.AmbushState = true
		Ambush.SetActive(faction_id, bool)

		jlib.Announce(v, Color(255, 0, 0), "[NOTICE] ", Color(255, 140, 140), "You have entered an ambush state", Color(255, 255, 255),
			"\n・ You are able to attack other factions/groups that meet the ambush requirements" ..
			"\n・ This ambush state will expire in " .. ((nut.config.get("ambushDuration") .. " seconds") or "100 seconds") ..
			"\n・ You will not be able to ambush again for " .. ((nut.config.get("ambushCooldown") .. " seconds") or "300 seconds")
		)

		DiscordEmbed(requester:Nick() ..  " ( " .. requester:SteamID() .. " ) " .. "has entered their faction into an ambush state", "🐱‍👤 Ambush Declaration Log 🐱‍👤" , Color(255, 255, 0), "Admin")
	end
end

-- End an ambush state for that faction
function Ambush.End(faction_id)
	if !faction_id then return end

	local factionMembers = GetAllFactionMembers(faction_id)

	if !nut.faction.indices[faction_id].NotAttackable and nut.faction.indices[faction_id].AmbushActive then

		Ambush.SetActive(faction_id, false)

		for k, v in pairs(factionMembers) do
			Ambush.DrawHUD(v, false)
			v.AmbushState = false

			jlib.Announce(v, Color(255, 0, 0), "[NOTICE] ", Color(255, 140, 140), "Your ambush state has ended", Color(255, 255, 255),
				"\n・ You will not be able to ambush again for " .. ((nut.config.get("ambushCooldown") .. " seconds") or "300 seconds")
			)
		end
	end
end
