mutantTransformer = mutantTransformer or {}
mutantTransformer.TriggerPos = Vector(1856, 4610, -2000)
mutantTransformer.entity = false
mutantTransformer.active = false
mutantTransformer.onCooldown = false
mutantTransformer.timeLimit = 100

-- logging
local function log(msg)
	MsgC(Color(0,255,0), "\n[MUTANT VAT]", Color(255,255,255), " " .. msg)
end

--changes a player's faction
local function changeFaction(victim)
	local character = victim:getChar()

	if (not IsValid(victim) or not character) then
		return false
	end

	-- Find the specified faction.
	local oldFaction = nut.faction.indices[character:getFaction()]
	local faction = nut.faction.teams["supermutant"]
	if (not faction) then
		for k, v in pairs(nut.faction.indices) do
			if (nut.util.stringMatches(L(v.name, victim), name)) then
				faction = v
				break
			end
		end
	end

	if not faction then
		return false
	end

	-- Change to the new faction.
	character.vars.faction = faction.uniqueID
	character:setFaction(faction.index)
	if (faction.onTransfered) then
		faction:onTransfered(victim, oldFaction)
	end
	hook.Run("CharacterFactionTransfered", character, oldFaction, faction)
end

--changes a player's class
local function changeClass(victim)
	local class = "Super Mutant - Default"
	local char = victim:getChar()
	local prevPos = victim:GetPos() -- Fix position annoyance

	if (IsValid(victim) and char) then
		local num = isnumber(tonumber(class)) and tonumber(class) or -1

		if (nut.class.list[num]) then
			local v = nut.class.list[num]

			if (char:joinClass(num)) then
				local class = nut.class.list[num]
				char:setData("class", class.uniqueID)

				return
			end
		else
			for k, v in ipairs(nut.class.list) do
				if (nut.util.stringMatches(v.uniqueID, class) or nut.util.stringMatches(L(v.name, victim), class)) then
					if (char:joinClass(k)) then
						local class = nut.class.list[k]
						char:setData("class", class.uniqueID)

						jlib.CallAfterTicks(25, function() -- Fix position annoyance
							victim:SetPos(prevPos + Vector(0,0,30))
						end)

						return
					end
				end
			end
		end
	end
end

-- Get our victim
local function getVictim()
	local victim
	local victimCount = {}

	for index, entity in pairs(ents.FindInSphere(mutantTransformer.TriggerPos, 45)) do
		if entity:IsPlayer() and entity:Alive() and entity:GetMoveType() != MOVETYPE_NOCLIP then
			victim = entity
			table.insert(victimCount, entity)
		end
	end

	if #victimCount > 1 then
		return false
	end

	return victim
end

-- Our event handler
local function startEvent(inflictor, victim)
	if Armor and victim:getChar() and victim:Alive() and not Armor.IsHuman(victim:getChar()) then
		inflictor:notify("You cannot mutify a non-human!")
		return
	end

	victim.inMutantChamber = true
	mutantTransformer.active = victim
	mutantTransformer.onCooldown = true

	victim:GodEnable() -- Don't let our victim die during sequence

	timer.Create("MutantQuery", mutantTransformer.timeLimit , 0, function()
		if IsValid(victim) and victim.inMutantChamber == true then
			mutantTransformer.active = nil
			victim.inMutantChamber = nil
			victim:GodDisable()
			victim:Kill()
		end
	end)

	victim:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 5, 10)

	timer.Simple(13, function()
		victim:ScreenFade(SCREENFADE.STAYOUT, Color(0, 0, 0, 255), 0, 0)
		victim:SetModel("models/player/keitho/supermutant.mdl")
		victim:EmitSound("ambient/levels/canals/toxic_slime_loop1.wav")

		jlib.RequestBool("Become a Super Mutant?", function(bool)
			victim:StopSound("ambient/levels/canals/toxic_slime_loop1.wav")
			victim.inMutantChamber = nil
			mutantTransformer.active = nil
			victim:ScreenFade(SCREENFADE.PURGE, Color(255, 255, 255, 255), 0.1, 0)

			if timer.Exists("MutantQuery") then
				timer.Remove("MutantQuery")
			end

			if not bool then
				for index, ply in pairs(ents.FindInSphere(victim:GetPos(), 1000)) do
					if ply:IsPlayer() and ply != victim and ply:Alive() then
						ply:falloutNotify("The victim died from shock . . .", "ui/badkarma.ogg")
					end
				end

				victim:GodDisable()
				victim:Kill()

				local zone = Dismemberment.GetDismembermentZone(HITGROUP_HEAD)
				Dismemberment.Dismember(victim, zone.Bone, zone.Attachment, zone.ScaleBones, zone.Gibs, IsValid(victim) and victim:GetForward() or VectorRand())

				return
			end

			victim:falloutNotify("You've become a Super Mutant", "fallout/death/death_2.wav")
			changeFaction(victim)
			changeClass(victim)
			victim:ScreenFade(SCREENFADE.IN, Color(155, 255, 155, 255), 2, 2)
			victim:getChar():setModel("models/player/keitho/supermutant.mdl")
			victim:GodDisable()

			timer.Simple(0.25, function()
				if IsValid(victim) then
					victim:ScreenFade(SCREENFADE.IN, Color(155, 255, 155, 255), 3, 3)

					if math.random() >= 0.5 then
						victim:EmitSound("unitynuke/cantescapeme.mp3")
					else
						victim:EmitSound("unitynuke/choochoo.mp3")
					end

					victim:SendLua("RunConsoleCommand('act', 'zombie')")
				end
			end)

		end, victim, "YES (CHANGE)", "NO (DIE)")
	end)

	timer.Simple(60, function()
		mutantTransformer.onCooldown = false
	end)
end

-- Initalize our button
hook.Add("InitPostEntity", "InitalizeMutantChamber", function()
	if game.GetMap() != "cgc_newvegas" then
		ErrorNoHalt("Attempted to load the 'Mutant Transform Event Script' on the incorrect map")
		log("Failed to initalize script due to incorrect map")
		return
	end

	for index, entity in pairs(ents.FindByClass("func_button")) do
		if entity:GetModel() == "*348" then
			log("Initalized mutant trigger button succesfully")
			mutantTransformer.entity = entity
			break
		end
	end

	-- Track the event state for the transformer on cgc_newvegas
	hook.Add("AcceptInput", "MutantChamberSequence", function(ent, name, activator, caller, data)
		if ent:GetModel() == "*348" and not mutantTransformer.onCooldown and not mutantTransformer.active then

			if IsValid(activator) and nut.faction.indices[activator:Team()].uniqueID != "unity" then
				ent:EmitSound("buttons/combine_button_locked.wav")
				return
			end

			local victim = getVictim()

			if IsValid(activator) and nut.faction.indices[activator:Team()].uniqueID == "unity" and IsValid(victim) and victim:IsPlayer() then
				ent:EmitSound("buttons/button24.wav")
				startEvent(activator, victim)
			end
		end
	end)
end)
