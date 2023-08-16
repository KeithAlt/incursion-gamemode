--resource.AddWorkshop("1688987855")
resource.AddSingleFile("sound/chems-boiling.wav")
resource.AddSingleFile("sound/ultrajetscream.ogg")

util.AddNetworkString("ChemsUse")
util.AddNetworkString("ChemsOpenMenu")
util.AddNetworkString("ChemsStartCraft")
util.AddNetworkString("ChemsTakeAll")
util.AddNetworkString("ChemsTakeChem")
util.AddNetworkString("ChemsClearAddiction")
util.AddNetworkString("ChemsAddiction")

--Chem effects
local PLAYER = FindMetaTable("Player")

function PLAYER:AddDR(amt, time, quality)
	if self.ChemsDR then return end

	time = time * (jChems.Config.Multipliers[quality or 0])

	self.ChemsDR = amt

	timer.Create(self:SteamID64() .. "ChemDR", time, 1, function()
		if IsValid(self) then
			self.ChemsDR = nil

			self:notify("Your DR buff has ended")
		end
	end)
end

function PLAYER:ClearChemEffects()
	if self.ChemsDR then
		timer.Remove(self:SteamID64() .. "ChemDR")
		self.ChemsDR = nil
		clearedEffect = true
	end

	if self.ChemsDMG then
		self.ChemsDMG = nil
		timer.Remove(self:SteamID64() .. "ChemDMG")
		clearedEffect = true
	end

	if self.ChemSpeed then
		local amt = self.ChemSpeed
		local factor = amt / 100

		self:SetWalkSpeed(self:GetWalkSpeed() / (1 + factor))
		self:SetRunSpeed(self:GetRunSpeed() / (1 + factor))
		timer.Remove(self:SteamID64() .. "ChemSpeed")

		self.ChemSpeed = nil
		self.WalkBonus = nil
		self.RunBonus = nil
		clearedEffect = true
	end

	if self.ChemHP then
		self:SetMaxHealth(self:GetMaxHealth() - self.ChemHP)
		self.ChemHP = nil
		clearedEffect = true
		timer.Remove(self:SteamID64() .. "ChemHP")
	end
end

hook.Add("EntityTakeDamage", "ChemsDR", function(target, dmg)
	if IsValid(target) and target:IsPlayer() and target.ChemsDR then
		dmg:ScaleDamage(1 - (target.ChemsDR / 100))
	end
end)

function PLAYER:AddDMG(amt, time, quality)
	if self.ChemsDMG then return end

	time = time * (jChems.Config.Multipliers[quality or 0])

	self.ChemsDMG = amt

	timer.Create(self:SteamID64() .. "ChemDMG", time, 1, function()
		if IsValid(self) then
			self.ChemsDMG = nil

			self:notify("Your DMG buff has ended.")
		end
	end)
end
hook.Add("EntityTakeDamage", "ChemsDMG", function(target, dmg)
	local attacker = dmg:GetAttacker()

	if IsValid(attacker) and attacker:IsPlayer() and attacker.ChemsDMG then
		dmg:ScaleDamage(1 + (attacker.ChemsDMG / 100))
	end
end)

function PLAYER:AddSpeed(amt, time, quality)
	if self.ChemSpeed then return end

	time = time * (jChems.Config.Multipliers[quality or 0])

	self.ChemSpeed = amt

	local factor = amt / 100
	self.WalkBonus = self:GetWalkSpeed() * factor
	self.RunBonus = self:GetRunSpeed() * factor
	self:SetWalkSpeed(self:GetWalkSpeed() + self.WalkBonus)
	self:SetRunSpeed(self:GetRunSpeed() + self.RunBonus)

	timer.Create(self:SteamID64() .. "ChemSpeed", time, 1, function()
		if IsValid(self) then
			self:setLocalVar("stm", 55)
			self:SetWalkSpeed(self:GetWalkSpeed() / (1 + factor))
			self:SetRunSpeed(self:GetRunSpeed() / (1 + factor))

			self.ChemSpeed = nil
			self.WalkBonus = nil
			self.RunBonus = nil

			self:falloutNotify("Your speed buff has ended.", "fallout/chems/ui_health_chems_wearoff.wav")
		end
	end)
end

