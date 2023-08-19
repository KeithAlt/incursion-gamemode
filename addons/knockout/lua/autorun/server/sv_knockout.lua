util.AddNetworkString("KnockoutStartCuff")
util.AddNetworkString("KnockoutStopCuff")

local PLAYER = FindMetaTable("Player")

function PLAYER:Knockout(attacker, forcedAttack, durOverride)
	if self.IsKnockedout then return end
	self:EmitSound("fx/bullet/impact/flesh/fx_bullet_impact_flesh02.mp3")
	self:falloutNotify("[ ! ] You've fallen unconcious . . .", "ui/addicteds.mp3")

	jlib.Announce(self, Color(255,0,0), "[NOTICE] ",
		Color(255,155,155), "Knockout Information:",
		Color(255,255,255), "\n· You can't speak in-character whatsoever while unconcious",
		"\n· Communicating via Discord or other is meta-game & bannable",
		"\n· If you awake and are kidnapped, you must comply"
	)

	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll.IsKnockoutDoll = true
	ragdoll.Ply = self
	ragdoll:SetModel(self:GetModel())
	ragdoll:SetPos(self:GetPos())
	ragdoll:SetAngles(self:GetAngles())
	ragdoll:Spawn()
	ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	if attacker then
		if forcedAttack then
			ragdoll:GetPhysicsObject():SetVelocity(attacker:GetAimVector() * 6000)
		else
			ragdoll:GetPhysicsObject():SetVelocity(attacker:GetAimVector() * 1700)
		end
	end

	self.OldActiveWep = self:GetActiveWeapon()
	if !self:HasWeapon(knockoutConfig.forcedWeapon) then
		self:Give(knockoutConfig.forcedWeapon)
	end
	self:SetActiveWeapon(self:GetWeapon(knockoutConfig.forcedWeapon))

	self:Lock()
	self:SetParent(ragdoll)
	self:SetNoDraw(true)
	self:SetNotSolid(true)

	self.KnockoutDoll = ragdoll
	self:SetNWEntity("KnockoutDoll", ragdoll)

	timer.Create("KnockoutTimer" .. self:SteamID64(), durOverride or forcedAttack and knockoutConfig.chanceKnockoutTime or knockoutConfig.knockoutTime, 1, function()
		if !IsValid(self) then
			ragdoll:Remove()
			return
		end

		self:UnKnockout()

		if IsValid(ragdoll.Cuff) then
			ragdoll.Cuff:DoHandcuff(self)
			ragdoll:EmitSound("buttons/lever7.wav")
		end
	end)

	timer.Simple(0, function() -- ScreenFade() ran twice on the same tick will cause a client crash: Prevents multiple calls of Knockout() crashing client
		self:ScreenFade(SCREENFADE.STAYOUT, Color(0, 0, 0, 255), 0, 0)
	end)

	self.IsKnockedout = true

	hook.Run("PlayerKnockedOut", self, attacker)

	-- Renders attachments, head, and arms on ragdoll
	timer.Simple(0.25, function()
		for k, client in pairs(player.GetAll()) do
			netstream.Start(client, "knockoutRagdollRender", self, self.Accessories)
		end
	end)
end

function PLAYER:UnKnockout()
	if !IsValid(self.KnockoutDoll) then return end
	local ragdoll = self.KnockoutDoll
	self:falloutNotify("You awake from unconciousness...", "fallout/chems/ui_health_chems_wearoff.wav")

	timer.Simple(0, function() -- ScreenFade() ran twice on the same tick will cause a client crash: Prevents multiple calls of UnKnockout() crashing client
		self:ScreenFade(SCREENFADE.PURGE, Color(255, 255, 255, 255), 0.1, 0)
	end)

	self:UnLock()
	self:SetParent()
	self:SetNoDraw(false)
	self:SetNotSolid(false)
	self:SetPos(ragdoll:GetPos() + Vector(0, 0, 10))

	self.WasCustomCollisions = nil
	self.IsKnockedout = nil

	if IsValid(self.OldActiveWep) then
		self:SetActiveWeapon(self.OldActiveWep)
	end

	ragdoll:Remove()
	self.KnockoutDoll = nil
	self:SetNWEntity("KnockoutDoll", NULL)

	hook.Run("PlayerUnKnockedOut", self)
end

function PLAYER:IsBehind(target)
	local attacker = self

	local results = ents.FindInCone(target:GetPos(), -target:GetAimVector(), 150, 0.2)
	for _, ent in ipairs(results) do
		if ent == attacker then return true end
	end

	return false
end

local painSounds = {
	Sound("vo/npc/male01/pain01.wav"),
	Sound("vo/npc/male01/pain02.wav"),
	Sound("vo/npc/male01/pain03.wav"),
	Sound("vo/npc/male01/pain04.wav"),
	Sound("vo/npc/male01/pain05.wav"),
	Sound("vo/npc/male01/pain06.wav")
}

hook.Add("EntityTakeDamage", "KnockoutDamage", function(ent, dmg)
	if ent.IsKnockoutDoll and IsValid(ent.Ply) and dmg:GetAttacker():IsPlayer() and dmg:GetDamageType() != DMG_CRUSH then
		local dmgAmt = dmg:GetDamage()
		ent.Ply:SetHealth(ent.Ply:Health() - dmgAmt)

		local painSound = hook.Run("GetPlayerPainSound", ent.Ply) or table.Random(painSounds)
		if ent.Ply:isFemale() and !painSound:find("female") then
			painSound = painSound:gsub("male", "female")
		end

		ent:EmitSound(painSound)

		if ent.Ply:Health() <= 0 then
			ent:Remove()
			ent.Ply:UnKnockout()
			ent.Ply:TakeDamage(ent.Ply:GetMaxHealth(), dmg:GetAttacker(), dmg:GetInflictor())
			ent.Ply:Spawn()
		end
	end
end)

