PLUGIN.name = "Capture Zones"
PLUGIN.author = "rusty"
PLUGIN.desc = "Advanced faction capture zones."

captureZonesConfig = {}
captureZonesConfig.colors = {
    ["ncr"] = Color(143, 102, 21, 50),
    ["legion"] = Color(167, 0, 0, 50),
    ["bos"] = Color(0, 17, 255, 50),
    ["enclave"] = Color(88, 88, 88, 50) //Color(r, g, b, a)
}

/*
	Documentation:
		Hooks:
			CaptureZones.Think(zone)
			CaptureZones.CanNPCSpawn(zone, string npc)
			CaptureZones.CanBeCaptured(zone, string faction)
			CaptureZones.OnPlayerEnter(zone, entity player)
			CaptureZones.OnPlayerLeave(zone, entity player)
			CaptureZones.OnZoneCaptured(zone, faction)
		Zone Metamethods
			Zone:SetOwnerFaction(string faction)
			Zone:SetRadius(number radius)
			Zone:SetPosition(vector position)
			Zone:StartSpawning()
			Zone:KillSpawning()
			Zone:Think()
			Zone:OnPlayerEnter(entity player)
			Zone:OnPlayerLeave(entity player)
			Zone:CanNPCSpawn(string npc)
			Zone:CanBeCaptured(string faction)

		Zone Object Metatable is PLUGIN.Zone
*/

/* Instead of using our own object, we could create a zone entity and have the engine network it for us. */

PLUGIN.ActiveZones = PLUGIN.ActiveZones or {}

nut.util.include("sv_plugin.lua")
nut.util.include("objects/sh_zone.lua")
nut.util.include("cl_plugin.lua")

-- Since nutscript does not have any sandbox tool handling for plugins,
-- and Garry nils out the global variable that contains the tool object
-- class, we have to copypaste it all and do it ourselves.

nut.util.include("sh_stool.lua")

/* Configuration */

nut.config.add("start_spawning_rad", nut.config.get("start_spawning_rad", 500), "The distance in which a player has to be within for NPCs to begin spawning.", nil, {
	form = "Int",
	data = {min=1, max=1000},
	category = "Capture Zones"
})

nut.config.add("capture_zone_payment", nut.config.get("capture_zone_payment", 2), "The multiplier for how much a faction earns per zone captured.", nil, {
	form = "Float",
	data = {min=1, max=10},
	category = "Capture Zones"
})

/* Value denotes how much of the spawn budget will be consumed on spawn. */
PLUGIN.Spawns = {
	["ncr"] = {
		{ npc = "npc_combine_s", value = 10 },
		{ npc = "npc_combine_s", value = 5 },
	},
		["legion"] = {
		{ npc = "npc_combine_s", value = 10 },
		{ npc = "npc_combine_s", value = 5 },
	},
		["bos"] = {
		{ npc = "npc_combine_s", value = 10 },
		{ npc = "npc_combine_s", value = 5 },
	},
	["enclave"] = {
		{ npc = "npc_metropolice", value = 10 },
		{ npc = "npc_metropolice", value = 2 },
		{ npc = "npc_metropolice", value = 4 },
		{ npc = "npc_metropolice", value = 6 },
	}
}

/* Functions */

-- Our constructor. We could set __index to a prototype table for default values.
function PLUGIN:CreateNewZone(position, radius, faction, network)
	local zone = setmetatable({}, self.Zone)

	if not position or not isvector(position) then
		error("Invalid position!")
	end

	if not radius or not isnumber(radius) then
		error("Invalid radius!")
	end

	zone:SetPosition(position)
	zone:SetRadius(radius)

	if faction and faction != "none" then
		zone:SetOwnerFaction(faction)
	end

	zone.id = table.maxn(self.ActiveZones) + 1
	self.ActiveZones[table.maxn(self.ActiveZones) + 1] = zone

	if network then
		local zone_table = {
			faction = zone:GetFaction(),
			pos = zone:GetPosition(),
			radius = zone:GetRadius(),
			id = zone.id,
		}

		netstream.Start(nil, "NewZoneCreated", zone_table)
	end

	return zone
end

PLUGIN.Tools = {
	["capture_zone_spawner"] = true,
	["capture_zone_create"] = true,
}
function PLUGIN:CanTool(ply, trace, tool)
	if self.Tools[tool] and !ply:IsAdmin() then
		return false
	end
end

function PLUGIN:Think()
	for k,v in next, self.ActiveZones do
		v:Think()
		hook.Run("CaptureZones.Think", v)
	end
end

-- We could use the npc entity as the key of the table.
function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
	for k,v in next, self.ActiveZones do
		for m,n in next, v.ActiveNPCs do
			if n == npc then
				n.SpawnUsed["SpawnUsed"] = false
				table.remove(v.ActiveNPCs, m)
			end
		end
	end
end

local npc_meta = FindMetaTable("NPC")

/* VJ Base has two tables called VJ_AddCertainEntityAsEnemy and VJ_AddCertainEntityAsFriendly. */
/* Because of the fact that DrVrej does not use the entity as the key in these tables, */
/* It forces me to do this nested mess. I do not like this. */
function npc_meta:SetFactionRelationship(faction, disposition, priority)
	for k,v in next, player.GetAll() do
		if v:getChar() and nut.faction.indices[v:getChar():getFaction()].uniqueID == faction then
			self:AddEntityRelationship(v, disposition, priority)
			if !self.IsVJBaseSNPC then return end
			if disposition == D_HT then
				table.insert(self.VJ_AddCertainEntityAsEnemy, v)
				self.PlayerFriendly = false
				if table.HasValue(self.VJ_AddCertainEntityAsFriendly, v) then
					table.RemoveByValue(self.VJ_AddCertainEntityAsFriendly, v)
				end
			elseif disposition == D_LI then
				table.insert(self.VJ_AddCertainEntityAsFriendly, v)
				self.PlayerFriendly = true
				if table.HasValue(self.VJ_AddCertainEntityAsEnemy, v) then
					table.RemoveByValue(self.VJ_AddCertainEntityAsEnemy, v)
				end
			end
		end
	end
end