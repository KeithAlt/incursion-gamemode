util.AddNetworkString("BountyHuntingRequest")
util.AddNetworkString("BountyHuntingFootstep")
util.AddNetworkString("BountyHuntingClearSteps")
util.AddNetworkString("BountyHuntingAccept")
util.AddNetworkString("BountyHuntingDecline")
util.AddNetworkString("BountyHeadCollect")
util.AddNetworkString("BountyHeadHalt")
util.AddNetworkString("BountyStartBoost")
util.AddNetworkString("BountyStopBoost")
--util.AddNetworkString("PKForceNameChange")
--util.AddNetworkString("PKSubmitNameChange")

--Send assets to client
/**
for _, file in pairs(file.Find("materials/bountyhunting/*", "GAME")) do
    resource.AddFile("materials/bountyhunting/" .. file)
end
**/

--General bounty handling
BountyHunting.Bounties = BountyHunting.Bounties or {}
BountyHunting.BountyHistory = BountyHunting.BountyHistory or {}

function BountyHunting.StartBounty(hunter, target, customer, price)
    if IsValid(hunter) and IsValid(target) and IsValid(customer) then
        local custChar = customer:getChar()
        custChar:giveMoney(-price)
        custChar:save() --Always save since we do refunds if the server crashes

        hunter:SetTarget(target)
        target:SetHunter(hunter)

        BountyHunting.Bounties[target:SteamID64()] = {
            hunter = hunter,
            price = price,
            customer = customer,
            customerCharID = customer:getChar():getID()
        }
        BountyHunting.BountyHistory[target:SteamID64()] = CurTime()

        file.Write("bountyrefunds.json", util.TableToJSON(BountyHunting.Bounties))

        //ULogs.AddLog(BountyHunting.LogID, hunter:Nick() .. " accepted a bounty placed on " .. target:Nick() .. " from " .. customer:Nick(), ULogs.Register(BountyHunting.LogID, hunter), ULogs.GetDate())
    end
end

function BountyHunting.TerminateBounty(hunter, reason)
    local target = hunter:GetTarget()
    local bounty = BountyHunting.Bounties[target:SteamID64()]
    local customer = bounty.customer

    hunter:SetTarget(NULL)
    target:SetHunter(NULL)

    BountyHunting.ClearSteps(hunter)

    if IsValid(customer) then
        nut.char.loaded[bounty.customerCharID]:giveMoney(bounty.price)
        customer:notify("The bounty you set on " .. target:Nick() .. " has been cancelled because " .. reason .. ".")
    else
        BountyHunting.OfflineRefund(bounty.price, bounty.customerCharID)
    end

    if IsValid(hunter) then
        hunter:notify("The bounty you accepted on " .. target:Nick() .. " has been cancelled because " .. reason .. ".")
    end

    BountyHunting.Bounties[target:SteamID64()] = nil

    file.Write("bountyrefunds.json", util.TableToJSON(BountyHunting.Bounties))

    //ULogs.AddLog(BountyHunting.LogID, hunter:Nick() .. " failed a bounty placed on " .. target:Nick(), ULogs.Register(BountyHunting.LogID, hunter), ULogs.GetDate())
	target.HasBeenHunted = nil
end

