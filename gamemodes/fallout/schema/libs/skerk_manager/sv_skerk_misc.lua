util.AddNetworkString("StartSPECIALBuff")

hook.Add("GetFallDamage", "nutSkerkFallDamage", function(entity, speed)
	if (entity:IsPlayer()) then
		local skerk = entity:hasSkerk("nofalldmg")
		if (skerk) then
			if (skerk == 1) then
				return ((speed - 580) * (100 / 444)) / 2
			elseif (skerk == 2) then
				return 0
			end;
		end;
	end;
end)

hook.Add("PlayerDeath", "nutSkerkHealingKill", function(victim, inflictor, attacker)
	local playerAttacker = (inflictor:IsPlayer() and inflictor) or (attacker:IsPlayer() and attacker) or false

	if !isbool(playerAttacker) and (victim:IsPlayer() and playerAttacker:IsPlayer()) then
		local skerk = playerAttacker:hasSkerk("healingkill")

		if (skerk and playerAttacker:getChar():getVar("lastHealKill", 0) <= CurTime()) then
			playerAttacker:SetHealth(math.min(playerAttacker:Health() + (10 * skerk), playerAttacker:GetMaxHealth()))
			playerAttacker:getChar():setVar("lastHealKill", CurTime() + (30 / skerk))
			playerAttacker:SendLua("surface.PlaySound('fallout/skills/healingkill.wav')")
			playerAttacker:ScreenFade(SCREENFADE.IN, Color(0,255,0,10), 0.5, 0.5)
		end;
	end;
end)

--[[hook.Add("CharacterLoaded", "nutSkerkRefund", function(char)
	char = nut.char.loaded[char]
	if (char:getData("specRefund", nil) != 6) then
		local level = char:getData("level", 0)
		if (level > 50) then
			level = 50
			char:setData("level", 50)
		end;
		char:setData("skillPoints", level)
		char:setData("specRefund", 6)
		char:setData("skerks", {})
		char:setData("special", {})
	end;
end)]]

netstream.Hook("NutRespec", function(player)
	local char = player:getChar()
	local level = char:getData("level", 0)
	local reset = char:getData("reset", 0)

	if (level < 50) then
		player:ChatPrint("You must be at least level 50 to respec.")
		return
	end

	if reset > 0 then
		local respecCost = nut.config.get("Respec Price")
		local shouldMultiply = nut.config.get("Respec Cost Multiplier")
		if !shouldMultiply then
			reset = 1 // just make it times by 1 instead.
		end

		if char:hasMoney(respecCost * reset) then
			char:takeMoney(respecCost * reset)
		else
			player:ChatPrint("You don't have enough Caps.")
			return
		end
	end

	char:setData("skillPoints", level + (Armor and Armor.Config.SkillPoints or 0))
	char:setData("skerks", {})
	char:setData("special", {})
	char:setData("reset", reset + 1)
	player:ChatPrint("All skill points have been refunded; All assigned perks and special points have been removed.")
end)

-----------------------------------
local stamDrain = 1.3
hook.Add("PostPlayerLoadout", "nutSherkPlayerLoadout", function(client)
	client:setLocalVar("stm", 100)

	local uniqueID = "nutStam"..client:SteamID()
	local offset = 0

	timer.Create(uniqueID, 0.25, 0, function()
		if (IsValid(client)) then
			local character = client:getChar()

			if (client:GetMoveType() != MOVETYPE_NOCLIP and character) then
				local velocity = client:GetVelocity()
				local length2D = velocity:Length2D()
				local runSpeed = client:GetRunSpeed()
				local walkSpeed = client:GetWalkSpeed()

				if (client:WaterLevel() > 1) then
					runSpeed = runSpeed * 0.775
				end

				if client:KeyDown(IN_SPEED) and runSpeed - walkSpeed > 5 and length2D >= runSpeed - 20 and !client:WearingPA() then
					offset = -stamDrain + math.Clamp(0.04 * math.max(client:getSpecial("E") + (client.hungerbuff or 0), 0), 0, stamDrain - (stamDrain / 10))
				elseif (offset > 0.5) then
					offset = 1
				else
					offset = 1.75
				end

				if (client:Crouching()) then
					offset = offset + 1
				end

				local current = client:getLocalVar("stm", 0)
				local value = math.Clamp(current + offset, 0, 100)

				if (current != value) then
					client:setLocalVar("stm", value)

					-- disabled since it can cause sprint to be locked in disabled state
					--[[
					if client:getNetVar("brth", false) and client:GetSprintEnabled() then
						client:SprintDisable()
					end
					--]]

					if (value == 0 and !client:getNetVar("brth", false)) then -- When stamina runs out
						client.skerkMgrOldRun = client:GetSprintEnabled() -- saves if the player had sprint enabled before we did this
						client:SprintDisable()
						client:setNetVar("brth", true)

						hook.Run("PlayerStaminaLost", client)
					elseif (value >= 50 and client:getNetVar("brth", false)) then -- When stamina restored
						-- if sprint was disabled before stamina ran out, don't re-enable it so it doesn't interfere with the other thing
						if(client.skerkMgrOldRun) then
							client:SprintEnable()
						end

						client:setNetVar("brth", nil)
						client.skerkMgrOldRun = nil
					end
				end
			end
		else
			timer.Remove(uniqueID)
		end
	end)
end)

local PLAYER = FindMetaTable("Player")

