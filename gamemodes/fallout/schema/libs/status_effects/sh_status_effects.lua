nut.status = nut.status or {}
nut.status.effects = nut.status.effects or {}

function nut.status.register(id, priority, serverTick, renderEffects, screenEffects, onStart, onEnd)
	nut.status.effects[id] = {
		["priority"] = priority,							-- Render priority, effect with the highest is rendered.
		["serverTick"] = serverTick(),				-- Runs every second (SERVER) for duration.
		["renderEffects"] = renderEffects(),	-- Runs on effects render.
		["screenEffects"] = screenEffects(),	-- Runs on screensapce render.
		["onStart"] = onStart(),							-- Runs when the effect is first triggered.
		["onEnd"] = onEnd(),									-- Runs when the effect is ending.
	}
end;
