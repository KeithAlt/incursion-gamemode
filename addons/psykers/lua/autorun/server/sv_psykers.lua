// resource.AddSingleFile("sound/psykers/ui_wildwasteland.ogg")

-- Item effects
function Psykers.VJBaseTransform(ply, npc)
	local npcEnt = ents.Create(npc)
	npcEnt:SetPos(ply:GetPos())
	npcEnt:Spawn()

	local npcController = ents.Create("ob_vj_npccontroller")
	npcController.TheController = ply
	npcController:SetControlledNPC(npcEnt)
	npcController:Spawn()
	npcController:StartControlling()

	ply:falloutNotify("You have been transformed!")

	ply:ConCommand("simple_thirdperson_enabled 0") -- Camera freaks out when STP is enabled
end

function Psykers.TransformEffect(ply)
	local effectData = EffectData()
	effectData:SetScale(5)

	for i = 0, Psykers.Config.TransformFXDuration do
		timer.Simple(i, function()
			if IsValid(ply) then
				effectData:SetOrigin(ply:GetPos() + ply:GetUp() * 2)
				util.Effect("VortDispel", effectData)
				ply:EmitSound("ambient/machines/thumper_hit.wav", 100, 50)

				if i == Psykers.Config.TransformFXDuration then
					jlib.Zap(ply)
					ParticleEffect("pgex*", ply:GetPos(), ply:GetAngles())
				end
			end
		end)
	end

	return Psykers.Config.TransformFXDuration
end

function Psykers.TeleportEffect(ply)
	jlib.Zap(ply)
	ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1, 0.15)
	util.ScreenShake(ply:EyePos(), 5, 5, 2.5, 50)
end

-- Make objects levitate for a bit
local function propRiseEffect(ply, entity)
	local tENTs = ents.FindInSphere(entity:GetPos(), 800)
	local pENT = entity

	if SERVER then
		for i = 1, #tENTs do
			local pENT = tENTs[i]

			if (pENT:IsPlayer()) and (pENT != self) then
				pENT:SetVelocity( Vector( 0, 0, 260 ) )
				pENT:SetGravity( 0.15 )
				timer.Simple( 3, function()
 					pENT:SetGravity( 1 )
				end)
			end
		end

		if (pENT:GetClass() == "prop_physics") or (pENT:GetClass() == "prop_ragdoll") or (pENT:GetClass() == "prop_physics_multiplayer") then
			local bones = pENT:GetPhysicsObjectCount()

			for  i=0, bones-1 do
				local phys = pENT:GetPhysicsObjectNum( i )

				if (IsValid(phys)) then
					phys:EnableGravity(false)
					phys:SetVelocity(Vector(0, 0, 5) * 2)
					timer.Simple(3, function()
						if !IsValid(phys) then
							return
						end
					end )
					phys:EnableGravity( true )
				end
			end
		end
	end
end



