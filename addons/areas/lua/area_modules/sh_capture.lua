Areas.Capture = Areas.Capture or {}
Areas.Capture.Print = jlib.GetPrintFunction("[AreasCapture]", Color(128, 0, 128, 255))
Areas.AddVar("Faction", "Int", true, -1)
Areas.AddVar("FactionUID", "String", true, "")
Areas.AddVar("Capture", "Bool", true, false)
Areas.AddVar("Spawns", "Table", true, {})
Areas.AddVar("Doors", "Table", true, {})

if CLIENT then
	function Areas.Capture.Start(area)
		if(istable(area)) then
			local client = LocalPlayer()
			local faction = area:GetFactionUID()
			local factionTbl = nut.faction.teams[faction] -- Faction table

			if(factionTbl) then
				-- Faction icon
				local factionIcon = FalloutScoreboard.GetFactionMaterial and FalloutScoreboard.GetFactionMaterial(factionTbl.uniqueID)
				if(factionIcon) then
					-- Put it on the screen for a few seconds
					Areas.Text.DisplayImage(area, factionIcon)
				end

				-- Text Color for faction
				local txtColor = nut.faction.indices[factionTbl.index].color

				-- Strings to display
				local displayString = {
					{
						(factionTbl.name .. " Territory") or "Unclaimed",
						txtColor,
						"nutAreaDisplaySmall",
					},
					{
						(area:GetName() or "Unnamed"),
						nut.config.get("color"),
						"nutAreaDisplay",
					}
				}

				Areas.Text.DisplayText(area, displayString, Color(255,255,255))
			end

			-- If it's a capturable area and the player is HC.
			if area:GetCapture() and hcWhitelist.isHC(client) and not factionTbl then
				jlib.Announce(Color(255,255,0), " [AREA] ", Color(255,255,155), "This area is capturable", Color(255,255,255), "\n· Enter ", Color(255,255,155), "'/area_capture' ", Color(255,255,255), " to do so\n· This will set your faction to spawn here")
			end
		end
	end

	function Areas.Capture.Stop(area)
	end

	hook.Add("PlayerEnteredArea", "Capture", function(ply, area)
		if ply == LocalPlayer() and (area:GetFactionUID() != "" or area:GetCapture()) then
			Areas.Capture.Start(area)
		end
	end)

	hook.Add("PlayerLeftArea", "Capture", function(ply, area)
		if ply == LocalPlayer() and (area:GetFactionUID() != "" or area:GetCapture()) then
			Areas.Capture.Stop(area)
		end
	end)

	hook.Add("HUDPaint", "Capture", function()

	end)

	hook.Add("RenderScreenspaceEffects", "AreasCapture", function()

	end)

	net.Receive("AreasCaptureStart", Areas.Capture.Start)
	net.Receive("AreasCaptureStop", Areas.Capture.Stop)
