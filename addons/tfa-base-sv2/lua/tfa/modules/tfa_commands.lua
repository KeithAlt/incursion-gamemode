local function CreateReplConVar(cvarname, cvarvalue, description)
	return CreateConVar(cvarname, cvarvalue, CLIENT and {FCVAR_REPLICATED} or {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, description)
end -- replicated only on clients, archive/notify on server

--Serverside Convars
if GetConVar("sv_tfa_weapon_strip") == nil then
	CreateReplConVar("sv_tfa_weapon_strip", "0", "Allow the removal of empty weapons? 1 for true, 0 for false")
	--print("Weapon strip/removal con var created")
end
if GetConVar("sv_tfa_spread_legacy") == nil then
	CreateReplConVar("sv_tfa_spread_legacy", "0", "Use legacy spread algorithms?")
	--print("Weapon strip/removal con var created")
end

if GetConVar("sv_tfa_cmenu") == nil then
	CreateReplConVar("sv_tfa_cmenu", "1", "Allow custom context menu?")
	--print("Weapon strip/removal con var created")
end

if GetConVar("sv_tfa_range_modifier") == nil then
	CreateReplConVar("sv_tfa_range_modifier", "0.5", "This controls how much the range affects damage.  0.5 means the maximum loss of damage is 0.5.")
	--print("Dry fire con var created")
end

if GetConVar("sv_tfa_allow_dryfire") == nil then
	CreateReplConVar("sv_tfa_allow_dryfire", "1", "Allow dryfire?")
	--print("Dry fire con var created")
end

if GetConVar("sv_tfa_penetration_limit") == nil then
	CreateReplConVar("sv_tfa_penetration_limit", "0", "Number of objects we can penetrate through.")
	--print("Dry fire con var created")
end

if GetConVar("sv_tfa_damage_multiplier") == nil then
	CreateReplConVar("sv_tfa_damage_multiplier", "1", "Multiplier for TFA base projectile damage.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_damage_mult_min") == nil then
	CreateReplConVar("sv_tfa_damage_mult_min", "0.95", "This is the lower range of a random damage factor.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_damage_mult_max") == nil then
	CreateReplConVar("sv_tfa_damage_mult_max", "1.05", "This is the lower range of a random damage factor.")
	--print("Damage Multiplier con var created")
end

cv_dfc = CreateReplConVar("sv_tfa_default_clip", "-1", "How many clips will a weapon spawn with? Negative reverts to default values.")

function TFAUpdateDefaultClip()
	local dfc = cv_dfc:GetInt()
	local weplist = weapons.GetList()
	if not weplist or #weplist <= 0 then return end

	for k, v in pairs(weplist) do
		local cl = v.ClassName and v.ClassName or v
		local wep = weapons.GetStored(cl)

		if wep and (wep.IsTFAWeapon or string.find(string.lower(wep.Base and wep.Base or ""), "tfa")) then
			if not wep.Primary then
				wep.Primary = {}
			end

			if not wep.Primary.TrueDefaultClip then
				wep.Primary.TrueDefaultClip = wep.Primary.DefaultClip
			end

			if not wep.Primary.TrueDefaultClip then
				wep.Primary.TrueDefaultClip = 0
			end

			if dfc < 0 then
				wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip
			else
				if wep.Primary.ClipSize and wep.Primary.ClipSize > 0 then
					wep.Primary.DefaultClip = wep.Primary.ClipSize * dfc
				else
					wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip * dfc
				end
			end
		end
	end
end

hook.Add("InitPostEntity", "TFADefaultClipPE", TFAUpdateDefaultClip)

if TFAUpdateDefaultClip then
	TFAUpdateDefaultClip()
end

--if GetConVar("sv_tfa_default_clip") == nil then

cvars.AddChangeCallback("sv_tfa_default_clip", function(convar_name, value_old, value_new)
	print("Update Default Clip")
	TFAUpdateDefaultClip()
end, "TFAUpdateDefaultClip")

--print("Default clip size con var created")
--end
if GetConVar("sv_tfa_unique_slots") == nil then
	CreateReplConVar("sv_tfa_unique_slots", "1", "Give TFA-based Weapons unique slots? 1 for true, 0 for false. RESTART AFTER CHANGING.")
	--print("Unique slot con var created")
end

if GetConVar("sv_tfa_spread_multiplier") == nil then
	CreateReplConVar("sv_tfa_spread_multiplier", "1", "Increase for more spread, decrease for less.")
	--print("Arrow force con var created")
end

if GetConVar("sv_tfa_force_multiplier") == nil then
	CreateReplConVar("sv_tfa_force_multiplier", "1", "Arrow force multiplier (not arrow velocity, but how much force they give on impact).")
	--print("Arrow force con var created")
end

if GetConVar("sv_tfa_dynamicaccuracy") == nil then
	CreateReplConVar("sv_tfa_dynamicaccuracy", "1", "Dynamic acuracy?  (e.g.more accurate on crouch, less accurate on jumping.")
	--print("DynAcc con var created")
end

if GetConVar("sv_tfa_ammo_detonation") == nil then
	CreateReplConVar("sv_tfa_ammo_detonation", "1", "Ammo Detonation?  (e.g. shoot ammo until it explodes) ")
	--print("DynAcc con var created")
end

if GetConVar("sv_tfa_ammo_detonation_mode") == nil then
	CreateConVar("sv_tfa_ammo_detonation_mode", "2", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Ammo Detonation Mode?  (0=Bullets,1=Blast,2=Mix) ")
	--print("DynAcc con var created")
end

if GetConVar("sv_tfa_ammo_detonation_chain") == nil then
	CreateConVar("sv_tfa_ammo_detonation_chain", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Ammo Detonation Chain?  (0=Ammo boxes don't detonate other ammo boxes, 1 you can chain them together) ")
	--print("DynAcc con var created")
end

if GetConVar("sv_tfa_scope_gun_speed_scale") == nil then
	CreateReplConVar("sv_tfa_scope_gun_speed_scale", "0", "Scale player sensitivity based on player move speed?")
end

if GetConVar("sv_tfa_bullet_penetration") == nil then
	CreateReplConVar("sv_tfa_bullet_penetration", "0", "Allow bullet penetration?")
end

if GetConVar("sv_tfa_holdtype_dynamic") == nil then
	CreateReplConVar("sv_tfa_holdtype_dynamic", "1", "Allow dynamic holdtype?")
end

if GetConVar("sv_tfa_arrow_lifetime") == nil then
	CreateReplConVar("sv_tfa_arrow_lifetime", "30", "Arrow lifetime.")
end

if GetConVar("sv_tfa_arrow_lifetime") == nil then
	CreateReplConVar("sv_tfa_arrow_lifetime", "30", "Arrow lifetime.")
end

if GetConVar("sv_tfa_fx_ejectionsmoke_override") == nil then
	CreateReplConVar("sv_tfa_fx_ejectionsmoke_override", "0", "-1 to let clients pick.  0 to force off.  1 to force on.")
end

if GetConVar("sv_tfa_fx_muzzlesmoke_override") == nil then
	CreateReplConVar("sv_tfa_fx_muzzlesmoke_override", "0", "-1 to let clients pick.  0 to force off.  1 to force on.")
end

if GetConVar("sv_tfa_fx_gas_override") == nil then
	CreateReplConVar("sv_tfa_fx_gas_override", "0", "-1 to let clients pick.  0 to force off.  1 to force on.")
end

if GetConVar("sv_tfa_fx_impact_override") == nil then
	CreateReplConVar("sv_tfa_fx_impact_override", "0", "-1 to let clients pick.  0 to force off.  1 to force on.")
end

if GetConVar("sv_tfa_worldmodel_culldistance") == nil then
	CreateReplConVar("sv_tfa_worldmodel_culldistance", "640", "-1 to leave unculled.  Anything else is feet*16.")
end

if GetConVar("sv_tfa_reloads_legacy") == nil then
	CreateReplConVar("sv_tfa_reloads_legacy", "0", "-1 to leave unculled.  Anything else is feet*16.")
end

if GetConVar("sv_tfa_fx_penetration_decal") == nil then
	CreateReplConVar("sv_tfa_fx_penetration_decal", "0", "Enable decals on the other side of a penetrated object?")
end

if GetConVar("sv_tfa_ironsights_enabled") == nil then
	CreateReplConVar("sv_tfa_ironsights_enabled", "1", "Enable ironsights? Disabling this still allows scopes.")
end

if GetConVar("sv_tfa_sprint_enabled") == nil then
	CreateConVar("sv_tfa_sprint_enabled", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable sprinting? Disabling this allows shooting while IN_SPEED.")
end

if GetConVar("sv_tfa_reloads_enabled") == nil then
	CreateReplConVar("sv_tfa_reloads_enabled", "1", "Enable reloading? Disabling this allows shooting from ammo pool.")
end

if GetConVar("sv_tfa_compat_movement") == nil then
	CreateReplConVar("sv_tfa_compat_movement", "0", "Enable compatibility mode for movement?")
end

if GetConVar("sv_tfa_net_idles") == nil then
	CreateReplConVar("sv_tfa_net_idles", "0", "Enable idle animations at the cost of significant network traffic?")
end

if GetConVar("sv_tfa_net_shells") == nil then
	CreateReplConVar("sv_tfa_net_shells", "0", "Enable MP shell ejection at the cost of increased network traffic?")
end

if GetConVar("sv_tfa_net_muzzles") == nil then
	CreateReplConVar("sv_tfa_net_muzzles", "0", "Enable MP muzzle flashes at the cost of increased network traffic?")
end

--Clientside Convars
if CLIENT then
	if GetConVar("cl_tfa_forcearms") == nil then
		CreateClientConVar("cl_tfa_forcearms", 1, true, true)
	end

	if GetConVar("cl_tfa_inspection_old") == nil then
		CreateClientConVar("cl_tfa_inspection_old", 0, true, true)
	end

	if GetConVar("cl_tfa_inspection_ckey") == nil then
		CreateClientConVar("cl_tfa_inspection_ckey", 0, true, true)
	end

	if GetConVar("cl_tfa_viewbob_intensity") == nil then
		CreateClientConVar("cl_tfa_viewbob_intensity", 1, true, false)
	end

	if GetConVar("cl_tfa_gunbob_intensity") == nil then
		CreateClientConVar("cl_tfa_gunbob_intensity", 1, true, false)
		--print("Viewbob intensity con var created")
	end

	if GetConVar("cl_tfa_3dscope") == nil then
		CreateClientConVar("cl_tfa_3dscope", 1, true, true)
	end

	if GetConVar("cl_tfa_3dscope_overlay") == nil then
		CreateClientConVar("cl_tfa_3dscope_overlay", 0, true, true)
	end

	if GetConVar("cl_tfa_scope_sensitivity_autoscale") == nil then
		CreateClientConVar("cl_tfa_scope_sensitivity_autoscale", 100, true, true)
		--print("Scope sensitivity autoscale con var created")
	end

	if GetConVar("cl_tfa_scope_sensitivity") == nil then
		CreateClientConVar("cl_tfa_scope_sensitivity", 100, true, true)
		--print("Scope sensitivity con var created")
	end

	if GetConVar("cl_tfa_ironsights_toggle") == nil then
		CreateClientConVar("cl_tfa_ironsights_toggle", 1, true, true)
		--print("Ironsights toggle con var created")
	end

	if GetConVar("cl_tfa_ironsights_resight") == nil then
		CreateClientConVar("cl_tfa_ironsights_resight", 1, true, true)
		--print("Ironsights resight con var created")
	end

	--Crosshair Params
	if GetConVar("cl_tfa_hud_crosshair_length") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_length", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_length_use_pixels") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_length_use_pixels", 0, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_width") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_width", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_enable_custom") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_enable_custom", 0, true, false)
		--print("Custom crosshair con var created")
	end

	if GetConVar("cl_tfa_hud_crosshair_gap_scale") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_gap_scale", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_dot") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_dot", 0, true, false)
	end

	--Crosshair Color
	if GetConVar("cl_tfa_hud_crosshair_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_r", 225, true, false)
		--print("Crosshair tweaking con vars created")
	end

	if GetConVar("cl_tfa_hud_crosshair_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_g", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_b", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_a", 200, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_team") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_team", 0, true, false)
	end

	--Crosshair Outline
	if GetConVar("cl_tfa_hud_crosshair_outline_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_r", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_g", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_b", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_a", 200, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_width") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_width", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_enabled", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_enabled", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_fadetime") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_fadetime", 0.3, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_solidtime") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_solidtime", 0.1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_scale") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_scale", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_r", 225, true, false)
		--print("hitmarker tweaking con vars created")
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_g", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_b", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_a", 200, true, false)
	end

	--Other stuff
	if GetConVar("cl_tfa_hud_ammodata_fadein") == nil then
		CreateClientConVar("cl_tfa_hud_ammodata_fadein", 0.2, true, false)
	end

	if GetConVar("cl_tfa_hud_hangtime") == nil then
		CreateClientConVar("cl_tfa_hud_hangtime", 1, true, true)
	end

	if GetConVar("cl_tfa_hud_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_enabled", 1, true, false)
	end

	if GetConVar("cl_tfa_fx_gasblur") == nil then
		CreateClientConVar("cl_tfa_fx_gasblur", 0, true, true)
	end

	if GetConVar("cl_tfa_fx_muzzlesmoke") == nil then
		CreateClientConVar("cl_tfa_fx_muzzlesmoke", 0, true, true)
	end

	if GetConVar("cl_tfa_fx_ejectionsmoke") == nil then
		CreateClientConVar("cl_tfa_fx_ejectionsmoke", 0, true, true)
	end

	if GetConVar("cl_tfa_fx_impact_enabled") == nil then
		CreateClientConVar("cl_tfa_fx_impact_enabled", 0, true, true)
	end

	--viewbob
	if GetConVar("cl_tfa_viewbob_drawing") == nil then
		CreateClientConVar("cl_tfa_viewbob_drawing", 0, true, false)
	end

	if GetConVar("cl_tfa_viewbob_reloading") == nil then
		CreateClientConVar("cl_tfa_viewbob_reloading", 1, true, false)
	end

	--Viewmodel Mods
	if GetConVar("cl_tfa_viewmodel_offset_x") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_x", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_y") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_y", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_z") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_z", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_fov") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_fov", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_multiplier_fov") == nil then
		CreateClientConVar("cl_tfa_viewmodel_multiplier_fov", 1, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_flip") == nil then
		CreateClientConVar("cl_tfa_viewmodel_flip", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_centered") == nil then
		CreateClientConVar("cl_tfa_viewmodel_centered", 0, true, false)
	end

	if GetConVar("cl_tfa_debugcrosshair") == nil then
		CreateClientConVar("cl_tfa_debugcrosshair", 0, true, false)
	end
end
