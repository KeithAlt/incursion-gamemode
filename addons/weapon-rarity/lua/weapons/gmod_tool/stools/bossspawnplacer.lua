TOOL.Category = "NPC Spawner"
TOOL.Name = "Boss Spawn Placer"
TOOL.Information = {
	"left",
	"right"
}

TOOL.ClientConVar["NPC"] = ""
TOOL.ClientConVar["Drops"] = ""

if CLIENT then
	language.Add("tool.bossspawnplacer.name", "Boss Spawn Placer")
	language.Add("tool.bossspawnplacer.desc", "Place or remove boss spawn locations")
	language.Add("tool.bossspawnplacer.left", "Adds a spawn")
	language.Add("tool.bossspawnplacer.right", "Removes a spawn")
	language.Add("tool.bossspawnplacer.0", "")
end

function TOOL:LeftClick(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

	if SERVER then
		local dat = {}
		dat.pos = trace.HitPos
		dat.npc = self:GetClientInfo("NPC")
		dat.drops = tonumber(self:GetClientInfo("Drops")) or 1

		self:GetOwner():notify("Adding boss spawn at " .. tostring(dat.pos))

		wRarity.AddBossSpawn(dat)
	end

	return true
end

function TOOL:RightClick(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

	if SERVER then
		local bossSpawn, dist, id = wRarity.FindNearestBossSpawn(trace.HitPos)

		if bossSpawn then
			wRarity.RemoveBossSpawn(id)

			self:GetOwner():notify("Removed boss spawn that was " .. math.Round(dist) .. "m away")
		else
			self:GetOwner():notify("No boss spawns found!")
		end
	end

	return true
end

function TOOL:DrawHUD()
	if !self:GetOwner():IsSuperAdmin() then return end

	for k, bossSpawn in ipairs(wRarity.BossSpawns) do
		local pos = bossSpawn.pos:ToScreen()

		local d = 35
		surface.SetDrawColor(wRarity.Config.Rarities[#wRarity.Config.Rarities].color)
		jlib.DrawCircle(pos.x - (d / 2), pos.y, d, 20)

		draw.SimpleText("Boss " .. "#" .. k, "wRaritySmall", pos.x - (d / 2), pos.y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end


function TOOL.BuildCPanel(panel)
	panel:SetName("Boss Spawn Placer")
	panel:Help("Left click to add a spawn, right click to remove one")

	panel:TextEntry("NPC Type", "bossspawnplacer_NPC")
	panel:NumSlider("Amount of Drops", "bossspawnplacer_Drops", 1, 10)
end
