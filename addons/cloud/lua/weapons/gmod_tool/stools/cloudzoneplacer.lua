TOOL.Category = "Cloud Zones"
TOOL.Name = "Cloud Zone Placer"
TOOL.Information = {
	"left",
	"right",
	"reload"
}

TOOL.ClientConVar["DMG"] = "3"

if CLIENT then
	language.Add("tool.cloudzoneplacer.name", "The Cloud Placer")
	language.Add("tool.cloudzoneplacer.desc", "Place or remove cloud zones")
    language.Add("tool.cloudzoneplacer.left", "Adds a zone")
    language.Add("tool.cloudzoneplacer.right", "Removes a zone")
	language.Add("tool.cloudzoneplacer.reload", "Cancels the current zone creation")
	language.Add("tool.cloudzoneplacer.0", "")
end

function TOOL:LeftClick(trace)
    if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

    local dmg = self:GetClientNumber("DMG")

    if self:GetOwner().CloudMins then
        if SERVER then
            local mins = self:GetOwner().CloudMins
            local maxs = trace.HitPos

            TheCloud.AddZone(mins, maxs, dmg)

			self:GetOwner():notify("Added zone")
        end

        self:GetOwner().CloudMins = nil
    else
        self:GetOwner().CloudMins = trace.HitPos
    end

    return true
end

function TOOL:RightClick(trace)
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

    if SERVER then
        local zoneID = TheCloud.FindNearestZone(trace.HitPos)
		if zoneID then
        	TheCloud.RemoveZone(zoneID)

			self:GetOwner():notify("Removed zone")
		else
			self:GetOwner():notify("No zones found to remove!")
		end
    end

    return true
end

function TOOL:Reload()
	if !IsFirstTimePredicted() or !self:GetOwner():IsSuperAdmin() then return false end

	self:GetOwner().CloudMins = nil

	return false
end

function TOOL:DrawHUD()
	if !self:GetOwner():IsSuperAdmin() then return end

    if self:GetOwner().CloudMins then
        local mins = self:GetOwner().CloudMins

        cam.Start3D()
            render.DrawWireframeBox(mins, Angle(0, 0, 0), Vector(0, 0, 0), LocalPlayer():GetEyeTrace().HitPos - mins, Color(255, 255, 255, 255))
        cam.End3D()
    end

    for k, zone in pairs(TheCloud.Zones) do
        cam.Start3D()
            render.DrawWireframeBox(zone.mins, Angle(0, 0, 0), Vector(0, 0, 0), zone.maxs - zone.mins, Color(66, 244, 122, 255))
        cam.End3D()
    end
end

function TOOL.BuildCPanel(panel)
	panel:SetName("Cloud Zone Placer")
    panel:Help("Left click to add a zone, right click to remove one")

    panel:NumSlider("Damage", "cloudzoneplacer_DMG", 1, 100)
end