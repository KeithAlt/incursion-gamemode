util.PrecacheSound("newbounty.ogg")
util.PrecacheSound("newbounty.mp3")

local PLAYER = FindMetaTable("Player")

function PLAYER:CanCreateJob()
	if (hook.Run("CanPlayerCreateJob", self) == false) then
		return false
	end

	return true
end

hook.Add("PhysgunPickup", "DisablePhysgunPosterEnt", function(Player, Ent)
    if Ent:GetClass() == "bountyposter" then
	    return false
	end
end)

hook.Add("InitializedPlugins", "BountyChatRegister", function(Player, Ent)
    --a chat type for the job posting message
	nut.chat.register("bounty", {
		onChatAdd = function(speaker, text)
			chat.AddText(Color(255, 20, 20), "[ ! ]", color_white, " " ..text)
		end,
		noSpaceAfter = true,
		filter = "ic",
	})
end)