Psykers.Effects = {
	[Psykers.Config.RegularEffectChance] = {
		{ -- Scale increase/decrease
			Effect = function(ply)
				local duration = 1.5
				local num = math.random()
				local scale = num < 0.5 and 0.75 or 1.25

				local sound = CreateSound(ply, "400hz.wav")
				sound:PlayEx(0.4, 100)
				sound:ChangePitch(scale < 1 and 20 or 180, duration)
				sound:FadeOut(duration)

				ply:SetModelScale(ply:GetModelScale() * scale, duration)

				ply:falloutNotify("You feel a sudden change in size")
			end,
			CanRun = function(ply)
				return true
			end
		},
		{ -- Random teleport
			Effect = function(ply)
				local map = game.GetMap()
				local posTbl = Psykers.Config.TeleportLocations[map]

				if !istable(posTbl) then
					error("Psykers is not configured for " .. map)
				end

				ply:SetPos(posTbl[math.random(#posTbl)])

				Psykers.TeleportEffect(ply)

				ply:falloutNotify("You are suddenly transported")
			end,
			CanRun = function(ply)
				local mapTbl = Psykers.Config.TeleportLocations[game.GetMap()]
				return istable(mapTbl) and #mapTbl > 0
			end
		},
		{ -- Timebomb
			Effect = function(ply)
				local duration = math.Rand(10, 15)
				local detonationTime = CurTime() + duration
				local nextBeep = CurTime()
				local deaths = ply:Deaths()
				local hookID = ply:SteamID64() .. "PsykerBomb"

				if isfunction(hook.GetTable().Think[hookID]) then
					return
				end

				ply:GodEnable()

				ply:SetModelScale(1.5, duration)

				hook.Add("Think", hookID, function()
					if !IsValid(ply) then
						hook.Remove("Think", hookID)
						return
					end

					if !ply:Alive() or ply:Deaths() > deaths then
						ply:GodDisable()
						hook.Remove("Think", hookID)
						return
					end

					if CurTime() >= nextBeep then
						nextBeep = CurTime() + ((detonationTime - CurTime()) / 30)
						ply:EmitSound("weapons/c4/c4_beep1.wav")
					end

					if CurTime() >= detonationTime then
						ply:GodDisable()

						local effect = EffectData()
						effect:SetOrigin(ply:GetPos())
						effect:SetMagnitude(150)
						util.Effect("Explosion", effect)

						util.BlastDamage(ply, ply, ply:GetPos(), 150, 200)

						ply:SetModelScale(1)

						hook.Remove("Think", hookID)
					end
				end)

				ply:falloutNotify("You feel bloated")
			end,
			CanRun = function(ply)
				return !isfunction(hook.GetTable().Think[ply:SteamID64() .. "PsykerBomb"])
			end
		},
		{ -- Jump height/gravity
			Effect = function(ply)
				ply:SetJumpPower(ply:GetJumpPower() * 1.5)
				ply:SetGravity(0.25)

				local hookID = ply:SteamID64() .. "PsykerGravity"
				hook.Add("PlayerSpawn", hookID, function(spawnPly)
					if !IsValid(ply) then
						hook.Remove("PlayerSpawn", hookID)
						return
					end

					if ply == spawnPly then
						ply:SetGravity(0)
						hook.Remove("PlayerSpawn", hookID)
					end
				end)

				ply:falloutNotify("You feel lighter")
			end,
			CanRun = function(ply)
				return true
			end
		},
		{ -- Location swap
			Effect = function(ply)
				local players = {}

				for i, target in ipairs(player.GetAll()) do
					if target != ply and Psykers.CanInject(target) then
						table.insert(players, target)
					end
				end

				local swapPly = players[math.random(#players)]
				local curPos = ply:GetPos()
				local swapPos = swapPly:GetPos()

				ply:SetPos(swapPos)
				swapPly:SetPos(curPos)

				Psykers.TeleportEffect(ply)
				Psykers.TeleportEffect(swapPly)

				ply:falloutNotify("You are suddenly displaced with another organism")
			end,
			CanRun = function(ply)
				for i, target in ipairs(player.GetAll()) do
					if ply != target and Psykers.CanInject(target) then
						return true
					end
				end
			end
		},
		{ -- Shrink until death
			Effect = function(ply)
				local duration = 5
				local deaths = ply:Deaths()

				ply:SetModelScale(0.15, duration)

				local sound = CreateSound(ply, "400hz.wav")
				sound:PlayEx(0.4, 100)
				sound:ChangePitch(20, duration)

				timer.Simple(duration, function()
					if IsValid(ply) and deaths == ply:Deaths() then
						local effect = EffectData()
						effect:SetOrigin(ply:GetPos())
						effect:SetStart(Vector(255, 0, 0))
						util.Effect("balloon_pop", effect)

						ply:Kill()
						ply:GetRagdollEntity():SetNoDraw(true)

						sound:Stop()
					end
				end)

				ply:falloutNotify("Your atomic structure begins to collapse")
			end,
			CanRun = function(ply)
				return true
			end
		},
		{ -- Black hole
			Effect = function(ply)
				local blackhole = ents.Create(Psykers.Config.BlackholeEntity)
				blackhole:SetPos(ply:GetPos() + Psykers.Config.BlackholeOffset)
				blackhole:SetLife(Psykers.Config.BlackholeDuration)
				blackhole:Spawn()

				ply:falloutNotify("Spacetime has been torn")
			end,
			CanRun = function(ply)
				return util.IsInWorld(ply:GetPos() + Psykers.Config.BlackholeOffset)
			end
		},
		{ -- Random pill
			Effect = function(ply)
				timer.Simple(Psykers.TransformEffect(ply), function()
					local pills = Psykers.Config.Pills
					pk_pills.apply(ply, pills[math.random(#pills)], "lock-life")
				end)
			end,
			CanRun = function(ply)
				return true
			end
		},
		{ -- VJBase transform
			Effect = function(ply)
				timer.Simple(Psykers.TransformEffect(ply), function()
					ply:EmitSound("vj_fallout_monsters/supermutantbehemoth_attack0" .. math.random(1, 3) .. ".mp3")
					Psykers.VJBaseTransform(ply, Psykers.Config.VJBaseNPC)
				end)
			end,
			CanRun = function(ply)
				local tr = util.TraceLine(util.GetPlayerTrace(ply, Vector(0, 0, 1)))
				return !tr.Hit or tr.StartPos:Distance(tr.HitPos) > 250
			end
		}
	},
	[100 - Psykers.Config.RegularEffectChance] = {
		{ -- Grant mind
			Effect = function(ply)
				Psykers.GrantAbility(ply, "mind")
			end,
			CanRun = function(ply)
				return !Psykers.IsAbilityTaken("mind") and !Psykers.HasAbility(ply, "mind")
			end
		},
		{ -- Grant body
			Effect = function(ply)
				Psykers.GrantAbility(ply, "body")
			end,
			CanRun = function(ply)
				return !Psykers.IsAbilityTaken("body") and !Psykers.HasAbility(ply, "body")
			end
		},
		{ -- Grant soul
			Effect = function(ply)
				Psykers.GrantAbility(ply, "soul")
			end,
			CanRun = function(ply)
				return !Psykers.IsAbilityTaken("soul") and !Psykers.HasAbility(ply, "soul")
			end
		}
	}
}

-- Permanent abilities
Psykers.TeleportBackup = 45

Psykers.Abilities = {
	["mind"] = {
		Activate = function(ply)
			local success = Psykers.Teleport(ply)
			if success then
				return Psykers.Config.Cooldowns.Mind
			else
				ply:falloutNotify("Teleport path is obstructed!")
				return 2
			end
		end,
		Deactivate = function(ply)
			return false
		end
	},
	["body"] = {
		Activate = function(ply)
			local hitPos = ply:GetEyeTrace().HitPos + Vector(0,0,150)

			if hitPos:Distance(ply:GetPos()) > 5000 then
				ply:falloutNotify("You can't use your ability that far away", "ui/notify.mp3")
				return 3
			end

			ply:EmitSound("weapons/physcannon/energy_bounce" .. math.random(1,2) .. ".wav", 90, 85)

			for index, entity in pairs(ents.FindInSphere(hitPos, 1000)) do
				if entity:IsPlayer() and entity:Alive() then
					entity:ScreenFade(SCREENFADE.IN, Color(155,50,50,75), 1, 0)
				end
			end

			util.ScreenShake(hitPos, 1000, 500, 3, 3000)

			local ent = ents.Create("prop_physics")
			ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
			ent:SetPos(hitPos)
			ent:Spawn()
			ent:GetPhysicsObject():EnableMotion(false)
			ent:SetMaterial("Models/effects/vol_light001")
			ent:DrawShadow(false)

			propRiseEffect(ply, ent)

			ParticleEffectAttach("_ai_wormhole", 0, ent, 0)
			ParticleEffectAttach("mr_b_fx_1_core", 0, ent, 0)
			ent:EmitSound("Sonic_Mania/RedCube_L.wav", 100, 90, 1.2)

			timer.Simple(0, function()
				local effectdata = EffectData()
				effectdata:SetOrigin(hitPos)
				util.Effect( "vm_distort", effectdata )

				ent:EmitSound("ambient/levels/labs/teleport_preblast_suckin1.wav", 100, 60)
			end)

			timer.Simple(3.2, function()
				if IsValid(ent) then
					for index, players in pairs(player.GetAll()) do
						players:SendLua("sound.Play('ambient/atmosphere/thunder' .. math.random(1,3) .. '.wav', LocalPlayer():GetPos() + Vector(500,500,500), 75, 100, 1)")
					end

					ent:Remove()
					util.ScreenShake(hitPos, 500, 500, 4, 3000)

					for index, entity in pairs(ents.FindInSphere(hitPos, 3000)) do
						if entity:IsPlayer() and entity:Alive() and entity != ply then
							entity:ScreenFade(SCREENFADE.IN, Color(155,100,100,255), 2, 0)

							if hitPos:Distance(entity:GetPos()) <= Psykers.Config.CrushRadius then
								if entity:Health() / entity:GetMaxHealth() < 0.8 then
									entity:Kill()

									local zone = Dismemberment.GetDismembermentZone(HITGROUP_HEAD)
									Dismemberment.Dismember(entity, zone.Bone, zone.Attachment, zone.ScaleBones, zone.Gibs, IsValid(entity) and entity:GetForward() or VectorRand())
								else
									entity:TakeDamage(entity:GetMaxHealth() / 1.25)
									entity:EmitSound("weapons/physcannon/energy_disintegrate" .. math.random(4,5) .. ".wav", 72, 90)
								end
							end
						end
					end
				end
			end)
			return Psykers.Config.Cooldowns.Body
		end,
		Deactivate = function(ply)
			if IsValid(ply:GetSlave()) then
				jlib.UnPossess(ply)
				jlib.Zap(ply)
				return true
			end
			return false
		end
	},
	["soul"] = {
		Activate = function(ply)
			Psykers.Forcefield(ply)

			timer.Simple(Psykers.Config.Cooldowns.SoulDuration,  function()
				if IsValid(ply) then
					Psykers.StopForcefield(ply)
				end
			end)

			return Psykers.Config.Cooldowns.SoulDuration + Psykers.Config.Cooldowns.Soul
		end,
		Deactivate = function(ply)
			if ply:GetNW2Bool("forcefieldEnabled", false) then
				Psykers.StopForcefield(ply)
				return true
			end
			return false
		end
	}
}

function Psykers.IsAbilityTaken(abilityID)
	return file.Exists(abilityID .. ".dat", "DATA")
end

function Psykers.IsAnyAbilityAvailable()
	for abilityID, ability in pairs(Psykers.Abilities) do
		if !Psykers.IsAbilityTaken(abilityID) then
			return true
		end
	end

	return false
end

function Psykers.Announce(...)
	local plys = player.GetAll()
	jlib.Announce(plys, ...)
	jlib.SendSound(Psykers.Config.AnnounceSound, plys)
end

function Psykers.GrantAbility(ply, abilityID, originalGrantTime)
	local char = ply:getChar()
	if !char then return end

	char:setData(Psykers.GetFullID(abilityID), true)
	char:setData(abilityID .. "Granted", originalGrantTime or os.time())
	file.Write(abilityID .. ".dat", char:getID())

	Psykers.Announce(Color(255, 255, 0), ply:Nick(), Color(255, 255, 255), " has been granted the " .. abilityID .. " psyker ability!")
	Psykers.GiveBinder(ply, abilityID)
	ply:ChatPrint("Check the settings tab in the F1 menu to bind a key for your new ability!")
end

function Psykers.RevokeAbility(ply, abilityID)
	local char = ply:getChar()
	if !char then return end

	char:setData(Psykers.GetFullID(abilityID), false)
	file.Delete(abilityID .. ".dat")
end

function Psykers.HasAbility(ply, abilityID)
	local char = ply:getChar()
	if !char then return false end

	return char:getData(Psykers.GetFullID(abilityID), false)
end

function Psykers.GetAbilities(ply)
	local char = ply:getChar()
	if !char then return {} end

	local result = {}

	for id, _ in pairs(Psykers.Abilities) do
		if char:getData(Psykers.GetFullID(id), false) then
			table.insert(result, id)
		end
	end

	return result
end

-- GiveBinder
util.AddNetworkString("PsykersGiveBinder")

function Psykers.GiveBinder(ply, id)
	net.Start("PsykersGiveBinder")
		net.WriteString(id)
	net.Send(ply)
end

hook.Add("PlayerLoadedChar", "PsykersBinders", function(ply, char)
	for abilityID, _ in pairs(Psykers.Abilities) do
		if char:getData(Psykers.GetFullID(abilityID), false) then
			local timeSinceGranted = os.time() - char:getData(abilityID .. "Granted", 0)

			if timeSinceGranted >= Psykers.Config.AbilityExpiry then
				Psykers.RevokeAbility(ply, abilityID)
				ply:falloutNotify("Your " .. abilityID .. " psyker ability has expired.")
				ply:ChatPrint("You no longer have access to the " .. abilityID .. " psyker ability as it has expired. It is now available to receive from the FEV virus again.")
			else
				Psykers.GiveBinder(ply, abilityID)
			end
		end
	end
end)

-- Creating concommands for each ability
for id, ability in pairs(Psykers.Abilities) do
	concommand.Add(Psykers.GetFullID(id), function(ply)
		if IsValid(ply) and Psykers.HasAbility(ply, id) then

			if CurTime() <= (ply["Next" .. id] or 0) then
				local deactivated = ability.Deactivate(ply)

				if deactivated then
					ply:falloutNotify("Deactivated ability.")
				else
					ply:falloutNotify("Ability on cooldown, try again in " .. string.NiceTime(ply["Next" .. id] - CurTime()))
				end

				return
			end

			if !ability then return end

			local cooldown = ability.Activate(ply)
			ply["Next" .. id] = CurTime() + cooldown
		end
	end)
end

function Psykers.GetEffect(ply)
	local doableEffects = {}
	local effectsTbl = Psykers.IsAnyAbilityAvailable() and jlib.WeightedRandom(Psykers.Effects) or Psykers.Effects[Psykers.Config.RegularEffectChance]

	for i, effect in ipairs(effectsTbl) do
		if effect.CanRun(ply) then
			table.insert(doableEffects, effect.Effect)
		end
	end

	return doableEffects[math.random(#doableEffects)]
end

-- Forcefield
util.AddNetworkString("PsykersForcefieldAddPlayer")
util.AddNetworkString("PsykersForcefieldRemovePlayer")
util.AddNetworkString("PsykersForcefieldImpact")

Psykers.ForcefieldPlayers = Psykers.ForcefieldPlayers or {}

function Psykers.Forcefield(ply)
	if ply:GetNW2Bool("forcefieldEnabled", false) then return end

	ply:SetNW2Bool("forcefieldEnabled", true)

	net.Start("PsykersForcefieldAddPlayer")
		net.WriteEntity(ply)
	net.Broadcast()

	table.insert(Psykers.ForcefieldPlayers, ply)
	ply.GravEnts = {}

	-- Effect data
	local effectdata = EffectData()
	effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
	util.Effect("effect_fo3_teslahit", effectdata)
	ply:EmitSound("ambient/levels/labs/electric_explosion" .. math.random(1, 5) .. ".wav", 50, 95, 0.5)
	util.ScreenShake(ply:GetPos(), 25, 25, 2, 1500)

	timer.Simple(0.1, function()
		ply:EmitSound("ambient/energy/force_field_loop1.wav", 40, 80, 0.4)
	end)

	local distSqr = 1500 ^ 2
	for _, p in ipairs(player.GetAll()) do
		if p:Alive() and p:GetPos():DistToSqr(ply:GetPos()) < distSqr then
			p:ScreenFade(SCREENFADE.IN, Color(0, 0, 120, 150), 0, 0.5)
		end
	end
end

function Psykers.StopForcefield(ply)
	if !ply:GetNW2Bool("forcefieldEnabled", false) then return end

	ply:SetNW2Bool("forcefieldEnabled", false)

	net.Start("PsykersForcefieldRemovePlayer")
		net.WriteEntity(ply)
	net.Broadcast()

	table.RemoveByValue(Psykers.ForcefieldPlayers, ply)

	for i, ent in ipairs(ply.GravEnts) do
		if IsValid(ent) then
			local physObj = ent:GetPhysicsObject()
			if IsValid(physObj) then
				physObj:EnableGravity(ent.WasGravityEnabled)
				ent.WasGravityEnabled = nil
			end
		end
	end
	ply.GravEnts = nil

	-- Effect data
	local effectdata = EffectData()
	effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
	util.Effect("effect_fo3_teslahit", effectdata)

	ply:EmitSound("ambient/levels/labs/electric_explosion" .. math.random(1, 5) .. ".wav", 60, 65, 0.75)

	timer.Simple(0.1, function()
		ply:StopSound("ambient/energy/force_field_loop1.wav")
	end)
end

hook.Add("PlayerDisconnected", "PsykersForcefield", Psykers.StopForcefield)
hook.Add("PlayerDeath", "PsykersForcefield", Psykers.StopForcefield)

hook.Add("Think", "Psykersforcefield", function()
	for _, ply in ipairs(Psykers.ForcefieldPlayers) do
		local plyCenter = ply:LocalToWorld(ply:OBBCenter())

		for i, ent in ipairs(ents.FindInSphere(plyCenter, Psykers.Config.ForcefieldRadius)) do
			if ent == ply or ent:GetOwner() == ply or ent:GetParent() == ply then continue end

			if Psykers.Config.ForcefieldEnts[ent:GetClass()] then
				if !ent.HasBeenReflected then
					local curPos = ent:GetPos()
					local curAng = ent:GetAngles()

					local effect = EffectData()
					effect:SetOrigin(curPos)
					effect:SetNormal(curAng:Forward())

					local entEffect = ents.Create("mr_effect27")
					entEffect:SetPos(curPos)
					entEffect:SetAngles(curAng)
					entEffect:Spawn()

					timer.Simple(1 / 2, function()
						if IsValid(entEffect) then
							entEffect:Remove()
						end
					end)

					util.Effect("AR2Impact", effect)
					util.Effect("cball_bounce", effect)

					sound.Play("vehicles/Airboat/pontoon_impact_hard" .. math.random(1, 2) .. ".wav", curPos, 110, 100, 1.3)

					local v = 0.25
					local physObj = ent:GetPhysicsObject()
					local curVelocity = ent:GetVelocity()
					local curDir = curVelocity:GetNormalized()
					local curSpeed = curVelocity:Length()
					local oppositeDir = curDir - (curDir * 2)
					local newDir = Vector(math.Rand(oppositeDir.x - v, oppositeDir.x + v), math.Rand(oppositeDir.y - v, oppositeDir.y + v), math.Rand(oppositeDir.z - v, oppositeDir.z + v))
					local newVelocity = newDir * (curSpeed * 0.85)

					ent:SetVelocity(newVelocity)
					ent:SetAngles(newDir:Angle())
					if IsValid(physObj) then
						physObj:SetVelocity(newVelocity)
					end

					ent.HasBeenReflected = true
				end
			elseif ent:GetClass() == "prop_physics" or ent:IsVehicle() then
				local physObj = ent:GetPhysicsObject()

				if IsValid(physObj) then
					if ent:GetPos():Distance(plyCenter) > Psykers.Config.ForcefieldRadius then
						if ent.WasGravityEnabled != nil then
							ent.WasGravityEnabled = physObj:EnableGravity(ent.WasGravityEnabled)
							ent.WasGravityEnabled = nil
							table.RemoveByValue(ply.GravEnts, ent)
						end
					else
						if !ent.HasBeenSlowed then
							physObj:SetVelocity(physObj:GetVelocity() / 3)
							ent.HasBeenSlowed = true
						end

						if ent.WasGravityEnabled == nil then
							ent.WasGravityEnabled = physObj:IsGravityEnabled()
							physObj:EnableGravity(false)
							table.insert(ply.GravEnts, ent)
						end
					end
				end
			end
		end
	end
end)

-- Teleportation
function Psykers.TeleportEffectStart(ply)
	jlib.Zap(ply)

	local attachment = ply:LookupAttachment("chest")
	ParticleEffectAttach("nr_jetflame_basetrail", PATTACH_POINT_FOLLOW, ply, attachment)
	ParticleEffectAttach("mr_portal_entrance", PATTACH_POINT_FOLLOW, ply, attachment)

	timer.Simple(0.3, function()
		ParticleEffectAttach("super_shlrd", PATTACH_POINT_FOLLOW, ply, attachment)
		timer.Simple(0.1,  function()
			ply:StopParticles()
		end)
	end)
end

function Psykers.TeleportEffectEnd(ply)
	ply:StopParticles()

	for i, target in ipairs(player.GetAll()) do
		if target:GetPos():DistToSqr(ply:GetPos()) < Psykers.Config.TeleportFlashRangeSqrd then
			target:ScreenFade(SCREENFADE.IN, Color(32, 174, 245, 160), 0.6, 0)
		end
	end
end

function Psykers.Teleport(ply)
	local aimVec = ply:GetAimVector()
	local curPos = ply:GetPos()
	local eyePos = ply:EyePos()
	local tr = util.QuickTrace(eyePos, aimVec * Psykers.Config.TeleportDist, ply)

	local newPos
	if tr.Hit then
		local dist = eyePos:Distance(tr.HitPos)

		if dist > Psykers.TeleportBackup + 16 then
			newPos = curPos + (aimVec * (dist - Psykers.TeleportBackup))
		end
	else
		newPos = curPos + (aimVec * Psykers.Config.TeleportDist)
	end

	if newPos then
		newPos.z = curPos.z

		local mins, maxs = ply:LocalToWorld(ply:OBBMins()), ply:LocalToWorld(ply:OBBMaxs())
		for i, vec in ipairs(jlib.MinMaxToVertices(mins, maxs)) do
			if !util.IsInWorld(newPos) then
				return false
			end
		end

		Psykers.TeleportEffectStart(ply)

		timer.Simple(0.2, function()
			ply:SetPos(newPos + Vector(0,0,15))
			Psykers.TeleportEffectEnd(ply)
		end)

		return true
	end

	return false
end
