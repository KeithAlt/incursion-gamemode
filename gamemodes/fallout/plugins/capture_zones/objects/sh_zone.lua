local zone = {}
zone.__index = zone
zone.ActiveNPCs = {}
zone.ActivePlayers = {}
zone.NextSpawnThink = 0
zone.DefaultBudget = 20
zone.MaxNPCs = 5
zone.NextCaptureThink = 0
function zone:__tostring()
	return "zone["..(self.id or 0).."]"
end

/*
	I had a discussion with TankNut about the use of hooks in gamemodes,
	he is of the philosophy that they should not be used very often, because
	they make it so you have to check a myriad of places when issues begin to appear.

	I believe that hooks are very good for leaving gamemode/addon open-ended for other
	developers to expand upon your code.
*/

/* Configuration */
function zone:SetOwnerFaction(faction)
	if !faction or faction == "none" then
		self.Faction = nil
		return
	end

	local faction_table
	if isnumber(faction) then
		faction_table = nut.faction.indices[faction]
	elseif isstring(faction) then
		faction_table = nut.faction.teams[faction]
	end

	if not faction_table then
		error("Invalid faction specified!")
	end

	self.Faction = faction
end

function zone:SetRadius(radius)
	if not radius or not isnumber(radius) then
		error("Invalid radius specified!")
	end

	self.ZoneRadius = radius
end

function zone:SetPosition(position)
	if not position or not isvector(position) then
		error("Invalid position specified!")
	end

	self.ZonePosition = position
end

function zone:SetBudget(budget)
	if not budget or not isnumber(budget) then
		error("Invalid budget specified!")
	end

	self.Budget = budget
end

/* Operations */
function zone:StartSpawning()
	if !self:CanStartSpawning() then return end

	self.IsSpawning = true
	self.NextSpawnThink = CurTime()
end

function zone:KillSpawning()
	self.IsSpawning = false
	self.NextSpawnThink = 0
end

