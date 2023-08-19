TOOL.Category = "Capture Zones"
TOOL.Name = "#tool.capture_zone_create.name"

if CLIENT then
	language.Add("tool.capture_zone_create.name", "Create Capture Zone")
	language.Add("tool.capture_zone_create.desc", "Create a new capture zone.")
	language.Add("tool.capture_zone_create.left", "Create a zone.")
	language.Add("tool.capture_zone_create.right", "Remove a zone.")
	language.Add("tool.capture_zone_create.help", "This creates new zones.")
end

TOOL.ClientConVar["radius"] = 300
TOOL.ClientConVar["faction"] = "none"
TOOL.ClientConVar["budget"] = 30
TOOL.ClientConVar["max_npcs"] = 6

TOOL.Information = {
	{name = "left"},
	{name = "right"},
}

function TOOL:LeftClick(trace)
	if not trace.HitPos or IsValid(trace.Entity) and trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()
	local radius = self:GetClientNumber("radius", 300)
	local faction = self:GetClientInfo("faction")
	local budget = self:GetClientNumber("budget", 30)
	local zone = nut.plugin.list["capture_zones"]:CreateNewZone(trace.HitPos, radius, faction, true)
	zone.DefaultBudget = budget
	zone.MaxNPCs = self:GetClientNumber("max_npcs", 6)

	return true
end

function TOOL:RightClick(trace)
	if not trace.HitPos or IsValid(trace.Entity) and trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	local plugin = nut.plugin.list["capture_zones"]
	for k,v in next, plugin.ActiveZones do
		if v:GetPosition():Distance(trace.HitPos) <= 16 then
			v:Destroy(true)
		end
	end
	
	return true
end

function TOOL:Think()

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {Description = "#tool.capture_zone_create.help"})
	
	CPanel:NumberWang("Zone Radius", "capture_zone_create_radius", 50, 1000, 0)
	CPanel:NumberWang("Zone Budget", "capture_zone_create_budget", 10, 100, 0)
	CPanel:NumberWang("Zone Max NPCs", "capture_zone_create_max_npcs", 1, 20, 0)
	
	local combo,label = CPanel:ComboBox("Zone Default Faction", "capture_zone_create_faction")
	combo:AddChoice("none")
	for k,v in next, nut.faction.teams do
		combo:AddChoice(k)
	end
end