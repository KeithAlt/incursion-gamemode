--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author

	Alydus Base Systems
	
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

alydusBaseSystems = {}
alydusBaseSystems.networkStrings = {
	"claimBaseController",
	"repairBaseController",
	"repairModules",
	"joinCameraUplink",
	"controlDoorServos",
	"toggleAlarm",
	"resetAlarm",
	"sendMessage",
	"toggleSystemView",
	"toggleGunTurretProperty",	"openFactionTarget"
}
for _, networkString in pairs(alydusBaseSystems.networkStrings) do
	util.AddNetworkString("alydusBaseSystems." .. networkString)
end
function alydusBaseSystems.boolToInt(input)
	if input == true then
		return 1
	elseif input == false then
		return 0
	end
end

function alydusBaseSystems.sendMessage(ply, message)
	if IsValid(ply) and ply:Alive() and message != "" then
		net.Start("alydusBaseSystems.sendMessage")
		net.WriteString(message)
		net.Send(ply)
	end
end
hook.Add("StartEntityDriving", "alydusBaseSystems.StartEntityDriving.PreventModuleDriving", function(ent, ply)
	if string.Left(ent:GetClass(), 18) == "alydusbasesystems_" then
		return false
	end
end)