local cuffRange = 50
local cuffRangeSqr = cuffRange ^ 2

local function EndCuff(attacker, target)
	net.Start("KnockoutStopCuff")
	net.Send(attacker)

	local wep = attacker:GetActiveWeapon()

	if !string.match(wep:GetClass(), "_cuff_") then
		return
	end

	target.Cuff = wep
	attacker:EmitSound("buttons/lever7.wav")
	attacker:falloutNotify("[!] You've cuffed the unconcious person")
	target.Ply:falloutNotify("[!] You've been handcuffed!", "ui/badkarma.ogg")
	target.Ply:UnKnockout()
	wep:DoHandcuff(target.Ply)
end

local function StartCuff(attacker, target)
	net.Start("KnockoutStartCuff")
	net.Send(attacker)

	local hookID = "CuffThink" .. attacker:SteamID64()
	local wep = attacker:GetActiveWeapon()

	if !string.match(wep:GetClass(), "_cuff_") then
		return
	end

	if hook.GetTable().Think[hookID] then
		return
	end

	local elapsedTime = 0
	hook.Add("Think", hookID, function()
		elapsedTime = elapsedTime + FrameTime()

		if !IsValid(attacker) or !IsValid(target) or !IsValid(target.Ply) or attacker:GetEyeTrace().Entity != target or attacker:GetPos():DistToSqr(target:GetPos()) > cuffRangeSqr or !IsValid(wep) or wep != attacker:GetActiveWeapon() then
			hook.Remove("Think", hookID)

			if IsValid(attacker) then
				net.Start("KnockoutStopCuff")
				net.Send(attacker)
			end

			return
		end

		if elapsedTime >= knockoutConfig.cuffTime then
			hook.Remove("Think", hookID)
			EndCuff(attacker, target)
		end
	end)
end

hook.Add("KeyPress", "KnockoutRestrain", function(ply, key)
	if key == IN_ATTACK then
		local wep = ply:GetActiveWeapon()
		if !IsValid(wep) then return end
		if !string.match(wep:GetClass(), "_cuff_") then return end
		
		//local tr = ply:GetEyeTraceNoCursor()
        local tr = util.TraceHull( {
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ( ply:GetAimVector() * 96 ),
            filter = ply,
            mins = Vector( -50, -50, 0 ),
            maxs = Vector( 50, 50, 71 )
        } )
		local ent = tr.Entity

		if IsValid(wep) and IsValid(ent) and ent.IsKnockoutDoll and !ent.Cuff then
			StartCuff(ply, ent)
		end
	end
end)


local meleeTypes = {
	[DMG_CLUB] = true,
	[DMG_SLASH] = true,
}
// melee types

hook.Add("ScalePlayerDamage", "Knockout", function(target, hitgroup, dmg)
	local attacker = dmg:GetAttacker()
	if !meleeTypes[dmg:GetDamageType()] or !target:IsPlayer() or !IsValid(attacker) or !attacker:IsPlayer() or knockoutConfig.immunity[target:SteamID()] then return end
	local wep = attacker:GetActiveWeapon()
	if !IsValid(wep) then return end

	if pk_pills and IsValid(pk_pills.getMappedEnt(target)) then return end

	if knockoutConfig.weps[wep:GetClass()] then
		local knockout = attacker:hasSkerk("knockout")
		local knockoutchance = attacker:hasSkerk("knockoutchance")

		local hasPA = target:WearingPA()
		if hitgroup == HITGROUP_HEAD and attacker:IsBehind(target) and (knockout == 2 or (knockout == 1 and !hasPA)) then
			if knockout == 2 and hasPA and !attacker:GetNWBool("chargemaxxxed") then -- Checking if the melee weapon is fully charged
				attacker:falloutNotify("You must charge your melee strike to KO a PA user!", "ui/notify.mp3")
			else
				dmg:SetDamage(0)
				target:Knockout(attacker)
				return
			end
		end

		if knockoutchance then
			local chance = knockoutConfig.knockoutChance[knockoutchance] / 100
			local maxSkill = table.Count(knockoutConfig.skerks)

			if target:WearingPA() then
				if knockoutchance < maxSkill then
					return
				end

				chance = chance - (knockoutConfig.powerArmorPenalty / 100)
			end

			local num = math.random()

			if num < chance or (knockoutchance >= maxSkill and num < (knockoutConfig.chargedKnockoutChance / 100) and attacker:GetNWBool("chargemaxxxed")) then
				target:Knockout(attacker, true)
			end
		end
	end
end)

local function NoSwep(ply)
	if !ply:Alive() or ply.IsKnockedout then return false end
end
hook.Add("PlayerSpawnSWEP", "KnockoutSWEP", NoSwep)
hook.Add("PlayerGiveSWEP", "KnockoutSWEP", NoSwep)
hook.Add("PlayerCanPickupWeapon", "KnockoutSWEP", NoSwep)

hook.Add("PlayerCanHearPlayersVoice", "KnockoutMute", function(listener, talker)
	if talker.IsKnockedout or listener.IsKnockedout then return false end
end)
