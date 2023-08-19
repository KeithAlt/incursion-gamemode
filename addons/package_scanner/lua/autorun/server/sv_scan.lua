MsgC(Color(255,0,0), "[PACKAGE SCANNER] ", Color(255,255,255), "Package scanner initialized\n") -- DEBUG
packageScanner = packageScanner or {}

-- Our network variables
util.AddNetworkString("getCharacterData")
util.AddNetworkString("readCharacterData")

-- Read and print our data
net.Receive("readCharacterData", function(len, ply)
	local str = net.ReadString()
	ply.logReader:ChatPrint(str)
end)

-- Handle package assignment on the backend
function packageScanner.redeemRank(target, admin, package)
	if !admin:IsSuperAdmin() then
		ErrorNoHalt(jlib.SteamIDName(admin) .. " attempted to redeem a package with no SuperAdmin status ; killing exeuction")
		return
	end

	PrometheusNS.ClaimPackage(package, target)

	DiscordEmbed(
		jlib.SteamIDName(admin) .. " has manually redeemed the following package for:" ..
		"\n• Player: " .. jlib.SteamIDName(target) ..
		"\n• Package: " .. package
		, "📦 Manual Package Redemption Log 📦" , Color(255,0,0), "Admin"
	)

	DiscordEmbed(
		jlib.SteamIDName(admin) .. " has manually redeemed the following package for:" ..
		"\n• Player: " .. jlib.SteamIDName(target) ..
		"\n• Package: " .. package
		, "📦 Manual Package Redemption Log 📦" , Color(255,0,0), "BTeamChat"
	)

	jlib.AlertStaff(
		jlib.SteamIDName(admin) .. " has manually redeemed the following package for:" ..
		"\n• Player: " .. jlib.SteamIDName(target) ..
		"\n• Package: " .. package
	)

	admin:notify("Redeeming player's package")
	target:notify("Package redemption processing...")

	jlib.Announce(admin, Color(255,0,0), "[NOTICE] ", Color(255,155,155), "This redemption has also been logged via Discord")
end
