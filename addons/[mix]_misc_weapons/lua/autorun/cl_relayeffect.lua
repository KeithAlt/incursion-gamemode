AddCSLuaFile()

local tab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = -.7,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = -0,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

hook.Add("RenderScreenspaceEffects", "PostProcessingExample", function()
	local ply = LocalPlayer()
	if ply:GetNWBool("IsBeingAbudcted") then
		DrawColorModify( tab ) --Draws Color Modify effect
		DrawSobel( 0.1 ) --Draws Sobel effect
		DrawMotionBlur(0.4, 1, 0.01)
		--
		local mat = Material("particle/warp4_warp_NoZ") -- particle/warp4_warp_NoZ
		local mat2 = Material("effects/tp_eyefx/tpeye")
		surface.SetDrawColor(200,200,200, 255)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(0, 0, ScrW() / 1, ScrH() / 1)

		surface.SetDrawColor(255,255,255, 255)
		surface.SetMaterial(mat2)
		surface.DrawTexturedRect(0, 0, ScrW() / 1, ScrH() / 1)

		timer.Simple(1.5, function()
			ply:ScreenFade( SCREENFADE.IN, Color(0,0,0,255), 0.5, 2.6)
		end)
	end
end )