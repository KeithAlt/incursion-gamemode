Psykers = Psykers or {}
Psykers.Config = Psykers.Config or {}
Psykers.Config.Cooldowns = Psykers.Config.Cooldowns or {}
Psykers.Author = "jonjo"

AddCSLuaFile("psykers_config.lua")
include("psykers_config.lua")

if SERVER then
	function Psykers.OnInject(ply, target)
		if !IsValid(target) then
			target = ply
		end

		if ply != target then
			ply:falloutNotify("You have injected someone with the F.E.V.")
			target:falloutNotify("You have been injected with the F.E.V.")
		else
			ply:falloutNotify("You have injected yourself with the F.E.V.")
		end

		target:ChatPrint("You have been injected with an unstable strain of the forced evolutionary virus. Unwanted results may occur...")
		target:EmitSound("ambient/voices/m_scream1.wav")
		jlib.SendSound("ui/stim.wav", ply != target and {ply, target} or target)
		jlib.SendSound("chems/ui_health_chems_wearoff.wav", target)
		target:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 255), 2, 0)
	end

	function Psykers.CanInject(ply)
		return ply:Alive() and ply:getChar() and ply:GetMoveType() == MOVETYPE_WALK and !ply:InVehicle() and !IsValid(ply:GetParent()) and (!pk_pills or !IsValid(pk_pills.getMappedEnt(ply)))
	end
end

hook.Add("InitPostEntity", "PyskerItemInit", function()
	local ITEM = nut.item.register("unstablefev", nil, false, nil, true)
	ITEM.name = "Unstable F.E.V."
	ITEM.desc = "Can be injected into a subject to inflict all kinds of effects.\nWARNING! Side effects may include: death, unstable vitals, sudden spacetime displacement, implosion, explosion, severe genetic mutation and other miscellaneous anomalies."
	ITEM.model = "models/fallout/items/chems/medx.mdl"

	ITEM.functions.Use = {
		name = "Use",
		icon = "icon16/error.png",
		onRun = function(item)
			local ply = item.player or item:getOwner()

			if Psykers.CanInject(ply) then
				local effect = Psykers.GetEffect(ply)
				local deaths = ply:Deaths()

				Psykers.OnInject(ply)

				timer.Simple(2, function()
					if IsValid(ply) and ply:Deaths() <= deaths then
						effect(ply)
					end
				end)
			else
				ply:falloutNotify("You cannot be injected with the F.E.V right now.")
				return false
			end
		end
	}

	ITEM.functions.Inject = {
		name = "Inject",
		icon = "icon16/error.png",
		onRun = function(item)
			local ply = item.player or item:getOwner()
			local tr = ply:GetEyeTrace()
			local target = tr.Entity
			if IsValid(target) and target:IsPlayer() and Psykers.CanInject(target) then
				local effect = Psykers.GetEffect(target)
				local deaths = target:Deaths()

				Psykers.OnInject(ply, target)

				timer.Simple(2, function()
					if IsValid(target) and target:Deaths() <= deaths then
						effect(target)
					end
				end)
			else
				ply:falloutNotify("No valid target")
				return false
			end
		end
	}

--	nut.command.add("transferpsyker", {
--		onRun = function(ply, args)
--			local abilityID = args[1]
--
--			if !isstring(abilityID) then
--				return "Invalid ability id"
--			end
--
--			if Psykers.HasAbility(ply, abilityID) then
--				local tr = ply:GetEyeTrace()
--				if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:getChar() then
--					local target = tr.Entity
--					jlib.RequestBool("Transferring to " .. target:Nick() .. " are you sure?", function(sure)
--						if IsValid(ply) and IsValid(target) and sure then
--							local char = ply:getChar()
--							local targetChar = target:getChar()
--							if char and targetChar then
--								Psykers.RevokeAbility(ply, abilityID)
--								Psykers.GrantAbility(target, abilityID, char:getData(abilityID .. "Granted", nil))
--
--								ply:falloutNotify("Transfer was successful!")
--
--								for id, _ in pairs(Psykers.Abilities) do
--									if targetChar:getData(Psykers.GetFullID(id), false) and id != abilityID then
--										local timeGranted = targetChar:getData(id .. "Granted", 0)
--										local timeSinceGranted = os.time() - timeGranted
--										local timeRemaining = Psykers.Config.AbilityExpiry - timeSinceGranted
--
--										if timeRemaining - Psykers.Config.ExpiryPenalty >= Psykers.Config.ExpiryPenalty then
--											targetChar:setData(id .. "Granted", timeGranted - Psykers.Config.ExpiryPenalty)
--											target:ChatPrint("Your " .. id .. " ability now expires " .. string.NiceTime(Psykers.Config.ExpiryPenalty) .. " earlier")
--										end
--									end
--								end
--							end
--						end
--					end, ply)
--				end
--			else
--				return "You don't have this psyker to transfer."
--			end
--		end
--	})

	local function ParseArgs(args)
		local abilityID = args[1]
		table.remove(args, 1)
		local playerName = table.concat(args, " ")
		local target, err = jlib.GetPlayer(playerName)

		if !IsValid(target) then
			return err
		end

		return abilityID, target
	end

	nut.command.add("grantpsyker", {
		superAdminOnly = true,
		syntax = "<ability> <player>",
		onRun = function(ply, args)
			if #args != 2 then
				return "Invalid arguments supplied"
			end

			local abilityID, target = ParseArgs(args)

			if !IsValid(target) then
				return abilityID
			end

			if Psykers.IsAbilityTaken(abilityID) then
				return "That ability is already taken"
			elseif !Psykers.Abilities[abilityID] then
				return "There is no ability with ID " .. abilityID
			else
				Psykers.GrantAbility(target, abilityID)
			end
		end
	})

	nut.command.add("revokepsyker", {
		superAdminOnly = true,
		syntax = "<ability> <player>",
		onRun = function(ply, args)
			if #args != 2 then
				return "Invalid arguments supplied"
			end

			local abilityID, target = ParseArgs(args)

			if !IsValid(target) then
				return abilityID
			end

			if !Psykers.Abilities[abilityID] then
				return "There is no ability with ID " .. abilityID
			elseif !Psykers.HasAbility(target, abilityID) then
				return "This player doesn't have that ability"
			else
				Psykers.RevokeAbility(target, abilityID)
				target:notify("Your " .. abilityID .. " ability has been revoked by " .. ply:Nick())
				return "Ability revoked"
			end
		end
	})
end)

