CLASS.name = "Talon - Hunter"
CLASS.faction = FACTION_TALON
CLASS.isDefault = false
CLASS.IsBountyHunter = true
CLASS.Color = Color(255, 203, 73)

function CLASS:onSpawn(ply)
	if SERVER then
		ply:ChatPrint("➤ You have awakened as a Man Hunter")
		ply:ChatPrint("• No FailRP Language is tolerated with this class")
		ply:ChatPrint("• You must wear your Faction Armor when Hunting")
		ply:ChatPrint("• Any abuse of this class will result in a ban or removal")
	end
end

CLASS_TALON_HUNTER = CLASS.index
