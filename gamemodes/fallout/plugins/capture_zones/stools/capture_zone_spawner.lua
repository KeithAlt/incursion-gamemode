TOOL.Category = "Capture Zones"
TOOL.Name = "#tool.capture_zone_spawner.name"

if CLIENT then
	language.Add("tool.capture_zone_spawner.name", "Create NPC Spawner")
	language.Add("tool.capture_zone_spawner.desc", "Create an NPC Spawner, for use in zones.")
	language.Add("tool.capture_zone_spawner.left", "Create a spawner.")
	language.Add("tool.capture_zone_spawner.right", "Remove a spawner.")
	language.Add("tool.capture_zone_spawner.help", "This creates a spawner for the selected NPC to be created from. Cannot be used outside of zones.")
end

//TOOL.ClientConVar["group"] = 52

TOOL.Information = {
	{name = "left"},
	{name = "right"},
}

function TOOL:LeftClick(trace)
	if not trace.HitPos or IsValid(trace.Entity) and trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()

	if not ply:IsSuperAdmin() then return end

	local entity = ents.Create("zone_spawner")
	entity:SetPos(trace.HitPos)
	entity:SetAngles(Angle(0,0,0))
	entity:Spawn()

	return true
end

function TOOL:RightClick(trace)
	if not trace.HitPos or IsValid(trace.Entity) and trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	for k,v in next, ents.FindInSphere(trace.HitPos, 16) do
		if v:GetClass() == "zone_spawner" then
			v:Remove()
			break
		end
	end

	return true
end

function TOOL:Think()

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {Description = "#tool.capture_zone_spawner.help"})
end