function BountyHunting.CompleteBounty(hunter)
    local target = hunter:GetTarget()
    local bounty = BountyHunting.Bounties[target:SteamID64()]
    local customer = bounty.customer

    hunter:getChar():giveMoney(bounty.price)

    hunter:SetTarget(NULL)
    target:SetHunter(NULL)

    BountyHunting.ClearSteps(hunter)

    if IsValid(bounty.customer) and bounty.customer:getChar() and bounty.customer:getChar():getID() == bounty.customerCharID then
        bounty.customer:notify("The bounty you placed on " .. target:Nick() .. " has been completed!")
    end
    hunter:notify("You have been awarded " .. bounty.price .. " caps for completing the bounty.")

    BroadcastLua("chat.AddText(Color(255,165,0), '[BOUNTY] ', Color(255,218,72), 'A bounty hunter has claimed their prize . . .')")

    BountyHunting.Bounties[target:SteamID64()] = nil

    file.Write("bountyrefunds.json", util.TableToJSON(BountyHunting.Bounties))

	//ULogs.AddLog(BountyHunting.LogID, hunter:Nick() .. " completed a bounty placed on " .. target:Nick() .. " by " .. (IsValid(customer) and customer:Nick() or bounty.customerCharID), ULogs.Register(BountyHunting.LogID, hunter), ULogs.GetDate())
	target.HasBeenHunted = nil
end

hook.Add("PlayerDeath", "BountyHuntingSuccess", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and attacker:GetTarget() == victim and BountyHunting.Bounties[victim:SteamID64()] then
		attacker:notify("You have successfully killed your target. You must collect their head to gain your reward.")
		jlib.Announce(victim, Color(255,0,0), "[NOTICE] ", Color(255,200,200), "You were assassinated by a bounty hunter!", Color(255,255,255), "\n· This was not RDM")
		nut.leveling.giveXP(attacker, 20) // Reward for killing target
		BroadcastLua("chat.AddText(Color(255,165,0), '[BOUNTY] ', Color(255,218,72), 'A bounty hunter has eliminated a target . . .')")
    end
end)

hook.Add("EntityTakeDamage", "BountyHuntingHunterDMG", function(ent, dmg)
    local attacker = dmg:GetAttacker()

    if ent:IsPlayer() and IsValid(attacker) and attacker:IsPlayer() then
        ent.LastAttacked = CurTime()
    end
end)

hook.Add("PlayerDeath", "BountyHuntingTerminate", function(victim, inflictor, attacker)
    if IsValid(victim:GetTarget()) and ((IsValid(attacker) and attacker:IsPlayer()) or (victim.LastAttacked and CurTime() - victim.LastAttacked <= BountyHunting.Config.DmgTime)) then
        BountyHunting.TerminateBounty(victim, "the hunter failed")
    end
end)

hook.Add("PlayerDisconnected", "BountyHuntingTerminate", function(ply)
    if IsValid(ply:GetTarget()) then
        BountyHunting.TerminateBounty(ply, "the hunter has vanished")
    end

    if IsValid(ply:GetHunter()) then
		--If they have been killed by the hunter and the head has yet to be collected just complete the bounty if they leave
		if IsValid(ply.jDoll) and !ply.jDoll.HeadCollected and ply.HasBeenHunted then
			BountyHunting.CompleteBounty(ply:GetHunter())
		else
			BountyHunting.TerminateBounty(ply:GetHunter(), "the target has vanished")
		end
    end
end)

hook.Add("PlayerLoadedChar", "BountyHuntingTerminate", function(ply, char, oldChar)
    if IsValid(ply:GetTarget()) then
        BountyHunting.TerminateBounty(ply, "the hunter has vanished")
    end

    if IsValid(ply:GetHunter()) then
		if IsValid(ply.jDoll) and !ply.jDoll.HeadCollected and ply.HasBeenHunted then
			BountyHunting.CompleteBounty(ply:GetHunter())
		else
			BountyHunting.TerminateBounty(ply:GetHunter(), "the target has vanished")
		end
    end
end)

--Footstep networking
function BountyHunting.SendFootstep(target, pos, ang, hunter, foot)
    local players = RecipientFilter()

    local group = hunter:GetGroup()
    if group then
        for ply, rank in pairs(group:GetPlayers()) do
			if !ply:IsBountyHunter() then
            	players:AddPlayer(ply)
			end
        end
    else
        players:AddPlayer(hunter)
    end

    net.Start("BountyHuntingFootstep")
        net.WriteEntity(target)
        net.WriteVector(pos)
        net.WriteAngle(ang)
        net.WriteBool(foot == 1)
    net.Send(players)
