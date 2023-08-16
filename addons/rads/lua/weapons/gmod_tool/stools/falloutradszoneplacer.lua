TOOL.Category = "Radiation Zones"
TOOL.Name = "Radiation Zone Placer"
TOOL.Information = {
	"left",
	"right",
	"reload"
}
TOOL.Command = nil
TOOL.ConfigName = "" --internal config

TOOL.ClientConVar[ "radAmount" ] = "1"

if CLIENT then

		language.Add("tool.falloutradszoneplacer.name", "Fallout Radiation Zone Placer")
		language.Add("tool.falloutradszoneplacer.desc", "Place or remove radiation zones")
        language.Add("tool.falloutradszoneplacer.left", "Adds a zone")
        language.Add("tool.falloutradszoneplacer.right", "Removes a zone")
		language.Add("tool.falloutradszoneplacer.reload", "Cancels the current zone creation")

end

function TOOL.BuildCPanel(panel)
	panel:SetName("Radiation zone placer")

    panel:NumSlider("Radiation lethality", "falloutRadsZonePlacer_radAmount", 1,  100)
end

if SERVER then return end

local startPos
local endPos
function TOOL:LeftClick(trace)
    if !IsFirstTimePredicted() then return false end --prevents the function being ran more than once per click

    if !startPos then startPos = trace.HitPos return true end
    endPos = trace.HitPos
    local lethality = self:GetClientInfo("radAmount", nil)

    --Check if a lethality value was entered
    if lethality == "" then
        nut.util.notify("You must first choose a lethality number")
        return false
    end

    --Send net message that creates a spawn point and then saves it
    net.Start("radzones_sendZone")
        net.WriteVector(startPos)
        net.WriteVector(endPos)
        net.WriteInt(lethality, 16)
    net.SendToServer()

    --Reset the start and end pos values
    startPos = nil
    endPos = nil
    nut.util.notify("Successfully created new radiation zone")
    return true
end

function TOOL:RightClick(trace)
	if !IsFirstTimePredicted() then return false end --prevents the function being ran more than once per click

    //remove the closest zone
	net.Start("radzones_removeZone")
		net.WriteVector(trace.HitPos)
	net.SendToServer()
	return true
end

function TOOL:Reload()
	if !IsFirstTimePredicted() then return false end --prevents the function being ran more than once

    if startPos then startPos = nil end
end

function TOOL:DrawHUD()
    //Draw the zone we are creating
    if startPos and !endPos then
        cam.Start3D()
            local hitpos = LocalPlayer():GetEyeTrace().HitPos
            local maxs = hitpos - startPos
            render.DrawWireframeBox(startPos, Angle(0, 0, 0), Vector(0, 0, 0), maxs, Color(255, 255, 255, 255))
        cam.End3D()
    end

	//Draw all existing zones
	if #zones == 0 then return end
	for k,v in pairs(zones) do
		cam.Start3D()
            local maxs = v.endPos - v.startPos
            render.DrawWireframeBox(v.startPos, Angle(0, 0, 0), Vector(0, 0, 0), maxs, Color(66, 244, 122, 255))
        cam.End3D()
	end
end