function PLAYER:AddMaxHP(amt, time, quality)
	if self.ChemHP then return end

	time = time * (jChems.Config.Multipliers[quality or 0])

	self.ChemHP = amt

	self:SetMaxHealth(self:GetMaxHealth() + amt)

	timer.Create(self:SteamID64() .. "ChemHP", time, 1, function()
		if IsValid(self) then
			self:SetMaxHealth(self:GetMaxHealth() - amt)

			self.ChemHP = nil

			self:notify("Your HP buff has ended.")
		end
	end)
end

function PLAYER.HealOverTime(ply, idPrefix, healAmt, totalTime, quality)
	local multi = jChems.Config.Multipliers[quality or 0]
	healAmt = healAmt * multi

	local id = idPrefix .. ply:SteamID64()
	local deaths = ply:Deaths()
	local time = nut.config.get("healRate") / (healAmt / totalTime) -- Rate of healing

	local timerFunc = function()
		if !IsValid(ply) or ply:Deaths() > deaths then
			timer.Remove(id)
			return
		end

		if ply:IsInCombat(8) then return end

		ply:SetHealth(math.min(ply:Health() + 1, ply:GetMaxHealth()))
	end

	if timer.Exists(id) then
		local reps = timer.RepsLeft(id)
		reps = reps + healAmt
		timer.Adjust(id, time, reps, timerFunc)
	end

	timer.Create(id, time, healAmt, timerFunc)
end

hook.Add("PlayerSpawn", "ChemsRemoveBuffs", function(ply)
	if ply.ChemsDR then
		timer.Remove(ply:SteamID64() .. "ChemDR")
		ply.ChemsDR = nil

		ply:notify("Your DR buff has ended.")
	end

	if ply.ChemsDMG then
		timer.Remove(ply:SteamID64() .. "ChemDMG")
		ply.ChemsDMG = nil

		ply:notify("Your DMG buff has ended.")
	end

	if ply.ChemSpeed then
		timer.Remove(ply:SteamID64() .. "ChemSpeed")
		ply.ChemSpeed = nil

		ply:notify("Your speed buff has ended.")
	end

	if ply.ChemHP then
		timer.Remove(ply:SteamID64() .. "ChemHP")
		ply.ChemHP = nil

		ply:notify("Your HP buff has ended.")
	end
end)

--Crafting
net.Receive("ChemsStartCraft", function(len, ply)
	local uniqueID = net.ReadString()
	local bench = net.ReadEntity()

	if !IsValid(bench) or ply:GetPos():DistToSqr(bench:GetPos()) > 500 * 500 then
		return
	end

	bench:StartProduction(uniqueID, ply)
end)

net.Receive("ChemsTakeAll", function(len, ply)
	local bench = net.ReadEntity()

	if !IsValid(bench) or ply:GetPos():DistToSqr(bench:GetPos()) > 500 * 500 then
		return
	end

	bench:TakeItems(ply)
end)

net.Receive("ChemsTakeChem", function(len, ply)
	local uniqueID = net.ReadString()
	local bench = net.ReadEntity()

	if !IsValid(bench) or ply:GetPos():DistToSqr(bench:GetPos()) > 500 * 500 then
		return
	end

	bench:TakeItem(ply, uniqueID)
end)

--Addiction
function jChems.AddictionEffects(ply, chemID, severity)
	if jChems.Chems[chemID].addictionEffects == nil then return end
	jChems.Chems[chemID].addictionEffects[severity](ply)

	net.Start("ChemsAddiction")
		net.WriteString(chemID)
		net.WriteInt(severity, 32)
	net.Send(ply)
end

function jChems.StartAddictionTimer(ply, id, severity)
	local chem = jChems.Chems[id]

	local timerID = id .. ply:SteamID64()
	timer.Create(timerID, 720, 4 - severity, function()
		if !IsValid(ply) or !ply.addictions[id] then
			timer.Remove(timerID)
			return
		end

		ply.addictions[id] = ply.addictions[id] + 1

		if ply.addictions[id] >= 4 then
			jChems.ClearAddiction(ply, id)

			return
		end

		jChems.AddictionEffects(ply, id, ply.addictions[id])

		ply:notify("You're experiencing withdrawls due to your addiction to " .. chem.name:lower())

		ply:getChar():setData("addictions", table.Copy(ply.addictions))
	end)
end

