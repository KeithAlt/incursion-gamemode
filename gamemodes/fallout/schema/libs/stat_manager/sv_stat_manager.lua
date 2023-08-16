hook.Add("PlayerLoadedChar", "nutStatsLoadedChar", function(client, character, lastChar)
	client:SetMaxHealth(nut.stats.maxHP(client))
end)
