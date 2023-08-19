TOOL.Category = "NPC Spawner"
TOOL.Name = "NPC Spawn Placer"
TOOL.Information = {
	"left",
	"right"
}
TOOL.Command = nil
TOOL.ConfigName = "" --internal config

TOOL.ClientConVar["spawnInterval"]  = "10"
TOOL.ClientConVar["npcSpawnRadius"] = "500"
TOOL.ClientConVar["NPCtype1"]       = ""
TOOL.ClientConVar["NPCtype2"]       = ""
TOOL.ClientConVar["NPCtype3"]       = ""
TOOL.ClientConVar["NPCtype4"]       = ""
TOOL.ClientConVar["NPCtype5"]       = ""
TOOL.ClientConVar["DropsEnabled"]   = "false"

if CLIENT then

		language.Add("tool.npcspawnplacer.name", "NPC Spawn Placer")
		language.Add("tool.npcspawnplacer.desc", "Place or remove NPC spawn locations")
        language.Add("tool.npcspawnplacer.left", "Adds a spawn")
        language.Add("tool.npcspawnplacer.right", "Removes a spawn")
		language.Add("tool.npcspawnplacer.0", " ")

		--Init the spawn points ready for the hud
		net.Start("jonjoGetSpawnPoints")
		net.SendToServer()


		--Receive the spawnpoints
		net.Receive("jonjoSendSpawnPoints", function()
			spawnPoints = net.ReadTable()
		end)

		--Material cache
		spawnPointMaterial = Material("spawnpoint.png")

end

if SERVER then return end

function TOOL:LeftClick(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

    --spawn place shit
    local vector = trace.HitPos
    local spawnInterval = math.Round(self:GetClientNumber("spawnInterval", 10))
    local radius =  math.Round(self:GetClientNumber("npcSpawnRadius", 500))

    --create the table to send using data we just got
    local dataTable = {}
    dataTable.npcs = {}
    dataTable.vector        = vector
    dataTable.spawnInterval = spawnInterval
    dataTable.radius        = radius
	dataTable.DropsEnabled  = tobool(self:GetClientInfo("DropsEnabled"))
	print(dataTable.DropsEnabled)

    local NPCtype1
    local NPCtype2
    local NPCtype3
    local NPCtype4
    local NPCtype5

    --Add NPCs if they exist
    if self:GetClientInfo("NPCtype1", nil) != "" then
        NPCtype1 = self:GetClientInfo("NPCtype1", nil)
        table.insert(dataTable.npcs, NPCtype1)
    end
    if self:GetClientInfo("NPCtype2", nil) != "" then
        NPCtype2 = self:GetClientInfo("NPCtype2", nil)
        table.insert(dataTable.npcs, NPCtype2)
    end
    if self:GetClientInfo("NPCtype3", nil) != "" then
        NPCtype3 = self:GetClientInfo("NPCtype3", nil)
        table.insert(dataTable.npcs, NPCtype3)
    end
    if self:GetClientInfo("NPCtype4", nil) != "" then
        NPCtype4 = self:GetClientInfo("NPCtype4", nil)
        table.insert(dataTable.npcs, NPCtype4)
    end
    if self:GetClientInfo("NPCtype5", nil) != "" then
        NPCtype5 = self:GetClientInfo("NPCtype5", nil)
        table.insert(dataTable.npcs, NPCtype5)
    end
    if !NPCtype1 and !NPCtype2 and !NPCtype3 and !NPCtype4 and !NPCtype5 then
        dataTable.npcs = nil
    end

    --Send net message that creates a spawn point and then saves it
    if dataTable.npcs then --only send if some NPCs were entered
        net.Start("jonjoSendSpawn")
            net.WriteTable(dataTable)
        net.SendToServer()
		return true
    else
        LocalPlayer():ChatPrint("ERROR: You must specify at least one NPC for the spawn point.")
		return false
    end
end

function TOOL:RightClick(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

	net.Start("jonjoRemoveSpawn")
		net.WriteVector(trace.HitPos)
	net.SendToServer()
	return true
end

function TOOL:Deploy()
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end
	net.Start("jonjoGetSpawnPoints")
	net.SendToServer()
end

function TOOL:Reload()
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

	net.Start("jonjoGetSpawnPoints")
	net.SendToServer()
end

function TOOL:DrawHUD()
	if !self:GetOwner():IsSuperAdmin() then return end

	if spawnPoints then
		for k,v in pairs (spawnPoints) do
			pos = v:ToScreen()
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(spawnPointMaterial)
			surface.DrawTexturedRect(pos.x - 25, pos.y - 25, 50, 50)
		end
	end

end


function TOOL.BuildCPanel(panel)
	panel:SetName("NPC Spawn Placer")
    panel:Help("Left click to add a spawn, right click to remove one")

    panel:NumSlider("Spawn Interval", "NPCSpawnPlacer_spawnInterval", 1,  120)
    panel:NumSlider("Radius", "NPCSpawnPlacer_npcSpawnRadius", 100,  2500)
    panel:TextEntry("NPC Type", "NPCSpawnPlacer_NPCtype1")
    panel:TextEntry("NPC Type", "NPCSpawnPlacer_NPCtype2")
    panel:TextEntry("NPC Type", "NPCSpawnPlacer_NPCtype3")
    panel:TextEntry("NPC Type", "NPCSpawnPlacer_NPCtype4")
    panel:TextEntry("NPC Type", "NPCSpawnPlacer_NPCtype5")

	panel:CheckBox("Drops Enabled", "NPCSpawnPlacer_DropsEnabled")
end