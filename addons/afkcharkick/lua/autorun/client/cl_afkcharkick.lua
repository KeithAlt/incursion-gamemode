surface.CreateFont("AFKKick25", {font = "Roboto", size = 25, weight = 400})
surface.CreateFont("AFKKick120", {font = "Roboto", size = 120, weight = 400})

function AFKKick.DrawWarning()
	if AFKKick.Alpha < 230 then
		AFKKick.Alpha = AFKKick.Alpha + (FrameTime() * 200)
	end

	draw.RoundedBox(0, 0, (ScrH() / 2) - ScreenScale(60), ScrW(), ScreenScale(120), Color(0, 0, 0, AFKKick.Alpha))
	draw.DrawText(AFKKick.Config.WarningHead, "AFKKick120", ScrW() * 0.5, (ScrH() * 0.5) - ScreenScale(50), Color(255, 0, 0, AFKKick.Alpha), TEXT_ALIGN_CENTER)
	draw.DrawText(AFKKick.Config.WarningSub .. "\nYou will be kicked in " .. math.floor(math.max(AFKKick.Config.KickTime - (CurTime() - AFKKick.WarningStart), 0)) .. "s", "AFKKick25", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255, 255, AFKKick.Alpha), TEXT_ALIGN_CENTER)
end

function AFKKick.EnableWarning()
	AFKKick.Alpha = 0
	AFKKick.WarningStart = CurTime()
	surface.PlaySound("HL1/fvox/bell.wav")
	hook.Add("HUDPaint", "AFKWarning", AFKKick.DrawWarning)
end

function AFKKick.DisableWarning()
	AFKKick.Alpha = nil
	AFKKick.AlphaRising = nil
	hook.Remove("HUDPaint", "AFKWarning")
end

net.Receive("AFKWarning", function()
	local enable = net.ReadBool()

	if enable then
		AFKKick.EnableWarning()
	else
		AFKKick.DisableWarning()
	end
end)

net.Receive("AFKAnnounce", function()
	local name = net.ReadString()

	if ply == LocalPlayer() then
		local menu = vgui.GetKeyboardFocus()
		if IsValid(menu) and menu.Close then
			menu:Close()
		end
	end

	chat.AddText(Color(255, 0, 0, 255), "Player ", Color(255, 255, 255, 255), name, Color(255, 0, 0, 255), " has been character kicked for being AFK.")
end)
