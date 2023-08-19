netstream.Hook("dailyRewardsUI", function(data, index)
	if (!IsValid(nut.gui.rewards)) then
		vgui.Create("nutDailyRewards")
	end;
end)