-- Forcefield
hook.Add("EntityFireBullets", "PsykersForcefield", function(ent, bullet)
	if CLIENT and !IsFirstTimePredicted() then return end

	for i, ply in ipairs(Psykers.ForcefieldPlayers) do
		local aimvec = ent:GetAimVector()
		local center = ply:LocalToWorld(ply:OBBCenter())
		local hitPos = jlib.RaySphereIntersection(center, Psykers.Config.ForcefieldRadius, ent:EyePos(), aimvec, ent)
		if hitPos then
			-- Render the tracer ourselves since we still want this but we're also
			-- suppressing the bullet from being actually fired
			local wep = ent:GetActiveWeapon()
			local tracerName

			if IsValid(wep) and wep.TracerName and wep.Base and wep.Base:StartWith("tfa") then
				tracerName = wep.TracerName:Replace("pcf_", "")
			else
				tracerName = bullet.TracerName
			end

			local shouldBullet = Psykers.Config.NoBullet[tracerName] != true

			if tracerName then
				local shouldTracer = (bullet.Num / bullet.Tracer) > math.random()
				if shouldTracer then
					util.ParticleTracerEx(tracerName, ent:GetShootPos(), hitPos, false, wep:EntIndex(), 1)
				end
			end

			if CLIENT then
				Psykers.ForcefieldImpact(hitPos, ent, ply, shouldBullet)
			else
				net.Start("PsykersForcefieldImpact")
					net.WriteEntity(ent)
					net.WriteEntity(ply)
					net.WriteVector(hitPos)
					net.WriteBool(shouldBullet)
				net.SendPVS(hitPos)
			end

			return false
		end
	end
end)

function Psykers.ForcefiledHitEffects(hitPos, hitAng, parent)
	ParticleEffect("mr_fx_falling_bsparks", hitPos, hitAng, parent)
	ParticleEffect("weapon_core_highcharge", hitPos, hitAng, parent)
	ParticleEffect("mr_electric_1", hitPos, hitAng, parent)
	//ParticleEffect("mr_bigsparks_1", hitPos, hitAng, parent)

	timer.Simple(1 / 3, function()
		if IsValid(parent) then
			parent:StopParticles()
		end
	end)
end

function Psykers.GetFullID(abilityID)
	return "psykerability_" .. abilityID
end
