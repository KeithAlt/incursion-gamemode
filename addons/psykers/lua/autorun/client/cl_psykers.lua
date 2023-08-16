-- jSettings binders
function Psykers.AddBinder(abilityID)
	local key = "Has" .. abilityID .. "Binder"

	if !Psykers[key] then
		jSettings.AddBinder("Binds", jlib.UpperFirstChar(abilityID) .. " Psyker", {Psykers.GetFullID(abilityID)})
		Psykers[key] = true
	end
end

net.Receive("PsykersGiveBinder", function()
	local abilityID = net.ReadString()
	Psykers.AddBinder(abilityID)
end)

-- Forcefield
Psykers.ForcefieldPlayers = Psykers.ForcefieldPlayers or {}
Psykers.BulletEnts = Psykers.BulletEnts or {}
Psykers.Materials = {
	Color = Material("models/effects/hexshield_color"),
	Reflect = Material("models/effects/hexshield_reflect"),
	Refract1 = Material("models/effects/hexshield_refract"),
	Refract2 = Material("effects/hexshield/hexshield_r1")
}
Psykers.OriginalModelRadius = 67.4

hook.Add("InitPostEntity", "ForcefieldSync", function()
	for i, ply in ipairs(player.GetAll()) do
		if ply:GetNW2Bool("forcefieldEnabled", false) then
			Psykers.ForcefieldPlayers[ply] = true
		end
	end
end)

function Psykers.CreateBullet(pos, ang, ply)
	-- Hacky parenting method since just using SetParent makes the bullets
	-- move around according to the local player's aim vector
	if ply == LocalPlayer() and !IsValid(ply.CenterParent) then
		local centerParent = ClientsideModel("models/hunter/misc/sphere025x025.mdl")
		centerParent:SetNoDraw(true)
		ply.CenterParent = centerParent
	end

	local bullet = ClientsideModel(Psykers.Config.BulletModel)
	bullet:SetPos(pos)
	bullet:SetAngles(ang)
	bullet:Spawn()
	bullet:SetParent(IsValid(ply.CenterParent) and ply.CenterParent or ply)
	bullet:CallOnRemove("BulletRemoved", function(ent)
		table.remove(Psykers.BulletEnts, ent.ID)
	end)

	bullet.ID = table.insert(Psykers.BulletEnts, bullet)

	SafeRemoveEntityDelayed(bullet, Psykers.Config.BulletLife)

	if #Psykers.BulletEnts > Psykers.Config.MaxBullets then
		local ent = Psykers.BulletEnts[1]

		table.remove(Psykers.BulletEnts, 1)

		if IsValid(ent) then
			ent:Remove()
		end
	end

	return bullet
end

function Psykers.ForcefieldImpact(hitPos, shooter, forcefieldUser, shouldBullet)
	local hitAng = (shooter:IsPlayer() and shooter:GetAimVector() or shooter:GetForward()):Angle()
	local bullet = Psykers.CreateBullet(hitPos, hitAng, forcefieldUser)
	Psykers.ForcefiledHitEffects(hitPos, hitAng, bullet)

	-- We still need something to parent the particles to and the player wont do
	-- because then it will stop all particles at once when StopParticles is called
	if !shouldBullet then
		bullet:SetNoDraw(true)
	end

	sound.Play("physics/metal/metal_box_impact_bullet" .. math.random(1, 3) .. ".wav", hitPos, 75, 100, 0.8)
	sound.Play("weapons/physcannon/energy_sing_flyby" .. math.random(1, 2) .. ".wav", hitPos, 75, 80, 0.8)
	//sound.Play("weapons/physcannon/energy_sing_loop4.wav", hitPos, 75, 85, 0.4)
end

net.Receive("PsykersForcefieldImpact", function()
	local shooter = net.ReadEntity()
	local forcefieldUser = net.ReadEntity()
	local hitPos = net.ReadVector()
	local shouldBullet = net.ReadBool()

	if IsValid(shooter) and shooter != LocalPlayer() and IsValid(forcefieldUser) then
		local ourHitPos = jlib.RaySphereIntersection(forcefieldUser:LocalToWorld(forcefieldUser:OBBCenter()), Psykers.Config.ForcefieldRadius, shooter:EyePos(), shooter:IsPlayer() and shooter:GetAimVector() or shooter:GetForward(), shooter)
		hitPos = ourHitPos or hitPos

		Psykers.ForcefieldImpact(hitPos, shooter, forcefieldUser, shouldBullet)
	end
end)