else
	util.AddNetworkString("AreasCaptureStart")
	util.AddNetworkString("AreasCaptureStop")
	util.AddNetworkString("AreasSetData")
	util.AddNetworkString("AreaRemove")

	-- Return areaID (or false) if the faction owns an area at the time
	function Areas.GetOwnership(factionID)
		local areas = {}
		for k, area in pairs(Areas.Instances) do
			local faction = area:GetFactionUID()

			if(faction == factionID) then
				areas[k] = area
			end
		end

		if(table.Count(areas) == 0) then
			return false
		end

		return areas
	end

	-- Search for and remove area ownership for the specified faction
	function Areas.RemoveOwnerByFaction(factionID)
		for areaID, area in pairs(Areas.Instances) do
			local faction = area:GetFactionUID()

			if(faction == factionID) then
				Areas.RemoveOwner(areaID)
			end
		end

		return true
	end

	-- Issue ownership of an area by ID of both args
	function Areas.AddOwner(areaID, factionID)
		local uniqueID

		if isnumber(factionID) then
			uniqueID = nut.faction.indices[factionID].uniqueID
		else
			uniqueID = factionID
		end

		local area = Areas.Instances[areaID]
		area:SetFactionUID(uniqueID)
	end

	-- Remove the faction owner of a area if one exists for that areaID
	function Areas.RemoveOwner(areaID)
		local area = Areas.Instances[areaID]
		area:SetFactionUID("")
	end

	-- If the player is within an area, return that areaID
	function Areas.getLocalAreaID(ply)
		local area = ply:GetArea()

		if(area) then
			return area.ID
		end
	end

	-- is the player within an area and does that area belong to their faction; return true if so
	function Areas.inOwnedArea(ply)
		local area = ply:GetArea()
		if(area) then
			local faction = area:GetFactionUID()

			local factionTbl = nut.faction.teams[faction]
			if(factionTbl and factionTbl.index == ply:Team()) then -- If the factions are the same, return true
				return true
			else
				return false
			end
		else
			return false
		end
	end

	-- Sets doors in an area to be owned by the faction that owns the area.
	function Areas.SetFactionDoors(area)
		local areaDoors = area:GetDoors()
		if(areaDoors) then
			local faction = area:GetFactionUID()
			local factionTbl = nut.faction.teams[faction]

			if(factionTbl) then
				for k, doorID in pairs(areaDoors) do
					local door = ents.GetMapCreatedEntity(doorID)
					if(!door) then continue end

					door.nutFactionID = factionTbl.uniqueID
					door:setNetVar("faction", factionTbl.index)

					local doorsPlugin = nut.plugin.list["doors"]
					doorsPlugin:SaveDoorData()
				end
			end
		end
	end

	function Areas.Capture.Start(ply)
		ply.InCaptureZone = true
	end

	function Areas.Capture.Stop(ply)
		ply.InCaptureZone = nil

		local timerID = Areas.GetTimerID(ply)
		if timer.Exists(timerID) then
			timer.Remove(timerID)
		end
	end

	function Areas.GetOwnerByID(areaID)

	end

	-- Sets a specific area data from the client (GUI menu), can only be used by admins.
	-- Might be worth moving to another file.
	net.Receive("AreasSetData", function(length, client)
		local dataID = net.ReadString()
		local areaID = net.ReadInt(32)
		local valueTbl = net.ReadTable()

		if(!client:IsAdmin()) then return end

		local area = Areas.Instances[areaID]
		if(area) then
			area["Set"..dataID](area, valueTbl[1])
		end

		Areas.SaveAreas()

		-- Hook that runs when data is updated
		hook.Run("AreaDataUpdated", dataID, area, valueTbl[1])
	end)

	-- Removes an area from the client, requires admin.
	-- Might be worth moving to another file.
	net.Receive("AreaRemove", function(length, client)
		local areaID = net.ReadInt(32)

		if(!client:IsSuperAdmin()) then return end

		local area = Areas.Instances[areaID]

		if SERVER then
			DiscordEmbed(jlib.SteamIDName(client) .. " has removed the '" .. area.Name .. "' from existence", "🚩 Area Deletion Log 🚩", Color(255, 0, 0), "BTeam") -- Added by Keith, for B-Team auditing
		end

		area:Remove()

		Areas.SaveAreas()

		client:notify("Area removed.")
	end)

	hook.Add("PlayerEnteredArea", "Capture", function(ply, area)
		if area.capture then
			Areas.Capture.Start(ply)
		end
	end)

	hook.Add("PlayerLeftArea", "Capture", function(ply, area)
		if area.capture then
			Areas.Capture.Stop(ply)
		end
	end)

	hook.Add("AreaDataUpdated", "CaptureDataUpdated", function(dataID, area, value)
		-- Only for faction changes
		if(dataID == "Faction") then
			Areas.SetFactionDoors(area)
		end
	end)
end

-- FIXME: Remove after deployment
--[[
local function areaDataFix()
	for k, area in pairs(Areas.Instances) do
		local factionIndex = area:GetFaction()
		if(factionIndex != -1) then
			local factionTbl = nut.faction.indices[factionIndex]
			area:SetFactionUID(factionTbl.uniqueID)
		end
	end
end

hook.Add("InitPostEntity", "AreasCapture", function()
	areaDataFix() -- FIXME
end)
--]]

-- Spawns player in owned areas if they have spawns.
local function areaFactionSpawn(client)
    local faction = client:getChar():getFaction()
	local factionTbl = nut.faction.indices[faction]

	if(!factionTbl) then return end

	local ownedAreas = Areas.GetOwnership(factionTbl.uniqueID)
	if(ownedAreas) then
		local posSpawns = {}

		-- Finds all the areas that have spawns in the list.
		for k, area in pairs(ownedAreas) do
			local spawns = area:GetSpawns()
			if(!table.IsEmpty(spawns)) then
				posSpawns[#posSpawns+1] = area
			end
		end

		-- Selects a random area and then selects a random spawn from it.
		local randomArea = table.Random(posSpawns)

		if(randomArea) then
			local randomSpawn = table.Random(randomArea:GetSpawns())

			if(randomSpawn) then
				client:SetPos(randomSpawn)
			end
		end
	end
end

hook.Add("PostPlayerLoadout" , "areaFactionSpawn", areaFactionSpawn)
