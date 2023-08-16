TOOL.Category = "Areas"
TOOL.Name = "Area Creator"
TOOL.Information = {
	"left",
	"right",
	"reload"
}

TOOL.ClientConVar["Name"] = "Name"
TOOL.ExtraZ = 200

local function areaChatPrint(ply, header, text)
	jlib.Announce(ply, Color(255,255,0), "[AREA TOOL] ", Color(255,255,155), header, Color(255,255,255), ("\n" .. text or ""))
end

if(SERVER) then
	-- Networking so the toolgun can stay in sync for server and client
	net.Receive("AreasSpawnMode", function(length, client)
		local status = net.ReadBool()

		if(!client:IsSuperAdmin()) then return end

		client.addingSpawn = status
	end)

	net.Receive("AreasDoorMode", function(length, client)
		local status = net.ReadBool()

		if(!client:IsAdmin()) then return end

		client.addingDoor = status
	end)

	-- Most of door linking function is serverside since :MapCreationID() is serverisde.
	net.Receive("AreasDoorAdd", function(length, client)
		local areaID = net.ReadInt(32)
		local door = net.ReadEntity()

		if(!client:IsSuperAdmin()) then return end

		local area = Areas.Instances[areaID]

		if(area) then
			local doorID = door:MapCreationID()

			local curDoors = area:GetDoors()

			-- Removes door if it's already in there
			local removing = false
			for k, v in pairs(curDoors) do
				if(v == doorID) then
					removing = true

					table.remove(curDoors, k)

					-- Removes faction from door
					door.nutFactionID = nil
					door:setNetVar("faction", nil)

					areaChatPrint(client, "Door removed", "Door" ..doorID.. " unlinked from area.")
					break
				end
			end

			-- Adds door if it's not already in there
			if(!removing) then
				table.insert(curDoors, doorID)

				areaChatPrint(client, "Door added", "Door" ..doorID.. " linked to area.")
			end

			area:SetDoors(curDoors)
			Areas.SetFactionDoors(area) -- Sets all linked doors to the area's faction
		end
	end)

	util.AddNetworkString("AreasSpawnMode")
	util.AddNetworkString("AreasDoorMode")
	util.AddNetworkString("AreasDoorAdd")
else
	language.Add("tool.areas.name", "Area Creator")
	language.Add("tool.areas.desc", "Create, remove and manage areas")
    language.Add("tool.areas.left", "Adds an area")
    language.Add("tool.areas.right", "Cancels the current area creation")
	language.Add("tool.areas.reload", "Opens area management menu")
	language.Add("tool.areas.0", "")
end

-- This function handles linking a door to an area, also removing.
local function addDoor(trace, client)
	local door = trace.Entity

	if(!(IsValid(door) and door:isDoor())) then -- Makes sure it's a valid door.
		return false
	end

	net.Start("AreasDoorAdd")
		net.WriteInt(client.selectedArea.ID, 32)
		net.WriteEntity(door)
	net.SendToServer()
end

-- This function handles adding a spawn with the toolgun, removes existing spawns if used close to an existing one
local function addSpawn(trace, client)
	local spawnPos = trace.HitPos

	local curSpawns = client.selectedArea:GetSpawns()

	-- Removes spawn if it is close to the attempted spawn add
	local removing = false
	for k, v in pairs(curSpawns) do
		if(spawnPos:DistToSqr(v) < 500) then
			table.remove(curSpawns, k)

			areaChatPrint(client, "Spawn Removed", "Spawn at " ..(v.x).. ", " ..(v.y).. ", " ..(v.z).. " removed from area.")

			removing = true
			break
		end
	end

	-- Don't add a new spawn if we just removed one there.
	if(!removing) then
		table.insert(curSpawns, spawnPos)

		areaChatPrint(client, "Spawn Add", "Spawn at " ..(spawnPos.x).. ", " ..(spawnPos.y).. ", " ..(spawnPos.z).. " added to area.")
	end

	net.Start("AreasSetData")
		net.WriteString("Spawns")
		net.WriteInt(client.selectedArea.ID, 32)
		net.WriteTable({curSpawns})
	net.SendToServer()
