Areas.OutOfBounds = Areas.OutOfBounds or {}
Areas.OutOfBounds.Print = jlib.GetPrintFunction("[AreasOOB]", Color(128, 0, 128, 255))
Areas.OutOfBounds.Time = 4
Areas.OutOfBounds.Msg = "LEAVE RESTRICTED AREA"
Areas.AddVar("OutOfBounds", "Bool", true, false)

function Areas.GetTimerID(ply)
	return "OOBZoneTimer" .. ply:SteamID64()
end

if CLIENT then
	function Areas.OutOfBounds.Start()
		local ctime = CurTime()
		Areas.OutOfBounds.InZone = ctime
		Areas.OutOfBounds.NextBeep = ctime
		Areas.OutOfBounds.Print("Entered out of bounds area")
	end

	function Areas.OutOfBounds.Stop()
		Areas.OutOfBounds.InZone = nil
		Areas.OutOfBounds.NextBeep = nil
		Areas.OutOfBounds.Print("Left out of bounds area")
	end

	hook.Add("PlayerEnteredArea", "OutOfBounds", function(ply, area)
		if ply == LocalPlayer() and area:GetOutOfBounds() then
			Areas.OutOfBounds.Start()
		end
	end)

	hook.Add("PlayerLeftArea", "OutOfBounds", function(ply, area)
		if ply == LocalPlayer() and area:GetOutOfBounds() then
			Areas.OutOfBounds.Stop()
		end
	end)

	hook.Add("HUDPaint", "AreasOutOfBounds", function()
		if Areas.OutOfBounds.InZone then
			local ctime = CurTime()

			if Areas.OutOfBounds.NextBeep <= ctime then
				surface.PlaySound("buttons/blip1.wav")
				Areas.OutOfBounds.NextBeep = ctime + 1
			end

			local timeLeft = math.abs(math.ceil(math.Clamp(0, Areas.OutOfBounds.Time, (Areas.OutOfBounds.InZone + Areas.OutOfBounds.Time) - ctime)))

			draw.SimpleText(Areas.OutOfBounds.Msg, "Trebuchet24", ScrW() / 2, (ScrH() / 2) - 75, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(timeLeft, "Trebuchet24", ScrW() / 2, (ScrH() / 2) - 50, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)

	Areas.OutOfBounds.Effect = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 0.6,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}

	hook.Add("RenderScreenspaceEffects", "AreasOutOfBounds", function()
		if Areas.OutOfBounds.InZone then
			DrawMaterialOverlay("models/shadertest/shader4", 0.05)
			DrawColorModify(Areas.OutOfBounds.Effect)
		end
	end)

	net.Receive("AreasOOBStart", Areas.OutOfBounds.Start)
	net.Receive("AreasOOBStop", Areas.OutOfBounds.Stop)
else
	util.AddNetworkString("AreasOOBStart")
	util.AddNetworkString("AreasOOBStop")

	function Areas.OutOfBounds.Start(ply)
		ply.InOOBZone = true

		local timerID = Areas.GetTimerID(ply)
		timer.Create(timerID, Areas.OutOfBounds.Time, 1, function()
			if IsValid(ply) then
				ply:Spawn()
			end
		end)
	end

	function Areas.OutOfBounds.Stop(ply)
		ply.InOOBZone = nil

		local timerID = Areas.GetTimerID(ply)
		if timer.Exists(timerID) then
			timer.Remove(timerID)
		end
	end

	hook.Add("PlayerEnteredArea", "OutOfBounds", function(ply, area)
		if area:GetOutOfBounds() then
			Areas.OutOfBounds.Start(ply)
		end
	end)

	hook.Add("PlayerLeftArea", "OutOfBounds", function(ply, area)
		if area:GetOutOfBounds() then
			Areas.OutOfBounds.Stop(ply)
		end
	end)
end

hook.Add("InitPostEntity", "AreasOutOfBounds", function()
	nut.command.add("setoob", {
		superAdminOnly = true,
		onRun = function(ply)
			local area = ply:GetArea()
			if IsValid(area) then
				area:SetOutOfBounds(true)

				local players = area:GetPlayersSequential()
				for i, p in ipairs(players) do
					Areas.OutOfBounds.Start(p)
				end

				net.Start("AreasOOBStart")
				net.Send(players)
			end
		end
	})

	nut.command.add("unsetoob", {
		superAdminOnly = true,
		onRun = function(ply)
			local area = ply:GetArea()
			if IsValid(area) then
				area:SetOutOfBounds(false)

				local players = area:GetPlayersSequential()
				for i, p in ipairs(players) do
					Areas.OutOfBounds.Stop(p)
				end

				net.Start("AreasOOBStop")
				net.Send(players)
			end
		end
	})
end)