end

function BountyHunting.ClearSteps(ply)
    net.Start("BountyHuntingClearSteps")
    net.Send(ply)
end

hook.Add("PlayerFootstep", "BountyHuntingFootstep", function(ply, pos, foot, sound, vol, filter)
    local hunter = ply:GetHunter()
    if IsValid(hunter) then
        BountyHunting.SendFootstep(ply, pos, ply:EyeAngles(), hunter, foot)
    end
end)

--Bounty request networking
net.Receive("BountyHuntingRequest", function(len, ply)
	if ply:IsBountyHunter() then
		ply:notify("You cannot request bounties while you are also a bounty hunter!")
		return
	end

    local target = net.ReadEntity()
    local hunter = net.ReadEntity()
    local price = net.ReadUInt(32)
    local reason = jlib.ReadCompressedString()
    local location = jlib.ReadCompressedString()

    if IsValid(hunter) and hunter:IsPlayer() and hunter:IsBountyHunter() and !IsValid(hunter:GetTarget()) and !IsValid(target:GetHunter()) then
        local lastContractTime = BountyHunting.BountyHistory[target:SteamID64()]
        if !lastContractTime or CurTime() - lastContractTime > BountyHunting.Config.TargetCooldown then
            net.Start("BountyHuntingRequest")
                net.WriteEntity(target)
                net.WriteEntity(ply)
                net.WriteUInt(price, 32)
                jlib.WriteCompressedString(reason)
                jlib.WriteCompressedString(location)
            net.Send(hunter)

			ply.RequestingHitFrom = ply.RequestingHitFrom or {}
			ply.RequestingHitFrom[hunter] = {time = CurTime(), price = price, target = target}

			ply:notify("Request sent!")
        else
            ply:notify("This target has been hunted recently try again in " .. string.NiceTime(BountyHunting.Config.TargetCooldown - (CurTime() - lastContractTime)) .. ".")
        end
    end
end)

net.Receive("BountyHuntingAccept", function(len, ply)
	local customer = net.ReadEntity()

	if !ply:IsBountyHunter() then
		ply:notify("You are not a bounty hunter!")
		return
	end

	if !customer.RequestingHitFrom or !customer.RequestingHitFrom[ply] then
		ply:notify("Failed to accept bounty, customers request not found")
		return
	end

	local request = customer.RequestingHitFrom[ply]

	if CurTime() - request.time > 60 then
		ply:notify("Failed to accept bounty, request timed out")
		return
	end

	if ply == customer then
		ply:notify("You can't accept a bounty on yourself!")
		return
	end

	if customer:IsBountyHunter() then
		ply:notify("You cannot accept bounties from another bounty hunter!")
		return
	end

	local target = request.target
	local price = request.price

	if IsValid(target:GetHunter()) then
		ply:notify("This target is already being hunted.")
		return
	end

	local lastContractTime = BountyHunting.BountyHistory[target:SteamID64()]
	if lastContractTime and CurTime() - lastContractTime < BountyHunting.Config.TargetCooldown then
		ply:notify("This target has been hunted recently try again in " .. string.NiceTime(BountyHunting.Config.TargetCooldown - (CurTime() - lastContractTime)) .. ".")
		return
	end

    BountyHunting.StartBounty(ply, target, customer, price)

	ply:ChatPrint("Successfully accepted bounty. You can review the contract details again at any time by pressing F6.")
    if IsValid(customer) then
        customer:notify(ply:Nick() .. " has accepted your bounty offer on " .. target:Nick() .. ".")
	end

	customer.RequestingHitFrom[ply] = nil
end)

net.Receive("BountyHuntingDecline", function(len, ply)
    local customer = net.ReadEntity()

    if IsValid(customer) then
        customer:notify(ply:Nick() .. " has declined your bounty offer.")
    end
end)

