nut.stats = nut.stats or {}

function nut.stats.maxHP(player)
	local HP = nut.faction.indices[player:getChar():getFaction()]["baseHP"] or 100

	hook.Call("CalculateMaxHP", player, HP)

	return HP
end;

function nut.stats.speedModifer(player)
	local speed = nut.faction.indices[player:getChar():getFaction()]["speedModifer"] or 1

	hook.Call("CalculateSpeedModifer", player, speed)

	return speed
end;
