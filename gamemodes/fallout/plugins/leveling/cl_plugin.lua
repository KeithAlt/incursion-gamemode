netstream.Hook("levelUp", function(level)
	vgui.Create("nutLevelUp"):open(level)
end)

netstream.Hook("getXP", function(xp, muteSound)
	vgui.Create("nutGetXP"):open(xp, muteSound)
end)