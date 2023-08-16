-- Performance boosting Commands
RunConsoleCommand("gmod_mcore_test", "1")   -- Enables Multicore
RunConsoleCommand("mat_queue_mode", "2")   -- Optimial Material Processing
RunConsoleCommand("r_drawmodeldecals", "0")  -- Disables decals from being drawn on non-world models (done to prevent a client-side crash issue associated with vehicles & decal stretching)
RunConsoleCommand("r_shadows", "0")	-- Disbales shdadows, constantly buggy on map as of 2.15.2021, auto-disabling due to
RunConsoleCommand("cl_playerspraydisable", "1") -- Disables sprays for players


-- TFA Safeynet Commands : Ensures player uses correct settings
RunConsoleCommand("cl_tfa_hud_crosshair_enable_custom", "0")  -- Disables TFA Weapon Custom Hitmarker
RunConsoleCommand("cl_tfa_hud_hitmarker_scale", "0.5")  -- Changes TFA Weapon Hitmarker Scale
RunConsoleCommand("cl_tfa_hud_hitmarker_color_r", "255")  -- Changes TFA Weapon Hitmarker Coloration
RunConsoleCommand("cl_tfa_hud_hitmarker_color_g", "178")  -- Changes TFA Weapon Hitmarker Coloration
RunConsoleCommand("cl_tfa_hud_hitmarker_color_b", "0")  -- Changes TFA Weapon Hitmarker Coloration
RunConsoleCommand("cl_tfa_hud_hitmarker_color_a", "200")  -- Changes TFA Weapon Hitmarker Coloration
RunConsoleCommand("cl_tfa_fx_gasblur", "0")   -- Disables TFA Weapon Muzzle Gas Blur
RunConsoleCommand("cl_tfa_fx_muzzlesmoke", "0")   -- Disables TFA Weapon Muzzle Smoke
RunConsoleCommand("cl_tfa_fx_ejectionsmoke", "0") -- Disables TFA Weapon Ejection FX
RunConsoleCommand("cl_tfa_fx_impact_enabled", "0") -- Disables TFA Weapon Impact FX

-- Misc Commands
RunConsoleCommand("pac_debug_clmdl", "1") -- Fixes PAC after 2020 Gmod Update Broke it
RunConsoleCommand("cl_qb_drawhud", "0") -- Disables Quantum Break HUD

/**
 -- Old commandlines
RunConsoleCommand("atlaschat_theme", "fallout") -- Changes Atlas Chat theme (REMOVED DUE TO: OUTDATED)
RunConsoleCommand("voice_maxgain", "10")  -- Makes Client hear others at maximum possible volume (REMOVED DUE TO: MARKED AS CHEAT)
RunConsoleCommand("mat_antialias", "2") -- Fixed a 2019 crash issue for clients whom would consistently crash with (REMOVED DUE TO: RISKY)
**/
