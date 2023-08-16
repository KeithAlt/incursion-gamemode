hook.Add("PostGamemodeLoaded", "DisableBaseThink", function()
	print("Disabling base_gmodentity think method")
	scripted_ents.GetStored("base_gmodentity").t.Think = nil
end)
