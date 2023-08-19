function nut.status.apply(player, effect, duration)
	local steamID = player:SteamID64()
	local char = player:getChar()

	local statusEffects = player:getNetVar("statusEffects") or {}

	if (!statusEffects[effect]) then
		statusEffects[effect] = nut.status.effects[effect]["priority"]

		timer.Create(steamID.."_statusEffect_"..effect, 1, duration, function()
			if (IsValid(player)) then
				if (char != player:getChar()) then
					timer.Remove(steamID.."_statusEffect_"..effect)
				end;

				nut.status.effects[effect]["serverTick"](player)

				if (timer.RepsLeft(steamID.."_statusEffect_"..effect) == 0) then
					nut.status.effects[effect]["onEnd"](player)
				end;
			else
				timer.Remove(steamID.."_statusEffect_"..effect)
			end;
		end)

		nut.status.effects[effect]["onStart"](player)
		timer.Start(steamID.."_statusEffect_"..effect)
	else
		return false
	end;
end;

hook.Add("PlayerLoadedChar", "nutStatusLoadedChar", function(client, character, lastChar)
	client:setNetVar("statusEffects", {})
end)
