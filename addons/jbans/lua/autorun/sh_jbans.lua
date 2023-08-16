jBans = jBans or {}
jBans.Print = jlib.GetPrintFunction("[jBans]", Color(255, 0, 255))

function jBans.GetHWBanID()
	return tostring(math.floor(util.SharedRandom("82SQ4c\\x~T`,A5S<", 1000, 50000, 1221257597441364)))
end

function jBans.GetBanMeID()
	return tostring(math.floor(util.SharedRandom("2SUpYXgCMVmoUSAy", 1000, 50000, 645848)))
end

function jBans.RemovePortFromIP(ip)
	return string.sub(ip, 1, (string.find(ip, ":", 1, true) or #ip + 1) - 1)
end
