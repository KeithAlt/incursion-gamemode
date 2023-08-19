local PLUGIN = PLUGIN
PLUGIN.name = "Flare Gun"
PLUGIN.author = "Chancer"
PLUGIN.desc = "Adds a flare gun that can alert faction members."

PLUGIN.blacklist = {
	[FACTION_WASTELANDER] = true,
	[FACTION_ROBOT] = true,
	[FACTION_CREATURE] = true,
	[FACTION_MONSTER] = true,
	[FACTION_FERAL] = true,
	[FACTION_SENTRY] = true
}

nut.config.add("flareTime", 30, "How long the popup from the flare gun lasts.", nil, {
	data = {min = 1, max = 84600},
	category = "Flare Gun"
})

if(SERVER) then
	function PLUGIN:flareLaunch(client)
		--[[
		local flarePos = client:GetEyeTraceNoCursor().HitPos
		flarePos = flarePos + Vector(0, 0, 10)
		--]]

		local flarePos = client:GetPos() + Vector(0,0,30)

		local faction = client:getChar():getFaction()

		--don't do this if faction is blacklisted
		if(PLUGIN.blacklist[faction]) then return end

		for k, v in pairs(player.GetAll()) do
			local char = v:getChar()

			if(char and char:getFaction() == faction) then --check if same faction
				netstream.Start(v, "nutFlare", flarePos)
			end
		end
	end
else --client
	netstream.Hook("nutFlare", function(position)
		local client = LocalPlayer()

		client.flarePos = position

		--just uses a simple timer to turn it off
		timer.Simple(nut.config.get("flareTime", 30), function()
			if(IsValid(client)) then
				client.flarePos = nil
			end
		end)

		client:EmitSound("HL1/fvox/bell.wav", 75, 65, 0.5)
	end)

	local flareIcon = Material("icons/495.png")
	local client, sx, sy, scrPos, marginx, marginy, x, y, teamColor, distance, factor, size, alpha
	local dimDistance = 8192
	function PLUGIN:HUDPaint()
		client = LocalPlayer()
		local flarePos = client.flarePos

		if(flarePos) then
			sx, sy = surface.ScreenWidth(), surface.ScreenHeight()

			scrPos = flarePos:ToScreen()
			marginx, marginy = sy*.1, sy*.1
			x, y = math.Clamp(scrPos.x, marginx, sx - marginx), math.Clamp(scrPos.y, marginy, sy - marginy)
			distance = client:GetPos():Distance(flarePos)
			factor = 1 - math.Clamp(distance/dimDistance, 0, 1)
			size = math.max(20, 64*factor)
			alpha = 255

			local size2 = size * 1.075
			surface.SetMaterial(flareIcon)
			surface.SetDrawColor(Color(255,165,70,alpha))
			surface.DrawTexturedRect(x - size2/2, y - size2/2 - 4, size2, size2)

			surface.SetMaterial(flareIcon)
			surface.SetDrawColor(Color(255,100,70,alpha))
			surface.DrawTexturedRect(x - size/2, y - size/2, size, size)
		end
	end
end
