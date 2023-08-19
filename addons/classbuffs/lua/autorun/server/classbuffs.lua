hook.Add("PostPlayerLoadout", "ClassBuffsLoadout", function(ply)
	timer.Simple(0, function() --timer only necessary for first spawn, getClass() returns nil for some reason.
		local char = ply:getChar()
	
		if(char.StatBuffs) then return end --this is a workaround for PlayerLoadout running twice on character load
	
		local class = (char and char:getClass()) or false

		if !char or !class then return end

		local classBuffs = nut.class.list[class].specialBuffs

		if classBuffs then
			char.StatBuffs = {}
		
			jlib.Announce(ply, Color(100,255,100), "[TRAINING] ", Color(175,255,175), "Your faction training yields you: ")

			for stat, amt in pairs(classBuffs) do
				char.StatBuffs[stat] = ply:BuffStat(stat, amt, -1)
				jlib.Announce(ply, Color(255,255,255), "\n 	|_ ", Color(255,255,0), "[" .. stat .. "] ", Color(100,255,100), "+ " .. amt)
			end
		end
	end)
end)

--allows buffs to be reapplied on respawn
hook.Add("PlayerSpawn", "ClassBuffsLoadedChar", function(ply, char)
	local char = ply:getChar()
	if(char) then
		char.StatBuffs = nil
	end
end)