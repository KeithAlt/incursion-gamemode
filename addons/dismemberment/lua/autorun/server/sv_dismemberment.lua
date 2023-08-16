function Dismemberment.ScalePlayerDamage(_, ply, hit, dmg)
	if hit == HITGROUP_HEAD and ply:WearingPA() then
		return
	end

	local attacker = dmg:GetAttacker()
	local caliber = Dismemberment.GetDefaultCaliber()

	if attacker:IsPlayer() or attacker:IsNPC() then
		local wep = attacker:GetActiveWeapon()
		caliber = Dismemberment.GetCaliber(wep) or Dismemberment.GetDefaultCaliber()
	end

	dmg:ScaleDamage(caliber.Multipliers[hit] or 1)

	local zone = Dismemberment.GetDismembermentZone(hit)

	if zone then
		local attackerForward = attacker:GetForward()

		timer.Simple(0, function()
			if !ply:Alive() then
				local num = math.random()

				if num <= caliber.LethalDismembermentChance then
					Dismemberment.Dismember(ply, zone.Bone, zone.Attachment, zone.ScaleBones, zone.Gibs, attackerForward)
				end
			end
		end)
	end
end
hook.Add("PostGamemodeLoaded", "DismembermentScalePlayerDamage", function()
	GAMEMODE.ScalePlayerDamage = Dismemberment.ScalePlayerDamage
end)
if GAMEMODE then
	GAMEMODE.ScalePlayerDamage = Dismemberment.ScalePlayerDamage
end

function Dismemberment.Dismember(ply, boneName, attach, scaleBones, gibs, normal)
	local ragdoll = ply:GetRagdollEntity()

	if !IsValid(ragdoll) then return end

	ragdoll:EmitSound("physics/flesh/flesh_bloody_break.wav", 100)

	for i, scaleBoneName in ipairs(scaleBones) do
		local scaleBone = ragdoll:LookupBone(scaleBoneName)
		if scaleBone then
			ragdoll:ManipulateBoneScale(scaleBone, Vector(0, 0, 0))
		end
	end

	local bone = ragdoll:LookupBone(boneName)
	if bone then
		local pos = ragdoll:GetBonePosition(bone)

		for gibMdl, amt in pairs(gibs) do
			for i = 1, amt do
				local gib = ents.Create("dismemberment_gib")
				gib:SetPos(pos + VectorRand())
				gib:SetModel(gibMdl)
				gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				gib:Spawn()
				local physObj = gib:GetPhysicsObject()
				if IsValid(physObj) then
					physObj:SetVelocity(normal * math.random(100, 150))
				end

				timer.Simple(Dismemberment.Config.GibLife, function()
					if IsValid(gib) then
						gib:Remove()
					end
				end)
			end
		end

		for i = 1, 3 do
			ParticleEffect("blood_impact_red_01", pos, ragdoll:GetAngles())
		end

		for i = 0, 3 do
			timer.Simple(i, function()
				ragdoll:EmitSound("Flesh_Bloody.ImpactHard")
				ParticleEffectAttach("blood_advisor_puncture_withdraw", PATTACH_POINT_FOLLOW, ragdoll, attach)
			end)
		end
	end
end

function Dismemberment.QuickDismember(ply, hitgroup, attacker)
	local zone = Dismemberment.GetDismembermentZone(hitgroup)
	Dismemberment.Dismember(ply, zone.Bone, zone.Attachment, zone.ScaleBones, zone.Gibs, IsValid(attacker) and attacker:GetForward() or VectorRand())
end