function Psykers.FadeForcefield(forcefield, time, out)
	forcefield.StartFade = forcefield.StartFade or CurTime()

	local weight = 1 - (CurTime() - forcefield.StartFade) / time

	for i = 0, 20 do
		forcefield:SetFlexWeight(i, weight)
	end

	if weight < 0 or weight > 1 then
		forcefield.HasFadedIn = true
		forcefield.StartFade = nil
	end
end

function Psykers.StopForcefield(ply)
	table.RemoveByValue(Psykers.ForcefieldPlayers, ply)
	if IsValid(ply.ForcefieldEnt) then
		ply.ForcefieldEnt:Remove()
	end

	if IsValid(ply.CenterParent) then
		ply.CenterParent:Remove()
	end

	ply:StopParticles()
	ply:StopSound("ambient/energy/force_field_loop1.wav")
end

net.Receive("PsykersForcefieldAddPlayer",  function()
	table.insert(Psykers.ForcefieldPlayers, net.ReadEntity())
end)

net.Receive("PsykersForcefieldRemovePlayer",  function()
	Psykers.StopForcefield(net.ReadEntity())
end)

hook.Add("PostDrawTranslucentRenderables", "PsykersForcefield", function(depth, skybox)
	if !skybox then
		if Psykers.Config.ForcefieldRainbow then
			Psykers.Config.ForcefieldColor = jlib.Rainbow(10)
		end

		if Psykers.Config.ForcefieldRefract then
			render.UpdateRefractTexture()
		end

		local toRemove = {}

		for _, ply in ipairs(Psykers.ForcefieldPlayers) do
			if !IsValid(ply) then
				toRemove[#toRemove + 1] = ply
				continue
			end

			local plyCenter = ply:GetPos() + ply:OBBCenter()

			if !IsValid(ply.ForcefieldEnt) then
				ply.ForcefieldEnt = ClientsideModel("error.mdl", RENDERGROUP_TRANSLUCENT)
			end

			if !ply.ForcefieldEnt.HasFadedIn then
				Psykers.FadeForcefield(ply.ForcefieldEnt, 0.8)
			end

			ply.ForcefieldEnt:SetModelScale(Psykers.Config.ForcefieldRadius / Psykers.OriginalModelRadius)

			if Psykers.Config.ForcefieldRefract then
				render.Model({model = "models/effects/hexshield.mdl", pos = plyCenter, angle = Angle(0, 0, 0)}, ply.ForcefieldEnt)
			end

			Psykers.Materials.Color:SetVector("$color2", Vector(Psykers.Config.ForcefieldColor.r / 255, Psykers.Config.ForcefieldColor.g / 255, Psykers.Config.ForcefieldColor.b / 255))
			local blend = render.GetBlend()
			render.SetBlend(0.0275)
				render.MaterialOverride(Psykers.Materials.Color)
				render.Model({model = "models/effects/hexshield.mdl", pos = plyCenter, angle = Angle(0, 0, 0)}, ply.ForcefieldEnt)
				render.MaterialOverride(nil)
			render.SetBlend(blend)

			Psykers.Materials.Reflect:SetVector("$envmapint", Vector((Psykers.Config.ForcefieldColor.r + 1) / 2, (Psykers.Config.ForcefieldColor.g + 1) / 2, (Psykers.Config.ForcefieldColor.b + 1) / 2))
			render.MaterialOverride(Psykers.Materials.Reflect)
			render.Model({model = "models/effects/hexshield_b.mdl", pos = plyCenter, angle = Angle(0, 0, 0)}, ply.ForcefieldEnt)
			render.MaterialOverride(nil)

			local centerParent = ply.CenterParent
			if IsValid(centerParent) then
				centerParent:SetPos(ply:GetPos() + ply:OBBCenter())
			end
		end

		for i, ply in ipairs(toRemove) do
			Psykers.StopForcefield(ply)
		end
	end
end)
