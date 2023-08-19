//Option tab

oobzones = {}
local oobTime --time until oobs activates
local inZone = false
local isImmune = false
local rate = 1
local radAmount

//net
net.Receive("oobzones_plyEnteredZone", function()
    inZone    = true
    isImmune  = net.ReadBool()
    if isImmune then return end

    oobTime = 10
	
	timer.Simple(0, function()
		LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0,0,0,200), 0.5, 0)
	end)
	
    if timer.Exists("oobCountDown") then timer.Remove("oobCountDown") end
    timer.Create("oobCountDown", 1, 0, function()
        if isImmune then return end
		
		if(oobTime > 0) then
			oobTime = oobTime - 1
		end
		
		surface.PlaySound("buttons/blip1.wav")
    end)
end)

net.Receive("oobzones_plyLeftZone", function()
    inZone = false

    if timer.Exists("oobCountDown") then timer.Remove("oobCountDown") end
end)

net.Receive("oobzones_updateImmune", function()
    isImmune = net.ReadBool()
end)

//HUD
local scrW = ScrW()
local scrH = ScrH()
local msg = "LEAVE RESTRICTED AREA"

hook.Add("HUDPaint", "oobZonesHUD", function()
	if(inZone and oobTime and !isImmune) then
		surface.SetFont("Trebuchet24")
		local textW = surface.GetTextSize(msg)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(scrW*0.5 - textW*0.5, scrH*0.4) --rad text 5 pixels to the left of the rad symbol
		surface.DrawText(msg)
		
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(scrW*0.5 - 4, scrH*0.45) --rad text 5 pixels to the left of the rad symbol
		surface.DrawText(oobTime)
	end
end)

local screenEffects = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0.1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

hook.Add("RenderScreenspaceEffects", "oobZonesEffects", function()
	if(inZone and oobTime and !isImmune) then
		DrawMaterialOverlay("models/shadertest/shader4", 0.05)
		DrawColorModify(screenEffects) --Draws Color Modify effect
	end
end)

local function receiveZone(zone) --Initializes area, center and ID
    local centerX = (zone.startPos.x + zone.endPos.x)/2
    local centerY = (zone.startPos.y + zone.endPos.y)/2
    local centerZ = (zone.startPos.z + zone.endPos.z)/2
    local center = Vector(centerX, centerY, centerZ)
    zone.center = center

    local w = zone.endPos.x - zone.startPos.x
    local h = zone.endPos.y - zone.startPos.y
    local area = w*h
    if area < 0 then area = area * -1 end --make sure its always positive
    zone.area = area

    local id = table.insert(oobzones, zone)
    oobzones[id]["id"] = id
end

//Receive batch of zones
net.Receive("oobzones_sendZones", function()
    local initZones = net.ReadTable()
    for k,v in pairs(initZones) do
		receiveZone(v)
    end
end)

//Receive new zones
net.Receive("oobzones_zoneCreated", function()
    local newZone = net.ReadTable()
    receiveZone(newZone)
end)

//Remove zones
net.Receive("oobzones_announceRemoveZone", function()
    local oldZone = net.ReadTable()

    for k,v in pairs(oobzones) do
        if v.startPos == oldZone.startPos and v.endPos == oldZone.endPos then
            oobzones[k] = nil
            return
        end
    end

    //Given that the zone was removed we should have exited the function by now, if this is not the case throw an error
    print("Attempt to remove client-side OOB zone failed")
end)