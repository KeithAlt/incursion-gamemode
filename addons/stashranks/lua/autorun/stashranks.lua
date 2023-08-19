local ranks = {
	["bronze"] = 30,
	["silver"] = 35,
	["gold"] = 40,
	["diamond"] = 45,
	["legendary"] = 50,
	["founder"] = 50,
	["developer"] = 50,
	["superadmin"] = 50,
	["senior administrator"] = 50,
	["trusted administrator"] = 50,
	["admin"] = 50,
	["senior moderator"] = 50,
	["trusted moderator"] = 50,
	["moderator"] = 50,
	["operator"] = 50,
	["retired staff"] = 50,
	["developer"] = 50,
	["faction leader"] = 50,
}

hook.Add("InitializedPlugins", "StashRanks", function()
	timer.Simple(0, function()
		local CHAR = nut.meta.character

		function CHAR:getStashMax()
			local ply = self:getPlayer()

			if IsValid(ply) then
				return ranks[ply:GetUserGroup()] or nut.config.get("maxStash", 30)
			else
				return nut.config.get("maxStash", 30)
			end
		end
	end)
end)
