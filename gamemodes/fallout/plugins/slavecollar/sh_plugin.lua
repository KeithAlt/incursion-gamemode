PLUGIN.name = "Slave Collar"
PLUGIN.desc = "Slave collar system."
PLUGIN.author = "Pilot"
PLUGIN.factions = {
	"legion",
	"paradise"
}

nut.util.include("sv_plugin.lua")
nut.util.include("cl_plugin.lua")

nut.config.add("timeToExplode", 10, "The time a player has before their collar explodes.", nil, {
	data = {min = 1, max = 10000},
	category = "slave collar"
})

nut.config.add("maxEnslaveTime", 60, "The maximum time a player can be a slave.", nil, {
	data = {min = 1, max = 10000},
	category = "slave collar"
})

nut.config.add("explosionDamage", 50, "The explosion damage of a slave collar.", nil, {
	data = {min = 1, max = 10000},
	category = "slave collar"
})

function PLUGIN:SaveData()
	local saveData = {}

	local locations = {}
	for _, entity in ipairs(ents.FindByClass("nut_slavespawn")) do
		local location = {entity:GetPos(), entity:getNetVar("owner")}

		locations[entity:EntIndex()] = location
	end

	saveData["locations"] = locations

	self:setData(saveData)
end

/** function PLUGIN:LoadData() -- Uneeded feature, casuses issues
	if type(self:getData()["locations"]) == "table" then
		if table.Count(self:getData()["locations"]) == 0 then return end

		-- Make sure we're not spawning multiple slave spawns
		local activeSlaveSpawns = {}
		for _, entity in ipairs(ents.FindByClass("nut_slavespawn")) do
			table.insert(activeSlaveSpawns, entity:getNetVar("owner"))
		end

		for _, entity in pairs(self:getData()["locations"]) do
			if table.HasValue(activeSlaveSpawns, entity[2]) then continue end

			local slavespawn = ents.Create("nut_slavespawn")
			slavespawn:SetPos(entity[1])
			slavespawn:setNetVar("owner", entity[2])
			slavespawn:Spawn()
		end
	end
end **/

-- Only allow one weapon_mad_collar per character
function PLUGIN:CanItemBeTransfered(item, curInv, inventory)
	if inventory.id then
		--if item.uniqueID == "weapon_mad_collar" and inventory:hasItem("weapon_mad_collar") then return false end
		if inventory:hasItem("weapon_mad_collar") then
			for k, weapon_mad_collar in pairs(inventory:getItemsByUniqueID("weapon_mad_collar")) do
				if k == 1 then continue end

				inventory:remove(weapon_mad_collar.id)
			end
		end

		if inventory:hasItem("slavecollar") then
			for _, collar in pairs(inventory:hasItem("slavecollar")) do
				collar = nut.item.instances[collar]
				if collar and collar:getData("equip") and item:getData("arm") then
					return false
				end
			end
		end
	end
end


function PLUGIN:OnItemTransfered(item, curInv, inventory)
	if item.uniqueID == "slavecollar" and item:getData("arm") then
		item:wearCollar(true)
	end
end

--[[-------------------------------------------------------------------------
playerMeta
---------------------------------------------------------------------------]]
local playerMeta = FindMetaTable("Player")

function playerMeta:enslave(target)
	if not self:getChar() or not target:getChar() then return end

	local collar = nil
	for _, item in pairs(self:getChar():getInv():getItemsByUniqueID("slavecollar")) do
		if item:getData("arm") then
			collar = item
		end
	end

	if not collar then
		self:notifyLocalized("You must first arm a collar!")
		return
	end

	if target:getCollar() then
		self:notifyLocalized("Character is already enslaved!")
		return
	end

	item:transfer(target:getChar():getInv():getID())
	item:wearCollar(true)
end

function playerMeta:timedExplosion(diffuse, instant)
	if not self:getChar() then return end

	diffuse = diffuse or false
	instant = instant or false

	local timerName = "explodeCollar"..self:getChar():getID()

	if not self:Alive() or not self:getCollar() or diffuse then
		if timer.Exists(timerName) then
			timer.Remove(timerName)
		end

		return
	end

	if instant then
		self:explode()
	end

	if timer.Exists(timerName) then return end

	timer.Create(timerName, 1, nut.config.get("timeToExplode"), function()
		if not self:IsValid() then return end

		self:EmitSound("slavecollar/beep.wav")

		if timer.RepsLeft(timerName) == 0 then
			self:explode()
		end
	end)
end

function playerMeta:explode()
	if not self:getCollar() then
		ErrorNoHalt("Attempted to kill " .. (self:Nick() or "NULL") .. " via slave collar without one equipped")
		return
	end

	local explosion = ents.Create("env_explosion")
	explosion:SetPos(self:GetPos())
	explosion:SetOwner(self)
	explosion:SetKeyValue("iMagnitude", tostring(nut.config.get("explosionDamage")))
	explosion:Fire("Explode", 0, 0)
	explosion:EmitSound("weapon_AWP.Single", 400, 400)

	self:Kill()
	Dismemberment.QuickDismember(self, HITGROUP_HEAD)
end

-- Purpose: Check to see if a player has a weapon_mad_collar
function playerMeta:getSlaveboy()
	if not self:getChar() then return end

	local weapon_mad_collars = self:getChar():getInv():getItemsByUniqueID("weapon_mad_collar")

	if #weapon_mad_collars == 0 then return end

	for _, weapon_mad_collar in ipairs(weapon_mad_collars) do
		return weapon_mad_collar
	end
end

-- Purpose: Return collar by checking if it is equipped on target
function playerMeta:getCollar()
	local char = self:getChar()

	if !char then return end

	return nut.item.instances[char:getVar("collarID", -1)]
end

-- Purpose: Get a list of a players slaves by their collar
function playerMeta:getSlaveCollars()
	if not self:getChar() then return end

	local collars = {}

	local id = self:getChar():getID()

	for _, client in ipairs(player.GetAll()) do
		local collar = client:getCollar()
		if collar and collar:getData("owner") == id then
			table.insert(collars, client:getCollar())
		end
	end

	return collars
end
