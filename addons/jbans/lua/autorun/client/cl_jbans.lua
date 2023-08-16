function jBans.BanMe(reason)
	net.Start(jBans.GetBanMeID())
		net.WriteString(reason)
	net.SendToServer()
end

function jBans.SetHWBanCookie()
	if cookie.GetString("bAccount") == nil then
		cookie.Set("bAccount", LocalPlayer():SteamID64())
	end
end

function jBans.HWBan()
	local str = net.ReadString()
	local steamID = (str and str != "") and str or LocalPlayer():SteamID64()
	cookie.Set("bAccount", steamID)

	net.Start(jBans.GetHWBanID())
		net.WriteString(bAccount or "")
	net.SendToServer()
end
net.Receive(jBans.GetHWBanID(), jBans.HWBan)

function jBans.CheckForHWBan()
	if cookie.GetString("bAccount") != nil then
		jBans.HWBan()
		return true
	end

	return false
end
hook.Add("InitPostEntity", "HWBanCheck", jBans.CheckForHWBan)