--[[
function PLAYER:restoreStamina(amount)
	local current = self:getLocalVar("stm", 0)

	local char = self:getChar()
	local value = math.Clamp(current + amount, 0, 100)
	if char then
		local agil = self:getSpecial("A")
		local mod = 1 + (agil * 0.015)
		value = math.Clamp(current + (amount * mod), 0, 100)
	end

	self:setLocalVar("stm", value)
end
]]

local energyWeapons = 
{
	["MicrofusionCell"] = true,
	["EnergyCell"] = true,
	["ElectronChargePack"] = true,
}
--Special stat effects
hook.Add("EntityTakeDamage", "SPECIALBuffDamage", function(target, dmg) --Strength and perception
	local attacker = dmg:GetAttacker()

	if !attacker:IsPlayer() then return end

	local weapon = attacker:GetActiveWeapon()
	if !IsValid(weapon) then return end

	if weapon:isMelee() then
		--Apply strength stat as a modifier
		dmg:ScaleDamage(1 + (0.01 * attacker:getSpecial("S")))
	else
		local weaponType = weapon.Primary.Ammo

		if energyWeapons[weaponType] then
			dmg:ScaleDamage(1 + (0.01 * attacker:getSpecial("I")))
		else
			--Apply perception stat as a modifier
			dmg:ScaleDamage(1 + (0.01 * attacker:getSpecial("P")))
		end
	end
end)

local function charismaTimer()
	for k,v in pairs(player.GetAll()) do
		local char = v:getChar()
		if !char then continue end
		local amt = v:getSpecial("C")
		if amt <= 0 then continue end
		amt = amt * 2
		char:giveMoney(amt)
		nut.util.notify("You have gained " .. amt .. " caps for your charisma.", v)
	end
end

timer.Create("CharismaPay", 600, 0, charismaTimer) --Charisma

local statNames = {
	["S"] = "Strength",
	["P"] = "Perception",
	["E"] = "Endurance",
	["C"] = "Charisma",
	["I"] = "Intelligence",
	["A"] = "Agility",
	["L"] = "Luck"
}

g_allBuffs = {}

function PLAYER:BuffStat(stat, amt, time, dontStack)
	local sid = self:SteamID64()

	if dontStack and g_allBuffs[sid] and g_allBuffs[sid][stat] then
		return
	end

	local endTime = time != -1 and CurTime() + time or nil
	local buff = {amt = amt, endTime = endTime}
	g_allBuffs[sid] = g_allBuffs[sid] or {}
	g_allBuffs[sid][stat] = g_allBuffs[sid][stat] or {}
	local id = table.insert(g_allBuffs[sid][stat], buff)

	self:SetBuff(stat, self:GetBuff(stat) + amt)

	local buffType = amt < 0 and "debuff" or "buff"
	self:falloutNotify("Your " .. string.lower(statNames[stat]) .. " stat has been " .. buffType .. "ed by " .. math.abs(amt))

	net.Start("StartSPECIALBuff")
		net.WriteString(stat)
		net.WriteInt(endTime or -1, 32)
	net.Send(self)

	return id
end

function PLAYER:SetBuff(stat, val)
	self:SetNW2Int(stat .. "Buff", val)
end

hook.Add("Think", "BuffThink", function()
	for sid, stats in pairs(g_allBuffs) do
		local shouldCheck = false
		local ply = player.GetBySteamID64(sid)

		if !IsValid(ply) then
			g_allBuffs[sid] = nil
			continue
		end

		for stat, buffs in pairs(stats) do
			-- Remove expired buffs
			for i, buff in pairs(buffs) do
				if buff.endTime and CurTime() >= buff.endTime then
					buffs[i] = nil

					ply:SetBuff(stat, ply:GetBuff(stat) - buff.amt)

					anyRemoved = true
				end
			end

			-- Remove empty stat tables
			if table.IsEmpty(buffs) then
				shouldCheck = true
				stats[stat] = nil
			end
		end

		-- Remove players from the buffs table if they have no buffs remaining
		if shouldCheck and table.Count(stats) <= 0 then
			g_allBuffs[sid] = nil
		end
	end
end)

function PLAYER:StopStatBuff(stat, id)
	local sid = self:SteamID64()
	local stats = g_allBuffs[sid]
	if stats then
		local buffs = stats[stat]
		if buffs and buffs[id] then
			self:SetBuff(stat, self:GetBuff(stat) - buffs[id].amt)
			buffs[id] = nil
		else
			print("[WARNING] Attempted to stop stat buff that doesn't exist for stat " .. stat .. " ID " .. (id or "no ID given"))

			-- Something is using the function incorrectly
			if !id then
				debug.Trace()
			end
		end
	end
end

hook.Add("PlayerSpawn", "SPECIALBuffReset", function(ply)
	g_allBuffs[ply:SteamID64()] = nil

	for stat, _ in pairs(nut.skerk.special) do
		ply:SetBuff(stat, 0)
	end
end)

hook.Add("PlayerSpawn", "SPECIALAgilityBuff", function(ply)
	local agil = math.max(ply:getSpecial("A") + (ply.thirstbuff or 0), 0) --Agil + buff, but no lower than 0
	ply:SetSpeedBuff(1 + (agil * 0.004))
end)

hook.Add("SPECIALStatChanged", "SPECIALAgilityBuff", function(ply, char, stat, val)
	local agil = math.max(val + (ply.thirstbuff or 0), 0)
	ply:SetSpeedBuff(1 + (agil * 0.004))
end)
