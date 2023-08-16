util.AddNetworkString("FactionRadioMsg")

// Checks if a char should have access to radio systems on spawn
hook.Add("CharacterLoaded", "RadioAccessInit", function(id)
	local char = nut.char.loaded[id]
	local ply  = char:getPlayer()

	for _, item in pairs(char:getInv():getItems()) do
		if item.uniqueID == "radio" and item:getData("power") == true then
			ply:SetNW2Bool("GlobalRadioAccess", true)
			return
		end
	end

	ply:SetNW2Bool("GlobalRadioAccess", false)
end)
