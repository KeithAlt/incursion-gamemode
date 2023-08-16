
	util.AddNetworkString("nutSlaveboyControlPanel") -- sh_weapon_mad_collar -> cl_weapon_mad_collarcontrolpanel
	util.AddNetworkString("nutUpdateSlaveManifest") --cl_weapon_mad_collarcontrolpanel -> sv_plugin
	util.AddNetworkString("nutUpdateSlaveManifestToClient") --sv_plugin -> cl_weapon_mad_collarcontrolpanel
	util.AddNetworkString("nutCreateSpawnpoint") -- cl_weapon_mad_collarcontrolpanel -> sv_plugin
	util.AddNetworkString("nutSlaveCollarActions") --cl_slavecollarcontrolpanel -> sv_plugin
	util.AddNetworkString("nutZiptieActions") --cl_plugin -> sv_plugin
	util.AddNetworkString("nutAttemptDisarmCollar") --cl_plugin -> sv_plugin
	util.AddNetworkString("nutZipCheckMoney")
--[[-------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]
function PLUGIN:PlayerSpawn(client)
	local char = client:getChar()
	local collar = client:getCollar()

	if !char or !collar or !IsValid(client) then return end

	timer.Simple(0, function()
		local spawnpoint = SlaveSpawns[collar:getData("owner", -1)]
		if IsValid(spawnpoint) then
			client:SetPos(spawnpoint:GetPos())

			if (client:isStuck()) then
				client:DropToFloor()
				client:SetPos(client:GetPos() + Vector(0, 0, 16))

				local positions = nut.util.findEmptySpace(client, {client, client})

				for k, v in ipairs(positions) do
					client:SetPos(v)

					if (!client:isStuck()) then
						return
					end
				end
			end
		else
			collar:remove()
		end
	end)
end

local safeDist = 350
local safeDistSqr = safeDist ^ 2

local function WithinSafeDist(ply, ent)
	return ent:GetPos():DistToSqr(ply:GetPos()) < safeDistSqr
end

function PLUGIN:PlayerPostThink(client)
	if !client:getChar() then return end

	local collar = client:getCollar()

	if !client:Alive() or !collar then
		client:timedExplosion(true)
		return
	end

	local slaverChar = nut.char.loaded[collar:getData("owner", -1)]
	local slaverPly = slaverChar and slaverChar:getPlayer() or nil
	local slaverSpawn = SlaveSpawns[collar:getData("owner", -1)]

	if !collar:getData("proximity") then
		client:timedExplosion(true)
		return
	end

	--if I'm not next to a valid spawnpoint or an owner, explode
	if (!IsValid(slaverPly) or WithinSafeDist(client, slaverPly)) or (IsValid(slaverSpawn) and WithinSafeDist(client, slaverSpawn)) then
		client:timedExplosion(true)
		return
	end

	client:timedExplosion()
end

--[[-------------------------------------------------------------------------
Serverside Net Messages
---------------------------------------------------------------------------]]
net.Receive("nutZipCheckMoney", function()
	local ply = net.ReadEntity()
	local target = 	ply:GetEyeTrace().Entity

	if !(target or target:Alive() or target:IsPlayer()) then
		ply:notify("Invalid player target")
		return
	end

	ply:ConCommand("say /it reaches into pocket and checks how many caps the person has")
	jlib.Announce(ply, Color(255,235,110), ". . . You find that the person has ", Color(255,255,0), target:getChar():getMoney() .. " ©")
	jlib.Announce(target, Color(255,235,110), "Someone has checked your wallet and now knows how many caps you have . . .")
end)

net.Receive("nutUpdateSlaveManifest", function(len, client)
	local manifest = {}

	for _, collar in ipairs(client:getSlaveCollars()) do
		local target = collar:getOwner()

		if type(target) == "table" then
			target = target[2]
		end

		insertChar = {}
		insertChar["name"] = target:getChar():getName()
		insertChar["location"] = target:getArea() or "Unknown"
		insertChar["proximity"] = collar:getData("proximity", false)
		insertChar["id"] = target:getChar():getID()

		table.insert(manifest, insertChar)
	end

	net.Start("nutUpdateSlaveManifestToClient")
	net.WriteTable(manifest)
	net.Send(client)
end)

net.Receive("nutCreateSpawnpoint", function(len, client)
	for _, entity in ipairs(ents.FindByClass("nut_slavespawn")) do
		if entity:GetOwner() == client then
			entity:Remove()

			client:notifyLocalized("Old spawnpoint removed!")
		end
	end

	local spawnpoint = ents.Create("nut_slavespawn")
	spawnpoint:SetPos(client:GetPos())
	spawnpoint:SetOwner(client)
	spawnpoint:Spawn()

	client:notifyLocalized("Slave spawnpoint created!")
end)

net.Receive("nutSlaveCollarActions", function(len, client) -- This whole section should be rewritten. But I'm bug patching on 2 hours of sleep so fuck off, Keith
	local action = net.ReadString()
	local target = net.ReadEntity()

	if client:getSlaveboy() and target:getCollar() and action == "detonate" and !client.SpawnProtect and client:Alive() then -- .SpawnProtect is from addons/SpawnProtection
		target:explode()
		return
	elseif client.SpawnProtect then
		client:notify("You cannot detonate a collar while spawning")
		return
	end

	if action == "unlock" then
		local collar = target:getCollar()

		if !collar then return end

		collar:wearCollar(false)
		collar:remove()
		return
	end

	if action == "proximity" then
		local collar = target:getCollar()

		if not collar then return end

		collar:setData("proximity", not collar:getData("proximity"))
		return
	end
end)

net.Receive("nutZiptieActions", function(len, client)
	local action = net.ReadString()

	if action == "tie" then
		for _, ziptie in ipairs(client:getChar():getInv():getItemsByUniqueID("tie")) do
			ziptie.player = client
			ziptie.functions.Use.onRun(ziptie)
			break
		end
	end

	if action == "untie" then
		local entity = net.ReadEntity()
		if (!client:getNetVar("restricted") and entity:IsPlayer() and entity:getNetVar("restricted") and !entity.nutBeingUnTied) then
			entity.nutBeingUnTied = true

			client:setNetVar("tyingU", CurTime())
			entity:setNetVar("tyingU", CurTime())

			client:setAction("Untying", 5, function()
				if(IsValid(entity) and IsValid(client) and entity:GetPos():Distance(client:GetPos()) < 96) then
					client:EmitSound("npc/roller/blade_in.wav")

					nut.chat.send(client, "me", "unties " ..entity:Name().. "'s hands . . .")

					entity:setRestricted(false)
				else
					client:falloutNotify("[ ! ]  Untying has failed")  -- Custom notification
				end

				client:setNetVar("tyingU", nil)
				entity:setNetVar("tyingU", nil)
				entity.nutBeingUnTied = nil
			end)
		end
	end

	if action == "search" then
		nut.command.run(client, "charsearch")
	end
end)

net.Receive("nutAttemptDisarmCollar", function(len, client)
	if client:getCollar() then
		client:falloutNotify("You cannot remove a collar while enslaved", "ui/notify.mp3")
		return
	end

	local target = net.ReadEntity()
	client:ConCommand("say /it attempts to disarm the slave collar . . .")
	target:EmitSound("npc/manhack/gib.wav", 40)

	client:setAction("Attempting to Disarm...", 6.5 - ((client:getSpecial("I") or 0) * 0.1), function()
		--Placeholder code for getting intelligence and disarming!
		if client:Alive() and client:getSpecial("I") >= 15 then
			local collar = target:getCollar()
			collar:wearCollar(false)
			client:falloutNotify("☑ You have disarmed the slave collar!", "ui/goodkarma.ogg")
			jlib.Announce(client, Color(255,0,0), "[INFO] ", Color(255,255,255), "Your INTEL allowed you to disarm the collar in - " .. (6.5 - (client:getSpecial("I") * 0.1)) .. " seconds")
			target:falloutNotify("☑  Someone has disarmed your slave collar!", "ui/goodkarma.ogg")
		else
			client:falloutNotify("☒  You fail to disarm the collar . . .", "ui/notify.mp3")
			jlib.Announce(client, Color(255,0,0), "[INFO] ", Color(255,255,255), "You must have at least ", Color(255,155,155), "level 15 intelligence ", Color(255,255,255), "to disarm a slave collar")
			target:EmitSound("ambient/energy/zap1.wav")
			target:falloutNotify("☒ Someone attempted to disarm your collar . . .")

			ParticleEffectAttach("mr_electric_1", PATTACH_POINT_FOLLOW, target, 2)

			timer.Simple(1, function()
				if IsValid(target) then
					target:StopParticles()
				end
			end)
		end
	end)
end)
