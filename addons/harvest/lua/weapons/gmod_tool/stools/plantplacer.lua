TOOL.Category = "Plant Spawner"
TOOL.Name = "Plant Spawn Placer"
TOOL.Information = {
	"left",
	"right"
}

TOOL.ClientConVar["RespawnRate"] = ""
TOOL.ClientConVar["PlantType"] = ""

if CLIENT then
	language.Add("tool.plantplacer.name", "Plant Spawn Placer")
	language.Add("tool.plantplacer.desc", "Place or remove plant spawn locations")
    language.Add("tool.plantplacer.left", "Adds a spawn")
    language.Add("tool.plantplacer.right", "Removes a spawn")
	language.Add("tool.plantplacer.0", "")
end

function TOOL:LeftClick(trace)
    if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

    if SERVER then
        self:GetOwner():notify("Adding plant spawn at " .. tostring(trace.HitPos))

		if self:GetClientInfo("PlantType") == "" or !tonumber(self:GetClientInfo("RespawnRate")) then
			self:GetOwner():notify("Please fill out the plant type and respawn rate.")
			return
		end

        Harvest.AddPlant(trace.HitPos, self:GetClientInfo("PlantType"), tonumber(self:GetClientInfo("RespawnRate")) or 120)
    end

    return true
end

function TOOL:RightClick(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

    if SERVER then
        local found = Harvest.RemoveClosestPlant(trace.HitPos)

        if isnumber(found) then
            self:GetOwner():notify("Removed plant spawn that was " .. math.Round(found) .. "m away")
        else
            self:GetOwner():notify("No plant spawns found!")
        end
    end

    return true
end

function TOOL:DrawHUD()
	if !self:GetOwner():IsSuperAdmin() then return end

    for i, plantSpawn in ipairs(Harvest.Spawns) do
        local pos = plantSpawn.pos:ToScreen()

        local d = 35
        surface.SetDrawColor(Color(200, 0, 0, 255))
        jlib.DrawCircle(pos.x - (d / 2), pos.y, d, 20)

        draw.SimpleText("Plant " .. "#" .. i, "PlantPlacer", pos.x - (d / 2), pos.y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function TOOL.BuildCPanel(panel)
	panel:SetName("Plant Spawn Placer")
    panel:Help("Left click to add a spawn, right click to remove one")

    local combo = panel:ComboBox("Plant Type", "plantplacer_PlantType")
	for id, plant in pairs(Harvest.Plants) do
		combo:AddChoice(id)
	end

    panel:NumSlider("Respawn Rate", "plantplacer_RespawnRate", 1, 3600)
end