end

function TOOL:LeftClick(trace)
    if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

	local client = self:GetOwner()

	if(client.addingDoor) then -- Door adding
		if(CLIENT) then
			addDoor(trace, client)
		end
	elseif(client.addingSpawn) then -- Spawn adding
		if(CLIENT) then
			addSpawn(trace, client)
		end
	elseif self.Vec then
        if SERVER then
			local name = self:GetClientInfo("Name")

            local mins = self.Vec
            local maxs = trace.HitPos + self:GetExtraZ(trace)

            local area = Areas.Instance()
			area:SetBounds(mins, maxs)
			area:SetName(name)

			areaChatPrint(client, "Area Add", "Added area")

			Areas.SaveAreas()
        end

        self.Vec = nil
    else
        self.Vec = trace.HitPos
    end

    return true
end

function TOOL:RightClick(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

	local client = self:GetOwner()

	self.Vec = nil

	if(CLIENT) then
		if(client.addingSpawn) then
			jlib.RequestBool("Cancel spawn placement mode?", function(bool)
				if !bool then return end

				local nearestArea, dist = self:GetNearestArea(trace.HitPos)

				client.addingSpawn = nil
				client.selectedArea = nil

				net.Start("AreasSpawnMode")
					net.WriteBool(false)
				net.SendToServer()
			end, ply, "Yes", "No", "")
		elseif(client.addingDoor) then
			jlib.RequestBool("Cancel door linking mode?", function(bool)
				if !bool then return end

				local nearestArea, dist = self:GetNearestArea(trace.HitPos)

				client.addingDoor = nil
				client.selectedArea = nil

				net.Start("AreasDoorMode")
					net.WriteBool(false)
				net.SendToServer()
			end, ply, "Yes", "No", "")
		end
	end

    return false
end

function TOOL:Reload(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

	local client = self:GetOwner()

	self.Vec = nil

	if CLIENT and trace.Hit then
		local nearestArea, dist = self:GetNearestArea(trace.HitPos)
		if(!nearestArea) then return end

		local frame = vgui.Create("DFrame")
		frame:SetSize(400, 600)
		frame:SetTitle("Area " ..nearestArea.ID)
		frame:MakePopup()
		frame:Center()

		-- Makes text entries for all these area vars
		local textEntries = {
			["Name"] = "Name",
		}

		for varID, varName in pairs(textEntries) do
			-- Label for the text entry
			local label = frame:Add("DLabel")
			label:Dock(TOP)
			label:DockMargin(5,5,5,0)
			label:SetText(varName)

			-- Text entry box
			local textEntry = frame:Add("DTextEntry")
			textEntry:Dock(TOP)
			textEntry:DockMargin(5,5,5,0)
			textEntry:SetText(nearestArea["Get" ..varID](nearestArea))
			function textEntry:OnValueChange(text)
				-- Networking that changes data on server, requires admin
				net.Start("AreasSetData")
					net.WriteString(varID)
					net.WriteInt(nearestArea.ID, 32)
					net.WriteTable({text})
				net.SendToServer()
			end
		end

		-- Makes checkboxes for all these area vars
		local checkboxes = {
			["OutOfBounds"] = "Out of Bounds",
			["Capture"] = "Capturable",
		}

		for varID, varName in pairs(checkboxes) do
			local checkbox = frame:Add("DCheckBoxLabel")
			checkbox:Dock(TOP)
			checkbox:DockMargin(5,5,5,0)
			checkbox:SetChecked(nearestArea["Get" ..varID](nearestArea))
			checkbox:SetText(varName)
			function checkbox:OnChange(checkValue)
				-- Networking that changes data on server, requires admin
				net.Start("AreasSetData")
					net.WriteString(varID)
					net.WriteInt(nearestArea.ID, 32)
					net.WriteTable({checkValue})
				net.SendToServer()
			end
		end

		-- Factions are the only thing that currently has choices like this, so they get a combo box.
		frame.faction = frame:Add("DComboBox")
		frame.faction:Dock(TOP)
		frame.faction:DockMargin(5,5,5,0)

		-- Adds all the factions to the possible choices
		for _, faction in pairs(nut.faction.teams) do
			frame.faction:AddChoice(faction.name, faction.index)
		end

		local areaFaction = nearestArea:GetFactionUID()
		local factionTbl = nut.faction.teams[areaFaction]
		if(factionTbl) then
			local factionName = factionTbl.name
			frame.faction:SetText(factionName)
		else
			frame.faction:SetText("")
		end

		function frame.faction:OnSelect(index, value, data)
			if(nut.faction.indices[tonumber(data)]) then
				local factionUID = nut.faction.indices[tonumber(data)].uniqueID

				-- Networking that changes data on server, requires admin
				net.Start("AreasSetData")
					net.WriteString("FactionUID")
					net.WriteInt(nearestArea.ID, 32)
					net.WriteTable({factionUID})
				net.SendToServer()
			end
		end

		-- Button that toggles spawn placing for nearest area
		frame.spawns = frame:Add("DButton")
		frame.spawns:Dock(TOP)
		frame.spawns:DockMargin(5,5,5,0)
		frame.spawns:SetText("Spawns Configuration")
		frame.spawns.DoClick = function()
			local spawnsFrame = vgui.Create("DFrame")
			spawnsFrame:SetSize(500, 300)
			spawnsFrame:SetTitle("Area Spawns")
			spawnsFrame:MakePopup()
			spawnsFrame:Center()

			local spawnsList = spawnsFrame:Add("DListView")
			spawnsList:Dock(TOP)
			spawnsList:DockMargin(5,5,5,0)
			spawnsList:SetHeight(200)
			spawnsList:AddColumn("Spawn")
			spawnsList:SetMultiSelect(false)

			local curSpawns = nearestArea:GetSpawns()
			for k, v in pairs(curSpawns) do
				spawnsList:AddLine(v.x..","..v.y..","..v.z)
			end

			local spawnsAdd = spawnsFrame:Add("DButton")
			spawnsAdd:Dock(TOP)
			spawnsAdd:DockMargin(5,5,5,0)
			spawnsAdd:SetText("Add Spawns")
			spawnsAdd.DoClick = function()
				client.addingSpawn = true
				client.selectedArea = nearestArea

				net.Start("AreasSpawnMode")
					net.WriteBool(true)
				net.SendToServer()

				areaChatPrint(client, "Spawn Mode", "Left click to add a spawn. Right click to cancel.")

				frame:Close()
				spawnsFrame:Close()
			end

			local spawnsRemove = spawnsFrame:Add("DButton")
			spawnsRemove:Dock(TOP)
			spawnsRemove:DockMargin(5,5,5,0)
			spawnsRemove:SetText("Delete Spawn")
			spawnsRemove.DoClick = function()
				local selectedLine = spawnsList:GetSelectedLine()

				if(selectedLine) then
					spawnsList:RemoveLine(selectedLine)

					curSpawns[selectedLine] = nil

					net.Start("AreasSetData")
						net.WriteString("Spawns")
						net.WriteInt(nearestArea.ID, 32)
						net.WriteTable({curSpawns})
					net.SendToServer()
				end
			end
		end

		-- Button that toggles spawn placing for nearest area
		frame.doors = frame:Add("DButton")
		frame.doors:Dock(TOP)
		frame.doors:DockMargin(5,5,5,0)
		frame.doors:SetText("Doors Configuration")
		frame.doors.DoClick = function()
			local doorsFrame = vgui.Create("DFrame")
			doorsFrame:SetSize(500, 300)
			doorsFrame:SetTitle("Doors")
			doorsFrame:MakePopup()
			doorsFrame:Center()

			local doorsList = doorsFrame:Add("DListView")
			doorsList:Dock(TOP)
			doorsList:DockMargin(5,5,5,0)
			doorsList:SetHeight(200)
			doorsList:AddColumn("Entities")
			doorsList:SetMultiSelect(false)

			local curDoors = nearestArea:GetDoors()
			for k, v in pairs(curDoors) do
				doorsList:AddLine(v)
				--doorsList:AddLine(v.x..","..v.y..","..v.z)
			end

			local doorsAdd = doorsFrame:Add("DButton")
			doorsAdd:Dock(TOP)
			doorsAdd:DockMargin(5,5,5,0)
			doorsAdd:SetText("Link Doors")
			doorsAdd.DoClick = function()
				client.addingDoor = true
				client.selectedArea = nearestArea

				net.Start("AreasDoorMode")
					net.WriteBool(true)
				net.SendToServer()

				areaChatPrint(client, "Door Add", "Left click on a door to add it to the area. Right click to cancel.")

				frame:Close()
				doorsFrame:Close()
			end

			local doorsRemove = doorsFrame:Add("DButton")
			doorsRemove:Dock(TOP)
			doorsRemove:DockMargin(5,5,5,0)
			doorsRemove:SetText("Unlink Door")
			doorsRemove.DoClick = function()
				local selectedLine = doorsList:GetSelectedLine()

				if(selectedLine) then
					doorsList:RemoveLine(selectedLine)

					curDoors[selectedLine] = nil

					net.Start("AreasSetData")
						net.WriteString("Doors")
						net.WriteInt(nearestArea.ID, 32)
						net.WriteTable({curDoors})
					net.SendToServer()
				end
			end
		end

		-- Button that opens music configuration menu
		frame.music = frame:Add("DButton")
		frame.music:Dock(TOP)
		frame.music:DockMargin(5,5,5,0)
		frame.music:SetText("Music Configuration")
		frame.music.DoClick = function()
			Areas.Music.OpenConfig(nearestArea)
		end

		-- Button that deletes the area
		frame.delete = frame:Add("DButton")
		frame.delete:Dock(BOTTOM)
		frame.delete:DockMargin(5,5,5,0)
		frame.delete:SetText("Delete Area")
		frame.delete.DoClick = function()
			Derma_Query("Are you sure you want to delete this area?", "Delete Area?", "Yes", function()
				net.Start("AreaRemove")
					net.WriteInt(nearestArea.ID, 32)
				net.SendToServer()

				frame:Remove()
			end, "No")
		end
    end

	return false
end

function TOOL:GetExtraZ(trace)
	return Vector(0, 0, (self.Vec and self.Vec.z <= trace.HitPos.z) and self.ExtraZ or 0)
end

function TOOL:GetNearestArea(vec)
	local shortestDist, nearestArea

	for i, area in pairs(Areas.Instances) do
		if !nearestArea then
			nearestArea = area
			shortestDist = area:Distance(vec)
			continue
		end

		local curDist = area:Distance(vec)
		if curDist < shortestDist then
			nearestArea = area
			shortestDist = curDist
		end
	end

	return nearestArea, shortestDist
end

function TOOL:DrawHUD()
	local client = self:GetOwner()
	if !client:IsSuperAdmin() then return end

	local trace = LocalPlayer():GetEyeTrace()

	cam.Start3D()
		render.SetColorMaterial()

    	for i, area in pairs(Areas.Instances) do
			area:Draw()

			if area and LocalPlayer().addingSpawn then
				for _, spawnPos in pairs(area:GetSpawns()) do
					render.DrawLine(spawnPos, spawnPos + Vector(0, 0, 60), Color(0, 0, 255))
				end
			end
		end

		if trace.Hit then
			if self.Vec then
				render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), self.Vec, trace.HitPos + self:GetExtraZ(trace), Color(70, 221, 70, 255), false)
			end

			local nearestArea, dist = self:GetNearestArea(trace.HitPos)
			if nearestArea and dist < nearestArea:GetPerimeter() / 2 then
				render.DrawLine(trace.HitPos, nearestArea:GetCenter(), Color(255, 0, 0))
			end
		end
	cam.End3D()
end

function TOOL.BuildCPanel(panel)
	panel:SetName("Area Creator")
    panel:Help("Left click to add an area, right click to remove one")

    panel:TextEntry("Name", "areas_Name")
end
