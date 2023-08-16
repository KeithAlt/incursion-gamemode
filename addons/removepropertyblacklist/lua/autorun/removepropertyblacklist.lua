--local oldFilter = properties.List.remove.Filter 

-- Overwrites the base function and adds a single line to check for the blacklist.
properties.List.remove.Filter = function(self, ent, ply)
	if ( !gamemode.Call( "CanProperty", ply, "remover", ent ) ) then return false end
	if ( !IsValid( ent ) ) then return false end
	if ( ent:IsPlayer() ) then return false end
	if ( ent.CannotRemove ) then return false end

	return true
end