--Bounty refunds in the event of a server crash
function BountyHunting.OfflineRefund(refundAmt, refundCharID)
    nut.db.query("SELECT _money FROM nut_characters WHERE _id = " .. refundCharID .. ";", function(result)
        local money = tonumber(result[1]._money)
        local newMoney = money + refundAmt
        nut.db.query("UPDATE nut_characters SET _money = " .. newMoney .. " WHERE _id = " .. refundCharID .. ";")
    end)
end

hook.Add("InitPostEntity", "BountyHuntingRefunds", function()
    local bountiesToRefund = util.JSONToTable(file.Read("bountyrefunds.json") or "[]")

    for targetSID, bounty in pairs(bountiesToRefund or {}) do
        print("Refunding character with ID " .. bounty.customerCharID .. " " .. bounty.price .. " for an incomplete bounty.")
        BountyHunting.OfflineRefund(bounty.price, bounty.customerCharID)
    end

    file.Write("bountyrefunds.json", "[]")
end)

--Head collection
BountyHunting.MinHeadDist = 40
BountyHunting.MinHeadDistSqr = BountyHunting.MinHeadDist ^ 2
hook.Add("KeyPress", "BountyHeadCollection", function(ply, key)
	if key == IN_USE then
		local tr = ply:GetEyeTraceNoCursor()
		local ragdoll = tr.Entity
		local victim = ragdoll.Ply

		if ply == victim then
			ply:notify("You cannot collect your own head!")
			return
		end

		local NoHead
		if IsValid(victim) and victim:IsPlayer() then
			NoHead = BountyHunting.Config.NoHead[nut.faction.indices[victim:getChar():getFaction()].uniqueID]
		end

		if IsValid(ragdoll) and ragdoll.IsjDoll and IsValid(victim) and !ragdoll.HeadCollected and
		ply:GetPos():DistToSqr(ragdoll:GetPos()) < BountyHunting.MinHeadDistSqr and
		(!NoHead or ply:IsBountyHunter()) then
			local name = victim:Nick()
			local time = BountyHunting.Config.HeadCollectionTime
			net.Start("BountyHeadCollect")
			net.Send(ply)

			local id = "HeadCollection" .. ply:SteamID64()

			local wep = ply:GetActiveWeapon()
			if IsValid(wep) and wep.Base and wep.Base == "dangumeleebase" then
				time = BountyHunting.Config.HeadCollectionTime / 5
			end

			timer.Create(id, time, 1, function()
				hook.Remove("Think", id)

				if IsValid(wep) and wep.Base and wep.Base == "dangumeleebase" then
					ply:EmitSound("slash1.wav")
					ply:ConCommand("say /me swiftly decapitates the corpse using their " .. (string.lower(wep.PrintName) or "weapon") .. " . . .")
				end
	
				if IsValid(ply) then
					local inv = ply:getChar():getInv()
					if !NoHead then
						local classIndex = victim:getChar():getClass()
						local className
						if classIndex then
					    	local classTable = nut.class.list[classIndex]
					    	className = classTable.name
						else
							local factionIndex = victim:getChar():getFaction()

							for _, class in ipairs(nut.class.list) do
								if class.faction == factionIndex and class.isDefault then
									className = class.name
								end
							end
						end

						if className then
							inv:add("playerhead", 1, {headowner = className})
							inv:add("food_human_meat", 1, {headowner = className})
							ply:addKarma(5, 2)
							ply:falloutNotify("⚖ You've lost Karma for defiling a corpse!", "ui/badkarma.ogg")
						end
					end

					//ply:notify("You have collected " .. name .. "'s head!")
					ragdoll.HeadCollected = true
					ragdoll.HeadCollector = ply

					if IsValid(victim) and ply:IsBountyHunter() and ply:GetTarget() == victim then
						BountyHunting.CompleteBounty(ply)
					end

					ragdoll:EmitSound("physics/flesh/flesh_bloody_break.wav", 100)

					local headBone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
					if headBone then
						ragdoll:ManipulateBoneScale(headBone, Vector(0, 0, 0))

						local pos = ragdoll:GetBonePosition(headBone)

						for i = 1, 3 do
							ParticleEffect("blood_impact_red_01", pos, ragdoll:GetAngles())
						end

						for i = 0, 3 do
							timer.Simple(i, function()
								ragdoll:EmitSound("Flesh_Bloody.ImpactHard")
								ParticleEffectAttach("blood_advisor_puncture_withdraw", PATTACH_POINT_FOLLOW, ragdoll, 1)
							end)
						end
					end
				end
			end)

			hook.Add("Think", id, function()
				if !IsValid(ply) or ply:GetEyeTrace().Entity != ragdoll or ply:GetPos():DistToSqr(ragdoll:GetPos()) > BountyHunting.MinHeadDistSqr then
					hook.Remove("Think", id)
					timer.Remove(id)

					if IsValid(ply) then
						net.Start("BountyHeadHalt")
						net.Send(ply)
					end
				end
			end)
		end
	end
end)

