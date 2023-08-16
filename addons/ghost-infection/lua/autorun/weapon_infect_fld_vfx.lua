local function PostProcess()
	if CLIENT 
	and IsValid(LocalPlayer():GetActiveWeapon()) then
		local wpn = LocalPlayer():GetActiveWeapon()
		if wpn:GetClass() == "weapon_infect_fld" 
		and	wpn.ToggleVFX then
			if LocalPlayer():GetModel() == wpn.WerewolfModel then
				DrawSobel(0.08)
				DrawColorModify({
					[ "$pp_colour_addr" ] = 0.02,
					[ "$pp_colour_addg" ] = 0.02,
					[ "$pp_colour_addb" ] = 0,
					[ "$pp_colour_brightness" ] = 0.15,
					[ "$pp_colour_contrast" ] = 1,
					[ "$pp_colour_colour" ] = 3,
					[ "$pp_colour_mulr" ] = 0,
					[ "$pp_colour_mulg" ] = 0.02,
					[ "$pp_colour_mulb" ] = 0})
				DrawMaterialOverlay( "models/props_lab/xencrystal_sheet", 0.0055 )
				DrawMotionBlur( 0.1, 0.39, 0.05 )
			else
				DrawMaterialOverlay( "models/props_lab/xencrystal_sheet", 0.00001 )
			end
		end
	end
end
hook.Add( "RenderScreenspaceEffects", "EOTIWerewolfPostProcess", PostProcess )

sound.Add( {
	name = "eoti_idlegrowlloop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "npc/antlion_guard/growl_idle.wav"
} )