function zone:SpawnNPC(npc)
	if self.Faction == "none" then return end

	local ent = ents.Create(npc)
	local npc_list = list.Get("NPC") //VJBASE_SPAWNABLE_NPC
	local npc_data = npc_list[npc]

	local spawners = {}
	for k,v in next, ents.FindInSphere(self:GetPosition(), self:GetRadius()) do
		if v:GetClass() != "zone_spawner" then continue end

		spawners[#spawners + 1] = v
	end

	if #spawners == 0 then
		error("No spawners within zone!")
	end

	local selected = spawners[math.random(1,#spawners)]
	if selected.SpawnUsed then return end

	ent:SetPos(selected:GetPos())
	selected.SpawnUsed = true
	ent.SpawnUsed = selected
	ent:SetFactionRelationship(self.Faction, D_LI, 99)

	for k,v in next, nut.faction.teams do
		if k != self.Faction  then
			ent:SetFactionRelationship(k, D_HT, 99)
		end
	end

	if npc_data.Weapons then
		for k,v in next, npc_data.Weapons do
			ent:Give(v)
		end
	end

	ent.CustomOnThink = function(npc)
		if self:GetPosition():Distance(npc:GetPos()) > self:GetRadius() then
			npc:SetMovementActivity(VJ_PICKRANDOMTABLE(npc.AnimTbl_Walk))

			local vsched = ai_vj_schedule.New("vj_idle_wander")
			npc:SetLastPosition(self:GetPosition())

			vsched:EngTask("TASK_SET_ROUTE_SEARCH_TIME", 0)
			vsched:EngTask("TASK_GET_PATH_TO_LASTPOSITION", 0)
			vsched.ResetOnFail = true
			vsched.CanBeInterrupted = true
			vsched.IsMovingTask = true
			vsched.IsMovingTask_Walk = true

			npc:StartSchedule(vsched)
		end
	end

	ent:Spawn()
	ent:Activate()
	table.insert(self.ActiveNPCs, ent)

	return true
end

function zone:RemoveAllNPCs()
	for k,v in next, self.ActiveNPCs do
		v.SpawnUsed["SpawnUsed"] = false
		v:Remove()
	end

	self.ActiveNPCs = {}
end

function zone:Destroy(network)
	if SERVER then
		self:RemoveAllNPCs()

		for k,v in next, self:GetSpawns() do
			v:Remove()
		end

		if network then
			netstream.Start(nil, "DestroyZone", self.id)
		end

		if(self.flag) then
			self.deleted = true
			SafeRemoveEntity(self.flag)
		end
	end

	nut.plugin.list["capture_zones"].ActiveZones[self.id] = nil
end

/* Hooks */
/* Nice thing about all this, all logic is predicted on the client and server. */
function zone:Think()
	hook.Run("CaptureZone.PlayerThink", self)
	self:PlayerThink()

	hook.Run("CaptureZone.CaptureThink", self)
	self:CaptureThink()

	hook.Run("CaptureZone.SpawnThink", self)
	self:SpawnThink()

	if(SERVER) then
		if(!self.deleted and !self.flag or !IsValid(self.flag)) then
			self.flag = ents.Create("prop_physics")
			self.flag:SetModel("models/sterling/flag.mdl")
			self.flag:SetPos(self:GetPosition())
			self.flag:SetMoveType(MOVETYPE_NONE)
		end
	end
end

/* Delegation, hell yeah. */

/* This handles all capture checking. */
function zone:CaptureThink()
	if CLIENT then return end
	/* These should never be nil, but sometimes with Lua garbage collection removes stuff you're still using. */
	if !self.NextCaptureThink or self.NextCaptureThink > CurTime() then return end
	if !self.ActivePlayers or table.Count(self.ActivePlayers) == 0 then return end

	local factions = {}
	for k,v in next, self.ActivePlayers do
		if !IsValid(k) then continue end
		if !k:Alive() then continue end
		/* This should never happen, but Source is magical sometimes. */
		if k:IsDormant() then continue end
		if !k:Team() then continue end
		if !nut.faction.indices[k:Team()] then continue end
		if !nut.faction.indices[k:Team()].uniqueID then continue end
		if !nut.plugin.list["capture_zones"].Spawns[nut.faction.indices[k:Team()].uniqueID] then continue end

		if nut.faction.indices[k:Team()].uniqueID != self:GetFaction() then
			factions[k:Team()] = (factions[k:Team()] or 0) + 1
		end
	end

	for k,v in next, factions do
		local ratio = v / table.Count(self.ActivePlayers)

		if ratio > 0.5 then
			self:CaptureLogic(k, ratio)
		end
	end

	self.NextCaptureThink = CurTime() + 0.5
end

/* No more nesting version */
function zone:SpawnThink()
	if CLIENT then return end
	if !self.IsSpawning or self.NextSpawnThink > CurTime() then return end
	if !self:GetFaction() then return end
	if #self.ActiveNPCs >= self.MaxNPCs then return end
	if #self:GetSpawns() == 0 then return end

	local possible_npcs = nut.plugin.list["capture_zones"].Spawns[self:GetFaction()]
	if !possible_npcs then return end
	local selected = possible_npcs[math.random(1, #possible_npcs)]
	if self:GetBudget() - selected.value < 0 then return end

	local success = self:SpawnNPC(selected.npc)

	if success then
		self:SetBudget(self:GetBudget() - selected.value)
	end

	self.NextSpawnThink = CurTime() + 1
end

function zone:PlayerThink()
	self.ply_in_zone = false
	for k,v in next, player.GetAll() do
		if CLIENT and v != LocalPlayer() then continue end --the client isn't interested
		if !v:Alive() then continue end
		if v:IsDormant() then continue end

		if !self.ActivePlayers[v] then
			if v:GetPos():Distance(self:GetPosition()) <= self.ZoneRadius then
				self:OnPlayerEnter(v)
				hook.Run("CapturePoint.OnPlayerEnter", self, v)
				self.ActivePlayers[v] = true
				if CLIENT then self.localply_in_zone = true end
			elseif CLIENT then
				self.localply_in_zone = false
			end
		else
			if v:GetPos():Distance(self:GetPosition()) > self.ZoneRadius + 50 then
				self:OnPlayerLeave(v)
				hook.Run("CapturePoint.OnPlayerLeave", self, v)
				self.ActivePlayers[v] = nil
			end
		end

		if self:GetFaction() then
			if v:GetPos():Distance(self:GetPosition()) <= self:GetRadius() + nut.config.get("start_spawning_rad", 500) then
				if !self.IsSpawning and #self.ActiveNPCs == 0 then
					self:StartSpawning()
				end
				self.ply_in_zone = true
			end
		end
	end

	if !self.ply_in_zone and self.IsSpawning then
		self:KillSpawning()
		self:SetBudget(self.DefaultBudget)
		self:RemoveAllNPCs()
	end
end

/* This really is a good reason to use an entity */
/* I could've used Netvars 2 */
function zone:CaptureLogic(faction_index, ratio)
	if CLIENT then return end
	local faction = nut.faction.indices[faction_index]

	if !self.LastCaptureFaction then
		self.LastCaptureFaction = faction_index
	end

	if self.LastCaptureFaction != faction_index then
		if GetGlobalInt("CaptureZone"..self.id..".CapturePoints", 0) > 0 then
			self.DepleteMode = true
		end

		if GetGlobalInt("CaptureZone"..self.id..".LastCaptureFaction", 0) == faction_index then
			self.DepleteMode = false
		end
	end

	if GetGlobalInt("CaptureZone"..self.id..".LastCaptureFaction", 0) == 0 then
		SetGlobalInt("CaptureZone"..self.id..".LastCaptureFaction", self.LastCaptureFaction)
	end

	if self.DepleteMode then
		local points = math.Round(GetGlobalInt("CaptureZone"..self.id..".CapturePoints", 0) - ratio * 2)
		SetGlobalInt("CaptureZone"..self.id..".CapturePoints", math.Clamp(points, 0, 100))

		if GetGlobalInt("CaptureZone"..self.id..".CapturePoints", 0) == 0 then
			SetGlobalInt("CaptureZone"..self.id..".LastCaptureFaction", faction_index)
			self:SetOwnerFaction("none")
			self.DepleteMode = false
		end
	else
		local points = math.Round(GetGlobalInt("CaptureZone"..self.id..".CapturePoints", 0) + ratio * 2)
		SetGlobalInt("CaptureZone"..self.id..".CapturePoints", math.Clamp(points, 0, 100))

		if GetGlobalInt("CaptureZone"..self.id..".CapturePoints", 0) == 100 then
			self:KillSpawning()
			self:SetBudget(self.DefaultBudget)
			self:RemoveAllNPCs()
			self:SetOwnerFaction(faction.uniqueID)

			hook.Run("CaptureZone.OnZoneCaptured", self, faction.uniqueID)
			self:OnZoneCaptured(self, faction.uniqueID)
		end
	end

	self.LastCaptureFaction = faction_index
end

function zone:OnPlayerEnter(ply)
end

function zone:OnPlayerLeave(ply)
end

function zone:OnZoneCaptured(entity, factionID)
	if(entity.flag and IsValid(entity.flag)) then
		local factionColor = captureZonesConfig.colors[factionID]
		if(factionColor) then
			entity.flag:SetColor(factionColor)
			entity.flag:EmitSound("ui/ui_xp_up.mp3")
		end
	end
end

/* Checks */
function zone:CanNPCSpawn(npc)

end

function zone:CanBeCaptured(faction)

end

function zone:CanStartSpawning()
	return #self.ActiveNPCs < self:GetMaxNPCs()
end

/* Data */
function zone:GetPosition()
	return self.ZonePosition
end

function zone:GetRadius()
	return self.ZoneRadius
end

function zone:GetFaction()
	return self.Faction
end

function zone:GetMaxNPCs()
	return self.MaxNPCs or 5
end

function zone:GetBudget()
	return self.Budget or self.DefaultBudget
end

function zone:GetSpawns()
	local spawns = {}
	for k,v in next, ents.FindInSphere(self:GetPosition(), self:GetRadius()) do
		if v:GetClass() != "zone_spawner" then continue end

		spawns[#spawns + 1] = v
	end

	return spawns
end

PLUGIN.Zone = zone;