hook.Add("PlayerInitialSpawn", "BountyDeath", function()
	function GAMEMODE:DoPlayerDeath(ply, attacker, dmg)
		local ragdoll = jlib.CreateRagdoll(ply)
		//jlib.SpectateEntity(ply, ragdoll)

		ply.HasBeenHunted = true
		local hunter = ply:GetHunter()
		timer.Simple(BountyHunting.Config.BodyAge, function()
			if IsValid(ply) then
				ply.HasBeenHunted = nil
			end

			if IsValid(ply) and IsValid(hunter) and hunter == attacker and ragdoll.HeadCollector != hunter then
				BountyHunting.TerminateBounty(hunter, "the hunter failed to collect the target's head")
			end

			if IsValid(ragdoll) then
				ragdoll:Remove()
			end
		end)

		ply:AddDeaths(1)

		if attacker:IsValid() and attacker:IsPlayer() then
			if attacker == ply then
				attacker:AddFrags(-1)
			else
				attacker:AddFrags(1)
			end
		end
	end

	hook.Remove("PlayerDeath", "replaceDeathShit")
	hook.Remove("PlayerInitialSpawn", "BountyDeath")
end)

--[[hook.Add("PlayerSpawn", "BountySpawn", function(ply)
	jlib.StopSpectate(ply)
end)]]

--Rocket Boots
local PLAYER = FindMetaTable("Player")

function PLAYER:SetRocketCharge(amt)
	self:SetNWFloat("RocketBootsCharge", math.Clamp(amt, 0, self.MaxRocketCharge))
end

function PLAYER:SetBoosting(boosting)
	local wasBoosting = self:GetNWBool("IsBoosting")

	self:SetNWBool("IsBoosting", boosting)

	if boosting and !wasBoosting then
		self.BoosterSound = self.BoosterSound or CreateSound(self, "PhysicsCannister.ThrusterLoop")
		if !self.BoosterSound:IsPlaying() then
			self.BoosterSound:Play()
		end

		net.Start("BountyStartBoost")
			net.WriteEntity(self)
		net.Broadcast()
	elseif !boosting and wasBoosting then
		if self.BoosterSound and self.BoosterSound:IsPlaying() then
			self.BoosterSound:Stop()
		end

		net.Start("BountyStopBoost")
			net.WriteEntity(self)
		net.Broadcast()
	end
end

--moved to pkdecap plugin
--[[
net.Receive("PKSubmitNameChange", function(len, ply)
	local newName = net.ReadString()
	local oldName = ply:Nick()

	local char = ply:getChar()

	if char then
		char:setName(newName)
		ServerLog(oldName .. " has been PKed and chose '" .. newName .. "' as their new name.\n")
	else
		ply:notify("Failed to find valid character.")
	end
end)
--]]
