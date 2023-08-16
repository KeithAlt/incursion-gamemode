hook.Add("HUDPaint", "nutStatusEffectsHUDPaint", function()
	if (IsValid(LocalPlayer():getNetVar("statusEffects"))) then
		local effect = false
		local priority = 0

		for i, v in pairs(LocalPlayer():getNetVar("statusEffects")) do
			if (v > priority) then
				effect = i
			end;
		end;

		if (effect) then nut.status.effects[effect]["screenEffects"]() end;
	end;
end)

hook.Add("RenderScreenspaceEffects", "nutStatusEffectsScreensEffects", function()
	if (IsValid(LocalPlayer():getNetVar("statusEffects"))) then
		local effect = false
		local priority = 0

		for i, v in pairs(LocalPlayer():getNetVar("statusEffects")) do
			if (v > priority) then
				effect = i
			end;
		end;

		if (effect) then nut.status.effects[effect]["renderEffects"]() end;
	end;
end)
