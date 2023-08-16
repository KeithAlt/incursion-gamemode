captureZonesConfig.renderDistance = 1000

/* Networking */
netstream.Hook("ReceiveZones", function(zones)
	local PLUGIN = nut.plugin.list["capture_zones"]

	for k,v in next, zones do
		local zone = setmetatable({}, PLUGIN.Zone)

		if v.faction and v.faction != "none" then
			zone:SetOwnerFaction(v.faction)
		end
		zone:SetPosition(v.pos)
		zone:SetRadius(v.radius)

		zone.id = k
		PLUGIN.ActiveZones[k] = zone
	end
end)

netstream.Hook("NewZoneCreated", function(zone)
	local PLUGIN = nut.plugin.list["capture_zones"]
	local object = setmetatable({}, PLUGIN.Zone)

	if zone.faction and zone.faction != "none" then
		object:SetOwnerFaction(zone.faction)
	end
	object:SetPosition(zone.pos)
	object:SetRadius(zone.radius)

	object.id = zone.id
	PLUGIN.ActiveZones[zone.id] = object
end)

netstream.Hook("DestroyZone", function(id)
	local PLUGIN = nut.plugin.list["capture_zones"]
	local zone = PLUGIN.ActiveZones[id]

	if zone then
		zone:Destroy()
	end
end)

/* Hooks */
function PLUGIN:InitPostEntity()
	netstream.Start("RequestCaptureZones")
	-- Thank you Garry.
	hook.GetTable()["OnGamemodeLoaded"]["CreateSpawnMenu"]()
end

function PLUGIN:PostDrawOpaqueRenderables(drawing_depth, drawing_skybox)
	-- Reset everything

	render.SetStencilWriteMask(0xFF)
	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()


	render.SetStencilEnable(true)

	for k,v in next, self.ActiveZones do
		local radius = v:GetRadius()
		local zonePos = v:GetPosition()
		local distance = LocalPlayer():GetPos():Distance(zonePos)
		render.SetColorMaterial()
		if LocalPlayer():IsAdmin() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then
			render.DrawSphere(zonePos, 16, 25, 25, Color(0,255,0,120))
		end
		if distance > radius + captureZonesConfig.renderDistance then continue end --render distance
		-- Set the reference value to 1. This is what the compare function tests against
		render.SetStencilReferenceValue(1)
		-- Force everything to fail
		render.SetStencilCompareFunction(STENCIL_NEVER)
		-- Save all the things we don't draw
		render.SetStencilFailOperation(STENCIL_REPLACE)

		render.DrawBox(zonePos, Angle(0,0,0), Vector(-radius, -radius, 0), Vector(radius, radius, 32), Color(255,0,0), true)

		-- Render all pixels that have their stencil value as 1
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		-- Don't modify the stencil buffer when things fail
		render.SetStencilFailOperation(STENCIL_KEEP)

		local faction_color = Color(100, 100, 100, 100)
		local faction = nut.faction.indices[GetGlobalInt("CaptureZone"..v.id..".LastCaptureFaction", 0)]
		if faction then
			faction_color = captureZonesConfig.colors[faction.uniqueID] or Color(faction.color.r, faction.color.g, faction.color.b, 50) or Color(100, 100, 100, 100)
		end

		render.SetColorMaterial()
		render.DrawSphere(zonePos, -radius, 25, 25, faction_color)
		if distance > radius then --only draw exterior when we're outside
			render.DrawSphere(zonePos, radius, 25, 25, faction_color)
		end

	end

	render.SetStencilEnable(false)


	/*
	cam.Start3D() --has slight overhead but stops the zone being drawn in the sky
	for k,v in next, self.ActiveZones do
		local radius = v:GetRadius()
		local zonePos = v:GetPosition()
		local plyPos = LocalPlayer():GetPos()
		local distance = plyPos:Distance(zonePos)
		if distance > radius + 1000 then continue end --render distance of 1000 units
		local faction_color = Color(100, 100, 100, 100)
		local faction = nut.faction.indices[GetGlobalInt("CaptureZone"..v.id..".LastCaptureFaction", 0)]
		if faction then
			faction_color = captureZonesConfig.colors[faction.uniqueID] or Color(faction.color.r, faction.color.g, faction.color.b, 50) or Color(100, 100, 100, 100)
		end
		render.SetColorMaterial()
		if distance > radius then --only draw the interior zone if we are in it, and only draw the exterior one if we're outside of it
			render.DrawSphere(zonePos, radius, 25, 25, faction_color)
		else
			render.DrawSphere(zonePos, -radius, 25, 25, faction_color)
		end

		if LocalPlayer():IsAdmin() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then
			render.DrawSphere(zonePos, 16, 25, 25, Color(0,255,0,120))
		end
	end
	cam.End3D()
	*/

end

function PLUGIN:HUDPaint()
	for k,v in next, self.ActiveZones do
		if v.localply_in_zone then
			local faction = nut.faction.indices[GetGlobalInt("CaptureZone"..v.id..".LastCaptureFaction", 0)]
			if !faction then return end

			surface.SetDrawColor(80, 80, 80, 255)
			surface.DrawRect(ScrW() / 2 - (ScrW() / 2) / 2, ScrH() / 20, ScrW() / 2, 24)

			local configColour = captureZonesConfig.colors[faction.uniqueID]
			local faction_color
			if captureZonesConfig.colors[faction.uniqueID] then
				faction_color = Color(configColour.r, configColour.g, configColour.b, 255)
			else
				faction_color = Color(faction.color.r, faction.color.g, faction.color.b, 50) or Color(100, 100, 100, 100)
			end
			surface.SetDrawColor(faction_color)

			local points = GetGlobalInt("CaptureZone"..v.id..".CapturePoints", 0)
			surface.DrawRect((ScrW() / 2 - (ScrW() / 2) / 2) + 1, ScrH() / 20 + 1, (ScrW() / 2) * (points / 100) - 2, 22)

			surface.SetFont("DermaLarge")
			local text_width, text_height = surface.GetTextSize("Zone "..v.id)

			/* Pho-outlined text. Not my favorite, really. */
			/* Would be much better to define our own font. */
			/* I leave that to you, Vex. */

			surface.SetTextColor(0, 0, 0, 255)
			surface.SetTextPos(ScrW() / 2 - (text_width / 2), (ScrH() / 22 - text_height) + 1)
			surface.DrawText("Zone "..v.id)

			surface.SetTextPos(ScrW() / 2 - (text_width / 2), (ScrH() / 22 - text_height) - 1)
			surface.DrawText("Zone "..v.id)

			surface.SetTextPos((ScrW() / 2 - (text_width / 2)) + 1, ScrH() / 22 - text_height)
			surface.DrawText("Zone "..v.id)

			surface.SetTextPos((ScrW() / 2 - (text_width / 2)) - 1, ScrH() / 22 - text_height)
			surface.DrawText("Zone "..v.id)

			surface.SetTextColor(160, 160, 160, 255)
			surface.SetTextPos(ScrW() / 2 - (text_width / 2), ScrH() / 22 - text_height)
			surface.DrawText("Zone "..v.id)
		end
	end
end