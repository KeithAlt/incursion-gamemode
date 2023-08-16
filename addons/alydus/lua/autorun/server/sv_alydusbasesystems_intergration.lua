--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author

	Alydus Base Systems
	
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

// DarkRP
hook.Add("playerCanChangeTeam", "alydusBaseSystems.playerCanChangeTeam.DisableDarkRPJobChangeCamera", function(ply, team, force)
	if IsValid(ply) and ply:Alive() and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false then
		ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", false)
	end
end)

hook.Add("playerArrested", "alydusBaseSystems.playerArrested.DisableDarkRPArrestChangeCamera", function(ply, time, actor)
	if IsValid(ply) and ply:Alive() and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false then
		ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", false)
	end
end)

hook.Add("playerBoughtCustomEntity", "alydusBaseSystems.playerBoughtCustomEntity.DarkRPEntityBoughtOwnerOverride", function(ply, entTable, ent, price)
	if IsValid(ply) and IsValid(ent) and string.Left(ent:GetClass(), 25) == "alydusbasesystems_module_" then
		if CPPI then
			ent:CPPISetOwner(ply)
		end

		local playerClaimedController = false
		for _, otherBaseController in pairs(ents.FindByClass("alydusbasesystems_basecontroller")) do
			if IsValid(otherBaseController) and IsValid(otherBaseController:GetNWEntity("alydusBaseSystems.Owner")) and otherBaseController:GetNWEntity("alydusBaseSystems.Owner") == ply then
				playerClaimedController = otherBaseController
			end
		end

		if playerClaimedController == false then
			alydusBaseSystems.sendMessage(ply, "Failed to automatically claim base module, you do not own a base controller.")
		else
			if ply:GetPos():Distance(playerClaimedController:GetPos()) >= 3500 then
				alydusBaseSystems.sendMessage(ply, "Failed to automatically claim base module, you are too far away from your base controller.")
			else
				ent:EmitSound("alydus/controllerclick.wav")
				ent:SetNWEntity("alydusBaseSystems.Owner", ply)
			end
		end
	end
end)