function jChems.RollAddiction(chem, ply)
	if ply:hasSkerk("noaddict") and math.random() >= 0.5 then
		ply:falloutNotify("✚ As a frequent addict, you avoid addiction", "ui/goodkarma.ogg")
		return false
	end

	local alreadyAddicted = ply.addictions and ply.addictions[chem.uniqueID] and ply.addictions[chem.uniqueID] > 0

	local num = math.random(0, 100)
	if num < chem.addictionChance or alreadyAddicted then
		if !alreadyAddicted then
			ply:notify("You are now addicted to " .. chem.name:lower())
		else
			jChems.ClearAddiction(ply, chem.uniqueID)
		end

		local id = chem.uniqueID

		ply.addictions = ply.addictions or {}
		ply.addictions[id] = (ply.addictions[id] or 0) + 1

		ply:getChar():setData("addictions", table.Copy(ply.addictions))

		jChems.AddictionEffects(ply, id, ply.addictions[id])

		jChems.StartAddictionTimer(ply, id, ply.addictions[id])
	elseif alreadyAddicted then --Reset them to addiction level 1
		local id = chem.uniqueID

		jChems.ClearAddiction(ply, id)

		ply.addictions = ply.addictions or {}
		ply.addictions[id] = 1

		ply:getChar():setData("addictions", table.Copy(ply.addictions))

		jChems.AddictionEffects(ply, id, ply.addictions[id])

		jChems.StartAddictionTimer(ply, id, ply.addictions[id])
	end
end

hook.Add("PlayerSpawn", "jChemsAddiction", function(ply)
	if !ply.addictions then
		return
	end

	for id, addictionLevel in pairs(ply.addictions) do
		for i = 1, addictionLevel do
			jChems.AddictionEffects(ply, id, i)
		end
	end
end)

hook.Add("PlayerLoadedChar", "jChemsAddiction", function(ply, char, oldChar)
	for chemID, severity in pairs(ply.addictions or {}) do
		net.Start("ChemsClearAddiction")
			net.WriteString(chemID)
		net.Send(ply)

		if isfunction(jChems.Chems[chemID].onAddictionCleared) then
			jChems.Chems[chemID].onAddictionCleared(ply)
		end
	end

	local addictions = char:getData("addictions", {})
	ply.addictions = addictions

	for id, addictionLevel in pairs(ply.addictions) do
		for i = 1, addictionLevel do
			jChems.AddictionEffects(ply, id, i)
			jChems.StartAddictionTimer(ply, id, i)
		end
	end
end)

--Workbenches support
hook.Add("WBMCTakeItem", "ChemsWorkbench", function(bench, ply, uniqueID)
	if jChems.Chems[uniqueID] then
		return {quality = ply:hasSkerk("chemist") or 0}
	end
end)

-- Chem history
jChems.ChemHistoryCache = jChems.ChemHistoryCache or {}

hook.Add("PlayerInitialSpawn", "ChemHistory", function(ply)
	local sid = ply:SteamID64()
	ply.ChemHistory = jChems.ChemHistoryCache[sid] or {}
	jChems.ChemHistoryCache[sid] = nil
end)

hook.Add("PlayerLoadedChar", "ChemHistory", function(ply, char)
	local id = char:getID()
	ply.ChemHistory[id] = ply.ChemHistory[id] or {}
end)

hook.Add("PlayerDisconnected", "ChemHistory", function(ply)
	jChems.ChemHistoryCache[ply:SteamID64()] = ply.ChemHistory
end)

function jChems.AddToHistory(chemID, ply)
	local char = ply:getChar()

	if !char then return end

	local charID = char:getID()

	ply.ChemHistory[charID][chemID] = CurTime()
end

function jChems.GetHistory(ply)
	local char = ply:getChar()

	if !char then return end

	local charID = char:getID()

	return ply.ChemHistory[charID] or {}
end

function jChems.GetChemsDone(ply, maxTime)
	local chemsDone = {}
	local cTime = CurTime()

	for chemID, lastDone in pairs(jChems.GetHistory(ply)) do
		if cTime - lastDone <= maxTime then
			table.insert(chemsDone, chemID)
		end
	end

	return chemsDone
end

function jChems.ClearHistory(ply)
	local char = ply:getChar()

	if !char then return end

	local charID = char:getID()

	ply.ChemHistory[charID] = {}
end
