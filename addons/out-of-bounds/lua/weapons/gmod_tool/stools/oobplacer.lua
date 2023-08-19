TOOL.Category = "Out of Bounds Zones"
TOOL.Name = "Out of Bounds Zone Placer"
TOOL.Information = {
	"left",
	"right",
	"reload"
}
TOOL.Command = nil
TOOL.ConfigName = "" --internal config

if CLIENT then
	language.Add("tool.oobplacer.name", "Out of Bounds Zone Placer")
	language.Add("tool.oobplacer.desc", "Place or remove out of bounds zones")
    language.Add("tool.oobplacer.left", "Adds a zone")
    language.Add("tool.oobplacer.right", "Removes a zone")
	language.Add("tool.oobplacer.reload", "Cancels the current zone creation")
end

function TOOL.BuildCPanel(panel)
	--panel:SetName("Out of Bounds Zone")
end

if SERVER then return end

local startPos
local endPos
function TOOL:LeftClick(trace)
    if !IsFirstTimePredicted() then return false end --prevents the function being ran more than once per click

    if !startPos then startPos = trace.HitPos return true end
    endPos = trace.HitPos

    --Send net message that creates a spawn point and then saves it
    net.Start("oobzones_sendZone")
        net.WriteVector(startPos)
        net.WriteVector(endPos)
    net.SendToServer()

    --Reset the start and end pos values
    startPos = nil
    endPos = nil
    nut.util.notify("Successfully created new out of bounds zone")
    return true
end

function TOOL:RightClick(trace)
	if !IsFirstTimePredicted() then return false end --prevents the function being ran more than once per click

    //remove the closest zone
	net.Start("oobzones_removeZone")
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
	if #oobzones == 0 then return end
	for k,v in pairs(oobzones) do
		cam.Start3D()
            local maxs = v.endPos - v.startPos
            render.DrawWireframeBox(v.startPos, Angle(0, 0, 0), Vector(0, 0, 0), maxs, Color(66, 244, 122, 255))
        cam.End3D()
	end
end